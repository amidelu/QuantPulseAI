import 'package:bloc/bloc.dart';
import 'package:core_storage/core_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:feature_backtester/src/engine/backtest_isolate_runner.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

sealed class const BacktesterEvent();

final class const BacktesterHistorySubscribed() extends BacktesterEvent;

final class const BacktestExecutionRequested({
  required final String symbol,
  required final List<Candle> candles,
  required final int fastEma,
  required final int slowEma,
}) extends BacktesterEvent;

final class const BacktesterState({
  final bool isRunning = false,
  final BacktestResultSummary? latestResult,
  final List<BacktestRun> savedRuns = const [],
}) with Equatable {
  BacktesterState copyWith({
    bool? isRunning,
    BacktestResultSummary? latestResult,
    List<BacktestRun>? savedRuns,
  }) => BacktesterState(
    isRunning: isRunning ?? this.isRunning,
    latestResult: latestResult ?? this.latestResult,
    savedRuns: savedRuns ?? this.savedRuns,
  );

  @override
  List<Object?> get props => [isRunning, latestResult, savedRuns];
}

final class BacktesterBloc extends Bloc<BacktesterEvent, BacktesterState> {
  new({
    required this._database,
    this._runner = const BacktestIsolateRunner(),
  }) : super(const BacktesterState()) {
    on<BacktesterHistorySubscribed>(_onHistorySubscribed);
    on<BacktestExecutionRequested>(_onExecutionRequested);
  }

  final AppDatabase _database;
  final BacktestIsolateRunner _runner;

  Future<void> _onHistorySubscribed(
      BacktesterHistorySubscribed event,
      Emitter<BacktesterState> emit,
      ) async {
    await emit.forEach<List<BacktestRun>>(
      _database.watchRecentBacktests(),
      onData: (runs) => state.copyWith(savedRuns: runs),
    );
  }

  Future<void> _onExecutionRequested(
      BacktestExecutionRequested event,
      Emitter<BacktesterState> emit,
      ) async {
    emit(state.copyWith(isRunning: true));

    final summary = await _runner.runEmaCrossover(
      symbol: event.symbol,
      candles: event.candles,
      fastPeriod: event.fastEma,
      slowPeriod: event.slowEma,
    );

    // Persist to cross-isolate Drift SQLite database
    await _database.insertBacktestRun(
      BacktestRunsCompanion.insert(
        symbol: summary.symbol,
        strategyName: 'EMA ${summary.fastEma}/${summary.slowEma} Crossover',
        fastEmaPeriod: summary.fastEma,
        slowEmaPeriod: summary.slowEma,
        totalTrades: summary.totalTrades,
        winRatePercent: summary.winRatePercent,
        netProfitPercent: summary.netProfitPercent,
        maxDrawdownPercent: summary.maxDrawdownPercent,
        sharpeRatio: summary.sharpeRatio,
        equityCurveJson: summary.equityCurveJson,
      ),
    );

    // Also auto-log a journal entry for Phase 4 Local RAG Search!
    await _database.insertJournalEntry(
      TradeJournalEntriesCompanion.insert(
        symbol: summary.symbol,
        side: summary.netProfitPercent >= 0 ? 'LONG' : 'SHORT',
        entryPrice: event.candles.isNotEmpty ? event.candles.first.close : 0,
        exitPrice: event.candles.isNotEmpty ? event.candles.last.close : 0,
        pnlPercent: summary.netProfitPercent,
        reasoningNote:
        'Backtested EMA(${summary.fastEma}/${summary.slowEma}) on ${summary.symbol}: '
            '${summary.totalTrades} trades, WinRate ${summary.winRatePercent.toStringAsFixed(1)}%, '
            'Sharpe ${summary.sharpeRatio.toStringAsFixed(2)}.',
      ),
    );

    emit(state.copyWith(isRunning: false, latestResult: summary));
  }
}
