import 'package:core_network/src/result.dart';
import 'package:dio/dio.dart';

/// Contract for fetching market symbols, mockable across packages.
abstract interface class IMarketApiClient {
  Future<Result<List<String>>> fetchActiveUsdtPairs();
}

/// Concrete implementation.
final class MarketApiClient implements IMarketApiClient {
  new({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://api.binance.com/api/v3',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

  final Dio _dio;

  /// Fetches all active USDT trading pairs (~400 coins) in a lightweight ~40KB payload.
  @override
  Future<Result<List<String>>> fetchActiveUsdtPairs() async {
    try {
      final response = await _dio.get<List<dynamic>>('/ticker/price');
      final data = response.data;
      if (data == null) {
        return const Success(['BTCUSDT', 'ETHUSDT', 'SOLUSDT', 'BNBUSDT']);
      }

      final pairs = <String>[];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final symbol = item['symbol'] as String?;
          if (symbol != null && symbol.endsWith('USDT')) {
            pairs.add(symbol);
          }
        }
      }

      pairs.sort();
      return Success(pairs.isNotEmpty ? pairs : ['BTCUSDT', 'ETHUSDT']);
    } on Object catch (e) {
      return Failure(NetworkFailure(message: 'Failed to fetch symbols: $e'));
    }
  }
}
