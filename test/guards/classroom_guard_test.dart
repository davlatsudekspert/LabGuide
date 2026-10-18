// Qorovul (guard) testlari: sinf (ustoz–talaba) imkoniyatlari.
//
// QR havola formati, havoladan kodni ajratish, variantli test vektorlari
// (D-66), "muddat tugagach" javoblarni yashirish shartnomasi va "Katta ekran"
// faqat taxallus ko'rsatishi. Jadval: docs/GUARDS.md.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/variant_draw.dart';
import 'package:labguide/features/classroom/board_screen.dart';
import 'package:labguide/features/classroom/invite_link.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';

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
}
