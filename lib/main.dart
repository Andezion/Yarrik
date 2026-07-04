import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state_provider.dart';
import 'screens/app_shell.dart';
import 'themes/app_theme.dart';
import 'widgets/animated_background.dart';
import 'widgets/splash_screen.dart';

void main() {
  runApp(const ArmforgeApp());
}

class ArmforgeApp extends StatelessWidget {
  const ArmforgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: MaterialApp(
        title: 'ARMFORGE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _RootGate(),
      ),
    );
  }
}

class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final provider = context.read<AppStateProvider>();
    await Future.wait([
      provider.load(),
      Future.delayed(const Duration(milliseconds: 700)),
    ]);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _ready ? const AppShell() : const SplashScreen(key: ValueKey('splash')),
      ),
    );
  }
}
