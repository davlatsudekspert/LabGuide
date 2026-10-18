// Ustoz–talaba oqimi HAQIQIY server bilan: ilovaning CloudflareLabBackend'i
// mahalliy Worker'ga (wrangler dev --local, cloudflare/dev/local.ts) haqiqiy
// HTTP orqali ulanadi. Ustoz taqdimotdan “Guruhga topshirish” qiladi
// (muddat + “muddat tugagach”), ikki talaba Bosh sahifadan testni ochib
// yechadi (biri xatosiz, biri xatolar bilan), natija — ball bor, javoblar
// yopiq; ustoz natijalar, taqsimot, eng qiyin savollarni ko'radi va testni
// yakunlaydi; talabada javoblar ochiladi; boshlamagan talaba “Test
// yakunlandi” ni ko'radi. Har qadamda ekran rasmi (uz, 390x844):
//
//   cd cloudflare && npx wrangler dev --local --port 8799 -c dev/wrangler.local.toml
//   LG_LOCAL_API=http://127.0.0.1:8799 flutter test \
//     tool/screenshots/walk_classroom_live_test.dart --update-goldens
//
// Rasmlar: tool/screenshots/out/walk/classroom_live_uz/. LG_LOCAL_API
// berilmasa test o'tkazib yuboriladi (faqat 127.0.0.1/localhost).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:labguide/app/app.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/cloudflare_backend.dart';
import 'package:labguide/core/backend/supabase_backend.dart'
    show MemorySessionStore;
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/diff_device_fakes.dart';
import '../../test/helpers/harness.dart';
import '../../test/helpers/learn_helpers.dart';
import 'walk_helper.dart';

const _deck = 'd013';
final uz = lookupAppLocalizations(const Locale('uz'));

