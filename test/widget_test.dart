import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Guard requires login, cancellation never opens form', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tapText(tester, 'Tambah Proyek');
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Login then validated authenticated save and logout', (
    tester,
  ) async {
    var creates = 0;
    final api = ApiClient(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/token/')) {
          return http.Response('{"token":"secret"}', 200);
        }
        if (request.url.path.endsWith('/logout/')) {
          return http.Response('', 204);
        }
        creates++;
        expect(request.headers['Authorization'], 'Token secret');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['tech_stack'], 'Flutter');
        expect(body.containsKey('category'), isFalse);
        return http.Response(jsonEncode({...body, 'id': 'new-id'}), 201);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tapText(tester, 'Tambah Proyek');
    await tester.enterText(find.byType(TextFormField).at(0), 'owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tapText(tester, 'Save');
    expect(creates, 0);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Portfolio');
    await tester.enterText(fields.at(1), 'Description');
    await tester.enterText(fields.at(2), 'Flutter');
    await tester.enterText(fields.at(3), 'invalid');
    await tapText(tester, 'Save');
    expect(creates, 0);
    await tester.enterText(fields.at(3), 'https://example.com');
    await tapText(tester, 'Save');
    expect(creates, 1);
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    await tapText(tester, 'OK');
    for (final field in tester.widgetList<EditableText>(
      find.byType(EditableText),
    )) {
      expect(field.controller.text, isEmpty);
    }
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tapText(tester, 'Logout');
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Public list retries errors and opens project details', (
    tester,
  ) async {
    var requests = 0;
    final api = ApiClient(
      client: MockClient((request) async {
        requests++;
        if (requests == 1) return http.Response('error', 500);
        return http.Response(
          jsonEncode([
            {
              'id': 'id',
              'title': 'Project A',
              'description': 'Description',
              'tech_stack': 'Django',
              'project_url': 'https://example.com',
            },
          ]),
          200,
        );
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tapText(tester, 'Lihat Proyek');
    await tapText(tester, 'Retry');
    await tapText(tester, 'Project A');
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Tech Stack: Django'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('Empty list can still be pulled to refresh', (tester) async {
    var requests = 0;
    final api = ApiClient(
      client: MockClient((_) async {
        requests++;
        return http.Response('[]', 200);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tapText(tester, 'Lihat Proyek');
    expect(find.text('No projects found.'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, 400),
    );
    await tester.pumpAndSettle();
    expect(requests, 2);
  });
}
