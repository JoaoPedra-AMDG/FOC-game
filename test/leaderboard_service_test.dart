import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:torque_chase/leaderboard/leaderboard_service.dart';

void main() {
  test('reads shared top scores through the public Data API', () async {
    final service = LeaderboardService(
      url: 'https://demo.supabase.co',
      publishableKey: 'sb_publishable_example',
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/rest/v1/torque_chase_scores');
        expect(request.url.queryParameters['limit'], '20');
        expect(
          request.url.queryParameters['order'],
          'max_rpm.desc,created_at.asc',
        );
        expect(request.headers['apikey'], 'sb_publishable_example');
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response(
          jsonEncode([
            {
              'nickname': 'Ace',
              'max_rpm': 123,
              'created_at': '2026-10-10T12:00:00Z',
            },
          ]),
          200,
        );
      }),
    );
    addTearDown(service.dispose);

    final scores = await service.topScores();
    expect(scores.single.nickname, 'Ace');
    expect(scores.single.maxRpm, 123);
  });

  test('submits a validated score without privileged credentials', () async {
    final service = LeaderboardService(
      url: 'https://demo.supabase.co',
      publishableKey: 'sb_publishable_example',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['apikey'], 'sb_publishable_example');
        expect(jsonDecode(request.body), {'nickname': 'Ace', 'max_rpm': 123});
        return http.Response('', 201);
      }),
    );
    addTearDown(service.dispose);

    await service.submit(' Ace ', 122.7);
    expect(LeaderboardService.validateNickname('<script>'), isNotNull);
  });
}