void main() {
  final base = Platform.environment['LG_LOCAL_API'] ?? '';
  if (base.isEmpty) {
    test('mahalliy Worker bilan UI', () {}, skip: 'LG_LOCAL_API berilmagan');
    return;
  }
  if (!base.contains('127.0.0.1') && !base.contains('localhost')) {
    throw StateError('Faqat mahalliy Worker: $base');
  }
  final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  setUpAll(loadAppFonts);

  testWidgets('ustoz → 2 talaba → natija → yakunlash (haqiqiy HTTP, uz)', (
    tester,
  ) async {
    // flutter_test hamma HTTP so'rovni 400 bilan to'xtatadi — bu testda
    // faqat mahalliy Worker'ga haqiqiy so'rov kerak.
    HttpOverrides.global = null;
    installDiffFakes();
    final w = Walk(tester, 'classroom_live_uz');

    Future<T> real<T>(Future<T> Function() f) async =>
        (await tester.runAsync(f)) as T;

    Future<String> lastCode(String email) async {
      final r = await http.get(Uri.parse('$base/__outbox'));
      final list = (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
      return list.lastWhere((m) => m['to'] == email)['code'] as String;
    }

    // Har foydalanuvchi — o'z ilova xizmatlari (alohida qurilma kabi); kirish
    // ilovaning o'z OTP oqimi orqali (kod mahalliy pochta qutisidan).
    Future<AppServices> device(String who, AppRole role) async {
      final email = '$who.$stamp@example.test';
      final b = CloudflareLabBackend(
        ApiConfig(url: base),
        sessionStore: MemorySessionStore(),
        // Soxta vaqt (pump) haqiqiy so'rov tugamasdan “timeout” bermasin.
        timeout: const Duration(days: 1),
        httpClient: _FreshConnections(http.Client()),
      );
      final s = await makeServices(tester, backend: b, role: role);
      await real(() async {
        await s.auth.requestCode(email);
        final v = await s.auth.verifyCode(await lastCode(email));
        expect(s.auth.hasAccount, isTrue, reason: '$who: $v');
      });
      return s;
    }

    /// Haqiqiy tarmoq javobini kutadi: real vaqt + kadrlar.
    Future<void> waitFor(Finder f, {int tries = 80}) async {
      for (var i = 0; i < tries; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 50));
        if (f.evaluate().isNotEmpty) {
          // Qolgan so'rovlar (masalan, ro'yxat yangilanishi) ham tugasin.
          for (var j = 0; j < 4; j++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 100)),
            );
            await tester.pump(const Duration(milliseconds: 50));
          }
          return;
        }
      }
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? t.textSpan?.toPlainText())
          .join(' | ');
      fail('Kutilgan element chiqmadi: $f\nEkranda: $texts');
    }

    // pumpAndSettle so'rov paytida ishlatilmaydi (yuklanish animatsiyasi
    // soxta vaqtni cheksiz suradi, haqiqiy javob esa kelmaydi).
    Future<void> go(String location) async {
      routerOf(tester).go(location);
      await tester.pump();
    }

    // harness.pumpApp kabi, lekin pumpAndSettle siz (Bosh sahifa kartalari
    // haqiqiy so'rov kutayotganda yuklanish animatsiyasi bor).
    Future<void> show(AppServices s) async {
      await tester.pumpWidget(const SizedBox());
      const ratio = 3.0;
      tester.view.devicePixelRatio = ratio;
      tester.view.physicalSize = const Size(390, 844) * ratio;
      tester.view.padding = const FakeViewPadding(
        top: 47 * ratio,
        bottom: 34 * ratio,
      );
      addTearDown(tester.view.reset);
      await tester.pumpWidget(LabGuideApp(services: s));
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    Future<void> tapKey(String key) async {
      final f = find.byKey(ValueKey(key));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pump();
    }

    // --- Hisoblar va guruh (guruh UI'si walk_classroom_test'da sinalgan).
    final t = await device('ustoz', AppRole.teacher);
    final a = await device('lola', AppRole.student);
    final b = await device('bobur', AppRole.student);
    final c = await device('kech', AppRole.student);
    final tb = t.backend as CloudflareLabBackend;
    final g = await real(() async {
      await tb.registerTeacher();
      final g = await tb.createGroup('Gematologiya 2-kurs');
      await a.backend.joinGroup(g.joinCode!, displayName: 'Lola');
      await b.backend.joinGroup(g.joinCode!);
      await c.backend.joinGroup(g.joinCode!, displayName: 'Kech');
      return g;
    });

    // --- 1. Ustoz: taqdimotdan “Guruhga topshirish”.
    await show(t);
    await go('/learn/lecture/test/$_deck/assign');
    await waitFor(find.byKey(ValueKey('assign-group-${g.id}')));
    await w.snap('topshirish_ekrani');
    await tapKey('assign-due-d1');
    await tapKey('assign-reveal-after');
    await tapScroll(tester, '5');
    await w.snap('sozlandi_5_savol');
    await tapKey('assign-send');
    await waitFor(find.text(uz.topicTestSent(1)));
    await w.snap('yuborildi');
    final asg = (await real(() => tb.assignments(g.id))).single;
    expect(asg.deckId, _deck);
    expect(asg.revealAfterDue, isTrue);
    expect(asg.questionIds, hasLength(5));
    await waitFor(find.byKey(ValueKey('sent-${asg.id}')));
    await tester.ensureVisible(find.byKey(ValueKey('sent-${asg.id}')));
    await w.snap('yuborilganlar_royxati');

    // --- 2. Talabalar: Bosh sahifa → test → javoblar → yuborish.
    Future<void> solve(
      AppServices s,
      String tag, {
      required bool mistakes,
    }) async {
      await show(s);
      final row = find.byKey(ValueKey('assigned-${asg.id}'));
      await go('/home');
      // Bosh sahifa ro'yxati dangasa quriladi: avval so'rovlar tugaydi.
      await waitFor(find.text(uz.navHome));
      for (var i = 0; i < 60 && row.hitTestable().evaluate().isEmpty; i++) {
        if (i.isEven) {
          await tester.drag(
            find.byType(Scrollable).hitTestable().first,
            const Offset(0, -250),
          );
        }
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 150)),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.ensureVisible(row);
      await w.snap('${tag}_bosh_sahifa');
      await tester.tap(row);
      await tester.pump();
      await waitFor(find.text(uz.classesStart));
      await w.snap('${tag}_boshlash');
      await tester.tap(find.text(uz.classesStart).hitTestable());
      await tester.pump();
      await waitFor(find.text(uz.examNext));
      final run = s.exams.assignmentSession(asg.id, s.backend.userId)!;
      await w.snap('${tag}_savol_1');
      for (var i = 0; i < run.length; i++) {
        final item = run.current;
        final q = ClassQuestionSource.of(
          s.content.pack!,
          s.toifa.bank,
        ).question(item.questionId)!;
        final wrong = mistakes && i.isOdd;
        final idx = wrong
            ? item.order.firstWhere((o) => !item.correct.contains(o))
            : item.correct.single;
        await tapScroll(tester, q.option(idx, 'uz'));
        if (i == 1) await w.snap('${tag}_javob_izohsiz');
        if (i < run.length - 1) await tapScroll(tester, uz.examNext);
      }
      await tapScroll(tester, uz.examFinish);
      await w.snap('${tag}_yakunlash_tasdiq');
      await tester.tap(find.text(uz.examFinish).hitTestable().last);
      await tester.pump();
      await waitFor(find.text(uz.classesServerScore));
      await w.snap('${tag}_natija_javoblar_yopiq');
      final later = uz.topicTestAnswersLater('#').split('(').first.trim();
      expect(find.textContaining(later), findsOneWidget);
      expect(find.text(uz.examAnalysis), findsNothing);
    }

    await solve(a, 'lola', mistakes: false);
    await solve(b, 'bobur', mistakes: true);
    final own = await real(() => b.backend.submissions(asg.id));
    expect(own.single.userId, b.backend.userId);
    expect(own.single.correct, isNull);
    expect(own.single.score, 3);

    // --- 3. Ustoz: natijalar, taqsimot, eng qiyin savollar → yakunlash.
    await show(t);
    await go('/learn/classes/g/${g.id}/a/${asg.id}');
    await waitFor(find.byKey(const ValueKey('assignment-close')));
    await w.snap('ustoz_natijalar');
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    await w.scroll(600);
    await w.snap('ustoz_taqsimot');
    await w.scroll(600);
    await w.snap('ustoz_eng_qiyin');
    await tapKey('assignment-close');
    await tester.pumpAndSettle();
    await w.snap('yakunlash_tasdiq');
    await tester.tap(find.text(uz.classroomTestFinish).hitTestable().last);
    await tester.pump();
    await waitFor(find.byKey(const ValueKey('assignment-closed')));
    await w.snap('yakunlandi');

    // --- 4. Talaba: endi to'g'ri javoblar va xatolar tahlili ochiq.
    await show(b);
    await go('/learn/classes/g/${g.id}/a/${asg.id}');
    await waitFor(find.text(uz.examAnalysis));
    await w.snap('bobur_javoblar_ochildi');
    await w.scroll(500);
    await w.snap('bobur_xatolar_tahlili');

    // --- 5. Boshlamagan talaba: “Test yakunlandi”, boshlash tugmasi yo'q.
    await show(c);
    await go('/learn/classes/g/${g.id}/a/${asg.id}');
    await waitFor(find.byKey(const ValueKey('assignment-closed')));
    expect(find.text(uz.classesStart), findsNothing);
    await w.snap('kech_test_yakunlangan');
    await go('/learn/classes/g/${g.id}');
    await waitFor(find.text(uz.classroomStatusTestDone));
    await w.snap('kech_guruh_royxati');

    // --- Tozalash: hisoblar o'chiriladi (ustoz bilan guruh ham).
    await tester.pumpWidget(const SizedBox());
    await real(() async {
      for (final s in [a, b, c, t]) {
        await s.backend.deleteAccount();
      }
    });
    expect(ExamSession, isNotNull);
  });
}

/// `wrangler dev` bo'sh turgan keep-alive ulanishni yopadi; soxta vaqtli
/// testda so'rovlar orasida real pauza bo'lgani uchun har so'rov — yangi
/// ulanish ("Connection closed before full header" bo'lmasin).
class _FreshConnections extends http.BaseClient {
  _FreshConnections(this.inner);
  final http.Client inner;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.persistentConnection = false;
    return inner.send(request);
  }
}
