import 'package:flutter/material.dart';

import '../theme/game_theme.dart';

class HowScreen extends StatelessWidget {
  const HowScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('How it works')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text('THE IDEA', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 10),
              Text(
                'You are the controller.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The rotor contains permanent magnets. Current in the stationary coils makes another magnetic field. Drag the yellow arrow to choose where that stator field points.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              const _IdeaCard(
                icon: Icons.rotate_right_rounded,
                title: 'Aim ahead',
                text:
                    'About 90° ahead of the rotor gives the strongest forward push in this game.',
                color: GameColors.mint,
              ),
              const _IdeaCard(
                icon: Icons.pause_circle_outline_rounded,
                title: 'A field in line gives no push',
                text:
                    'At 0°, the magnets line up but produce almost no turning force.',
                color: GameColors.gold,
              ),
              const _IdeaCard(
                icon: Icons.keyboard_double_arrow_left_rounded,
                title: 'Wrong side? You brake.',
                text:
                    'A negative angle produces reverse torque. The rotor can slow, stop, and spin backwards.',
                color: GameColors.coral,
              ),
              const SizedBox(height: 22),
              Text(
                'WHY POSITION MATTERS',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'As the rotor speeds up, its magnetic axis moves faster. A real field-oriented controller continuously tracks that position and turns the stator field for you. Your finger is doing that job manually.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              Text(
                'THE INVESTIGATION',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Our university investigation compares sensored FOC, sensorless FOC, and sensored trapezoidal control on a permanent magnet synchronous machine. A sensored controller measures rotor position with a physical sensor. A sensorless controller estimates rotor state from electrical measurements and a model.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'This game simplifies motor physics on purpose. Its sinusoidal torque model teaches field orientation; it is not a complete PMSM or FOC simulation.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Engineering explanation'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    'We use T = Tₘₐₓ sin(δ), where δ is the signed field angle relative to the rotor. Then J·dω/dt = T − viscous drag − dry friction. Angular velocity changes the rotor angle. A real drive additionally measures or estimates phase currents, transforms coordinates, and regulates current with feedback.',
                    style: Theme.of(context).textTheme.bodyMedium,
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

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
