import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Stores historical strategy backtest executions and performance metrics.
class BacktestRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get symbol => text()();
  TextColumn get strategyName => text()();
  IntColumn get fastEmaPeriod => integer()();
  IntColumn get slowEmaPeriod => integer()();
  IntColumn get totalTrades => integer()();
  RealColumn get winRatePercent => real()();
  RealColumn get netProfitPercent => real()();
  RealColumn get maxDrawdownPercent => real()();
  RealColumn get sharpeRatio => real()();
  TextColumn get equityCurveJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Stores user & AI-annotated trade journal entries for Phase 4 Local RAG search.
class TradeJournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get symbol => text()();
  TextColumn get side => text()(); // 'LONG' or 'SHORT'
  RealColumn get entryPrice => real()();
  RealColumn get exitPrice => real()();
  RealColumn get pnlPercent => real()();
  TextColumn get reasoningNote => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [BacktestRuns, TradeJournalEntries])
class AppDatabase extends _$AppDatabase {
  new([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'quant_pulse_db',
      native: DriftNativeOptions(
        shareAcrossIsolates: true,
        databaseDirectory: () async {
          try {
            return await getApplicationDocumentsDirectory();
          } on Exception catch (_) {
            return Directory.systemTemp;
          }
        },
        tempDirectoryPath: () async {
          try {
            final temp = await getTemporaryDirectory();
            return temp.path;
          } on Exception catch (_) {
            return Directory.systemTemp.path;
          }
        },
      ),
    );
  }

  /// Reactive stream of recent backtest runs ordered newest first.
  Stream<List<BacktestRun>> watchRecentBacktests({int limit = 20}) {
    return (select(backtestRuns)
      ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit))
        .watch();
  }

  /// Inserts a completed backtest run into SQLite.
  Future<int> insertBacktestRun(BacktestRunsCompanion entry) {
    return into(backtestRuns).insert(entry);
  }

  /// Inserts a trade journal note (used by Backtester & Phase 4 AI Copilot).
  Future<int> insertJournalEntry(TradeJournalEntriesCompanion entry) {
    return into(tradeJournalEntries).insert(entry);
  }

  /// Reactive stream of all journal entries for local RAG context.
  Stream<List<TradeJournalEntry>> watchJournalEntries() {
    return (select(tradeJournalEntries)
      ..orderBy([
            (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      ]))
        .watch();
  }
}
