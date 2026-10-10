import 'dart:convert';

import 'package:http/http.dart' as http;

class ScoreEntry {
  const ScoreEntry({
    required this.nickname,
    required this.maxRpm,
    required this.createdAt,
  });

  final String nickname;
  final int maxRpm;
  final DateTime createdAt;

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    nickname: json['nickname'] as String,
    maxRpm: json['max_rpm'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class LeaderboardService {
  LeaderboardService({http.Client? client, String? url, String? publishableKey})
    : _client = client ?? http.Client(),
      _url = url ?? const String.fromEnvironment('SUPABASE_URL'),
      _publishableKey =
          publishableKey ??
          const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  final http.Client _client;
  final String _url;
  final String _publishableKey;

  bool get configured => _url.isNotEmpty && _publishableKey.isNotEmpty;

  Uri get _endpoint => Uri.parse(
    '${_url.replaceFirst(RegExp(r"/+$"), "")}/rest/v1/torque_chase_scores',
  );

  Map<String, String> get _headers => {
    'apikey': _publishableKey,
    'Content-Type': 'application/json',
  };

  static String? validateNickname(String value) {
    final name = value.trim();
    if (name.length < 2 || name.length > 16) {
      return 'Use 2–16 characters.';
    }
    if (!RegExp(r'^[A-Za-z0-9 _-]+$').hasMatch(name)) {
      return 'Use letters, numbers, spaces, _ or -.';
    }
    return null;
  }

  Future<List<ScoreEntry>> topScores() async {
    if (!configured) return [];
    final uri = _endpoint.replace(
      queryParameters: {
        'select': 'nickname,max_rpm,created_at',
        'order': 'max_rpm.desc,created_at.asc',
        'limit': '20',
      },
    );
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw StateError('Leaderboard unavailable (${response.statusCode}).');
    }
    final rows = jsonDecode(response.body) as List<dynamic>;
    return rows
        .map((row) => ScoreEntry.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> submit(String nickname, double rpm) async {
    if (!configured) throw StateError('Leaderboard is not configured yet.');
    final error = validateNickname(nickname);
    if (error != null) throw ArgumentError(error);
    final score = rpm.round();
    if (score < 0 || score > 10000) {
      throw ArgumentError('The score is outside the supported range.');
    }
    final response = await _client.post(
      _endpoint,
      headers: {..._headers, 'Prefer': 'return=minimal'},
      body: jsonEncode({'nickname': nickname.trim(), 'max_rpm': score}),
    );
    if (response.statusCode != 201) {
      throw StateError('Could not submit score (${response.statusCode}).');
    }
  }

  void dispose() => _client.close();
}
