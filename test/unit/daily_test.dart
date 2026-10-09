import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/daily/daily_controller.dart';
import 'package:labguide/features/daily/daily_picker.dart';
import 'package:labguide/features/daily/daily_reminder.dart';
import 'package:labguide/features/daily/daily_streak.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/daily_fakes.dart';

/// 2026-10-05 — dushanba.
final monday = dayOf(DateTime(2026, 10, 5));

Set<int> days(Iterable<int> offsets) => {for (final o in offsets) monday + o};

void main() {
  group('kalendar kuni', () {
    test('soat kun raqamiga ta’sir qilmaydi', () {
      expect(
        dayOf(DateTime(2026, 10, 9)),
        dayOf(DateTime(2026, 10, 9, 23, 59)),
      );
      expect(
        dayOf(DateTime.utc(2026, 10, 9, 23)),
        dayOf(DateTime(2026, 10, 9)),
      );
      expect(
        dateOfDay(dayOf(DateTime(2026, 10, 9))),
        DateTime.utc(2026, 10, 9),
      );
    });

    test('yozgi vaqt o‘tishida (23/25 soatlik kun) ketma-ket kunlar', () {
      // Yevropa: 2026-03-29 va 2026-10-25; AQSh: 2026-03-08 va 2026-11-01.
      for (final d in [
        DateTime(2026, 3, 29),
        DateTime(2026, 10, 25),
        DateTime(2026, 3, 8),
        DateTime(2026, 11, 1),
      ]) {
        final before = DateTime(d.year, d.month, d.day - 1, 23, 30);
        final after = DateTime(d.year, d.month, d.day, 0, 30);
        final next = DateTime(d.year, d.month, d.day + 1, 0, 30);
        expect(dayOf(after) - dayOf(before), 1, reason: '$d');
        expect(dayOf(next) - dayOf(after), 1, reason: '$d');
      }
    });

    test('hafta dushanbadan boshlanadi', () {
      expect(weekOf(monday), weekOf(monday + 6));
      expect(weekOf(monday - 1), weekOf(monday) - 1);
      expect(dateOfDay(monday).weekday, DateTime.monday);
    });
  });

  group('ketma-ketlik', () {
    test('bo‘sh tarix', () {
      final s = computeStreak({}, monday);
      expect(s.current, 0);
      expect(s.best, 0);
      expect(s.todayDone, isFalse);
    });

    test('ketma-ket kunlar; bugun hali bajarilmagan bo‘lsa uzilmaydi', () {
      final done = days([0, 1, 2]);
      expect(computeStreak(done, monday + 2).current, 3);
      expect(computeStreak(done, monday + 2).todayDone, isTrue);
      // Ertasi kuni, hali bajarilmagan: seriya hali tirik.
      final next = computeStreak(done, monday + 3);
      expect(next.current, 3);
      expect(next.todayDone, isFalse);
    });

    test('bitta o‘tkazib yuborilgan kun — haftalik muzlatish', () {
      final done = days([0, 1, 3, 4]);
      final s = computeStreak(done, monday + 4);
      expect(s.current, 4, reason: 'muzlatilgan kun sanalmaydi');
      expect(s.frozen, {monday + 2});
      expect(s.freezeUsedThisWeek, isTrue);
    });

    test('kecha o‘tkazilgan, bugun hali bajarilmagan — muzlatish saqlaydi', () {
      final done = days([0, 1]);
      final s = computeStreak(done, monday + 3);
      expect(s.current, 2);
      expect(s.frozen, {monday + 2});
    });

    test('ketma-ket ikki kun o‘tkazilsa — seriya uziladi', () {
      final done = days([0, 1, 4]);
      expect(computeStreak(done, monday + 4).current, 1);
      expect(computeStreak(days([0, 1]), monday + 4).current, 0);
    });

    test('bir haftada ikkinchi o‘tkazish — uziladi', () {
      // Seshanba va payshanba o'tkazilgan (bir hafta).
      final done = days([0, 2, 4]);
      final s = computeStreak(done, monday + 4);
      expect(s.current, 2);
      expect(s.frozen, {monday + 3});
    });

    test('muzlatish har hafta yangilanadi', () {
      // 1-hafta chorshanba, 2-hafta chorshanba o'tkazilgan.
      final done = days([0, 1, 3, 4, 5, 6, 7, 8, 10, 11]);
      final s = computeStreak(done, monday + 11);
      expect(s.current, 10);
      expect(s.frozen, {monday + 2, monday + 9});
    });

    test('eng uzun seriya — tarixdagi va saqlangan qiymat', () {
      final done = days([0, 1, 2, 3, 4, 10, 11]);
      final s = computeStreak(done, monday + 11);
      expect(s.current, 2);
      expect(s.best, 5);
      expect(computeStreak(done, monday + 11, storedBest: 9).best, 9);
    });

    test('soat orqaga surilsa (g‘arbga uchish) seriya yo‘qolmaydi', () {
      // Toshkentda 5-kun bajarildi, keyin mintaqa o'zgarib sana 4-kun.
      final done = days([3, 4]);
      final s = computeStreak(done, monday + 3);
      expect(s.current, 2);
      expect(s.todayDone, isTrue);
    });

    test('sana sakrab o‘tsa (sharqqa uchish) — muzlatish bilan saqlanadi', () {
      final done = days([0, 1, 3]);
      expect(computeStreak(done, monday + 3).current, 3);
    });
  });

  group('kunlik to‘plam tanlovi', () {
    final pool = [for (var i = 0; i < 40; i++) 'q$i'];
    final prio = pool.take(12).toList();
    final others = pool.skip(12).toList();

    test('deterministik va kirish tartibiga bog‘liq emas', () {
      final a = pickDaily(priority: prio, others: others, day: 100, seed: 7);
      final b = pickDaily(
        priority: prio.reversed,
        others: others.reversed,
        day: 100,
        seed: 7,
      );
      expect(a, b);
      expect(a, hasLength(kDailySize));
      expect(a.toSet(), hasLength(kDailySize));
    });

    test('kun va urug‘ o‘zgarsa — boshqa to‘plam', () {
      final a = pickDaily(priority: prio, others: others, day: 100, seed: 7);
      expect(
        pickDaily(priority: prio, others: others, day: 101, seed: 7),
        isNot(a),
      );
      expect(
        pickDaily(priority: prio, others: others, day: 100, seed: 8),
        isNot(a),
      );
    });

    test('rolga mos mavzulardan 3 ta, qolganidan 2 ta', () {
      final a = pickDaily(priority: prio, others: others, day: 5, seed: 1);
      expect(a.where(prio.contains), hasLength(kDailyPriority));
      expect(a.where(others.contains), hasLength(kDailySize - kDailyPriority));
    });

    test('hovuz tugamaguncha savollar takrorlanmaydi', () {
      final seen = <String>{};
      for (var d = 0; d < 6; d++) {
        seen.addAll(
          pickDaily(priority: const [], others: pool, day: d, seed: 3),
        );
      }
      expect(seen, hasLength(30));
    });

    test('kichik hovuz — bor savollar bilan', () {
      expect(
        pickDaily(
          priority: const ['a'],
          others: const ['b', 'c'],
          day: 9,
          seed: 1,
        ).toSet(),
        {'a', 'b', 'c'},
      );
      expect(
        pickDaily(priority: const [], others: const [], day: 9, seed: 1),
        isEmpty,
      );
    });
  });

  group('DailyController', () {
    const pool = DailyPool(
      sourceId: 'pack',
      priority: ['p1', 'p2', 'p3', 'p4'],
      others: ['o1', 'o2', 'o3', 'o4', 'o5'],
    );

    test('kun ichida o‘zgarmaydi, yangi kunda yangilanadi', () {
      var now = DateTime(2026, 10, 9, 0, 5);
      final c = DailyController(
        MemoryKeyValueStore(),
        clock: () => now,
        random: Random(1),
      );
      final first = c.ensureToday(pool)!.ids;
      now = DateTime(2026, 10, 9, 23, 55);
      expect(c.ensureToday(pool)!.ids, first);
      // Rol o'zgarib hovuz boshqacha bo'lsa ham — bugungi to'plam o'sha.
      expect(
        c
            .ensureToday(
              const DailyPool(
                sourceId: 'pack',
                priority: [],
                others: ['x', 'y'],
              ),
            )!
            .ids,
        first,
      );
      now = DateTime(2026, 10, 10, 0, 1);
      final next = c.ensureToday(pool)!;
      expect(next.day, dayOf(now));
      expect(next.ids, isNot(first));
    });

    test('javoblar, kun yakuni va qayta ochilganda saqlanishi', () async {
      final store = MemoryKeyValueStore();
      final now = DateTime(2026, 10, 9, 9);
      final c = DailyController(store, clock: () => now, random: Random(2));
      final set = c.ensureToday(pool)!;
      for (final (i, id) in set.ids.indexed) {
        final finished = await c.answer(id, 0, correct: i.isEven);
        expect(finished, i == set.ids.length - 1);
      }
      // Ikkinchi marta javob qabul qilinmaydi.
      expect(await c.answer(set.ids.first, 1, correct: false), isFalse);
      expect(c.todaySet!.correctCount, 3);
      expect(c.streak.current, 1);
      expect(c.streak.todayDone, isTrue);

      final again = DailyController(store, clock: () => now);
      expect(again.todaySet!.ids, set.ids);
      expect(again.todaySet!.correctCount, 3);
      expect(again.streak.current, 1);
      expect(again.ensureToday(pool)!.ids, set.ids);
      final saved = jsonDecode(store.getString(StoreKeys.dailyStreak)!) as Map;
      expect(saved['days'], [dayOf(now)]);
    });

    test('urug‘ qurilmada saqlanadi — to‘plam qayta tuzilsa ham o‘sha', () {
      final store = MemoryKeyValueStore();
      final now = DateTime(2026, 10, 9, 9);
      final a = DailyController(store, clock: () => now, random: Random(5));
      final ids = a.ensureToday(pool)!.ids;
      // Bugungi to'plam o'chib ketsa ham (masalan, buzilgan yozuv).
      store.remove(StoreKeys.dailyToday);
      final b = DailyController(store, clock: () => now, random: Random(99));
      expect(b.ensureToday(pool)!.ids, ids);
    });

    test('manba faqat javob berilmagan bo‘lsa almashadi', () async {
      final now = DateTime(2026, 10, 9, 9);
      final c = DailyController(MemoryKeyValueStore(), clock: () => now);
      final toifa = c.ensureToday(
        const DailyPool(sourceId: 'toifa', priority: [], others: ['t1', 't2']),
      )!;
      expect(c.ensureToday(pool)!.sourceId, 'pack');
      await c.answer(c.todaySet!.ids.first, 0, correct: true);
      expect(
        c
            .ensureToday(
              const DailyPool(sourceId: 'toifa', priority: [], others: ['t1']),
            )!
            .sourceId,
        'pack',
      );
      expect(toifa.sourceId, 'toifa');
    });

    test('bankdan yo‘qolgan savol — to‘plam qayta tuziladi', () {
      final now = DateTime(2026, 10, 9, 9);
      final c = DailyController(MemoryKeyValueStore(), clock: () => now);
      final ids = c.ensureToday(pool)!.ids;
      final next = c.ensureToday(pool, exists: (id) => id != ids.first)!;
      expect(next.ids, isNot(contains(ids.first)));
    });

    test('buzilgan yozuv ilovani yiqitmaydi', () {
      final store = MemoryKeyValueStore({
        StoreKeys.dailyToday: '{"day": "x"',
        StoreKeys.dailyStreak: '[1,2]',
      });
      final c = DailyController(store, clock: () => DateTime(2026, 10, 9));
      expect(c.todaySet, isNull);
      expect(c.streak.current, 0);
      expect(c.ensureToday(pool), isNotNull);
    });

    test('lokal ma’lumot o‘chirilganda', () async {
      final now = DateTime(2026, 10, 9, 9);
      final c = DailyController(MemoryKeyValueStore(), clock: () => now);
      final set = c.ensureToday(pool)!;
      for (final id in set.ids) {
        await c.answer(id, 0, correct: true);
      }
      c.resetInMemory();
      expect(c.todaySet, isNull);
      expect(c.streak.current, 0);
    });
  });

  group('eslatma', () {
    test('keyingi vaqtlar: bugun vaqt o‘tmagan bo‘lsa — bugundan', () {
      final t = upcomingReminderTimes(
        DateTime(2026, 10, 9, 8),
        hour: 20,
        minute: 0,
        todayDone: false,
      );
      expect(t, hasLength(kReminderDays));
      expect(t.first, DateTime(2026, 10, 9, 20));
      expect(t.last, DateTime(2026, 10, 15, 20));
    });

    test('bugun bajarilgan yoki vaqt o‘tgan — ertadan', () {
      for (final (now, done) in [
        (DateTime(2026, 10, 9, 8), true),
        (DateTime(2026, 10, 9, 21), false),
        (DateTime(2026, 10, 9, 20), false),
      ]) {
        final t = upcomingReminderTimes(
          now,
          hour: 20,
          minute: 0,
          todayDone: done,
        );
        expect(t.first, DateTime(2026, 10, 10, 20));
        expect(t, hasLength(kReminderDays));
      }
    });

    test('yozgi vaqt o‘tishida ham tanlangan soat', () {
      final t = upcomingReminderTimes(
        DateTime(2026, 3, 27, 22),
        hour: 7,
        minute: 30,
        todayDone: false,
      );
      for (final x in t) {
        expect((x.hour, x.minute), (7, 30));
      }
      expect([for (final x in t) x.day], [28, 29, 30, 31, 1, 2, 3]);
    });

    ({ReminderController r, DailyController d, FakeReminderScheduler f}) setup({
      ReminderPermission p = ReminderPermission.granted,
    }) {
      final store = MemoryKeyValueStore();
      final d = DailyController(store, clock: () => DateTime(2026, 10, 9, 9));
      final f = FakeReminderScheduler(permission: p);
      final settings = SettingsController(
        store,
        systemLocales: const [Locale('uz')],
      );
      return (
        r: ReminderController(store, f, daily: d, settings: settings),
        d: d,
        f: f,
      );
    }

    test('standart o‘chiq, ruxsat so‘ralmaydi', () async {
      final (:r, d: _, :f) = setup();
      expect(r.enabled, isFalse);
      expect(r.shouldOffer, isTrue);
      await r.sync();
      expect(f.permissionRequests, 0);
      expect(f.scheduled, isEmpty);
    });

    test('yoqilganda reja; bajarilgan kunda bugungi eslatma yo‘q', () async {
      final (:r, :d, :f) = setup();
      expect(await r.enable(), ReminderPermission.granted);
      expect(r.enabled, isTrue);
      expect(r.shouldOffer, isFalse);
      expect(f.scheduled.first, DateTime(2026, 10, 9, 20));
      expect(f.texts!.title, isNotEmpty);
      final set = d.ensureToday(
        const DailyPool(sourceId: 'pack', priority: [], others: ['a', 'b']),
      )!;
      for (final id in set.ids) {
        await d.answer(id, 0, correct: true);
      }
      await Future<void>.delayed(Duration.zero);
      expect(f.scheduled.first, DateTime(2026, 10, 10, 20));
      await r.setTime(7, 15);
      expect(f.scheduled.first, DateTime(2026, 10, 10, 7, 15));
      await r.disable();
      expect(f.scheduled, isEmpty);
      expect(f.cancels, 1);
    });

    test('ruxsat rad etilsa — o‘chiq qoladi va sababi aytiladi', () async {
      final (:r, d: _, :f) = setup(p: ReminderPermission.denied);
      expect(await r.enable(), ReminderPermission.denied);
      expect(r.enabled, isFalse);
      expect(r.lastDenied, ReminderPermission.denied);
      expect(f.scheduled, isEmpty);
      await r.closeOffer();
      expect(r.shouldOffer, isFalse);
    });

    test('bildirishnoma bosilsa — bir martalik ochish so‘rovi', () {
      final (:r, d: _, :f) = setup();
      expect(r.takeOpenRequest(), isFalse);
      f.tap();
      expect(r.takeOpenRequest(), isTrue);
      expect(r.takeOpenRequest(), isFalse);
    });
  });
}
