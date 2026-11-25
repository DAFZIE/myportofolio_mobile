import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

void main() {
  const project = Project(
    id: 'server-id',
    title: 'Portfolio',
    description: 'Description',
    techStack: 'Flutter',
    projectUrl: 'https://example.com',
  );

  test('JSON uses API keys, excludes id and defaults optional image', () {
    final json = project.toJson();
    expect(json.containsKey('id'), isFalse);
    expect(json['tech_stack'], 'Flutter');
    json.remove('project_image_url');
    expect(Project.fromJson(json).projectImageUrl, '');
    json['project_image_url'] = null;
    expect(Project.fromJson(json).projectImageUrl, '');
  });

  test('Public GET and authenticated POST use correct API contract', () async {
    final client = ApiClient(
      baseUrl: 'https://example.com/',
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/projects/');
        if (request.method == 'GET') {
          expect(request.headers.containsKey('Authorization'), isFalse);
          return http.Response(jsonEncode([project.toJson()]), 200);
        }
        expect(request.headers['Authorization'], 'Token secret');
        expect(jsonDecode(request.body), project.toJson());
        return http.Response(
          jsonEncode({...project.toJson(), 'id': 'new-id'}),
          201,
        );
      }),
    );
    expect((await client.getProjects()).single.title, 'Portfolio');
    expect((await client.createProject(project, token: 'secret')).id, 'new-id');
    client.close();
  });

  test(
    'Login notifies; logout sends token and clears memory on network failure',
    () async {
      final client = ApiClient(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/token/')) {
            expect(jsonDecode(request.body), {
              'username': 'owner',
              'password': 'password',
            });
            return http.Response('{"token":"secret"}', 200);
          }
          expect(request.headers['Authorization'], 'Token secret');
          throw http.ClientException('offline');
        }),
      );
      final auth = AuthState(client);
      var notifications = 0;
      auth.addListener(() => notifications++);
      await auth.login('owner', 'password');
      expect(auth.isLoggedIn, isTrue);
      await expectLater(auth.logout(), throwsA(isA<http.ClientException>()));
      expect(auth.token, isNull);
      expect(notifications, 2);
      auth.dispose();
      client.close();
    },
  );

  test(
    '204 logout needs no JSON; API errors never expose debug bodies',
    () async {
      final client = ApiClient(
        client: MockClient(
          (request) async => request.url.path.endsWith('/logout/')
              ? http.Response('', 204)
              : http.Response('<html>SECRET DEBUG</html>', 401),
        ),
      );
      await client.logout(token: 'secret');
      await expectLater(
        client.getProjects(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 401)
              .having(
                (e) => e.message.contains('SECRET'),
                'safe message',
                isFalse,
              ),
        ),
      );
      client.close();
    },
  );
}
