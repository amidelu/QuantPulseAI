import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:core_network/core_network.dart';
import 'package:market_stream_engine/src/buffer/candle_ring_buffer.dart';
import 'package:market_stream_engine/src/models/market_models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Commands sent from Main Isolate -> Background Worker Isolate.
sealed class const IsolateCommand();

final class const SubscribeSymbolCommand(final String symbol) extends IsolateCommand;

final class const DisposeWorkerCommand() extends IsolateCommand;

/// High-frequency Market Stream Engine running inside a dedicated Worker Isolate.
final class MarketStreamEngine {
  Isolate? _workerIsolate;
  SendPort? _workerSendPort;
  ReceivePort? _mainReceivePort;
  StreamController<Result<MarketFrameSnapshot>>? _snapshotController;

  /// Starts the worker isolate and returns a conflated 60Hz stream of [MarketFrameSnapshot].
  Future<Stream<Result<MarketFrameSnapshot>>> connect({required String symbol}) async {
    await dispose();

    final receivePort = ReceivePort();
    final controller = StreamController<Result<MarketFrameSnapshot>>.broadcast();
    _mainReceivePort = receivePort;
    _snapshotController = controller;

    _workerIsolate = await Isolate.spawn<_WorkerBootstrapConfig>(
      _workerEntryPoint,
      _WorkerBootstrapConfig(
        mainSendPort: receivePort.sendPort,
        initialSymbol: symbol.toLowerCase(),
      ),
      debugName: 'QuantPulse_MarketStreamIsolate',
    );

    receivePort.listen((message) {
      if (message is SendPort) {
        _workerSendPort = message;
      } else if (message is MarketFrameSnapshot && !controller.isClosed) {
        controller.add(Success(message));
      } else if (message is String && !controller.isClosed) {
        controller.add(Failure(IsolateExecutionFailure(message: message)));
      }
    });

    return controller.stream;
  }

  /// Switches the active ticker symbol without respawning the Isolate.
  void switchSymbol(String symbol) {
    _workerSendPort?.send(SubscribeSymbolCommand(symbol.toLowerCase()));
  }

  Future<void> dispose() async {
    _workerSendPort?.send(const DisposeWorkerCommand());
    _mainReceivePort?.close();
    await _snapshotController?.close();
    _workerIsolate?.kill(priority: Isolate.immediate);
    _workerIsolate = null;
  }
}

final class const _WorkerBootstrapConfig({
  required final SendPort mainSendPort,
  required final String initialSymbol,
});

