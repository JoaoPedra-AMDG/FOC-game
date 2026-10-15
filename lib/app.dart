import 'package:flutter/material.dart';

import 'game/game_controller.dart';
import 'leaderboard/leaderboard_service.dart';
import 'screens/about_screen.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/how_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/results_screen.dart';
import 'theme/game_theme.dart';

class TorqueChaseApp extends StatelessWidget {
  const TorqueChaseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FOC FAST',
    debugShowCheckedModeBanner: false,
    theme: gameTheme(),
    home: const _AppShell(),
  );
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  late final GameController _game = GameController();
  late final LeaderboardService _leaderboard = LeaderboardService();
  GamePhase _phase = GamePhase.home;

  @override
  void initState() {
    super.initState();
    _game.addListener(_onGameChanged);
  }

  void _onGameChanged() {
    if (_phase != _game.phase) setState(() => _phase = _game.phase);
  }

  void _show(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  void dispose() {
    _game.removeListener(_onGameChanged);
    _game.dispose();
    _leaderboard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch (_phase) {
    GamePhase.home => HomeScreen(
      onPlay: () => _game.start(),
      onSensorlessPlay: () => _game.start(sensorless: true),
      onHow: () => _show(const HowScreen()),
      onLeaderboard: () => _show(LeaderboardScreen(service: _leaderboard)),
      onAbout: () => _show(const AboutScreen()),
    ),
    GamePhase.countdown ||
    GamePhase.playing => GameScreen(controller: _game, onExit: _game.home),
    GamePhase.results => ResultsScreen(
      controller: _game,
      service: _leaderboard,
      onPlayAgain: () => _game.start(sensorless: _game.sensorlessMode),
      onHome: _game.home,
      onHow: () => _show(const HowScreen()),
      onLeaderboard: () => _show(LeaderboardScreen(service: _leaderboard)),
    ),
  };
}
