import 'package:feature_terminal/src/bloc/terminal_bloc.dart';
import 'package:feature_terminal/src/widgets/candlestick_chart_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

final class TerminalScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

final class _TerminalScreenState extends State<TerminalScreen> {
  int? _crosshairIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111622),
        title: BlocBuilder<TerminalBloc, TerminalState>(
          buildWhen: (prev, curr) =>
              prev.activeSymbol != curr.activeSymbol ||
              prev.snapshot?.processedTicksPerSecond != curr.snapshot?.processedTicksPerSecond,
          builder: (context, state) {
            final tps = state.snapshot?.processedTicksPerSecond ?? 0;
            return Row(
              children: [
                DropdownButton<String>(
                  value: state.activeSymbol,
                  dropdownColor: const Color(0xFF1A2130),
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(color: Colors.white, fontWeight: .bold, fontSize: 18),
                  items: const [
                    DropdownMenuItem(value: 'BTCUSDT', child: Text('BTC / USDT')),
                    DropdownMenuItem(value: 'ETHUSDT', child: Text('ETH / USDT')),
                  ],
                  onChanged: (symbol) {
                    if (symbol != null) {
                      context.read<TerminalBloc>().add(TerminalSymbolChanged(symbol));
                    }
                  },
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ISOLATE: $tps ticks/s',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 12,
                      fontWeight: .w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<TerminalBloc, TerminalState>(
        builder: (context, state) {
          final snapshot = state.snapshot;
          if (snapshot == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _PriceHeaderBar(snapshot: snapshot, crosshairIndex: _crosshairIndex),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: CandlestickChartCanvas(
                    candles: snapshot.candles,
                    crosshairIndex: _crosshairIndex,
                    onCrosshairChanged: (idx) => setState(() => _crosshairIndex = idx),
                  ),
                ),
              ),
              const Divider(color: Color(0xFF1E2638), height: 1),
              Expanded(
                flex: 2,
                child: _OrderBookDepthPanel(bids: snapshot.bids, asks: snapshot.asks),
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _PriceHeaderBar extends StatelessWidget {
  const new({required this.snapshot, this.crosshairIndex});

  final MarketFrameSnapshot snapshot;
  final int? crosshairIndex;

  @override
  Widget build(BuildContext context) {
    final inspected = (crosshairIndex != null && crosshairIndex! < snapshot.candles.length)
        ? snapshot.candles[crosshairIndex!]
        : (snapshot.candles.isNotEmpty ? snapshot.candles.last : null);

    final isPositive = snapshot.priceChangePercent24h >= 0;
    final color = isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF111622),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                snapshot.lastPrice.toStringAsFixed(2),
                style: TextStyle(color: color, fontSize: 24, fontWeight: .bold),
              ),
              Text(
                '${isPositive ? '+' : ''}${snapshot.priceChangePercent24h.toStringAsFixed(3)}%',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
          if (inspected != null)
            Text(
              'O: ${inspected.open.toStringAsFixed(1)}  '
              'H: ${inspected.high.toStringAsFixed(1)}  '
              'L: ${inspected.low.toStringAsFixed(1)}  '
              'V: ${inspected.volume.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

final class _OrderBookDepthPanel extends StatelessWidget {
  const new({required this.bids, required this.asks});

  final List<OrderBookLevel> bids;
  final List<OrderBookLevel> asks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _BookSideList(title: 'BIDS (BUY)', levels: bids, color: const Color(0xFF00E676)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _BookSideList(
              title: 'ASKS (SELL)',
              levels: asks,
              color: const Color(0xFFFF5252),
            ),
          ),
        ],
      ),
    );
  }
}

final class _BookSideList extends StatelessWidget {
  const new({required this.title, required this.levels, required this.color});

  final String title;
  final List<OrderBookLevel> levels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: .bold),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            itemCount: levels.length,
            itemExtent: 22,
            itemBuilder: (context, index) {
              final level = levels[index];
              return Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    level.price.toStringAsFixed(2),
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                  Text(
                    level.quantity.toStringAsFixed(4),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
