import 'package:feature_terminal/feature_terminal.dart';
import 'package:flutter/material.dart';
import 'package:market_stream_engine/market_stream_engine.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const HotReloadWidgetbook());
}

final class HotReloadWidgetbook extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookCategory(
          name: 'Trading Terminal Canvas',
          children: [
            WidgetbookComponent(
              name: 'CandlestickChartCanvas',
              useCases: [
                WidgetbookUseCase(
                  name: 'Live 120 FPS Bullish Trend',
                  builder: (context) => SizedBox(
                    height: 320,
                    child: CandlestickChartCanvas(
                      candles: List.generate(
                        40,
                            (i) => Candle(
                          openTimeMs: 1700000000000 + i * 5000,
                          open: 83000.0 + (i * 12),
                          high: 83030.0 + (i * 14),
                          low: 82990.0 + (i * 10),
                          close: 83025.0 + (i * 13),
                          volume: 3.5 + (i % 4),
                        ),
                      ),
                      aiOverlay: const ChartAiOverlay(
                        supportPrice: 83100,
                        resistancePrice: 83500,
                        regimeLabel: 'ACCUMULATION',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
