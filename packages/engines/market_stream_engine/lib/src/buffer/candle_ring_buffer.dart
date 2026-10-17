import 'package:market_stream_engine/src/models/market_models.dart';

/// Fixed-capacity O(1) circular buffer for storing live OHLCV candles
/// without unbounded memory growth during multi-hour trading sessions.
final class CandleRingBuffer(final int capacity) {
  final List<Candle?> _buffer = List<Candle?>.filled(capacity, null);
  int _head = 0;
  int _count = 0;

  int get length => _count;

  /// Appends a new candle or updates the latest candle if openTimeMs matches.
  void upsert(Candle candle) {
    if (_count > 0) {
      final lastIndex = (_head - 1 + capacity) % capacity;
      final lastCandle = _buffer[lastIndex];
      if (lastCandle != null && lastCandle.openTimeMs == candle.openTimeMs) {
        _buffer[lastIndex] = candle;
        return;
      }
    }

    _buffer[_head] = candle;
    _head = (_head + 1) % capacity;
    if (_count < capacity) {
      _count++;
    }
  }

  /// Returns an ordered immutable snapshot from oldest to newest candle.
  List<Candle> toList() {
    if (_count == 0) return const [];
    final result = <Candle>[];
    final start = _count < capacity ? 0 : _head;
    for (var i = 0; i < _count; i++) {
      final index = (start + i) % capacity;
      final item = _buffer[index];
      if (item != null) result.add(item);
    }
    return List.unmodifiable(result);
  }

  void clear() {
    _buffer.fillRange(0, capacity, null);
    _head = 0;
    _count = 0;
  }
}
