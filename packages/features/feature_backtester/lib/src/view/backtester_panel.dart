import 'dart:math' as math;

import 'package:feature_backtester/src/bloc/backtester_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

final class BacktesterBottomSheet extends StatefulWidget {
  const new({
    required this.symbol,
    required this.currentCandles,
    super.key,
  });

  final String symbol;
  final List<Candle> currentCandles;

  @override
  State<BacktesterBottomSheet> createState() => _BacktesterBottomSheetState();
}

final class _BacktesterBottomSheetState extends State<BacktesterBottomSheet> {
  int _fastEma = 5;
  int _slowEma = 15;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF111622),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: BlocBuilder<BacktesterBloc, BacktesterState>(
          builder: (context, state) {
            final latest = state.latestResult;
            return Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'QUANT STRATEGY BACKTESTER (${widget.symbol})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: state.isRunning
                        ? null
                        : () {
                      context.read<BacktesterBloc>().add(
                        BacktestExecutionRequested(
                          symbol: widget.symbol,
                          candles: widget.currentCandles,
                          fastEma: _fastEma,
                          slowEma: _slowEma,
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(state.isRunning ? 'Simulating...' : 'Run in Isolate'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SliderControl(
                      label: 'Fast EMA: $_fastEma',
                      value: _fastEma.toDouble(),
                      min: 2,
                      max: 20,
                      onChanged: (v) => setState(() => _fastEma = v.round()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SliderControl(
                      label: 'Slow EMA: $_slowEma',
                      value: _slowEma.toDouble(),
                      min: 8,
                      max: 50,
                      onChanged: (v) => setState(() => _slowEma = v.round()),
                    ),
                  ),
                ],
              ),
              if (latest != null) ...[
                const SizedBox(height: 8),
                _MetricsRow(
                  netPct: latest.netProfitPercent,
                  winRate: latest.winRatePercent,
                  sharpe: latest.sharpeRatio,
                  trades: latest.totalTrades,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _EquityCurvePainter(latest.equityCurve),
                  ),
                ),
              ],
              const Divider(color: Color(0xFF1E2638), height: 20),
              const Text(
                'SAVED DRIFT (SQLITE) BACKTEST LOGS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: .bold,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: state.savedRuns.isEmpty
                    ? const Center(
                  child: Text(
                    'No saved runs yet. Click "Run in Isolate" to test & persist.',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                )
                    : ListView.builder(
                  itemCount: state.savedRuns.length,
                  itemExtent: 36,
                  itemBuilder: (context, index) {
                    final run = state.savedRuns[index];
                    final isPos = run.netProfitPercent >= 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${run.symbol} • ${run.strategyName}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Win: ${run.winRatePercent.toStringAsFixed(0)}% | '
                              'Sharpe: ${run.sharpeRatio.toStringAsFixed(2)} | '
                              '${isPos ? '+' : ''}${run.netProfitPercent.toStringAsFixed(3)}%',
                          style: TextStyle(
                            color: isPos
                                ? const Color(0xFF00E676)
                                : const Color(0xFFFF5252),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

final class _SliderControl extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

final class _MetricsRow extends StatelessWidget {
  const new({
    required this.netPct,
    required this.winRate,
    required this.sharpe,
    required this.trades,
  });

  final double netPct;
  final double winRate;
  final double sharpe;
  final int trades;

  @override
  Widget build(BuildContext context) {
    final isPos = netPct >= 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _StatChip(
            label: 'Net PnL',
            value: '${isPos ? '+' : ''}${netPct.toStringAsFixed(3)}%',
            color: isPos ? const Color(0xFF00E676) : const Color(0xFFFF5252),
          ),
        ),
        Expanded(
          child: _StatChip(
            label: 'Win Rate',
            value: '${winRate.toStringAsFixed(1)}%',
            color: Colors.white,
          ),
        ),
        Expanded(
          child: _StatChip(
            label: 'Sharpe',
            value: sharpe.toStringAsFixed(2),
            color: const Color(0xFF40C4FF),
          ),
        ),
        Expanded(
          child: _StatChip(
            label: 'Trades',
            value: '$trades',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

final class _StatChip extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

final class _EquityCurvePainter extends CustomPainter {
  const new(this.points);

  final List<double> points;

  static final Paint _linePaint = Paint()
    ..color = const Color(0xFF00E676)
    ..strokeWidth = 2
    ..style = .stroke;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    var minVal = double.infinity;
    var maxVal = -double.infinity;
    for (final p in points) {
      if (p < minVal) minVal = p;
      if (p > maxVal) maxVal = p;
    }
    final range = math.max<double>(maxVal - minVal, 1);
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minVal) / range) * (size.height - 12) - 6;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, _linePaint);
  }

  @override
  bool shouldRepaint(covariant _EquityCurvePainter oldDelegate) =>
      oldDelegate.points != points;
}
