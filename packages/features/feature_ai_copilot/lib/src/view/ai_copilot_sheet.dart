import 'package:feature_ai_copilot/src/bloc/ai_copilot_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hybrid_ai_engine/hybrid_ai_engine.dart';

final class AiCopilotBottomSheet extends StatefulWidget {
  const new({
    required this.marketContext,
    super.key,
  });

  final MarketContextInput marketContext;

  @override
  State<AiCopilotBottomSheet> createState() => _AiCopilotBottomSheetState();
}

final class _AiCopilotBottomSheetState extends State<AiCopilotBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AiCopilotBloc>().add(const AiCopilotInitialized());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    context.read<AiCopilotBloc>().add(
      AiPromptSubmitted(
        prompt: text.trim(),
        marketContext: widget.marketContext,
      ),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 580,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavigationBarHeight),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1420),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocBuilder<AiCopilotBloc, AiCopilotState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'HYBRID EDGE-AI QUANT COPILOT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: .bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<ThermalCondition>(
                    value: state.simulatedThermal,
                    dropdownColor: const Color(0xFF1A2130),
                    underline: const SizedBox.shrink(),
                    style: const TextStyle(
                      color: Color(0xFF40C4FF),
                      fontSize: 12,
                      fontWeight: .w600,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ThermalCondition.nominal,
                        child: Text('Mode: EDGE ISOLATE'),
                      ),
                      DropdownMenuItem(
                        value: ThermalCondition.serious,
                        child: Text('Mode: CLOUD'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        context.read<AiCopilotBloc>().add(
                          AiThermalSimulationChanged(val),
                        );
                      }
                    },
                  ),
                ],
              ),
              if (state.simulatedThermal == .nominal) ...[
                const SizedBox(height: 6),
                _EdgeModelStatusCard(state: state),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Plot Support & Resistance on Chart'),
                    onPressed: () => _submit(
                      'Analyze market regime and plot support and resistance zones',
                    ),
                  ),
                  ActionChip(
                    label: const Text('Auto-Backtest Best EMA + RAG Journal'),
                    onPressed: () => _submit(
                      'Optimize and backtest EMA crossover signals and search my SQLite journal',
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF1E2638), height: 18),
              Expanded(
                child: state.messages.isEmpty
                    ? const Center(
                  child: Text(
                    'Switch between Groq Cloud LPU and On-Device GGUF Edge Isolate in the top right.',
                    textAlign: .center,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                )
                    : ListView.builder(
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? const Color(0xFF1E3A5F)
                              : const Color(0xFF171E2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Ask Copilot to analyze ${widget.marketContext.symbol}...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF171E2E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _submit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: state.isThinking
                        ? null
                        : () => _submit(_controller.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _EdgeModelStatusCard extends StatelessWidget {
  const new({required this.state});

  final AiCopilotState state;

  @override
  Widget build(BuildContext context) {
    final snap = state.modelSnapshot;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171E2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF26324B)),
      ),
      child: switch (snap.status) {
        LocalModelStatus.notDownloaded || LocalModelStatus.error => Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Expanded(
              child: Text(
                snap.errorMessage ??
                    'On-Device Model: Qwen2.5-0.5B-GGUF (Not downloaded)',
                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.read<AiCopilotBloc>().add(
                const AiLocalModelDownloadRequested(),
              ),
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Download GGUF', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        LocalModelStatus.downloading => Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Downloading Qwen2.5-0.5B GGUF... '
                      '(${state.downloadedMb} / ${state.totalDownloadMb} MB)',
                  style: const TextStyle(color: Color(0xFF40C4FF), fontSize: 11.5),
                ),
                TextButton(
                  onPressed: () => context.read<AiCopilotBloc>().add(
                    const AiLocalModelDownloadCancelled(),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            LinearProgressIndicator(value: snap.progress),
          ],
        ),
        LocalModelStatus.ready => Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'GGUF Ready on Disk (${snap.fileSizeMb} MB • Magic Header Verified)',
                style: const TextStyle(color: Color(0xFF00E676), fontSize: 11.5),
              ),
            ),
          ],
        ),
      },
    );
  }
}
