import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/differential/differential_controller.dart';
import 'package:labguide/features/differential/differential_quiz.dart';
import 'package:labguide/features/differential/differential_sources.dart';

void main() {
  group('DifferentialController', () {
    test('maqsadga yetganda to\'xtaydi va ortiqcha bosish qo\'shilmaydi', () {
      final c = DifferentialController(MemoryKeyValueStore());
      for (var i = 0; i < 99; i++) {
        expect(c.tap(DiffCell.segmented), TapOutcome.added);
      }
      expect(c.tap(DiffCell.lymphocyte), TapOutcome.completed);
      expect(c.isComplete, isTrue);
      expect(c.tap(DiffCell.monocyte), TapOutcome.blocked);
      expect(c.total, 100);
      expect(c.count(DiffCell.monocyte), 0);
    });

    test('200 maqsad; sanalganidan kichik maqsad tanlanmaydi', () {
      final c = DifferentialController(MemoryKeyValueStore());
      expect(c.setTarget(200), isTrue);
      for (var i = 0; i < 150; i++) {
        c.tap(DiffCell.lymphocyte);
      }
      expect(c.isComplete, isFalse);
      expect(c.setTarget(100), isFalse);
      expect(c.target, 200);
      expect(c.setTarget(300), isFalse);
    });

    test('uzoq bosish (−1), bekor qilish va tozalash', () {
      final c = DifferentialController(MemoryKeyValueStore());
      c
        ..tap(DiffCell.band)
        ..tap(DiffCell.eosinophil)
        ..tap(DiffCell.band);
      expect(c.decrement(DiffCell.band), isTrue);
      expect(c.count(DiffCell.band), 1);
      expect(c.decrement(DiffCell.basophil), isFalse);
      expect(c.undo(), DiffCell.eosinophil);
      expect(c.undo(), DiffCell.band);
      expect(c.undo(), isNull);
      expect(c.total, 0);
      c
        ..tap(DiffCell.monocyte)
        ..reset();
      expect(c.isEmpty, isTrue);
    });

    test('foiz va mutlaq son = ulush × WBC', () {
      final c = DifferentialController(MemoryKeyValueStore());
      for (var i = 0; i < 42; i++) {
        c.tap(DiffCell.segmented);
      }
      for (var i = 0; i < 58; i++) {
        c.tap(DiffCell.lymphocyte);
      }
      expect(c.current.absolute(DiffCell.segmented), isNull);
      c.setWbc(5);
      final r = c.current;
      expect(r.percent(DiffCell.segmented), 42);
      // JSST misoli: 0,42 × 5×10⁹/l = 2,1×10⁹/l.
      expect(r.absolute(DiffCell.segmented), closeTo(2.1, 1e-9));
      c.setWbc(-1);
      expect(c.wbc, isNull);
    });

    test('qoralama va tarix qurilmada saqlanadi, o\'chiriladi', () async {
      final store = MemoryKeyValueStore();
      var now = DateTime(2026, 10, 9, 9, 30);
      final c = DifferentialController(store, clock: () => now)
        ..setWbc(7.5)
        ..tap(DiffCell.segmented)
        ..tap(DiffCell.monocyte);
      final again = DifferentialController(store);
      expect(again.total, 2);
      expect(again.wbc, 7.5);
      expect(again.count(DiffCell.monocyte), 1);

      final saved = await c.save(label: ' 12-namuna ');
      now = now.add(const Duration(minutes: 1));
      await c.save();
      final reloaded = DifferentialController(store);
      expect(reloaded.history, hasLength(2));
      expect(reloaded.history.last.label, '12-namuna');
      expect(reloaded.history.last.wbc, 7.5);
      expect(reloaded.record(saved!.id)!.count(DiffCell.segmented), 1);

      await reloaded.delete(saved.id);
      expect(DifferentialController(store).history, hasLength(1));
      await reloaded.clearHistory();
      expect(DifferentialController(store).history, isEmpty);
      expect(
        store.snapshot.containsKey(StoreKeys.differentialHistory),
        isFalse,
      );
    });

    test('tarix hech qachon yashirincha qisqartirilmaydi', () async {
      final store = MemoryKeyValueStore();
      var t = DateTime(2026);
      final c = DifferentialController(
        store,
        clock: () => t = t.add(const Duration(seconds: 1)),
      )..tap(DiffCell.basophil);
      for (var i = 0; i < 260; i++) {
        await c.save();
      }
      expect(c.history, hasLength(260));
      expect(DifferentialController(store).history, hasLength(260));
    });

    test('buzilgan yozuv ilovani yiqitmaydi', () async {
      final store = MemoryKeyValueStore();
      await store.setString(StoreKeys.differentialDraft, '{oops');
      await store.setString(StoreKeys.differentialHistory, '[1,2]');
      final c = DifferentialController(store);
      expect(c.total, 0);
      expect(c.history, isEmpty);
    });

    test('kalitlar StoreKeys.all da', () {
      expect(StoreKeys.all, contains(StoreKeys.differentialDraft));
      expect(StoreKeys.all, contains(StoreKeys.differentialHistory));
    });
  });

  group('kontent', () {
    Iterable<Map<String, String>> allTexts() sync* {
      for (final g in cellGuides) {
        yield* [
          g.name,
          g.size,
          g.nucleus,
          g.cytoplasm,
          g.granules,
          g.key,
        ].map((t) => t.values);
        if (g.seenIn != null) yield g.seenIn!.values;
      }
      for (final c in confusions) {
        yield c.tip.values;
        for (final (a, b, d) in c.rows) {
          yield* [a.values, b.values, d.values];
        }
      }
      for (final f in diffFindings) {
        yield* [f.title.values, f.what.values];
        yield* f.causes.map((t) => t.values);
      }
      for (final s in techniqueSections) {
        yield s.title.values;
        yield* s.items.map((t) => t.values);
      }
      yield* diffCellNames.values.map((t) => t.values);
    }

    test('har matn uch tilda, o‘zbekchada to‘g‘ri tutuq belgilari', () {
      for (final t in allTexts()) {
        for (final lang in ['uz', 'ru', 'en']) {
          expect(t[lang]?.trim(), isNotEmpty, reason: '$t');
        }
        expect(t['uz'], isNot(contains("o'")), reason: t['uz']);
        expect(t['uz'], isNot(contains("g'")), reason: t['uz']);
      }
    });

    test('har hujayra sxemasi va manbasi bor', () {
      for (final g in cellGuides) {
        expect(File(cellImage(g.id)).existsSync(), isTrue, reason: g.id);
        expect(g.refs, isNotEmpty, reason: g.id);
      }
      expect(File(cellImage('hero')).existsSync(), isTrue);
      for (final img in diffCellImage.values) {
        expect(cellGuide(img), isNotNull);
      }
      for (final c in confusions) {
        expect(cellGuide(c.a), isNotNull);
        expect(cellGuide(c.b), isNotNull);
      }
      for (final f in diffFindings) {
        expect(f.refs, isNotEmpty, reason: f.id);
      }
      for (final s in DiffSources.all) {
        expect(Uri.parse(s.url).isScheme('https'), isTrue);
      }
      // Blast — "shifokorga yuboring" ogohlantirishi bilan.
      expect(cellGuide('blast')!.refer, isTrue);
    });

    test('kengaytirilgan mashq: rasmli + tavsifli savollar', () {
      final items = buildDiffQuiz(Random(2), extended: true);
      expect(items, hasLength(diffExtendedQuizSize));
      final described = items.where((i) => !i.showImage).toList();
      expect(described, hasLength(diffQuizSize));
      for (final i in described) {
        final q = i.question;
        expect(q.options[q.correctIndex].text, cellGuide(i.image)!.name);
        for (final lang in ['uz', 'ru', 'en']) {
          expect(
            q.prompt.of(lang),
            contains(cellGuide(i.image)!.nucleus.of(lang)),
          );
        }
      }
    });

    test('"Bu qaysi hujayra?" — 10+ savol, to\'g\'ri javob rasmga mos', () {
      final items = buildDiffQuiz(Random(1));
      expect(items.length, greaterThanOrEqualTo(10));
      expect(items.map((i) => i.image).toSet(), hasLength(items.length));
      for (final i in items) {
        final q = i.question;
        expect(q.options, hasLength(4));
        expect(q.options[q.correctIndex].text, cellGuide(i.image)!.name);
        expect(
          q.options.map((o) => o.text.of('en')).toSet(),
          hasLength(4),
          reason: i.image,
        );
      }
    });
  });
}
