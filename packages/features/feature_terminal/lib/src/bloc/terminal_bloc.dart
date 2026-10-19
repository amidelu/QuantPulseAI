import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core_network/core_network.dart';
import 'package:equatable/equatable.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

sealed class const TerminalEvent();

final class const TerminalStarted({final String symbol = 'BTCUSDT'}) extends TerminalEvent;

final class const TerminalSymbolsRequested() extends TerminalEvent;

final class const TerminalSymbolChanged(final String symbol) extends TerminalEvent;

enum TerminalStatus { initial, connecting, streaming, failure }

final class const TerminalState({
  final TerminalStatus status = .initial,
  final String activeSymbol = 'BTCUSDT',
  final List<String> availableSymbols = const [
    'BTCUSDT',
    'ETHUSDT',
    'SOLUSDT',
    'BNBUSDT',
    'XRPUSDT',
    'DOGEUSDT',
    'ADAUSDT',
  ],
  final MarketFrameSnapshot? snapshot,
  final String? errorMessage,
}) with Equatable {
  TerminalState copyWith({
    TerminalStatus? status,
    String? activeSymbol,
    List<String>? availableSymbols,
    MarketFrameSnapshot? snapshot,
    String? errorMessage,
  }) => TerminalState(
    status: status ?? this.status,
    activeSymbol: activeSymbol ?? this.activeSymbol,
    availableSymbols: availableSymbols ?? this.availableSymbols,
    snapshot: snapshot ?? this.snapshot,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, activeSymbol, availableSymbols, snapshot, errorMessage];
}

final class TerminalBloc extends Bloc<TerminalEvent, TerminalState> {
  new({required this._streamEngine, this._apiClient}) : super(const TerminalState()) {
    on<TerminalStarted>(_onStarted, transformer: restartable());
    on<TerminalSymbolsRequested>(_onSymbolsRequested);
    on<TerminalSymbolChanged>(_onSymbolChanged);
  }

  final IMarketStreamEngine _streamEngine;
  final IMarketApiClient? _apiClient;

  Future<void> _onSymbolsRequested(
      TerminalSymbolsRequested event,
      Emitter<TerminalState> emit,
      ) async {
    final result = await _apiClient?.fetchActiveUsdtPairs();
    result?.fold(
      onSuccess: (pairs) => emit(state.copyWith(availableSymbols: pairs)),
      onFailure: (_) {}, // Fall back silently to default list
    );
  }

  Future<void> _onStarted(TerminalStarted event, Emitter<TerminalState> emit) async {
    emit(state.copyWith(status: .connecting, activeSymbol: event.symbol));

    final stream = await _streamEngine.connect(symbol: event.symbol);

    await emit.forEach<Result<MarketFrameSnapshot>>(
      stream,
      onData: (result) => result.fold(
        onSuccess: (snapshot) =>
            state.copyWith(status: .streaming, activeSymbol: snapshot.symbol, snapshot: snapshot),
        onFailure: (failure) => state.copyWith(status: .failure, errorMessage: failure.message),
      ),
    );
  }

  void _onSymbolChanged(TerminalSymbolChanged event, Emitter<TerminalState> emit) {
    emit(state.copyWith(status: .connecting, activeSymbol: event.symbol));
    _streamEngine.switchSymbol(event.symbol);
  }

  @override
  Future<void> close() async {
    await _streamEngine.dispose();
    return await super.close();
  }
}
