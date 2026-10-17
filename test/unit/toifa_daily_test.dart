import 'dart:convert';
import 'dart:math';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/daily/daily_controller.dart';
import 'package:labguide/features/daily/daily_reminder.dart';
import 'package:labguide/features/daily/daily_streak.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';
import 'package:labguide/features/toifa/toifa_controller.dart';
import 'package:labguide/features/toifa/toifa_daily.dart';

import '../helpers/daily_fakes.dart';

/// Soat (testda qo'lda suriladi).
class _Clock {
  _Clock(this.t);
  DateTime t;
  DateTime call() => t;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('kun kaliti (mahalliy sana)', () {
    test('yarim tun: 23:59 — bugun, 00:00 — ertangi kun', () {
      expect(toifaDayKey(DateTime(2026, 10, 17, 23, 59, 59)), '2026-10-17');
      expect(toifaDayKey(DateTime(2026, 10, 18)), '2026-10-18');
      expect(toifaDayKey(DateTime(2026, 12, 31, 23, 59)), '2026-12-31');
      expect(toifaDayKey(DateTime(2027)), '2027-01-01');
    });

    test('UTC lahza mahalliy sanaga o‘giriladi', () {
      final utc = DateTime.utc(2026, 10, 17, 21, 30);
      expect(toifaDayKey(utc), toifaDayKey(utc.toLocal()));
    });

    test('kalit ↔ kun raqami (oy/yil chegarasi, kabisa)', () {
      for (final d in [
        DateTime(2026, 10, 17),
        DateTime(2026, 12, 31),
        DateTime(2027),
        DateTime(2028, 2, 29),
      ]) {
        final day = dayOf(d);
        expect(toifaKeyOfDay(day), toifaDayKey(d));
        expect(toifaDayOfKey(toifaKeyOfDay(day)), day);
      }
      expect(toifaDayOfKey('buzilgan'), isNull);
    });
  });

  group('kunlik hisob va seriya', () {
    test('maqsad: 50 savol yoki 1 bilet; sozlanadi', () {
      const d = ToifaDay(answered: 20, correct: 15);
      expect(d.meets(50), false);
      expect(d.meets(20), true);
      expect(d.percent, 75);
      expect(d.progress(50), closeTo(0.4, 1e-9));
      expect(const ToifaDay(tickets: 1).meets(100), true);
      expect(const ToifaDay(tickets: 1).progress(100), 1);
    });

    test('seriya: ketma-ket kunlar, bugun hali bajarilmagan — uzilmaydi', () {
      final days = {
        10: const ToifaDay(answered: 50),
        11: const ToifaDay(tickets: 1),
        12: const ToifaDay(answered: 49),
        13: const ToifaDay(answered: 60),
        14: const ToifaDay(answered: 50),
      };
      expect(toifaStreak(days, 14, 50), 2);
      expect(toifaStreak(days, 15, 50), 2, reason: 'bugun hali tugamagan');
      expect(toifaStreak(days, 16, 50), 0, reason: 'kecha o‘tkazib yuborildi');
      expect(toifaStreak(days, 12, 50), 2, reason: '12 bajarilmagan → 10–11');
      expect(toifaStreak(days, 14, 20), 5, reason: 'maqsad 20 bo‘lsa');
    });

    test('controller: yarim tundan keyingi javob ertangi kunga, seriya va '
        'saqlash', () async {
      final store = MemoryKeyValueStore();
      final clock = _Clock(DateTime(2026, 10, 17, 23, 58));
      final c = ToifaController(store, bundle: rootBundle, clock: clock.call);
      expect(c.opened, false);
      await c.recordAnswers(answered: 50, correct: 40);
      expect(c.todayGoalMet, true);
      expect(c.streak, 1);
      clock.t = DateTime(2026, 10, 18, 0, 1);
      expect(c.todayStats, ToifaDay.empty, reason: 'yangi kun');
      expect(c.todayGoalMet, false);
      expect(c.streak, 1, reason: 'kechagi seriya kun tugamaguncha turadi');
      await c.recordAnswers(answered: 30, correct: 30);
      expect(c.todayStats.answered, 30);
      expect(c.streak, 1);
      await c.setGoal(20);
      expect(c.todayGoalMet, true);
      expect(c.streak, 2);
      final week = c.lastDays();
      expect(week.length, 7);
      expect(week.last.$1, c.today);
      expect(week[5].$2.answered, 50);

      // Qurilmada saqlangan: yangi controller xuddi shuni o'qiydi.
      final again = ToifaController(
        store,
        bundle: rootBundle,
        clock: clock.call,
      );
      expect(again.goalQuestions, 20);
      expect(again.todayStats, const ToifaDay(answered: 30, correct: 30));
      expect(again.streak, 2);
      expect(again.opened, true);
      final raw = jsonDecode(store.getString(StoreKeys.toifaDaily)!) as Map;
      expect((raw['days'] as Map).keys, ['2026-10-17', '2026-10-18']);

      // 60 kundan eskilari o'chiriladi.
      clock.t = DateTime(2026, 12, 31, 12);
      await again.recordAnswers(answered: 1, correct: 1);
      final pruned = jsonDecode(store.getString(StoreKeys.toifaDaily)!) as Map;
      expect((pruned['days'] as Map).keys, ['2026-12-31']);
    });

    test('buzilgan yozuv ilovani yiqitmaydi', () {
      final store = MemoryKeyValueStore()
        ..setString(StoreKeys.toifaDaily, '{bad')
        ..setString(StoreKeys.toifaLeitner, '[1,2]')
        ..setString(StoreKeys.toifaDrill, '{"id":1}');
      final c = ToifaController(store, bundle: rootBundle);
      expect(c.todayStats, ToifaDay.empty);
      expect(c.goalQuestions, ToifaGoal.defaultQuestions);
      expect(c.drill, isNull);
    });
  });

