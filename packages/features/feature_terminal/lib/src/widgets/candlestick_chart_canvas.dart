import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

/// AI or Backtester overlay data painted directly on the Candlestick Canvas.
final class const ChartAiOverlay({
  final double? supportPrice,
  final double? resistancePrice,
  final String? regimeLabel,
  final Map<int, bool> tradeSignalsByOpenTimeMs = const {}, // openTimeMs -> isBuy
});

/// Interactive 60/120 FPS Candlestick, EMA-12, Volume, and AI Overlay Canvas.
final class CandlestickChartCanvas extends StatefulWidget {
  const new({
    required this.candles,
    this.aiOverlay,
    this.crosshairIndex,
    this.onCrosshairChanged,
    super.key,
  });

  final List<Candle> candles;
  final ChartAiOverlay? aiOverlay;
  final int? crosshairIndex;
  final ValueChanged<int?>? onCrosshairChanged;

  @override
  State<CandlestickChartCanvas> createState() => _CandlestickChartCanvasState();
}

final class _CandlestickChartCanvasState extends State<CandlestickChartCanvas> {
  int _visibleCandleCount = 45;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _updateCrosshair(details.localPosition),
      onTapUp: (_) => widget.onCrosshairChanged?.call(null),
      onScaleStart: (details) {
        if (details.pointerCount == 1) {
          _updateCrosshair(details.localFocalPoint);
        }
      },
      onScaleUpdate: (details) {
        if (details.scale != 1.0) {
          setState(() {
            _visibleCandleCount = (_visibleCandleCount / details.scale)
                .round()
                .clamp(20, 120);
          });
        } else {
          _updateCrosshair(details.localFocalPoint);
        }
      },
      onScaleEnd: (_) => widget.onCrosshairChanged?.call(null),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _CandlestickPainter(
            candles: widget.candles,
            visibleCount: _visibleCandleCount,
            aiOverlay: widget.aiOverlay,
            crosshairIndex: widget.crosshairIndex,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  void _updateCrosshair(Offset localPosition) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || widget.candles.isEmpty) return;

    final width = renderBox.size.width;
    final startIdx = math.max(0, widget.candles.length - _visibleCandleCount);
    final visible = widget.candles.sublist(startIdx);
    if (visible.isEmpty) return;

    final slotWidth = width / visible.length;
    final idx = (localPosition.dx / slotWidth).floor().clamp(0, visible.length - 1);
    widget.onCrosshairChanged?.call(startIdx + idx);
  }
}

final class _CandlestickPainter extends CustomPainter {
  const new({
    required this.candles,
    required this.visibleCount,
    this.aiOverlay,
    this.crosshairIndex,
  });

  final List<Candle> candles;
  final int visibleCount;
  final ChartAiOverlay? aiOverlay;
  final int? crosshairIndex;

  static final Paint _bullPaint = Paint()
    ..color = const Color(0xFF00E676)
    ..style = .fill;

  static final Paint _bearPaint = Paint()
    ..color = const Color(0xFFFF5252)
    ..style = .fill;

  static final Paint _wickBullPaint = Paint()
    ..color = const Color(0xFF00E676)
    ..strokeWidth = 1.3;

  static final Paint _wickBearPaint = Paint()
    ..color = const Color(0xFFFF5252)
    ..strokeWidth = 1.3;

  static final Paint _emaPaint = Paint()
    ..color = const Color(0xFF40C4FF)
    ..strokeWidth = 1.8
    ..style = .stroke;

  static final Paint _supportPaint = Paint()
    ..color = const Color(0xFF00E676)
    ..strokeWidth = 1.4;

  static final Paint _resistancePaint = Paint()
    ..color = const Color(0xFFFFAB40)
    ..strokeWidth = 1.4;

  static final Paint _gridPaint = Paint()
    ..color = const Color(0x18FFFFFF)
    ..strokeWidth = 1;

