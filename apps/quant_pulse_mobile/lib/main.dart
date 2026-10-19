import 'package:core_storage/core_storage.dart';
import 'package:feature_ai_copilot/feature_ai_copilot.dart';
import 'package:feature_backtester/feature_backtester.dart';
import 'package:feature_terminal/feature_terminal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hybrid_ai_engine/hybrid_ai_engine.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  final database = AppDatabase();
  final telemetryBridge = HardwareTelemetryBridge();
  final aiEngine = HybridAiCopilotEngine(
    database: database,
    telemetryBridge: telemetryBridge,
  );
  runApp(QuantPulseApp(database: database, aiEngine: aiEngine));
}

final class QuantPulseApp extends StatelessWidget {
  const QuantPulseApp({
    required this.database,
    required this.aiEngine,
    super.key,
  });

  final AppDatabase database;
  final HybridAiCopilotEngine aiEngine;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              TerminalBloc(streamEngine: MarketStreamEngine())
                ..add(const TerminalStarted()),
        ),
        BlocProvider(
          create: (_) =>
              BacktesterBloc(database: database)
                ..add(const BacktesterHistorySubscribed()),
        ),
        BlocProvider(create: (_) => AiCopilotBloc(engine: aiEngine)),
      ],
      child: MaterialApp(
        title: 'QuantPulse AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.light,
              systemStatusBarContrastEnforced: false,
              systemNavigationBarContrastEnforced: false,
            ),
          ),
        ),
        home: const _CoordinatorShell(),
      ),
    );
  }
}

final class _CoordinatorShell extends StatefulWidget {
  const _CoordinatorShell();

  @override
  State<_CoordinatorShell> createState() => _CoordinatorShellState();
}

final class _CoordinatorShellState extends State<_CoordinatorShell> {
  double? _supportPrice;
  double? _resistancePrice;
  String? _regimeLabel;
  Map<int, bool> _tradeSignals = const {};

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen to Backtester completions -> Plot BUY/SELL signals on the chart
        BlocListener<BacktesterBloc, BacktesterState>(
          listenWhen: (prev, curr) => prev.latestResult != curr.latestResult,
          listener: (context, state) {
            final res = state.latestResult;
            if (res == null) return;
            setState(() {
              _tradeSignals = {
                for (final m in res.markers) m.candleOpenTimeMs: m.isBuy,
              };
            });
          },
        ),
        // Listen to AI Copilot tool directives -> Plot Support/Resistance OR trigger Backtest
        BlocListener<AiCopilotBloc, AiCopilotState>(
          listenWhen: (prev, curr) => prev.lastDirective != curr.lastDirective,
          listener: (context, state) {
            final directive = state.lastDirective;
            if (directive == null) return;

            switch (directive) {
              case PlotSupportResistanceDirective(
                :final supportPrice,
                :final resistancePrice,
                :final regimeLabel,
              ):
                setState(() {
                  _supportPrice = supportPrice;
                  _resistancePrice = resistancePrice;
                  _regimeLabel = regimeLabel;
                });
              case TriggerStrategyBacktestDirective(
                :final fastEma,
                :final slowEma,
              ):
                final tState = context.read<TerminalBloc>().state;
                final candles = tState.snapshot?.candles ?? const [];
                if (candles.isNotEmpty) {
                  context.read<BacktesterBloc>().add(
                    BacktestExecutionRequested(
                      symbol: tState.activeSymbol,
                      candles: candles,
                      fastEma: fastEma,
                      slowEma: slowEma,
                    ),
                  );
                }
            }
          },
        ),
      ],
      child: Scaffold(
        body: TerminalScreen(
          aiOverlay: ChartAiOverlay(
            supportPrice: _supportPrice,
            resistancePrice: _resistancePrice,
            regimeLabel: _regimeLabel,
            tradeSignalsByOpenTimeMs: _tradeSignals,
          ),
        ),
        floatingActionButton: BlocBuilder<TerminalBloc, TerminalState>(
          builder: (context, state) {
            final candles = state.snapshot?.candles ?? const [];
            return Row(
              mainAxisSize: .min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'ai_copilot_fab',
                  backgroundColor: const Color(0xFF40C4FF),
                  foregroundColor: Colors.black,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'AI Copilot',
                    style: TextStyle(fontWeight: .bold),
                  ),
                  onPressed: candles.isEmpty
                      ? null
                      : () {
                          final marketInput = MarketContextInput(
                            symbol: state.activeSymbol,
                            closePrices: candles.map((c) => c.close).toList(),
                            highs: candles.map((c) => c.high).toList(),
                            lows: candles.map((c) => c.low).toList(),
                          );
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => BlocProvider.value(
                              value: context.read<AiCopilotBloc>(),
                              child: AiCopilotBottomSheet(
                                marketContext: marketInput,
                              ),
                            ),
                          );
                        },
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  heroTag: 'backtester_fab',
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text(
                    'Backtest & SQLite',
                    style: TextStyle(fontWeight: .bold),
                  ),
                  onPressed: candles.isEmpty
                      ? null
                      : () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => BlocProvider.value(
                              value: context.read<BacktesterBloc>(),
                              child: BacktesterBottomSheet(
                                symbol: state.activeSymbol,
                                currentCandles: candles,
                              ),
                            ),
                          );
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
