import 'dart:convert';

import 'package:core_network/core_network.dart';
import 'package:dio/dio.dart';
import 'package:hybrid_ai_engine/src/engine/hybrid_ai_copilot_engine.dart';

/// Output from Groq LPU Cloud inference including any structured tool call.
final class const GroqCompletionOutput({
  required final String markdownContent,
  required final String modelUsed,
  final AiToolCallDirective? toolDirective,
});

/// OpenAI-compatible Groq LPU Client using Dio ^5.11.1.
final class GroqCloudClient {
  new({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://api.groq.com/openai/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: const {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;

  /// Production Groq models supporting native tool-calling:
  /// - 'llama-3.3-70b-versatile'
  /// - 'openai/gpt-oss-20b'
  /// - 'qwen/qwen3.8-27b'
  static const String defaultModel = 'openai/gpt-oss-20b';

  Future<Result<GroqCompletionOutput>> completeWithTools({
    required String apiKey,
    required String prompt,
    required MarketContextInput marketContext,
    required List<String> ragSnippets,
    String model = defaultModel,
  }) async {
    final closes = marketContext.closePrices;
    final lastPrice = closes.isNotEmpty ? closes.last : 0.0;
    final minLow = marketContext.lows.isNotEmpty
        ? marketContext.lows.reduce((a, b) => a < b ? a : b)
        : 0.0;
    final maxHigh = marketContext.highs.isNotEmpty
        ? marketContext.highs.reduce((a, b) => a > b ? a : b)
        : 0.0;

    final ragContextText = ragSnippets.isEmpty
        ? 'No matching SQLite trade journal notes found.'
        : ragSnippets.join('\n');

    final systemPrompt = '''
You are QuantPulse AI, an institutional quantitative trading copilot running on Groq LPU.
Active Symbol: ${marketContext.symbol}
Latest Price: ${lastPrice.toStringAsFixed(2)}
Window Low: ${minLow.toStringAsFixed(2)} \vert{} Window High:${maxHigh.toStringAsFixed(2)}
Recent Close Sample: ${closes.reversed.take(12).map((p) => p.toStringAsFixed(2)).join(', ')}

Local SQLite Trade Journal RAG Context:
$ragContextText

Instructions:
1. Provide a concise, high-signal quantitative analysis in Markdown.
2. Call `plot_support_resistance` if the user asks for chart levels, zones, or regime analysis.
3. Call `trigger_ema_backtest` if the user asks to backtest, optimize EMA, or generate buy/sell signals.
''';

    try {
      final response = await _dio.post<Map<String, Object?>>(
        '/chat/completions',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
        data: {
          'model': model,
          'temperature': 0.2,
          'max_completion_tokens': 512,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'tool_choice': 'auto',
          'tools': [
            {
              'type': 'function',
              'function': {
                'name': 'plot_support_resistance',
                'description':
                'Draws horizontal support and resistance price zones on the Flutter CustomPainter candlestick canvas.',
                'parameters': {
                  'type': 'object',
                  'properties': {
                    'supportPrice': {'type': 'number'},
                    'resistancePrice': {'type': 'number'},
                    'regimeLabel': {'type': 'string'},
                  },
                  'required': ['supportPrice', 'resistancePrice', 'regimeLabel'],
                },
              },
            },
            {
              'type': 'function',
              'function': {
                'name': 'trigger_ema_backtest',
                'description':
                'Triggers the Dart Isolate EMA crossover backtester and plots BUY/SELL markers on the chart.',
                'parameters': {
                  'type': 'object',
                  'properties': {
                    'fastEma': {'type': 'integer'},
                    'slowEma': {'type': 'integer'},
                    'rationale': {'type': 'string'},
                  },
                  'required': ['fastEma', 'slowEma', 'rationale'],
                },
              },
            },
          ],
        },
      );

      final body = response.data;
      final choices = body?['choices'] as List<Object?>?;
      if (choices == null || choices.isEmpty) {
        return const Failure(
          NetworkFailure(message: 'Empty choices returned from Groq API.'),
        );
      }

      final firstChoice = choices.first! as Map<String, Object?>;
      final message = firstChoice['message'] as Map<String, Object?>?;
      final content = (message?['content'] as String?) ?? '';
      final toolCalls = message?['tool_calls'] as List<Object?>?;

      AiToolCallDirective? directive;
      var toolCallSummary = '';

      if (toolCalls != null && toolCalls.isNotEmpty) {
        final firstTool = toolCalls.first! as Map<String, Object?>;
        final fn = firstTool['function'] as Map<String, Object?>?;
        final fnName = fn?['name'] as String?;
        final rawArgs = fn?['arguments'] as String? ?? '{}';
        final args = jsonDecode(rawArgs) as Map<String, Object?>;

        if (fnName == 'plot_support_resistance') {
          final sup = (args['supportPrice'] as num?)?.toDouble() ?? minLow;
          final res = (args['resistancePrice'] as num?)?.toDouble() ?? maxHigh;
          final label = args['regimeLabel'] as String? ?? 'GROQ QUANT REGIME';
          directive = PlotSupportResistanceDirective(
            supportPrice: sup,
            resistancePrice: res,
            regimeLabel: label,
          );
          toolCallSummary =
          '\n\n**Groq Tool Executed (`plot_support_resistance`):**\n'
              '→ Support: **${sup.toStringAsFixed(2)}** | Resistance: **${res.toStringAsFixed(2)}** ($label)';
        } else if (fnName == 'trigger_ema_backtest') {
          final fast = (args['fastEma'] as num?)?.toInt() ?? 5;
          final slow = (args['slowEma'] as num?)?.toInt() ?? 18;
          final rationale = args['rationale'] as String? ?? 'Groq LPU EMA Optimization';
          directive = TriggerStrategyBacktestDirective(
            fastEma: fast.clamp(2, 25),
            slowEma: slow.clamp(8, 60),
            rationale: rationale,
          );
          toolCallSummary =
          '\n\n**Groq Tool Executed (`trigger_ema_backtest`):**\n'
              '→ Dispatched **EMA($fast/$slow)** to Background Isolate ($rationale)';
        }
      }

      final finalMarkdown = content.trim().isEmpty
          ? '**Groq LPU (`$model`) Dispatched Tool Call:**$toolCallSummary'
          : '${content.trim()}$toolCallSummary';

      return Success(
        GroqCompletionOutput(
          markdownContent: finalMarkdown,
          modelUsed: model,
          toolDirective: directive,
        ),
      );
    } on DioException catch (e) {
      final errData = e.response?.data;
      return Failure(
        NetworkFailure(
          message: 'Groq API Error (${e.response?.statusCode}): $errData',
        ),
      );
    } on Object catch (e) {
      return Failure(NetworkFailure(message: 'Groq unexpected error: $e'));
    }
  }
}
