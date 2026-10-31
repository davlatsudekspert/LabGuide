import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/app/update_gate.dart';
import 'package:labguide/core/policy/app_policy.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

AppPolicyController _controller(Map<String, Object?> body) =>
    AppPolicyController(
      appVersion: '0.1.1',
      endpoint: Uri.parse('https://api.example.org/v1/app-policy'),
      client: MockClient((r) async => http.Response(jsonEncode(body), 200)),
    );

Widget _app(AppPolicyController c, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => UpdateGate(controller: c, child: child!),
      home: const Scaffold(body: Text('APP-CONTENT')),
    );

void main() {
  testWidgets('no policy: the app is shown untouched', (tester) async {
    final c = _controller({});
    await tester.pumpWidget(_app(c));
    expect(find.text('APP-CONTENT'), findsOneWidget);
    expect(find.text('Update the app'), findsNothing);
  });

  testWidgets('required: blocking screen replaces the app, link button shown', (
    tester,
  ) async {
    final c = _controller({
      'min_version': '0.2.0',
      'update_url': 'https://example.org/app',
    });
    await tester.runAsync(c.refresh);
    await tester.pumpWidget(_app(c));
    expect(find.text('APP-CONTENT'), findsNothing);
    expect(find.text('Update the app'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
  });

  testWidgets('required without a URL: no button', (tester) async {
    final c = _controller({'min_version': '0.2.0'});
    await tester.runAsync(c.refresh);
    await tester.pumpWidget(_app(c));
    expect(find.text('Update the app'), findsOneWidget);
    expect(find.text('Update'), findsNothing);
  });

  testWidgets('available: banner above the app, "Later" dismisses it', (
    tester,
  ) async {
    final c = _controller({'latest_version': '0.2.0'});
    await tester.runAsync(c.refresh);
    await tester.pumpWidget(_app(c));
    expect(find.text('APP-CONTENT'), findsOneWidget);
    expect(find.text('A new version of the app is available.'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await tester.pump();
    expect(find.text('A new version of the app is available.'), findsNothing);
    expect(find.text('APP-CONTENT'), findsOneWidget);
  });

  // uz / ru uchun Material delegatlari testda yo'q: Flutter "locale not supported" ogohlantirishini
  // istisno sifatida beradi — har testda bitta pump, ogohlantirish takeException bilan olinadi.
  testWidgets('Uzbek text', (tester) async {
    final c = _controller({'min_version': '0.2.0'});
    await tester.runAsync(c.refresh);
    await tester.pumpWidget(_app(c, locale: const Locale('uz')));
    tester.takeException();
    expect(find.text('Ilovani yangilang'), findsOneWidget);
  });

  testWidgets('Russian text', (tester) async {
    final c = _controller({'min_version': '0.2.0'});
    await tester.runAsync(c.refresh);
    await tester.pumpWidget(_app(c, locale: const Locale('ru')));
    tester.takeException();
    expect(find.text('Обновите приложение'), findsOneWidget);
  });
}
