import 'dart:isolate';
import 'dart:math' as math;

import 'package:core_storage/core_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:hybrid_ai_engine/src/bridge/hardware_telemetry_bridge.dart';
import 'package:hybrid_ai_engine/src/cloud/groq_cloud_client.dart';
import 'package:hybrid_ai_engine/src/edge/local_model_manager.dart';

/// Structured Agentic Tool Call that can be executed by the UI / Chart Canvas.
sealed class const AiToolCallDirective() with Equatable {
  @override
  List<Object?> get props => [];
}

/// Instructs the Candlestick Chart Canvas to draw Support & Resistance zones.
final class const PlotSupportResistanceDirective({
  required final double supportPrice,
  required final double resistancePrice,
  required final String regimeLabel,
}) extends AiToolCallDirective {
  @override
  List<Object?> get props => [supportPrice, resistancePrice, regimeLabel];
}

/// Instructs the Backtester Engine to run a specific EMA strategy and plot BUY/SELL arrows.
final class const TriggerStrategyBacktestDirective({
  required final int fastEma,
  required final int slowEma,
  required final String rationale,
}) extends AiToolCallDirective {
  @override
  List<Object?> get props => [fastEma, slowEma, rationale];
}

/// Response returned by the Hybrid AI Copilot.
final class const AiCopilotResponse({
  required final String markdownAnswer,
  required final ComputeTarget executedOn,
  required final HardwareHealthSnapshot hardwareSnapshot,
  required final int ragMatchedJournalCount,
  required final int inferenceLatencyMs,
  final AiToolCallDirective? toolCall,
}) with Equatable {
  @override
  List<Object?> get props => [
    markdownAnswer,
    executedOn,
    hardwareSnapshot,
    ragMatchedJournalCount,
    inferenceLatencyMs,
    toolCall,
  ];
}

/// Input snapshot of market prices for quantitative AI analysis.
final class const MarketContextInput({
  required final String symbol,
  required final List<double> closePrices,
  required final List<double> highs,
  required final List<double> lows,
});

final class HybridAiCopilotEngine {
  new({
    required this._database,
    required this._telemetryBridge,
    GroqCloudClient? groqClient,
    LocalModelManager? modelManager,
  }) : _groqClient = groqClient ?? GroqCloudClient(),
        _modelManager = modelManager ?? LocalModelManager();

  final AppDatabase _database;
  final HardwareTelemetryBridge _telemetryBridge;
  final GroqCloudClient _groqClient;
  final LocalModelManager _modelManager;

  HardwareTelemetryBridge get telemetryBridge => _telemetryBridge;
  LocalModelManager get modelManager => _modelManager;

