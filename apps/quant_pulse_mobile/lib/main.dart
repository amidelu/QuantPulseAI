import 'package:feature_terminal/feature_terminal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_stream_engine/market_stream_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuantPulseApp());
}

final class QuantPulseApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantPulse AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: BlocProvider(
        create: (_) =>
            TerminalBloc(streamEngine: MarketStreamEngine())..add(const TerminalStarted()),
        child: const TerminalScreen(),
      ),
    );
  }
}
