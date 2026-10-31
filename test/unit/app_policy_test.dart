import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/core/policy/app_policy.dart';

void main() {
  group('versions', () {
    test('parse and compare', () {
      expect(parseAppVersion('0.1.1'), [0, 1, 1]);
      expect(parseAppVersion('0.1.1+4'), [0, 1, 1]);
      expect(parseAppVersion('1.2'), isNull);
      expect(parseAppVersion('x'), isNull);
      expect(parseAppVersion(null), isNull);
      expect(compareAppVersions([0, 1, 0], [0, 1, 1]), lessThan(0));
      expect(compareAppVersions([0, 2, 0], [0, 1, 9]), greaterThan(0));
      expect(compareAppVersions([1, 0, 0], [1, 0, 0]), 0);
    });
  });

  group('AppPolicy', () {
    test('needFor: required beats available, current is none', () {
      final p = AppPolicy.fromJson({
        'min_version': '0.2.0',
        'latest_version': '0.3.0',
        'update_url': 'https://example.org/app',
      })!;
      expect(p.needFor('0.1.1'), UpdateNeed.required);
      expect(p.needFor('0.2.5'), UpdateNeed.available);
      expect(p.needFor('0.3.0'), UpdateNeed.none);
      expect(p.updateUrl.toString(), 'https://example.org/app');
    });

    test('empty policy and bad values never force anything', () {
      final empty = AppPolicy.fromJson(<String, Object?>{})!;
      expect(empty.needFor('0.0.1'), UpdateNeed.none);
      final bad = AppPolicy.fromJson({
        'min_version': 'oops',
        'latest_version': '1',
        'update_url': 'http://insecure.example.org',
      })!;
      expect(bad.needFor('0.0.1'), UpdateNeed.none);
      expect(bad.updateUrl, isNull);
      expect(AppPolicy.fromJson('nope'), isNull);
      expect(AppPolicy.fromJson(null), isNull);
    });

    test('an unparsable app version is never blocked', () {
      final p = AppPolicy.fromJson({'min_version': '9.0.0'})!;
      expect(p.needFor('dev'), UpdateNeed.none);
    });
  });

  group('AppPolicyController', () {
    final uri = Uri.parse('https://api.example.org/v1/app-policy');

    AppPolicyController make(http.Client c, {Uri? endpoint}) =>
        AppPolicyController(
          appVersion: '0.1.1',
          endpoint: endpoint ?? uri,
          client: c,
        );

    test('required policy is applied after refresh', () async {
      final c = make(
        MockClient(
          (r) async => http.Response(
            jsonEncode({'min_version': '0.2.0', 'latest_version': '0.2.0'}),
            200,
          ),
        ),
      );
      expect(c.need, UpdateNeed.none);
      await c.refresh();
      expect(c.need, UpdateNeed.required);
      // Majburiy yangilashni "keyinroq" bilan yopib bo'lmaydi.
      c.dismissSoft();
      expect(c.need, UpdateNeed.required);
    });

    test('available policy can be dismissed', () async {
      final c = make(
        MockClient(
          (r) async => http.Response(jsonEncode({'latest_version': '0.2.0'}), 200),
        ),
      );
      await c.refresh();
      expect(c.need, UpdateNeed.available);
      c.dismissSoft();
      expect(c.need, UpdateNeed.none);
    });

    test('offline, errors and garbage fail open', () async {
      final offline = make(
        MockClient((r) async => throw http.ClientException('offline')),
      );
      await offline.refresh();
      expect(offline.need, UpdateNeed.none);

      final serverError = make(MockClient((r) async => http.Response('x', 500)));
      await serverError.refresh();
      expect(serverError.need, UpdateNeed.none);

      final garbage = make(MockClient((r) async => http.Response('<html>', 200)));
      await garbage.refresh();
      expect(garbage.need, UpdateNeed.none);
    });

    test('no endpoint: nothing is requested', () async {
      var calls = 0;
      final c = AppPolicyController(
        appVersion: '0.1.1',
        endpoint: null,
        client: MockClient((r) async {
          calls++;
          return http.Response('{}', 200);
        }),
      );
      await c.refresh();
      expect(calls, 0);
      expect(c.need, UpdateNeed.none);
    });

    test('a later failure keeps the last known policy', () async {
      var fail = false;
      final c = make(
        MockClient((r) async {
          if (fail) throw http.ClientException('offline');
          return http.Response(jsonEncode({'min_version': '0.2.0'}), 200);
        }),
      );
      await c.refresh();
      fail = true;
      await c.refresh();
      expect(c.need, UpdateNeed.required);
    });
  });
}
