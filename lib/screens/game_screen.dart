import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../theme/game_theme.dart';
import '../widgets/kart_track.dart';
import '../widgets/motor_painter.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.controller, required this.onExit});

  final GameController controller;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: AnimatedBuilder(
            animation: controller,
            builder:
                (context, _) => LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 660;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Exit run',
                                onPressed: onExit,
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                              Text(
                                'TORQUE CHASE',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const Spacer(),
                              Text(
                                '${controller.timeLeft.ceil()}s LEFT',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: GameColors.gold),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            height: compact ? 65 : 84,
                            child: KartTrack(
                              distance: controller.trackDistance,
                              rpm: controller.motor.rpm,
                            ),
                          ),
                          const SizedBox(height: 9),
                          _SpeedReadout(
                            controller: controller,
                            compact: compact,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: _MotorControl(controller: controller),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            controller.phase == GamePhase.countdown
                                ? 'Get ready — drag the mint field arrow'
                                : 'Drag around the motor · Aim 90° ahead of the rotor',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontSize: compact ? 12 : 14),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ),
      ),
    ),
  );
}

class _SpeedReadout extends StatelessWidget {
  const _SpeedReadout({required this.controller, required this.compact});
  final GameController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rpm = controller.motor.rpm;
    final torque = controller.motor.normalizedTorque;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MOTOR SPEED',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                '${rpm.round()} RPM',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: compact ? 31 : 39,
                ),
              ),
              Text(
                'BEST  ${controller.maxAbsoluteRpm.round()} RPM',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameColors.gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ANGLE  ${(controller.motor.torqueAngle * 180 / math.pi).round()}°',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'TORQUE  ${torque >= 0 ? '+' : ''}${(torque * 100).round()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: torque >= 0 ? GameColors.mint : GameColors.coral,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ],
    );
  }
}

class _MotorControl extends StatelessWidget {
  const _MotorControl({required this.controller});
  final GameController controller;

  void _move(Offset position, Size size) {
    final delta = position - Offset(size.width / 2, size.height / 2);
    if (delta.distance < 12) return;
    controller.setFieldAngle(math.atan2(delta.dy, delta.dx));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      return GestureDetector(
        key: const Key('motor-control'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (event) => _move(event.localPosition, size),
        onPanStart: (event) => _move(event.localPosition, size),
        onPanUpdate: (event) => _move(event.localPosition, size),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                painter: MotorPainter(
                  rotorAngle: controller.motor.rotorAngle,
                  fieldAngle: controller.motor.fieldAngle,
                  torqueAngle: controller.motor.torqueAngle,
                  torque: controller.motor.normalizedTorque,
                ),
              ),
            ),
            if (controller.phase == GamePhase.countdown ||
                (controller.phase == GamePhase.playing &&
                    controller.timeLeft > 24.45))
              IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: GameColors.ink.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: GameColors.mint),
                    ),
                    child: Text(
                      controller.phase == GamePhase.countdown
                          ? '${controller.countdownLeft.ceil()}'
                          : 'GO!',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: GameColors.mint,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
