import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../content/home_copy.dart';
import '../theme/game_theme.dart';
import '../widgets/motor_painter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onPlay,
    required this.onHow,
    required this.onLeaderboard,
    required this.onAbout,
  });

  final VoidCallback onPlay;
  final VoidCallback onHow;
  final VoidCallback onLeaderboard;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF58305F),
                      Color(0xFF242461),
                      Color(0xFF101438),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FOURTH-YEAR INVESTIGATION · FIELD-ORIENTED CONTROL',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFF4B9DE),
                        fontSize: 10,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      HomeCopy.brand,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 42,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      HomeCopy.headline,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: GameColors.cream),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      HomeCopy.introduction,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0D0D2A),
                  border: Border(bottom: BorderSide(color: GameColors.line)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Tab(
                        label: 'PLAY THE GAME',
                        selected: true,
                        onTap: onPlay,
                      ),
                      _Tab(label: 'HOW IT WORKS', onTap: onHow),
                      _Tab(label: 'TOP SCORES', onTap: onLeaderboard),
                      _Tab(
                        key: const Key('home-about'),
                        label: 'ABOUT US',
                        onTap: onAbout,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'THE GAME',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: GameColors.coral),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'TAKE CONTROL OF THE FIELD',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Drag the stator field a quarter turn ahead of the rotor. Hold it there to accelerate; fall behind and the motor brakes.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 230,
                          decoration: BoxDecoration(
                            color: GameColors.ink,
                            border: Border.all(color: const Color(0xFF353B79)),
                          ),
                          child: CustomPaint(
                            painter: const MotorPainter(
                              rotorAngle: -math.pi / 5,
                              fieldAngle: math.pi / 3,
                              torqueAngle: math.pi / 3 + math.pi / 5,
                              torque: 0.98,
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),
                        FilledButton.icon(
                          key: const Key('home-play'),
                          onPressed: onPlay,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(HomeCopy.play),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      foregroundColor: selected ? GameColors.cream : GameColors.muted,
      backgroundColor: selected ? GameColors.raised : Colors.transparent,
      shape: const RoundedRectangleBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    ),
  );
}
