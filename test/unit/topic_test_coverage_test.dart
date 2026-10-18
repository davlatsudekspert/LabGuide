// docs/TOPIC_TEST_COVERAGE.md — mavzu testlari uchun tekshirilgan savollar
// qamrovi. Hujjat ilovadagi aynan shu tanlov qoidasi (topic_test.dart) bilan
// hisoblanadi; bank yoki o'quv dasturi o'zgarsa test yiqiladi va hujjatni
// yangilash kerak:
//
//   LG_WRITE_COVERAGE=1 flutter test test/unit/topic_test_coverage_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/toifa/toifa_bank.dart';

const _path = 'docs/TOPIC_TEST_COVERAGE.md';

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

typedef _Row = ({
  CurriculumTopic t,
  int n,
  int toifa,
  int pack,
  int derived,
  int excluded,
  String? deck,
});

String _cell(String s) => s.replaceAll('|', '/').replaceAll('\n', ' ');

String buildCoverage() {
  final cur = Curriculum.parse(
    File('assets/curriculum/curriculum.json').readAsStringSync(),
  );
  final pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
  final bank = ToifaBank.fromJson(
    _json('assets/toifa/kdl_tests.json'),
    _json('assets/toifa/kdl_oral.json'),
  );
  final catalog = DeckCatalog.parse(
    File('assets/lectures/index_v2.json').readAsStringSync(),
  );
  final source = PackQuestionSource.of(pack);

  final rows = <_Row>[
    for (final t in cur.topics)
      () {
        final pool = verifiedTopicQuestions(t, pack, bank);
        final toifaOk = pool.whereType<ToifaTestQuestion>().length;
        final derivedIds = t.derivedQuizCandidates.toSet();
        final derivedOk = pool.where((q) => derivedIds.contains(q.id)).length;
        final packOk = pool.length - toifaOk - derivedOk;
        final toifaExcluded =
            t.testCandidates.where((id) => bank.test(id) != null).length -
            toifaOk;
        final packExcluded =
            t.packQuizCandidates
                .where((id) => source.question(id) != null)
                .length -
            packOk;
        final derivedExcluded =
            t.derivedQuizCandidates
                .where((id) => source.question(id) != null)
                .length -
            derivedOk;
        return (
          t: t,
          n: pool.length,
          toifa: toifaOk,
          pack: packOk,
          derived: derivedOk,
          excluded: toifaExcluded + packExcluded + derivedExcluded,
          deck: catalog.byTopic(t.id)?.id,
        );
      }(),
  ];
  String table(Iterable<_Row> list) {
    final b = StringBuffer()
      ..writeln(
        '| Mavzu | Nomi | Toifa (ok) | Paket (manbali) | Deck matnidan | Jami | Chiqarilgan nomzod | test_gap | Deck |',
      )
      ..writeln('|---|---|---:|---:|---:|---:|---:|:-:|---|');
    for (final r in list) {
      final t = r.t;
      b.writeln(
        '| ${t.id} | ${_cell(t.title.of('uz'))} | ${r.toifa} | ${r.pack} | '
        '${r.derived} | **${r.n}** | ${r.excluded} | ${t.testGap ? 'ha' : ''} | '
        '${r.deck ?? '—'} |',
      );
    }
    return b.toString();
  }

  final zero = rows.where((r) => r.n == 0).toList();
  final few = rows.where((r) => r.n > 0 && r.n < kTopicTestMin).toList();
  final under5 = rows.where((r) => r.n >= kTopicTestMin && r.n < 5).toList();
  final mid = rows.where((r) => r.n >= 5 && r.n < 10).toList();
  final full = rows.where((r) => r.n >= 10).toList();
  final gapWithQuestions = rows.where((r) => r.t.testGap && r.n > 0).toList();
  final zeroNoGap = rows.where((r) => !r.t.testGap && r.n == 0).toList();

  final decks = [
    for (final d in catalog.decks)
      (d: d, pool: deckQuestionPool(d, cur, pack, bank)),
  ];
  int deckCount(DeckTestState s) =>
      decks.where((e) => deckTestState(e.d, e.pool) == s).length;

  final b = StringBuffer()
    ..writeln('# Mavzu testlari: savollar qamrovi')
    ..writeln()
    ..writeln(
      'Har taqdimot (deck) oxiridagi **Mavzu testi** faqat shu mavzuga '
      'bog‘langan, **tekshirilgan** savollardan tuziladi (10 ta; kam bo‘lsa — '
      'boricha; $kTopicTestMin tadan kam bo‘lsa — “Bu mavzu uchun savollar '
      'tayyorlanmoqda”). Savollar o‘ylab topilmaydi.',
    )
    ..writeln()
    ..writeln('Tekshirilgan savol deganda:')
    ..writeln()
    ..writeln(
      '- **Toifa** — `curriculum.json` → `test_candidates.ids` dagi rasmiy '
      'ro‘yxat savoli: kaliti bor, chiqarilmagan (`held` yo‘q), LabGuide '
      'kalit tekshiruvi `verdict: ok` va izohi tasdiqlangan (`unverified` '
      'emas). `ambiguous`/`disputed` savollar testga kirmaydi.',
    )
    ..writeln(
      '- **Paket** — `test_candidates.pack_quiz_ids` dagi mashq savoli, '
      'manbasi (`refs`) ko‘rsatilgan.',
    )
    ..writeln(
      '- **Deck matnidan** — `test_candidates.derived_quiz_ids` dagi paket '
      'savoli (`provenance: derived`, manba fayli '
      '`content_src/additions/derived_topic_quiz.json`): har biri deck '
      'slaydidagi manbali gapdan olingan; `derived_from` da deck, slayd '
      'sarlavhasi, asl manba yorlig‘i va o‘sha gap (uz/ru/en) saqlangan, '
      '`test/unit/derived_quiz_test.dart` gap slaydda borligini tekshiradi.',
    )
    ..writeln(
      '- Hammasida: bitta to‘g‘ri javob, uchala tilda variantlar '
      'takrorlanmaydi.',
    )
    ..writeln()
    ..writeln(
      'Hujjat `test/unit/topic_test_coverage_test.dart` bilan ilovadagi '
      'aynan shu qoida (`lib/features/classroom/topic_test.dart`) bo‘yicha '
      'yoziladi: `LG_WRITE_COVERAGE=1 flutter test '
      'test/unit/topic_test_coverage_test.dart`.',
    )
    ..writeln()
    ..writeln('## Xulosa')
    ..writeln()
    ..writeln('| | Mavzular |')
    ..writeln('|---|---:|')
    ..writeln('| Jami mavzu | ${rows.length} |')
    ..writeln('| 0 ta savol | ${zero.length} |')
    ..writeln(
      '| 1–${kTopicTestMin - 1} ta (test o‘tkazilmaydi) | ${few.length} |',
    )
    ..writeln('| $kTopicTestMin–4 ta | ${under5.length} |')
    ..writeln(
      '| **< 5 ta (jami, 0 bilan)** | ${zero.length + few.length + under5.length} |',
    )
    ..writeln('| 5–9 ta | ${mid.length} |')
    ..writeln('| **≥ 10 ta** (to‘liq 10 savollik test) | ${full.length} |')
    ..writeln(
      '| `test_gap: true` belgisi | ${rows.where((r) => r.t.testGap).length} |',
    )
    ..writeln()
    ..writeln('Taqdimotlar (${decks.length} ta):')
    ..writeln()
    ..writeln('| Holat | Decklar |')
    ..writeln('|---|---:|')
    ..writeln(
      '| Test tayyor (≥ $kTopicTestMin savol) | ${deckCount(DeckTestState.ready)} |',
    )
    ..writeln(
      '| “Savollar tayyorlanmoqda” (< $kTopicTestMin) | ${deckCount(DeckTestState.preparing)} |',
    )
    ..writeln(
      '| Tugma yo‘q — amaliy protokol, mavzuga bog‘lanmagan | '
      '${deckCount(DeckTestState.hidden)} |',
    )
    ..writeln()
    ..writeln(
      'Amaliy protokol decklari (`index_v2.json` da `topics: []`) hech '
      'qaysi mavzu yoki analitga bog‘lanmagan — ularda test tugmasi '
      'ko‘rsatilmaydi. Bog‘lash uchun eksportga (`tool/slides/'
      'export_app_decks.py`) mavzu/analit havolasi qo‘shilishi kerak '
      '(mutaxassis tanlovi bilan).',
    )
    ..writeln()
    ..writeln(
      '“Chiqarilgan nomzod” — curriculum nomzodlari ichida tekshiruvdan '
      'o‘tmaganlari (toifa: kalit `ok` emas yoki izoh tasdiqlanmagan; paket: '
      'manbasiz). Ular mutaxassis ko‘rib chiqsa, testga qo‘shilishi mumkin.',
    )
    ..writeln()
    ..writeln('## Yangi savollar qanday qo‘shiladi')
    ..writeln()
    ..writeln(
      'Deck matnidan olingan savollar faqat deck slaydidagi manbali gapga '
      'tayanadi: kalit va xato variantlar o‘sha manbadan; noaniq, eskirgan '
      'yoki ilovadagi boshqa gapga zid savollar ikkinchi (taqrizchi) '
      'bosqichda o‘chirilgan. Ular ham `review_state: pending` — mutaxassis '
      'ko‘rigi kutilmoqda. Slaydlarida manba ko‘rsatilmagan deck (d001) uchun '
      'bunday savol yozilmaydi.',
    )
    ..writeln()
    ..writeln(
      'Boshqa yo‘l: qoralama uchun `tool/ai` '
      '(AI yordamida qoralama) bor, lekin uning natijasi **mutaxassis '
      'tekshiruvisiz** testga kirmaydi: savol bankka manbasi bilan qo‘shilib, '
      'kaliti tekshirilgach (`verdict: ok` yoki `refs`), mavzuning '
      '`test_candidates` ro‘yxatiga yoziladi — shundan keyin test o‘zi paydo '
      'bo‘ladi.',
    )
    ..writeln()
    ..writeln('## 0 ta savol (${zero.length})')
    ..writeln()
    ..write(table(zero))
    ..writeln()
    ..writeln(
      '`test_gap` belgisi yo‘q, lekin savoli 0 ta mavzular: '
      '${zeroNoGap.length} ta (asosan 91–142-kunlar amaliyoti: '
      'curriculum’da nomzod ro‘yxati bo‘sh).',
    )
    ..writeln()
    ..writeln(
      '## 1–${kTopicTestMin - 1} ta savol — test o‘tkazilmaydi (${few.length})',
    )
    ..writeln()
    ..write(table(few))
    ..writeln()
    ..writeln('## $kTopicTestMin–4 ta savol (${under5.length})')
    ..writeln()
    ..write(table(under5))
    ..writeln()
    ..writeln('## 5–9 ta savol (${mid.length})')
    ..writeln()
    ..write(table(mid))
    ..writeln()
    ..writeln('## ≥ 10 ta savol (${full.length})')
    ..writeln()
    ..write(table(full))
    ..writeln()
    ..writeln(
      '## `test_gap` belgisi bor, lekin bir nechta savol topilgan '
      '(${gapWithQuestions.length})',
    )
    ..writeln()
    ..writeln(
      'Belgi curriculum’da “savollar yetarli emas” degani; bu mavzularda '
      'tekshirilgan savol bor, lekin test uchun kamida $kTopicTestMin ta kerak.',
    )
    ..writeln()
    ..write(table(gapWithQuestions))
    ..writeln()
    ..writeln('## Taqdimotlar bo‘yicha')
    ..writeln()
    ..writeln('| Deck | Mavzular | Savollar | Holat |')
    ..writeln('|---|---|---:|---|');
  for (final e in decks) {
    final s = deckTestState(e.d, e.pool);
    b.writeln(
      '| ${e.d.id} | ${e.d.topics.isEmpty ? '—' : e.d.topics.join(', ')} | '
      '${e.pool.length} | ${switch (s) {
        DeckTestState.ready => 'tayyor',
        DeckTestState.preparing => 'tayyorlanmoqda',
        DeckTestState.hidden => 'tugma yo‘q',
      }} |',
    );
  }
  return b.toString();
}

void main() {
  test('docs/TOPIC_TEST_COVERAGE.md hozirgi bank va dastur bilan mos', () {
    final doc = buildCoverage();
    if (Platform.environment['LG_WRITE_COVERAGE'] == '1') {
      File(_path).writeAsStringSync(doc);
    }
    expect(
      File(_path).readAsStringSync(),
      doc,
      reason: 'LG_WRITE_COVERAGE=1 bilan qayta yozing',
    );
  });
}
