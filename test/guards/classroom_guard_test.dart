// Qorovul (guard) testlari: sinf (ustoz–talaba) imkoniyatlari.
//
// QR havola formati, havoladan kodni ajratish, variantli test vektorlari
// (D-66), "muddat tugagach" javoblarni yashirish shartnomasi va "Katta ekran"
// faqat taxallus ko'rsatishi, ilova ichidagi QR skaner (D-68): tugma,
// kamera ruxsatlari. Jadval: docs/GUARDS.md.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/variant_draw.dart';
import 'package:labguide/features/classroom/board_screen.dart';
import 'package:labguide/features/classroom/invite_link.dart';
import 'package:labguide/features/classroom/qr_scanner.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart' show ValueKey;

import '../helpers/fake_backend.dart';
import '../helpers/fake_qr_scanner.dart';
import '../helpers/harness.dart';

const _aid = '0f8b2c4e-1d2a-4b3c-9d8e-7f6a5b4c3d2e';

void main() {
  group('QR / taklif havolasi', () {
    test('format: https://labguide.nfcstore.uz/j/?c=KOD[&a=TEST]', () {
      expect(
        inviteUrl('ABCD2345'),
        'https://labguide.nfcstore.uz/j/?c=ABCD2345',
      );
      expect(
        inviteUrl('ABCD2345', assignmentId: _aid),
        'https://labguide.nfcstore.uz/j/?c=ABCD2345&a=$_aid',
      );
    });

    test('kod ajratiladi: sayt, ilova havolasi, xom kod, taklif matni', () {
      const want = InviteTarget('ABCD2345', assignmentId: _aid);
      expect(parseInvite(inviteUrl('ABCD2345', assignmentId: _aid)), want);
      expect(parseInvite('labguide://app/j?c=abcd2345&a=$_aid'), want);
      expect(parseInvite('abcd-2345'), const InviteTarget('ABCD2345'));
      expect(
        parseInvite('Guruhga qo‘shiling. Kod: ABCD 2345'),
        const InviteTarget('ABCD2345'),
      );
      expect(parseInvite('salom dunyo'), isNull);
    });

    test('sayt sahifasi site/j/ ilovani shu havola bilan ochadi', () {
      final page = File('site/j/index.html').readAsStringSync();
      expect(page, contains("'labguide://app/j?c='"));
      expect(page, contains('URLSearchParams'));
    });

    test('Android: labguide://app/j intent-filter saqlanadi', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      final filter =
          RegExp(
                r'<intent-filter>((?:(?!</intent-filter>).)*?)</intent-filter>',
                dotAll: true,
              )
              .allMatches(manifest)
              .map((m) => m[1]!)
              .where((f) => f.contains('android:scheme="labguide"'));
      expect(filter, hasLength(1));
      final f = filter.single;
      expect(f, contains('android:host="app"'));
      expect(f, contains('android.intent.action.VIEW'));
      expect(f, contains('android.intent.category.BROWSABLE'));
      expect(f, contains('android.intent.category.DEFAULT'));
    });

    test('iOS: Info.plist da "labguide" URL sxemasi saqlanadi', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(
        RegExp(
          r'<key>CFBundleURLTypes</key>\s*<array>.*?<key>CFBundleURLSchemes</key>'
          r'\s*<array>\s*<string>labguide</string>',
          dotAll: true,
        ).hasMatch(plist),
        isTrue,
      );
    });

    test('ci.yml: Google (iOS) sxemasi mavjud CFBundleURLTypes ga qo‘shiladi '
        '(labguide o‘chmaydi), so‘ng ikkalasi tekshiriladi', () {
      final yml = File('.github/workflows/ci.yml').readAsStringSync();
      final start = yml.indexOf('- name: Google kirishi (iOS) sozlamasi');
      expect(start, isNonNegative);
      final next = yml.indexOf('\n      - name:', start + 10);
      final step = yml.substring(start, next < 0 ? yml.length : next);
      // Massiv faqat yo'q bo'lsa yaratiladi: har bir 'Add :CFBundleURLTypes
      // array' qatori oldin Print bilan tekshiradi (`Print … || … Add`).
      final addLines = step
          .split('\n')
          .where((l) => l.contains('Add :CFBundleURLTypes array'))
          .toList();
      for (final l in addLines) {
        expect(
          RegExp(
            r"Print :CFBundleURLTypes'[^|\n]*\|\|[^\n]*Add :CFBundleURLTypes array",
          ).hasMatch(l),
          isTrue,
          reason: 'shartsiz Add: $l',
        );
      }
      // Yangi element oxiriga ($N) qo'shiladi — 0-element (labguide) ustiga emas.
      expect(step, contains(r'Add :CFBundleURLTypes:$N dict'));
      expect(step, isNot(contains('Add :CFBundleURLTypes:0 dict')));
      expect(step, isNot(contains('Delete :CFBundleURLTypes')));
      // Yakunda ikkala sxema tekshiriladi.
      expect(
        step,
        contains('Print :CFBundleURLTypes\' "\$P" | grep -q "\$REV"'),
      );
      expect(
        step,
        contains('Print :CFBundleURLTypes\' "\$P" | grep -q \'labguide\''),
      );
    });
  });

  group('variantli test (D-66)', () {
    final vectors = jsonDecode(
      File('cloudflare/test/variant_vectors.json').readAsStringSync(),
    ) as Map<String, Object?>;

    test('umumiy vektorlar o‘chirilmagan va Dart tanlovi mos', () {
      final cases = (vectors['cases']! as List).cast<Map<String, Object?>>();
      expect(cases.length, greaterThanOrEqualTo(4));
      for (final c in cases) {
        expect(
          drawVariant(
            assignmentId: c['assignment_id']! as String,
            userId: c['user_id']! as String,
            pool: (c['pool']! as List).cast<String>(),
            poolTopics: (c['pool_topics'] as List?)?.cast<String?>(),
            count: c['count']! as int,
          ),
          (c['expected']! as List).cast<String>(),
          reason: '${c['name']}',
        );
      }
    });
  });

  group('natijani ko‘rsatish', () {
    test('"muddat tugagach": server `correct: null` bersa — ilova ham '
        'to‘g‘ri/xatoni bilmaydi', () {
      final hidden = GroupSubmission.fromJson({
        'assignment_id': _aid,
        'user_id': 'u1',
        'score': 3,
        'total': 5,
        'submitted_at': '2026-10-18T09:00:00Z',
        'answers': [0, 1, 2, 3, 0],
        'correct': null,
      });
      expect(hidden.correct, isNull);
      final shown = GroupSubmission.fromJson({
        'assignment_id': _aid,
        'user_id': 'u1',
        'score': 1,
        'total': 2,
        'submitted_at': '2026-10-18T09:00:00Z',
        'answers': [0, 1],
        'correct': [true, false],
      });
      expect(shown.correct, [true, false]);
    });

    test(
      'Katta ekran: faqat taxallus yoki "Talaba NN"; ustoz va email yo‘q',
      () {
        final l = lookupAppLocalizations(const Locale('uz'));
        final joined = DateTime.utc(2026, 10, 18, 9);
        final members = [
          GroupMember(userId: 't', isTeacher: true, joinedAt: joined),
          GroupMember(
            userId: 'a',
            isTeacher: false,
            joinedAt: joined,
            alias: 'Lola',
            seatNo: 1,
          ),
          GroupMember(
            userId: 'b',
            isTeacher: false,
            joinedAt: joined,
            seatNo: 3,
          ),
          // Server email bersa ham model uni olmaydi.
          GroupMember.fromJson({
            'user_id': 'c',
            'member_role': 'student',
            'display_name': null,
            'seat_no': 4,
            'email': 'student@example.test',
            'joined_at': '2026-10-18T09:00:00Z',
          }),
        ];
        final rows = boardRows(
          l: l,
          members: members,
          submissions: const [],
          attempts: const [],
          assignmentId: _aid,
        );
        expect(rows.map((r) => r.userId), isNot(contains('t')));
        expect(rows.map((r) => r.name).toSet(), {
          'Lola',
          'Talaba 03',
          'Talaba 04',
        });
        for (final r in rows) {
          expect(r.name, isNot(contains('@')));
        }
        final src = File('lib/features/classroom/board_screen.dart')
            .readAsStringSync();
        // Ustozning lokal eslatmasi (ism) ekranga chiqmaydi.
        expect(src, isNot(contains('localName')));
        expect(src, isNot(contains('.email')));
      },
    );
  });

  group('Ilova ichidagi QR skaner (D-68)', () {
    testWidgets('qo‘shilish ekranida "QR kodni skanerlash" (qo‘llansa)', (
      tester,
    ) async {
      final b = FakeLabBackend();
      final s = await makeServices(
        tester,
        backend: b,
        role: AppRole.student,
        qrScanner: FakeQrScanner(),
      );
      await pumpApp(tester, s, size: const Size(390, 1600));
      await s.auth.signOut();
      await s.auth.requestCode('guard@example.com');
      await s.auth.verifyCode(FakeLabBackend.otpCode);
      await goTo(tester, '/learn/classes/join');
      expect(find.byKey(const ValueKey('join-scan')), findsOneWidget);
      expect(
        find.text(lookupAppLocalizations(const Locale('uz')).qrScanAction),
        findsOneWidget,
      );
    });

    test('plagin: faqat Android/iOS; skaner interfeys ortida', () {
      expect(const MobileQrScanner().isSupported, isTrue); // test: android
      final src = File(
        'lib/features/classroom/qr_scanner.dart',
      ).readAsStringSync();
      expect(src, contains('!kIsWeb'));
      // Plagin faqat shu faylda — ekranlar interfeysni ishlatadi.
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        if (f.path.endsWith('qr_scanner.dart')) continue;
        expect(
          f.readAsStringSync(),
          isNot(contains('package:mobile_scanner')),
          reason: f.path,
        );
      }
    });

    test('Android: CAMERA ruxsati, kamera majburiy emas', () {
      final m = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(m, contains('android.permission.CAMERA'));
      expect(
        RegExp(
          r'<uses-feature\s+android:name="android.hardware.camera"\s+'
          r'android:required="false"',
        ).hasMatch(m),
        isTrue,
      );
    });

    test('iOS: NSCameraUsageDescription QR skanerni tilga oladi', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final m = RegExp(
        r'<key>NSCameraUsageDescription</key>\s*<string>([^<]+)</string>',
      ).firstMatch(plist);
      expect(m, isNotNull);
      expect(m![1], contains('QR'));
      for (final lang in ['uz', 'ru', 'en']) {
        final strings = File(
          'ios/Runner/$lang.lproj/InfoPlist.strings',
        ).readAsStringSync();
        expect(
          RegExp(r'"NSCameraUsageDescription" = "[^"]*QR').hasMatch(strings),
          isTrue,
          reason: lang,
        );
      }
    });

    test('iOS deployment target plagin talabidan past emas (12.0)', () {
      final pbx = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      final targets = RegExp(
        r'IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);',
      ).allMatches(pbx).map((m) => double.parse(m[1]!));
      expect(targets, isNotEmpty);
      expect(targets.every((t) => t >= 12.0), isTrue);
    });
  });
}
