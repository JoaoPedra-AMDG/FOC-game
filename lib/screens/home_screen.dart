import 'dart:math' as math;

import 'package:flutter/material.dart';

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
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            children: [
              Row(
                children: [
                  Image.asset('web/icons/app-logo.png', width: 34, height: 34),
                  const SizedBox(width: 8),
                  Text(
                    'TORQUE CHASE',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (MediaQuery.sizeOf(context).width > 460) ...[
                    const Spacer(),
                    Text(
                      'FIELD CONTROL GAME',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'CAN YOU\nCONTROL\nTHE MOTOR?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: MediaQuery.sizeOf(context).width < 380 ? 43 : 53,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Keep the magnetic field about 90° ahead of the rotor. The faster it spins, the harder it gets.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: MediaQuery.sizeOf(context).height < 680 ? 220 : 270,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: const MotorPainter(
                            rotorAngle: -math.pi / 5,
                            fieldAngle: math.pi / 3,
                            torqueAngle: math.pi / 3 + math.pi / 5,
                            torque: 0.98,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 18,
                        bottom: 14,
                        child: _HintPill(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: const Text('PLAY  ·  25 SECOND RUN'),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallLink(
                    label: 'How it works',
                    icon: Icons.auto_stories_outlined,
                    onTap: onHow,
                  ),
                  _SmallLink(
                    label: 'Leaderboard',
                    icon: Icons.emoji_events_outlined,
                    onTap: onLeaderboard,
                  ),
                  _SmallLink(
                    label: 'About us',
                    icon: Icons.people_outline,
                    onTap: onAbout,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HintPill extends StatelessWidget {
  const _HintPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: GameColors.ink.withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: GameColors.line),
    ),
    child: const Text(
      'DRAG THE MINT ARROW',
      style: TextStyle(
        color: GameColors.mint,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _SmallLink extends StatelessWidget {
  const _SmallLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 17),
    label: Text(label),
  );
}
