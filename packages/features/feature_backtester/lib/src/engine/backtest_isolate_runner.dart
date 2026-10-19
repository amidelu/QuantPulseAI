import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

/// Represents a BUY or SELL execution plotted on the candlestick chart.
final class const TradeSignalMarker({
  required final int candleOpenTimeMs,
  required final bool isBuy,
  required final double price,
  required final double pnlPercent,
}) with Equatable {
  @override
  List<Object?> get props => [candleOpenTimeMs, isBuy, price, pnlPercent];
}

/// Output of a quantitative backtest simulation.
final class const BacktestResultSummary({
  required final String symbol,
  required final int fastEma,
  required final int slowEma,
  required final int totalTrades,
  required final double winRatePercent,
  required final double netProfitPercent,
  required final double maxDrawdownPercent,
  required final double sharpeRatio,
  required final List<double> equityCurve,
  required final List<TradeSignalMarker> markers,
}) with Equatable {
  String get equityCurveJson => jsonEncode(equityCurve);

  @override
  List<Object?> get props => [
    symbol,
    fastEma,
    slowEma,
    totalTrades,
    winRatePercent,
    netProfitPercent,
    maxDrawdownPercent,
    sharpeRatio,
    equityCurve,
    markers,
  ];
}

/// Runs EMA Crossover simulation inside a short-lived background Isolate via Isolate.run.
final class BacktestIsolateRunner {
  const new();

  Future<BacktestResultSummary> runEmaCrossover({
    required String symbol,
    required List<Candle> candles,
    required int fastPeriod,
    required int slowPeriod,
  }) {
    return Isolate.run(
          () => _executeSimulation(
        symbol: symbol,
        candles: candles,
        fastPeriod: fastPeriod,
        slowPeriod: slowPeriod,
      ),
    );
  }

  static BacktestResultSummary _executeSimulation({
    required String symbol,
    required List<Candle> candles,
    required int fastPeriod,
    required int slowPeriod,
  }) {
    if (candles.length < 5) {
      return BacktestResultSummary(
        symbol: symbol,
        fastEma: fastPeriod,
        slowEma: slowPeriod,
        totalTrades: 0,
        winRatePercent: 0,
        netProfitPercent: 0,
        maxDrawdownPercent: 0,
        sharpeRatio: 0,
        equityCurve: const [10000],
        markers: const [],
      );
    }

    var equity = 100.0;
    var peakEquity = 100.0;
    var maxDrawdown = 0.0;
    final equityCurve = <double>[equity];
    final markers = <TradeSignalMarker>[];
    final tradeReturns = <double>[];

    var fastEma = candles.first.close;
    var slowEma = candles.first.close;
    final kFast = 2 / (fastPeriod + 1);
    final kSlow = 2 / (slowPeriod + 1);

    double? activeEntryPrice;
    var wins = 0;

    for (var i = 1; i < candles.length; i++) {
      final c = candles[i];
      final prevDiff = fastEma - slowEma;

      fastEma = (c.close - fastEma) * kFast + fastEma;
      slowEma = (c.close - slowEma) * kSlow + slowEma;
      final currDiff = fastEma - slowEma;

      // Bullish crossover -> Enter Long
      if (prevDiff <= 0 && currDiff > 0 && activeEntryPrice == null) {
        activeEntryPrice = c.close;
        markers.add(
          TradeSignalMarker(
            candleOpenTimeMs: c.openTimeMs,
            isBuy: true,
            price: c.close,
            pnlPercent: 0,
          ),
        );
      }
      // Bearish crossover (or final candle) -> Exit Long
      else if ((prevDiff >= 0 && currDiff < 0 || i == candles.length - 1) &&
          activeEntryPrice != null) {
        final rawReturn = (c.close - activeEntryPrice) / activeEntryPrice;
        // Apply realistic 0.04% taker fee
        final netReturn = rawReturn - 0.0004;
        tradeReturns.add(netReturn);
        if (netReturn > 0) wins++;

        equity = equity * (1 + netReturn);
        if (equity > peakEquity) peakEquity = equity;
        final dd = ((peakEquity - equity) / peakEquity) * 100;
        if (dd > maxDrawdown) maxDrawdown = dd;

        markers.add(
          TradeSignalMarker(
            candleOpenTimeMs: c.openTimeMs,
            isBuy: false,
            price: c.close,
            pnlPercent: netReturn * 100,
          ),
        );
        activeEntryPrice = null;
      }

      equityCurve.add(equity);
    }

    final totalTrades = tradeReturns.length;
    final winRate = totalTrades > 0 ? (wins / totalTrades) * 100 : 0.0;
    final netProfitPct = ((equity - 10000.0) / 10000.0) * 100;

    // Calculate annualized-style Sharpe Ratio across trade returns
    var sharpe = 0.0;
    if (tradeReturns.length > 1) {
      final mean = tradeReturns.reduce((a, b) => a + b) / tradeReturns.length;
      final variance = tradeReturns
          .map((r) => math.pow(r - mean, 2))
          .reduce((a, b) => a + b) /
          tradeReturns.length;
      final stdDev = math.sqrt(variance);
      if (stdDev > 0) {
        sharpe = (mean / stdDev) * math.sqrt(tradeReturns.length);
      }
    }

    return BacktestResultSummary(
      symbol: symbol,
      fastEma: fastPeriod,
      slowEma: slowPeriod,
      totalTrades: totalTrades,
      winRatePercent: winRate,
      netProfitPercent: netProfitPct,
      maxDrawdownPercent: maxDrawdown,
      sharpeRatio: sharpe,
      equityCurve: equityCurve,
      markers: markers,
    );
  }
}
