import 'package:flutter/material.dart';

import '../leaderboard/leaderboard_service.dart';
import '../theme/game_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.service});
  final LeaderboardService service;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<ScoreEntry>> _scores = widget.service.topScores();

  void _refresh() => setState(() => _scores = widget.service.topScores());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Leaderboard'),
      actions: [
        IconButton(
          onPressed: widget.service.configured ? _refresh : null,
          tooltip: 'Refresh scores',
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child:
              !widget.service.configured
                  ? _Message(
                    icon: Icons.cloud_off_outlined,
                    title: 'Online scores coming soon',
                    text:
                        'The game works now. Shared scores will appear after the leaderboard backend is connected.',
                  )
                  : FutureBuilder<List<ScoreEntry>>(
                    future: _scores,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData && !snapshot.hasError) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _Message(
                          icon: Icons.wifi_off_rounded,
                          title: 'Could not load scores',
                          text: 'Check your connection and try refresh.',
                        );
                      }
                      final rows = snapshot.data!;
                      if (rows.isEmpty) {
                        return const _Message(
                          icon: Icons.emoji_events_outlined,
                          title: 'Be the first on the board',
                          text: 'Finish a run and post your speed.',
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                        children: [
                          Text(
                            'TOP 20 SPEEDS',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 12),
                          for (final (index, row) in rows.indexed)
                            Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      index < 3
                                          ? GameColors.gold
                                          : GameColors.raised,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          index < 3
                                              ? GameColors.ink
                                              : GameColors.cream,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                title: Text(row.nickname),
                                subtitle: Text(
                                  '${row.createdAt.toLocal().day}/${row.createdAt.toLocal().month}/${row.createdAt.toLocal().year}',
                                ),
                                trailing: Text(
                                  '${row.maxRpm} RPM',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: GameColors.mint),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
        ),
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: GameColors.mint),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 9),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );
}
