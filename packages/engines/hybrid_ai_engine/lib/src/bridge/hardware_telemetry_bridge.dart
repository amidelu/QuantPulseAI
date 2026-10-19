import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum ThermalCondition { nominal, fair, serious, critical }

enum ComputeTarget { edgeIsolate, cloudApi }

final class const HardwareHealthSnapshot({
  required final ThermalCondition thermalCondition,
  required final int availableRamMb,
  required final bool isLowPowerMode,
}) with Equatable {
  /// Determines whether the device can safely execute local Edge-AI inference
  /// without dropping 120Hz chart frames or overheating.
  ComputeTarget get recommendedTarget {
    if (thermalCondition == .serious ||
        thermalCondition == .critical ||
        isLowPowerMode ||
        availableRamMb < 1536) {
      return .cloudApi;
    }
    return .edgeIsolate;
  }

  @override
  List<Object?> get props => [thermalCondition, availableRamMb, isLowPowerMode];
}

/// Communicates with the Host OS via Pigeon channel (with graceful desktop/simulator fallback)
/// and manages encrypted LLM API keys via flutter_secure_storage ^11.2.0.
final class HardwareTelemetryBridge {
  new({
    FlutterSecureStorage? secureStorage,
    String? groqApiKey,
  }) : _secureStorage = secureStorage ??
      const FlutterSecureStorage(
        // flutter_secure_storage v11.2.0 uses storageNamespace instead of sharedPreferencesName
        aOptions: AndroidOptions(storageNamespace: 'quant_pulse_vault'),
      ),
        _groqApiKey = groqApiKey ?? _defaultGroqApiKey;

  /// Paste your Groq API key directly here (or pass via --dart-define=GROQ_API_KEY=gsk_...)
  static const String _defaultGroqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: 'gsk_YOUR_GROQ_API_KEY_HERE',
  );

  static const MethodChannel _channel = MethodChannel(
    'dev.flutter.pigeon.quant_pulse_ai.DeviceTelemetryHostApi.getDeviceHealth',
  );

  final FlutterSecureStorage _secureStorage;
  String _groqApiKey;

  /// Defaults to .serious so Groq Cloud LPU is active right out of the box!
  /// Allows toggling thermal throttling in the UI to demonstrate dynamic AI routing in interviews.
  ThermalCondition simulatedThermalState = .serious;

  /// Direct synchronous getter for the configured Groq API key.
  String get groqApiKey => _groqApiKey;

  /// Returns true when a real Groq API key has been pasted into `_defaultGroqApiKey`.
  bool get hasConfiguredKey =>
      _groqApiKey.trim().isNotEmpty && !_groqApiKey.startsWith('gsk_YOUR_');

  /// Sets the simulated thermal state for testing/demo purposes.
  // ignore: use_setters_to_change_properties
  void setSimulatedThermalState(ThermalCondition condition) {
    simulatedThermalState = condition;
  }

  Future<HardwareHealthSnapshot> queryDeviceHealth() async {
    try {
      final response = await _channel.invokeMapMethod<String, Object?>(
        'getDeviceHealth',
      );
      if (response != null) {
        final thermalIndex = response['thermalState'] as int? ?? 0;
        final ramMb = response['availableMemoryMb'] as int? ?? 4096;
        final lowPower = response['isLowPowerMode'] as bool? ?? false;
        return HardwareHealthSnapshot(
          thermalCondition: ThermalCondition.values[
          thermalIndex.clamp(0, ThermalCondition.values.length - 1)],
          availableRamMb: ramMb,
          isLowPowerMode: lowPower,
        );
      }
    } on MissingPluginException {
      // Fallback when running on desktop/simulator without native handler attached
    } on PlatformException {
      // Graceful fallback
    }

    return HardwareHealthSnapshot(
      thermalCondition: simulatedThermalState,
      availableRamMb: simulatedThermalState == .serious ? 1024 : 6144,
      isLowPowerMode: simulatedThermalState == .critical,
    );
  }

  Future<void> saveCloudApiKey(String apiKey) async {
    _groqApiKey = apiKey.trim();
    try {
      await _secureStorage.write(key: 'cloud_llm_api_key', value: _groqApiKey);
    } on PlatformException {
      // Unsigned macOS debug builds without Keychain entitlement fall back to _groqApiKey in memory
    }
  }

  Future<String?> readCloudApiKey() async {
    if (hasConfiguredKey) return _groqApiKey;
    try {
      final stored = await _secureStorage.read(key: 'cloud_llm_api_key');
      if (stored != null && stored.trim().isNotEmpty) {
        return stored.trim();
      }
    } on PlatformException {
      // Graceful fallback on unsigned desktop builds
    }
    return _groqApiKey;
  }
}
