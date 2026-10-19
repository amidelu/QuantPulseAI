import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core_network/core_network.dart';
import 'package:feature_terminal/feature_terminal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_stream_engine/market_stream_engine.dart';
import 'package:mocktail/mocktail.dart';

class MockMarketStreamEngine extends Mock implements IMarketStreamEngine;
class MockMarketApiClient extends Mock implements IMarketApiClient;

void main() {
  late MockMarketStreamEngine mockStreamEngine;
  late MockMarketApiClient mockApiClient;
  late StreamController<Result<MarketFrameSnapshot>> streamController;

  const sampleSnapshot = MarketFrameSnapshot(
    symbol: 'BTCUSDT',
    lastPrice: 83050,
    priceChangePercent24h: 1.25,
    candles: [
      Candle(
        openTimeMs: 1700000000000,
        open: 83000,
        high: 83100,
        low: 82950,
        close: 83050,
        volume: 4.5,
      ),
    ],
    bids: [OrderBookLevel(price: 83049, quantity: 1.2)],
    asks: [OrderBookLevel(price: 83051, quantity: 0.8)],
    processedTicksPerSecond: 45,
    timestampMs: 1700000005000,
  );

  setUp(() {
    mockStreamEngine = MockMarketStreamEngine();
    mockApiClient = MockMarketApiClient();
    streamController = StreamController<Result<MarketFrameSnapshot>>.broadcast();

    when(() => mockStreamEngine.connect(symbol: any(named: 'symbol')))
        .thenAnswer((_) async => streamController.stream);
    when(() => mockStreamEngine.switchSymbol(any())).thenReturn(null);
    when(() => mockStreamEngine.dispose()).thenAnswer((_) async {});
    when(() => mockApiClient.fetchActiveUsdtPairs())
        .thenAnswer((_) async => const Success(['BTCUSDT', 'ETHUSDT', 'SOLUSDT']));
  });

  tearDown(() async {
    await streamController.close();
  });

  group('TerminalBloc', () {
    test('initial state has default status and symbol list', () {
      final bloc = TerminalBloc(
        streamEngine: mockStreamEngine,
        apiClient: mockApiClient,
      );
      expect(bloc.state.status, TerminalStatus.initial);
      expect(bloc.state.activeSymbol, 'BTCUSDT');
      expect(bloc.state.availableSymbols.isNotEmpty, true);
    });

    blocTest<TerminalBloc, TerminalState>(
      'emits updated symbols list when TerminalSymbolsRequested succeeds',
      build: () => TerminalBloc(
        streamEngine: mockStreamEngine,
        apiClient: mockApiClient,
      ),
      act: (bloc) => bloc.add(const TerminalSymbolsRequested()),
      expect: () => [
        isA<TerminalState>().having(
              (s) => s.availableSymbols,
          'availableSymbols',
          ['BTCUSDT', 'ETHUSDT', 'SOLUSDT'],
        ),
      ],
    );

    blocTest<TerminalBloc, TerminalState>(
      'emits [connecting, streaming] when TerminalStarted connects and emits frames',
      build: () => TerminalBloc(
        streamEngine: mockStreamEngine,
        apiClient: mockApiClient,
      ),
      act: (bloc) async {
        bloc.add(const TerminalStarted());
        await pumpEventQueue();
        streamController.add(const Success(sampleSnapshot));
      },
      expect: () => [
        isA<TerminalState>()
            .having((s) => s.status, 'status', TerminalStatus.connecting)
            .having((s) => s.activeSymbol, 'symbol', 'BTCUSDT'),
        isA<TerminalState>()
            .having((s) => s.status, 'status', TerminalStatus.streaming)
            .having((s) => s.snapshot?.lastPrice, 'price', 83050.0),
      ],
    );

    blocTest<TerminalBloc, TerminalState>(
      'switches symbol cleanly and notifies background engine',
      build: () => TerminalBloc(
        streamEngine: mockStreamEngine,
        apiClient: mockApiClient,
      ),
      act: (bloc) => bloc.add(const TerminalSymbolChanged('ETHUSDT')),
      expect: () => [
        isA<TerminalState>()
            .having((s) => s.status, 'status', TerminalStatus.connecting)
            .having((s) => s.activeSymbol, 'symbol', 'ETHUSDT'),
      ],
      verify: (_) {
        verify(() => mockStreamEngine.switchSymbol('ETHUSDT')).called(1);
      },
    );
  });
}