  static final Paint _crosshairPaint = Paint()
    ..color = const Color(0x99FFFFFF)
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty || size.width <= 0 || size.height <= 0) return;

    final startIdx = math.max(0, candles.length - visibleCount);
    final visible = candles.sublist(startIdx);
    final count = visible.length;

    final chartHeight = size.height * 0.78;
    final volumeTop = size.height * 0.82;
    final volumeHeight = size.height * 0.18;

    for (var i = 1; i <= 4; i++) {
      final y = (chartHeight / 5) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }

    var minPrice = double.infinity;
    var maxPrice = -double.infinity;
    var maxVolume = 0.0;

    for (final c in visible) {
      if (c.low < minPrice) minPrice = c.low;
      if (c.high > maxPrice) maxPrice = c.high;
      if (c.volume > maxVolume) maxVolume = c.volume;
    }

    final priceRange = math.max<double>(maxPrice - minPrice, 0.0001);
    final slotWidth = size.width / count;
    final bodyWidth = (slotWidth * 0.68).clamp(2, 18).toDouble();

    double priceToY(double price) =>
        chartHeight - ((price - minPrice) / priceRange) * (chartHeight - 16) - 8;

    // Draw AI Support & Resistance horizontal zones if active
    final overlay = aiOverlay;
    if (overlay != null) {
      if (overlay.supportPrice != null) {
        final sy = priceToY(overlay.supportPrice!).clamp(4, chartHeight - 4).toDouble();
        canvas.drawLine(Offset(0, sy), Offset(size.width, sy), _supportPaint);
      }
      if (overlay.resistancePrice != null) {
        final ry = priceToY(overlay.resistancePrice!).clamp(4, chartHeight - 4).toDouble();
        canvas.drawLine(Offset(0, ry), Offset(size.width, ry), _resistancePaint);
      }
    }

    final emaPath = Path();
    var emaValue = visible.first.close;
    const emaMultiplier = 2 / (12 + 1);

    for (var i = 0; i < count; i++) {
      final candle = visible[i];
      final centerX = (i + 0.5) * slotWidth;
      final highY = priceToY(candle.high);
      final lowY = priceToY(candle.low);
      final openY = priceToY(candle.open);
      final closeY = priceToY(candle.close);

      final isBull = candle.isBullish;
      canvas.drawLine(
        Offset(centerX, highY),
        Offset(centerX, lowY),
        isBull ? _wickBullPaint : _wickBearPaint,
      );

      final top = math.min(openY, closeY);
      final bottom = math.max(openY, closeY);
      final rectHeight = math.max<double>(bottom - top, 2);

      canvas.drawRect(
        Rect.fromLTWH(centerX - bodyWidth / 2, top, bodyWidth, rectHeight),
        isBull ? _bullPaint : _bearPaint,
      );

      // Draw Agentic BUY / SELL signal markers on matching candles
      final isBuySignal = overlay?.tradeSignalsByOpenTimeMs[candle.openTimeMs];
      if (isBuySignal != null) {
        final markerY = isBuySignal ? lowY + 8 : highY - 8;
        canvas.drawCircle(
          Offset(centerX, markerY),
          4.5,
          isBuySignal ? _bullPaint : _bearPaint,
        );
      }

      if (maxVolume > 0) {
        final volBarHeight = (candle.volume / maxVolume) * volumeHeight;
        final volPaint = Paint()
          ..color = (isBull ? const Color(0xFF00E676) : const Color(0xFFFF5252))
              .withValues(alpha: 0.28);
        canvas.drawRect(
          Rect.fromLTWH(
            centerX - bodyWidth / 2,
            volumeTop + (volumeHeight - volBarHeight),
            bodyWidth,
            volBarHeight,
          ),
          volPaint,
        );
      }

      emaValue = (candle.close - emaValue) * emaMultiplier + emaValue;
      final emaY = priceToY(emaValue);
      if (i == 0) {
        emaPath.moveTo(centerX, emaY);
      } else {
        emaPath.lineTo(centerX, emaY);
      }
    }

    canvas.drawPath(emaPath, _emaPaint);

    final activeIdx = crosshairIndex;
    if (activeIdx != null && activeIdx >= startIdx && activeIdx < candles.length) {
      final localIdx = activeIdx - startIdx;
      final cx = (localIdx + 0.5) * slotWidth;
      final cy = priceToY(visible[localIdx].close);
      canvas..drawLine(Offset(cx, 0), Offset(cx, size.height), _crosshairPaint)
      ..drawLine(Offset(0, cy), Offset(size.width, cy), _crosshairPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) =>
      oldDelegate.candles != candles ||
          oldDelegate.visibleCount != visibleCount ||
          oldDelegate.aiOverlay != aiOverlay ||
          oldDelegate.crosshairIndex != crosshairIndex;
}
