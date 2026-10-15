import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../content/home_copy.dart';
import '../theme/game_theme.dart';
import '../widgets/motor_painter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onPlay,
    required this.onSensorlessPlay,
    required this.onHow,
    required this.onLeaderboard,
    required this.onAbout,
  });

  final VoidCallback onPlay;
  final VoidCallback onSensorlessPlay;
  final VoidCallback onHow;
  final VoidCallback onLeaderboard;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, 0.15),
          radius: 1.15,
          colors: [Color(0xFF4569A5), Color(0xFF284778), GameColors.ink],
          stops: [0, 0.52, 1],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: GameColors.gold,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GameColors.cream, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF11284D),
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: GameColors.panel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      HomeCopy.brand,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(
                            color: Color(0xFF12264C),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF385A92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameColors.line),
                      ),
                      child: Text(
                        HomeCopy.subject,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: GameColors.cream,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  HomeCopy.eyebrow,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: GameColors.gold,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  HomeCopy.headline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: MediaQuery.sizeOf(context).width < 390 ? 32 : 37,
                    height: 1.02,
                    shadows: const [
                      Shadow(color: Color(0xFF142A55), offset: Offset(0, 3)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  HomeCopy.introduction,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 275,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFF5B7FB9), Color(0xFF36588F)],
                          ),
                          border: Border.all(
                            color: const Color(0xFF9FB7D9),
                            width: 8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF142B55),
                              spreadRadius: 6,
                            ),
                            BoxShadow(
                              color: Color(0x550D1A38),
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 218,
                        height: 218,
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
                        top: 24,
                        left: 28,
                        child: Icon(
                          Icons.auto_awesome,
                          color: GameColors.gold,
                          size: 22,
                        ),
                      ),
                      const Positioned(
                        bottom: 22,
                        right: 30,
                        child: Icon(
                          Icons.auto_awesome,
                          color: GameColors.gold,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                FilledButton.icon(
                  key: const Key('home-play'),
                  onPressed: onPlay,
                  icon: const Icon(Icons.bolt_rounded, size: 24),
                  label: Text(HomeCopy.play),
                ),
                const SizedBox(height: 9),
                OutlinedButton.icon(
                  key: const Key('home-sensorless'),
                  onPressed: onSensorlessPlay,
                  icon: const Icon(Icons.visibility_off_outlined, size: 22),
                  label: const Text(HomeCopy.sensorlessPlay),
                ),
                const SizedBox(height: 7),
                Text(
                  HomeCopy.sensorlessHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 19),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SmallLink(
                      label: HomeCopy.how,
                      icon: Icons.auto_stories_outlined,
                      onTap: onHow,
                    ),
                    _SmallLink(
                      label: HomeCopy.leaderboard,
                      icon: Icons.emoji_events_outlined,
                      onTap: onLeaderboard,
                    ),
                    _SmallLink(
                      key: const Key('home-about'),
                      label: HomeCopy.about,
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
    ),
  );
}

class _SmallLink extends StatelessWidget {
  const _SmallLink({
    super.key,
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
    icon: Icon(icon, size: 16),
    label: Text(
      label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}