  group('Leitner', () {
    test('qutilar: bilmadim → 1, qisman → 2, bildim → yuqoriga', () {
      expect(ToifaLeitner.nextBox(null, OralRating.knew), 3);
      expect(ToifaLeitner.nextBox(4, OralRating.knew), 5);
      expect(ToifaLeitner.nextBox(5, OralRating.knew), 5);
      expect(ToifaLeitner.nextBox(5, OralRating.unknown), 1);
      expect(ToifaLeitner.nextBox(4, OralRating.partial), 2);
    });

    test('tartib: zaif (muddati kelgan) → yangi → mustahkam → qolgan', () {
      final pool = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
      final cards = {
        'b': const LeitnerCard(2, 1), // 2-quti, 2 biletdan keyin
        'c': const LeitnerCard(1, 2), // 1-quti, keyingi biletda
        'd': const LeitnerCard(5, 0), // mustahkam, muddati kelmagan
        'e': const LeitnerCard(3, 0), // mustahkam, muddati kelgan (4)
      };
      expect(ToifaLeitner.order(pool, cards, 4, size: 8), [
        'c', // 1-quti birinchi
        'b',
        'a', 'f', 'g', 'h', // yangilari
        'e',
        'd',
      ]);
      // Muddati kelmaganlar yangilaridan keyin (muddatiga yaqini oldin).
      expect(ToifaLeitner.order(pool, cards, 2, size: 8), [
        'a', 'f', 'g', 'h', 'b', 'c', 'e', 'd', //
      ]);
    });

    test('bitta biletda takror savollar ko‘pi bilan 3 ta', () {
      final pool = [for (var i = 0; i < 10; i++) 'q$i'];
      final cards = {for (var i = 0; i < 5; i++) 'q$i': LeitnerCard(1, 0)};
      final t = ToifaLeitner.order(pool, cards, 1);
      expect(t.length, 5);
      expect(t.where(cards.containsKey).length, 3);
    });

    test('controller: “Bilmadim”/“Qisman” keyingi biletda birinchi '
        'qaytadi, baho o‘zgartirilsa quti ikki marta surilmaydi', () async {
      final store = MemoryKeyValueStore();
      final c = ToifaController(store, bundle: rootBundle, random: Random(5));
      await c.ensureLoaded();
      final first = (await c.drawTicket(ToifaCategory.first))!;
      expect(first.ids.length, ToifaFormat.ticketSize);
      await c.startReview();
      final ratings = [
        OralRating.unknown,
        OralRating.partial,
        OralRating.knew,
        OralRating.knew,
        OralRating.knew,
      ];
      for (final r in ratings) {
        await c.rateCurrent(r);
      }
      final t1 = c.ticket!;
      final unknown = t1.ids.firstWhere(
        (id) => t1.ratings[id] == OralRating.unknown,
      );
      final partial = t1.ids.firstWhere(
        (id) => t1.ratings[id] == OralRating.partial,
      );
      expect(t1.toRepeat.toSet(), {unknown, partial});
      expect(c.card(unknown)!.box, 1);
      expect(c.card(partial)!.box, 2);
      // Bahoni o'zgartirish: "bildim" → yana "bildim" — 3-quti (4 emas).
      final knew = t1.ids.firstWhere((id) => t1.ratings[id] == OralRating.knew);
      await c.openInTicket(t1.ids.indexOf(knew));
      await c.rateCurrent(OralRating.knew);
      expect(c.card(knew)!.box, 3);
      // Yakunlangan bilet bugungi hisobga bir marta yozildi.
      expect(c.todayStats.tickets, 1);
      expect(c.todayGoalMet, true);

      // Keyingi bilet: "Bilmadim" (1-quti) albatta bor.
      final second = (await c.drawTicket(ToifaCategory.first))!;
      expect(second.ids, contains(unknown));
      expect(second.ids, isNot(contains(knew)));
      // Yana bir bilet: "Qisman" (2-quti) ham muddati keldi.
      await c.drawTicket(ToifaCategory.first);
      final third = (await c.drawTicket(ToifaCategory.first))!;
      expect(third.ids, contains(partial));

      // Saqlangan: yangi controller qutilarni o'qiydi.
      final again = ToifaController(store, bundle: rootBundle);
      expect(again.card(unknown)!.box, 1);
      expect(again.card(knew)!.box, 3);
    });
  });

