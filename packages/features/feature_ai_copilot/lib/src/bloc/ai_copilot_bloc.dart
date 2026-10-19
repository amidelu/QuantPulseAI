import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hybrid_ai_engine/hybrid_ai_engine.dart';

sealed class const AiCopilotEvent();

final class const AiCopilotInitialized() extends AiCopilotEvent;

final class const AiPromptSubmitted({
  required final String prompt,
  required final MarketContextInput marketContext,
}) extends AiCopilotEvent;

final class const AiThermalSimulationChanged(
    final ThermalCondition condition,
    ) extends AiCopilotEvent;

final class const AiLocalModelDownloadRequested() extends AiCopilotEvent;

final class const AiLocalModelDownloadCancelled() extends AiCopilotEvent;

final class const _AiDownloadProgressUpdated({
  required final double progress,
  required final int receivedMb,
  required final int totalMb,
}) extends AiCopilotEvent;

final class const ChatMessage({
  required final bool isUser,
  required final String text,
  final ComputeTarget? target,
  final int? latencyMs,
  final int? ragCount,
}) with Equatable {
  @override
  List<Object?> get props => [isUser, text, target, latencyMs, ragCount];
}

final class const AiCopilotState({
  final bool isThinking = false,
  final ThermalCondition simulatedThermal = .serious,
  final LocalModelStateSnapshot modelSnapshot = const LocalModelStateSnapshot(),
  final int downloadedMb = 0,
  final int totalDownloadMb = 0,
  final List<ChatMessage> messages = const [],
  final AiToolCallDirective? lastDirective,
}) with Equatable {
  AiCopilotState copyWith({
    bool? isThinking,
    ThermalCondition? simulatedThermal,
    LocalModelStateSnapshot? modelSnapshot,
    int? downloadedMb,
    int? totalDownloadMb,
    List<ChatMessage>? messages,
    AiToolCallDirective? lastDirective,
  }) => AiCopilotState(
    isThinking: isThinking ?? this.isThinking,
    simulatedThermal: simulatedThermal ?? this.simulatedThermal,
    modelSnapshot: modelSnapshot ?? this.modelSnapshot,
    downloadedMb: downloadedMb ?? this.downloadedMb,
    totalDownloadMb: totalDownloadMb ?? this.totalDownloadMb,
    messages: messages ?? this.messages,
    lastDirective: lastDirective ?? this.lastDirective,
  );

  @override
  List<Object?> get props => [
    isThinking,
    simulatedThermal,
    modelSnapshot,
    downloadedMb,
    totalDownloadMb,
    messages,
    lastDirective,
  ];
}

final class AiCopilotBloc extends Bloc<AiCopilotEvent, AiCopilotState> {
  new({required this._engine})
      : super(const AiCopilotState()) {
    on<AiCopilotInitialized>(_onInitialized);
    on<AiPromptSubmitted>(_onPromptSubmitted);
    on<AiThermalSimulationChanged>(_onThermalChanged);
    on<AiLocalModelDownloadRequested>(_onDownloadRequested);
    on<AiLocalModelDownloadCancelled>(_onDownloadCancelled);
    on<_AiDownloadProgressUpdated>(_onProgressUpdated);
  }

  final HybridAiCopilotEngine _engine;

  Future<void> _onInitialized(
      AiCopilotInitialized event,
      Emitter<AiCopilotState> emit,
      ) async {
    final status = await _engine.modelManager.checkModelStatus();
    emit(state.copyWith(modelSnapshot: status));
  }

  void _onThermalChanged(
      AiThermalSimulationChanged event,
      Emitter<AiCopilotState> emit,
      ) {
    _engine.telemetryBridge.setSimulatedThermalState(event.condition);
    emit(state.copyWith(simulatedThermal: event.condition));
  }

  Future<void> _onDownloadRequested(
      AiLocalModelDownloadRequested event,
      Emitter<AiCopilotState> emit,
      ) async {
    emit(
      state.copyWith(
        modelSnapshot: const LocalModelStateSnapshot(status: .downloading),
        downloadedMb: 0,
      ),
    );

    final finalStatus = await _engine.modelManager.downloadModel(
      onProgress: (progress, receivedMb, totalMb) {
        if (!isClosed) {
          add(
            _AiDownloadProgressUpdated(
              progress: progress,
              receivedMb: receivedMb,
              totalMb: totalMb,
            ),
          );
        }
      },
    );

    emit(state.copyWith(modelSnapshot: finalStatus));
  }

  void _onDownloadCancelled(
      AiLocalModelDownloadCancelled event,
      Emitter<AiCopilotState> emit,
      ) {
    _engine.modelManager.cancelDownload();
    emit(
      state.copyWith(
        modelSnapshot: const LocalModelStateSnapshot(),
        downloadedMb: 0,
      ),
    );
  }

  void _onProgressUpdated(
      _AiDownloadProgressUpdated event,
      Emitter<AiCopilotState> emit,
      ) {
    emit(
      state.copyWith(
        modelSnapshot: LocalModelStateSnapshot(
          status: .downloading,
          progress: event.progress,
        ),
        downloadedMb: event.receivedMb,
        totalDownloadMb: event.totalMb,
      ),
    );
  }

  Future<void> _onPromptSubmitted(
      AiPromptSubmitted event,
      Emitter<AiCopilotState> emit,
      ) async {
    final updated = [
      ...state.messages,
      ChatMessage(isUser: true, text: event.prompt),
    ];
    emit(state.copyWith(isThinking: true, messages: updated));

    final response = await _engine.askCopilot(
      prompt: event.prompt,
      marketContext: event.marketContext,
    );

    emit(
      state.copyWith(
        isThinking: false,
        lastDirective: response.toolCall,
        messages: [
          ...updated,
          ChatMessage(
            isUser: false,
            text: response.markdownAnswer,
            target: response.executedOn,
            latencyMs: response.inferenceLatencyMs,
            ragCount: response.ragMatchedJournalCount,
          ),
        ],
      ),
    );
  }
}
