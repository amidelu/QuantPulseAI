import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

enum LocalModelStatus { notDownloaded, downloading, ready, error }

final class const LocalModelStateSnapshot({
  final LocalModelStatus status = .notDownloaded,
  final double progress = 0,
  final String? modelFilePath,
  final int fileSizeMb = 0,
  final String? errorMessage,
}) with Equatable {
  @override
  List<Object?> get props => [
    status,
    progress,
    modelFilePath,
    fileSizeMb,
    errorMessage,
  ];
}

/// Manages downloading, caching, and verifying quantized GGUF Edge-AI models
/// inside the platform's Application Support directory.
final class LocalModelManager {
  new({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  CancelToken? _activeCancelToken;

  /// Lightweight quantized GGUF model hosted on Hugging Face for fast mobile Edge testing.
  /// (Using Qwen2.5-0.5B-Instruct Q2_K / compact GGUF weight file so it downloads quickly on mobile/emulator)
  static const String modelFileName = 'qwen2.5-0.5b-instruct-q2_k.gguf';
  static const String huggingFaceDownloadUrl =
      'https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q2_k.gguf';

  Future<File> _resolveModelFile() async {
    final supportDir = await getApplicationSupportDirectory();
    final modelsDir = Directory('${supportDir.path}/edge_models');
    if (!modelsDir.existsSync()) {
      await modelsDir.create(recursive: true);
    }
    return File('${modelsDir.path}/$modelFileName');
  }

  /// Checks if the quantized `.gguf` model is already present and valid on disk.
  Future<LocalModelStateSnapshot> checkModelStatus() async {
    try {
      final file = await _resolveModelFile();
      if (!file.existsSync()) {
        return const LocalModelStateSnapshot();
      }
      final lengthBytes = await file.length();
      // Ensure file isn't an empty or corrupted partial download (> 10 MB)
      if (lengthBytes < 10 * 1024 * 1024) {
        return const LocalModelStateSnapshot();
      }
      final isValidGguf = await _verifyGgufMagicBytesInIsolate(file.path);
      if (!isValidGguf) {
        return const LocalModelStateSnapshot(
          status: .error,
          errorMessage: 'Corrupted GGUF header on disk.',
        );
      }
      return LocalModelStateSnapshot(
        status: .ready,
        progress: 1,
        modelFilePath: file.path,
        fileSizeMb: (lengthBytes / (1024 * 1024)).round(),
      );
    } on Object catch (e) {
      return LocalModelStateSnapshot(
        status: .error,
        errorMessage: 'Storage check failed: $e',
      );
    }
  }

  /// Downloads the GGUF model from Hugging Face with real-time progress callbacks.
  Future<LocalModelStateSnapshot> downloadModel({
    required void Function(double progress, int receivedMb, int totalMb) onProgress,
  }) async {
    _activeCancelToken?.cancel();
    final cancelToken = CancelToken();
    _activeCancelToken = cancelToken;

    try {
      final targetFile = await _resolveModelFile();
      final tempFilePath = '${targetFile.path}.part';

      await _dio.download(
        huggingFaceDownloadUrl,
        tempFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          final ratio = (received / total).clamp(0, 1).toDouble();
          final recMb = (received / (1024 * 1024)).round();
          final totMb = (total / (1024 * 1024)).round();
          onProgress(ratio, recMb, totMb);
        },
      );

      final tempFile = File(tempFilePath);
      if (tempFile.existsSync()) {
        await tempFile.rename(targetFile.path);
      }

      return await checkModelStatus();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return const LocalModelStateSnapshot();
      }
      return LocalModelStateSnapshot(
        status: .error,
        errorMessage: 'Download failed: ${e.message}',
      );
    } on Object catch (e) {
      return LocalModelStateSnapshot(
        status: .error,
        errorMessage: 'Download error: $e',
      );
    }
  }

  void cancelDownload() {
    _activeCancelToken?.cancel('User cancelled model download');
    _activeCancelToken = null;
  }

  Future<LocalModelStateSnapshot> deleteModel() async {
    cancelDownload();
    final file = await _resolveModelFile();
    if (file.existsSync()) {
      await file.delete();
    }
    return const LocalModelStateSnapshot();
  }

  /// Reads the first 4 bytes inside a background Isolate to verify the ASCII 'GGUF' magic header.
  static Future<bool> _verifyGgufMagicBytesInIsolate(String path) {
    return Isolate.run(() {
      final raf = File(path).openSync();
      try {
        final header = raf.readSync(4);
        if (header.length < 4) return false;
        // 'G' (0x47), 'G' (0x47), 'U' (0x55), 'F' (0x46)
        return header[0] == 0x47 &&
            header[1] == 0x47 &&
            header[2] == 0x55 &&
            header[3] == 0x46;
      } finally {
        raf.closeSync();
      }
    });
  }
}