  group('mashq rejimi testi (qoralama)', () {
    test(
      '50 savol, darhol baholash, ilova yopilsa davom, xatolar raundi',
      () async {
        final store = MemoryKeyValueStore();
        final c = ToifaController(store, bundle: rootBundle, random: Random(2));
        await c.ensureLoaded();
        final bank = c.bank!;
        final qs = drawQuestions(
          toifaTestPool(bank),
          ToifaFormat.testSize,
          c.random,
        );
        final d = (await c.startDrill(qs, pass: 70))!;
        expect(d.length, 50);
        expect(d.ids.every((id) => bank.test(id)!.scorable), true);
        // Birinchisi to'g'ri, ikkinchisi xato.
        expect(await c.answerDrill(d.keys[0]), true);
        expect(await c.answerDrill(d.keys[0] + 1), isNull, reason: 'bir marta');
        await c.drillNext();
        final wrong = (d.keys[1] + 1) % bank.test(d.ids[1])!.optionCount;
        expect(await c.answerDrill(wrong), false);
        expect(c.todayStats, const ToifaDay(answered: 2, correct: 1));

        // Ilova yopildi — qoralama joyida.
        final again = ToifaController(store, bundle: rootBundle);
        await again.ensureLoaded();
        final r = again.activeDrill!;
        expect(r.ids, d.ids);
        expect(r.index, 1);
        expect(r.answers, {0: d.keys[0], 1: wrong});
        expect(r.pass, 70);

        // Qolganini to'g'ri yechish.
        await again.drillNext();
        while (again.activeDrill != null) {
          final x = again.activeDrill!;
          if (!x.isAnswered(x.index)) await again.answerDrill(x.keys[x.index]);
          await again.drillNext();
        }
        final done = again.drill!;
        expect(done.finished, true);
        expect(done.correctCount, 49);
        expect(done.percent, 98);
        expect(done.passed, true);
        expect(done.wrongIndexes, [1]);

        // Xatolarni qayta ishlash — faqat xato savollar.
        final rework = (await again.startDrill([
          for (final i in done.wrongIndexes) bank.test(done.ids[i])!,
        ], rework: true))!;
        expect(rework.ids, [d.ids[1]]);
        expect(rework.rework, true);
      },
    );

    test('muddatidan oldin yakun: javobsizlar noto‘g‘ri, chegara', () {
      final d = ToifaDrill(
        id: 'x',
        ids: const ['a', 'b', 'c', 'd'],
        keys: const [0, 1, 2, 0],
        startedAt: DateTime(2026),
        answers: {0: 0, 1: 0, 2: 2},
        pass: 60,
      )..finishedAt = DateTime(2026);
      expect(d.correctCount, 2);
      expect(d.wrongCount, 1);
      expect(d.unansweredCount, 1);
      expect(d.percent, 50);
      expect(d.passed, false);
      expect(d.wrongIndexes, [1]);
      final back = ToifaDrill.fromJson(
        (jsonDecode(jsonEncode(d.toJson())) as Map).cast<String, Object?>(),
      );
      expect(back.answers, d.answers);
      expect(back.finished, true);
    });
  });