/// Entry point executed purely inside the background Isolate.
Future<void> _workerEntryPoint(_WorkerBootstrapConfig config) async {
  final workerReceivePort = ReceivePort();
  config.mainSendPort.send(workerReceivePort.sendPort);

  final ringBuffer = CandleRingBuffer(120);
  var currentSymbol = config.initialSymbol;
  var lastPrice = 0.0;
  var open24hPrice = 0.0;
  var bids = <OrderBookLevel>[];
  var asks = <OrderBookLevel>[];
  var ticksThisSecond = 0;
  var currentTps = 0;
  var isDirty = false;

  WebSocketChannel? channel;
  StreamSubscription<Object?>? wsSubscription;

  void seedInitialHistory(double basePrice) {
    ringBuffer.clear();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final rng = math.Random(42);
    var price = basePrice;
    for (var i = 60; i > 0; i--) {
      final delta = (rng.nextDouble() - 0.495) * (basePrice * 0.0018);
      final open = price;
      final close = price + delta;
      final high = math.max(open, close) + rng.nextDouble() * (basePrice * 0.0009);
      final low = math.min(open, close) - rng.nextDouble() * (basePrice * 0.0009);
      ringBuffer.upsert(
        Candle(
          openTimeMs: ((nowMs - i * 5000) ~/ 5000) * 5000,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: 1.5 + rng.nextDouble() * 12,
        ),
      );
      price = close;
    }
    lastPrice = price;
    open24hPrice = basePrice;
    isDirty = true;
  }

  Future<void> connectStream(String symbol) async {
    await wsSubscription?.cancel();
    await channel?.sink.close();

    currentSymbol = symbol;
    final seedPrice = symbol.startsWith('eth') ? 2650.0 : 68400.0;
    seedInitialHistory(seedPrice);

    final uri = Uri.parse(
      'wss://stream.binance.com:9443/stream?streams=$symbol@aggTrade/$symbol@depth10@100ms',
    );

    try {
      final ws = WebSocketChannel.connect(uri);
      channel = ws;
      // web_socket_channel ^3.0.3 requires awaiting ready to catch connection errors
      await ws.ready;

      wsSubscription = ws.stream.listen(
        (rawFrame) {
          if (rawFrame is! String) return;
          ticksThisSecond++;

          final decoded = jsonDecode(rawFrame) as Map<String, Object?>;
          final streamName = decoded['stream'] as String?;
          final data = decoded['data'] as Map<String, Object?>?;
          if (streamName == null || data == null) return;

          if (streamName.endsWith('@aggTrade')) {
            final price = double.tryParse(data['p'] as String? ?? '');
            final qty = double.tryParse(data['q'] as String? ?? '');
            final tradeTimeMs = data['T'] as int?;
            if (price == null || qty == null || tradeTimeMs == null) return;

            lastPrice = price;
            // Group into 5-second high-frequency candles for responsive visual movement
            final bucketTimeMs = (tradeTimeMs ~/ 5000) * 5000;
            final candles = ringBuffer.toList();
            if (candles.isNotEmpty && candles.last.openTimeMs == bucketTimeMs) {
              ringBuffer.upsert(candles.last.copyWithTrade(price: price, quantity: qty));
            } else {
              ringBuffer.upsert(
                Candle(
                  openTimeMs: bucketTimeMs,
                  open: price,
                  high: price,
                  low: price,
                  close: price,
                  volume: qty,
                ),
              );
            }
            isDirty = true;
          } else if (streamName.contains('@depth10')) {
            final rawBids = data['bids'] as List<Object?>? ?? const [];
            final rawAsks = data['asks'] as List<Object?>? ?? const [];
            bids = rawBids.take(8).map((e) {
              final pair = e! as List<Object?>;
              return OrderBookLevel(
                price: double.parse(pair[0]! as String),
                quantity: double.parse(pair[1]! as String),
              );
            }).toList();
            asks = rawAsks.take(8).map((e) {
              final pair = e! as List<Object?>;
              return OrderBookLevel(
                price: double.parse(pair[0]! as String),
                quantity: double.parse(pair[1]! as String),
              );
            }).toList();
            isDirty = true;
          }
        },
        onError: (Object error) {
          config.mainSendPort.send('WebSocket stream error: $error');
        },
      );
    } on Object catch (e) {
      config.mainSendPort.send('WebSocket connection failed: $e');
    }
  }

  await connectStream(currentSymbol);

  // TPS Counter Timer (1Hz)
  final tpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
    currentTps = ticksThisSecond;
    ticksThisSecond = 0;
    isDirty = true;
  });

  // Conflated Frame Emitter (16ms = ~60 FPS cap across SendPort)
  final frameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
    if (!isDirty) return;
    isDirty = false;

    final pctChange = open24hPrice > 0 ? ((lastPrice - open24hPrice) / open24hPrice) * 100 : 0.0;

    config.mainSendPort.send(
      MarketFrameSnapshot(
        symbol: currentSymbol.toUpperCase(),
        lastPrice: lastPrice,
        priceChangePercent24h: pctChange,
        candles: ringBuffer.toList(),
        bids: bids,
        asks: asks,
        processedTicksPerSecond: currentTps,
        timestampMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  });

  workerReceivePort.listen((command) async {
    if (command is SubscribeSymbolCommand) {
      await connectStream(command.symbol);
    } else if (command is DisposeWorkerCommand) {
      tpsTimer.cancel();
      frameTimer.cancel();
      await wsSubscription?.cancel();
      await channel?.sink.close();
      workerReceivePort.close();
    }
  });
}
