import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../leaderboard/leaderboard_service.dart';
import '../theme/game_theme.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.controller,
    required this.service,
    required this.onPlayAgain,
    required this.onHome,
    required this.onHow,
    required this.onLeaderboard,
  });

  final GameController controller;
  final LeaderboardService service;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;
  final VoidCallback onHow;
  final VoidCallback onLeaderboard;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _nickname = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  int? _rank;
  String? _error;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = LeaderboardService.validateNickname(_nickname.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.service.submit(
        _nickname.text,
        widget.controller.maxAbsoluteRpm,
      );
      if (!mounted) return;
      setState(() => _sent = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not post score. Please try again.');
      return;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    try {
      final scores = await widget.service.topScores();
      final score = widget.controller.maxAbsoluteRpm.round();
      final index = scores.indexWhere((row) => row.maxRpm <= score);
      if (mounted && index >= 0) setState(() => _rank = index + 1);
    } catch (_) {
      // The score was posted; ranking can still be viewed later.
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 590),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
            children: [
              Row(
                children: [
                  Text(
                    'RUN COMPLETE',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onHome,
                    tooltip: 'Home',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.emoji_events_rounded,
                size: 72,
                color: GameColors.gold,
              ),
              const SizedBox(height: 18),
              Text(
                'MAX MOTOR SPEED',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.controller.maxAbsoluteRpm.round()}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 82,
                  color: GameColors.mint,
                ),
              ),
              Text(
                'RPM',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 14),
              Text(
                'Average forward torque: ${widget.controller.torqueControlPercent.round()}%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              if (widget.service.configured)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child:
                        _sent
                            ? Column(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: GameColors.mint,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _rank == null
                                      ? 'Score posted!'
                                      : 'Score posted · #$_rank on the board',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Claim your place',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 11),
                                TextField(
                                  controller: _nickname,
                                  maxLength: 16,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintText: 'Your nickname',
                                    errorText: _error,
                                    counterText: '',
                                  ),
                                  onSubmitted:
                                      (_) => _sending ? null : _submit(),
                                ),
                                const SizedBox(height: 11),
                                FilledButton(
                                  onPressed: _sending ? null : _submit,
                                  child: Text(
                                    _sending ? 'POSTING…' : 'POST SCORE',
                                  ),
                                ),
                              ],
                            ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'Shared scores are not connected yet. You can still play again and beat this speed.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: widget.onPlayAgain,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('PLAY AGAIN'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: widget.onLeaderboard,
                icon: const Icon(Icons.leaderboard_outlined),
                label: const Text('LEADERBOARD'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: widget.onHow,
                child: const Text('HOW DOES THIS WORK?'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