  group('toifa eslatmasi', () {
    Future<({ReminderController r, ToifaController t, FakeReminderScheduler f})>
    setup({ReminderPermission p = ReminderPermission.granted}) async {
      final store = MemoryKeyValueStore();
      final clock = _Clock(DateTime(2026, 10, 17, 10));
      final settings = SettingsController(
        store,
        systemLocales: const [Locale('uz')],
      );
      await settings.setLanguage(AppLanguage.uz);
      await settings.setRole(AppRole.lab);
      final t = ToifaController(store, bundle: rootBundle, clock: clock.call);
      final f = FakeReminderScheduler(permission: p);
      final r = ReminderController(
        store,
        f,
        daily: DailyController(store, clock: clock.call),
        settings: settings,
        toifa: t,
      );
      return (r: r, t: t, f: f);
    }

    test('standart o‘chiq; yoqilsa — faqat toifa turi, 20:00', () async {
      final (:r, :t, :f) = await setup();
      expect(r.toifaEnabled, false);
      expect(r.shouldOfferToifa, false, reason: 'maqsad hali bajarilmagan');
      await r.syncToifa();
      expect(f.plans[ReminderSlot.toifa], isNull);
      await r.enableToifa();
      final plan = f.plans[ReminderSlot.toifa]!;
      expect(plan.first, DateTime(2026, 10, 17, 20));
      expect(plan.length, kReminderDays);
      expect(f.scheduled, isEmpty, reason: 'kunlik eslatmaga tegmaydi');
      expect(f.textsBySlot[ReminderSlot.toifa]!.body, contains('50'));
      // Bugungi maqsad bajarildi — eslatma ertadan.
      await t.recordAnswers(answered: 50, correct: 45);
      await Future<void>.delayed(Duration.zero);
      expect(r.shouldOfferToifa, true);
      expect(f.plans[ReminderSlot.toifa]!.first, DateTime(2026, 10, 18, 20));
      // Maqsad 20 — matn yangilanadi.
      await t.setGoal(20);
      await Future<void>.delayed(Duration.zero);
      expect(f.textsBySlot[ReminderSlot.toifa]!.body, contains('20'));
      await r.setToifaTime(7, 30);
      expect(f.plans[ReminderSlot.toifa]!.first, DateTime(2026, 10, 18, 7, 30));
      await r.disableToifa();
      expect(f.plans[ReminderSlot.toifa], isEmpty);
      expect(f.cancelsBySlot[ReminderSlot.toifa], 1);
      expect(f.cancels, 0, reason: 'kunlik bekor qilinmadi');
      await r.closeToifaOffer();
      expect(r.shouldOfferToifa, false);
    });

    test('ruxsat berilmasa — o‘chiq qoladi', () async {
      final (:r, t: _, :f) = await setup(p: ReminderPermission.denied);
      await r.enableToifa(hour: 21, minute: 0);
      expect(r.toifaEnabled, false);
      expect(r.toifaDenied, ReminderPermission.denied);
      expect(f.plans[ReminderSlot.toifa], isNull);
    });

    test('bildirishnoma bosildi — toifa so‘rovi alohida', () async {
      final (:r, t: _, :f) = await setup();
      f.tap(ReminderSlot.toifa);
      expect(r.takeOpenRequest(), false);
      expect(r.takeToifaOpenRequest(), true);
      expect(r.takeToifaOpenRequest(), false);
    });
  });
}
