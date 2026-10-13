import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/game_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const projectUrl =
      'https://dsl-masters-interest.netlify.app/projects/group-01/';
  static const dashboardUrl =
      'https://oryonchoonoo.github.io/Simulation_Display/';

  Future<void> _open(BuildContext context, String name) async {
    final link = Uri.parse('$projectUrl#:~:text=${Uri.encodeComponent(name)}');
    var opened = false;
    try {
      opened = await launchUrl(link, webOnlyWindowName: '_blank');
      if (!opened) {
        opened = await launchUrl(link, webOnlyWindowName: '_self');
      }
    } catch (_) {
      // Show a useful message if the browser refuses both routes.
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the DSL profile page.')),
      );
    }
  }

  Future<void> _openDashboard(BuildContext context) async {
    final link = Uri.parse(dashboardUrl);
    var opened = false;
    try {
      opened = await launchUrl(link, webOnlyWindowName: '_blank');
      if (!opened) {
        opened = await launchUrl(link, webOnlyWindowName: '_self');
      }
    } catch (_) {
      // Show a useful message if the browser refuses both routes.
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the full dashboard.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About us')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Image.asset('web/favicon.png', width: 78, height: 78),
              const SizedBox(height: 14),
              Text(
                'Meet the team',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Joao and Oryon are investigating control methods for a permanent magnet synchronous machine. Read their Digital Smart Lab profiles and learn more about the Group 01 project.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              Card(
                key: const Key('about-dashboard'),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: GameColors.raised,
                    child: Icon(
                      Icons.dashboard_customize_rounded,
                      color: GameColors.mint,
                    ),
                  ),
                  title: const Text('Open the full investigation dashboard'),
                  subtitle: const Text(
                    'Explore the dynamometer, FOC animations, simulation results and measured comparisons.',
                  ),
                  trailing: const Icon(
                    Icons.open_in_new_rounded,
                    color: GameColors.mint,
                  ),
                  onTap: () => _openDashboard(context),
                ),
              ),
              const SizedBox(height: 26),
              _ProfileCard(
                name: 'Joao Pedra',
                initials: 'JP',
                onTap: () => _open(context, 'Joao Pedra'),
              ),
              _ProfileCard(
                name: 'Oryon Choonoo',
                initials: 'OC',
                onTap: () => _open(context, 'Oryon Choonoo'),
              ),
              const SizedBox(height: 13),
              Text(
                'Both profiles are on the same Group 01 page. Each link jumps to the selected name when the browser supports text fragments.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.initials,
    required this.onTap,
  });
  final String name;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: GameColors.raised,
        child: Text(
          initials,
          style: const TextStyle(
            color: GameColors.mint,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      title: Text(name, style: Theme.of(context).textTheme.titleLarge),
      subtitle: const Text('View profile on Digital Smart Lab'),
      trailing: const Icon(Icons.open_in_new_rounded, color: GameColors.mint),
      onTap: onTap,
    ),
  );
}