  Future<AiCopilotResponse> askCopilot({
    required String prompt,
    required MarketContextInput marketContext,
  }) async {
    final stopwatch = Stopwatch()..start();

    // 1. Check hardware thermal & RAM state via Pigeon bridge
    final health = await _telemetryBridge.queryDeviceHealth();
    final target = health.recommendedTarget;

    // 2. Fetch stored trade journal entries from Cross-Isolate Drift SQLite
    final journalEntries = await _database.watchJournalEntries().first;
    final journalTexts = journalEntries
        .map(
          (e) =>
      '[${e.symbol}${e.side} PnL: ${e.pnlPercent.toStringAsFixed(2)}%]${e.reasoningNote}',
    )
        .toList();

    // 3. Score local RAG snippets inside background Isolate
    final ragSnippets = await Isolate.run(
          () => _matchRagNotes(prompt, marketContext.symbol, journalTexts),
    );

    // 4. Route to Groq Cloud API if target is cloudApi (or if API key is saved & thermal is serious)
    final savedGroqKey = await _telemetryBridge.readCloudApiKey();
    if (target == .cloudApi &&
        savedGroqKey != null &&
        savedGroqKey.trim().isNotEmpty) {
      final groqResult = await _groqClient.completeWithTools(
        apiKey: savedGroqKey.trim(),
        prompt: prompt,
        marketContext: marketContext,
        ragSnippets: ragSnippets,
      );

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      final cloudResponse = groqResult.fold<AiCopilotResponse>(
        onSuccess: (groqOutput) => AiCopilotResponse(
          markdownAnswer:
          '**Routing Engine:** `GROQ LPU CLOUD (${groqOutput.modelUsed} • ${elapsed}ms)`\n\n'
              '${groqOutput.markdownContent}',
          executedOn: .cloudApi,
          hardwareSnapshot: health,
          ragMatchedJournalCount: ragSnippets.length,
          inferenceLatencyMs: elapsed,
          toolCall: groqOutput.toolDirective,
        ),
        onFailure: (failure) => AiCopilotResponse(
          markdownAnswer:
          '**Groq Cloud Error:** `${failure.message}`\n\n'
              '*Tip: Tap the Key icon in the Copilot header to verify your `gsk_...` Groq API key.*',
          executedOn: .cloudApi,
          hardwareSnapshot: health,
          ragMatchedJournalCount: ragSnippets.length,
          inferenceLatencyMs: elapsed,
        ),
      );
      return cloudResponse;
    }

    // 5. Otherwise execute Local Edge Isolate Quantitative Pipeline
    final modelSnap = await _modelManager.checkModelStatus();
    final localModelLabel = modelSnap.status == LocalModelStatus.ready
        ? 'GGUF Verified (${LocalModelManager.modelFileName} •${modelSnap.fileSizeMb}MB)'
        : 'Dart Statistical Isolate (Download GGUF above for Neural Weights)';

    final result = await Isolate.run(() {
      return _executeQuantRagPipeline(
        prompt: prompt,
        marketContext: marketContext,
        topRagSnippets: ragSnippets,
        target: target,
        health: health,
        localModelLabel: localModelLabel,
        hasGroqKey: savedGroqKey != null && savedGroqKey.trim().isNotEmpty,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    });

    stopwatch.stop();
    return AiCopilotResponse(
      markdownAnswer: result.markdownAnswer,
      executedOn: result.executedOn,
      hardwareSnapshot: result.hardwareSnapshot,
      ragMatchedJournalCount: result.ragMatchedJournalCount,
      inferenceLatencyMs: math.max(stopwatch.elapsedMilliseconds, 12),
      toolCall: result.toolCall,
    );
  }

  static List<String> _matchRagNotes(
      String prompt,
      String symbol,
      List<String> journalNotes,
      ) {
    final lowerPrompt = prompt.toLowerCase();
    final queryTokens = lowerPrompt
        .split(RegExp(r'\W+'))
        .where((t) => t.length > 2)
        .toSet();

    final matched = <String>[];
    for (final note in journalNotes) {
      final lowerNote = note.toLowerCase();
      if (lowerNote.contains(symbol.toLowerCase()) ||
          queryTokens.any(lowerNote.contains)) {
        matched.add(note);
      }
    }
    return matched.take(3).toList();
  }

  static AiCopilotResponse _executeQuantRagPipeline({
    required String prompt,
    required MarketContextInput marketContext,
    required List<String> topRagSnippets,
    required ComputeTarget target,
    required HardwareHealthSnapshot health,
    required String localModelLabel,
    required bool hasGroqKey,
    required int elapsedMs,
  }) {
    final lowerPrompt = prompt.toLowerCase();
    final closes = marketContext.closePrices;

    final minLow = marketContext.lows.isEmpty
        ? 0.0
        : marketContext.lows.reduce(math.min);
    final maxHigh = marketContext.highs.isEmpty
        ? 0.0
        : marketContext.highs.reduce(math.max);
    final lastClose = closes.isEmpty ? 0.0 : closes.last;
    final firstClose = closes.isEmpty ? 0.0 : closes.first;
    final trendPct = firstClose > 0
        ? ((lastClose - firstClose) / firstClose) * 100
        : 0.0;

    AiToolCallDirective? directive;
    if (lowerPrompt.contains('backtest') ||
        lowerPrompt.contains('optimize') ||
        lowerPrompt.contains('ema') ||
        lowerPrompt.contains('signal')) {
      final fast = trendPct.abs() > 0.15 ? 4 : 6;
      final slow = trendPct.abs() > 0.15 ? 12 : 18;
      directive = TriggerStrategyBacktestDirective(
        fastEma: fast,
        slowEma: slow,
        rationale:
        'Volatility-adjusted EMA($fast/$slow) for${marketContext.symbol}',
      );
    } else {
      final range = maxHigh - minLow;
      directive = PlotSupportResistanceDirective(
        supportPrice: minLow + range * 0.15,
        resistancePrice: maxHigh - range * 0.12,
        regimeLabel: trendPct >= 0 ? 'BULLISH ACCUMULATION' : 'MEAN REVERSION',
      );
    }

    final ragSection = topRagSnippets.isEmpty
        ? '• *No prior SQLite journal entries matched `${marketContext.symbol}` yet. Run a backtest to populate local RAG memory.*'
        : topRagSnippets.map((s) => '• `$s`').join('\n');

    final routingBadge = target == ComputeTarget.edgeIsolate
        ? 'EDGE ISOLATE [$localModelLabel \vert{} Thermal:${health.thermalCondition.name.toUpperCase()}]'
        : 'EDGE FALLBACK (Set Groq API Key in code to enable Groq LPU Cloud!)';

    final toolSummary = switch (directive) {
      PlotSupportResistanceDirective(
          :final supportPrice,
          :final resistancePrice,
          :final regimeLabel,
      ) =>
      'Executed Tool `plot_chart_zones`: Support **${supportPrice.toStringAsFixed(2)}** | Resistance **${resistancePrice.toStringAsFixed(2)}** ($regimeLabel)',
      TriggerStrategyBacktestDirective(
          :final fastEma,
          :final slowEma,
          :final rationale,
      ) =>
      'Executed Tool `run_ema_backtest`: **EMA($fastEma/$slowEma)** —$rationale',
    };

    final answer = '''
**Routing Engine:** `$routingBadge`

**Market Regime (${marketContext.symbol}):**
• Spot Price: **${lastClose.toStringAsFixed(2)}** (${trendPct >= 0 ? '+' : ''}${trendPct.toStringAsFixed(3)}% window drift)
• Key Window Range: **${minLow.toStringAsFixed(2)}** – **${maxHigh.toStringAsFixed(2)}**

**Local SQLite RAG Matches (${topRagSnippets.length} found):**$ragSection

**Agentic Action Dispatched to Canvas:**
→ $toolSummary
''';

    return AiCopilotResponse(
      markdownAnswer: answer.trim(),
      executedOn: target,
      hardwareSnapshot: health,
      ragMatchedJournalCount: topRagSnippets.length,
      inferenceLatencyMs: elapsedMs,
      toolCall: directive,
    );
  }
}
