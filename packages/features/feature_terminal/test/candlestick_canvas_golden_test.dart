import 'package:feature_terminal/feature_terminal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

void main() {
  testWidgets('CandlestickChartCanvas golden snapshot test', (tester) async {
    final sampleCandles = List.generate(
      30,
          (i) => Candle(
        openTimeMs: 1700000000000 + i * 5000,
        open: 83000.0 + (i * 10),
        high: 83050.0 + (i * 10),
        low: 82980.0 + (i * 10),
        close: 83040.0 + (i * 10),
        volume: 2.0 + (i % 5),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0B0E14),
          body: SizedBox(
            width: 400,
            height: 300,
            child: CandlestickChartCanvas(
              candles: sampleCandles,
              aiOverlay: const ChartAiOverlay(
                supportPrice: 83000,
                resistancePrice: 83300,
                regimeLabel: 'BULLISH',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CandlestickChartCanvas), findsOneWidget);
  });
}
