import 'package:equatable/equatable.dart';

/// Immutable OHLCV candlestick model with Dart 3.13 primary constructor.
final class const Candle({
  required final int openTimeMs,
  required final double open,
  required final double high,
  required final double low,
  required final double close,
  required final double volume,
}) with Equatable {
  bool get isBullish => close >= open;

  Candle copyWithTrade({required double price, required double quantity}) => Candle(
    openTimeMs: openTimeMs,
    open: open,
    high: price > high ? price : high,
    low: price < low ? price : low,
    close: price,
    volume: volume + quantity,
  );

  @override
  List<Object?> get props => [openTimeMs, open, high, low, close, volume];
}

/// Single price level in the Order Book (Bid or Ask).
final class const OrderBookLevel({required final double price, required final double quantity})
    with Equatable {
  @override
  List<Object?> get props => [price, quantity];
}

/// Conflated frame snapshot sent from the Background Isolate to the Main UI Isolate.
final class const MarketFrameSnapshot({
  required final String symbol,
  required final double lastPrice,
  required final double priceChangePercent24h,
  required final List<Candle> candles,
  required final List<OrderBookLevel> bids,
  required final List<OrderBookLevel> asks,
  required final int processedTicksPerSecond,
  required final int timestampMs,
}) with Equatable {
  @override
  List<Object?> get props => [
    symbol,
    lastPrice,
    priceChangePercent24h,
    candles,
    bids,
    asks,
    processedTicksPerSecond,
    timestampMs,
  ];
}
