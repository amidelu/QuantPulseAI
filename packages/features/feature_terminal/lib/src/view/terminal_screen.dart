import 'package:feature_terminal/src/bloc/terminal_bloc.dart';
import 'package:feature_terminal/src/widgets/candlestick_chart_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

final class TerminalScreen extends StatefulWidget {
  const new({this.aiOverlay, super.key});

  final ChartAiOverlay? aiOverlay;

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

final class _TerminalScreenState extends State<TerminalScreen> {
  int? _crosshairIndex;

  Future<void> _showSymbolSearchPicker(BuildContext context, TerminalState state) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111622),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        var filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = state.availableSymbols
                .where((s) => s.toLowerCase().contains(filter.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search coin (e.g. SOL, DOGE, ADA)...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1A2130),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => setModalState(() => filter = val),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemExtent: 44,
                      itemBuilder: (context, idx) {
                        final symbol = filtered[idx];
                        final isSelected = symbol == state.activeSymbol;
                        return ListTile(
                          dense: true,
                          title: Text(
                            symbol.replaceAll('USDT', ' / USDT'),
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF00E676)
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: Color(0xFF00E676), size: 18)
                              : null,
                          onTap: () {
                            context.read<TerminalBloc>().add(
                              TerminalSymbolChanged(symbol),
                            );
                            Navigator.pop(bottomSheetContext);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111622),
        title: BlocBuilder<TerminalBloc, TerminalState>(
          buildWhen: (prev, curr) =>
          prev.activeSymbol != curr.activeSymbol ||
              prev.availableSymbols != curr.availableSymbols ||
              prev.snapshot?.processedTicksPerSecond !=
                  curr.snapshot?.processedTicksPerSecond,
          builder: (context, state) {
            final tps = state.snapshot?.processedTicksPerSecond ?? 0;
            return Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showSymbolSearchPicker(context, state),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.activeSymbol.replaceAll('USDT', ' / USDT'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      ],
                    ),
                  ),
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
                      fontWeight: FontWeight.w600,
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
                    aiOverlay: widget.aiOverlay,
                    crosshairIndex: _crosshairIndex,
                    onCrosshairChanged: (idx) => setState(() => _crosshairIndex = idx),
                  ),
                ),
              ),
              const Divider(color: Color(0xFF1E2638), height: 1),
              Expanded(
                flex: 2,
                child: SafeArea(
                  top: false,
                  child: _OrderBookDepthPanel(bids: snapshot.bids, asks: snapshot.asks),
                ),
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
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'O: ${inspected.open.toStringAsFixed(1)}  '
                    'H: ${inspected.high.toStringAsFixed(1)}  '
                    'L: ${inspected.low.toStringAsFixed(1)}  '
                    'V: ${inspected.volume.toStringAsFixed(2)}',
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ),
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
