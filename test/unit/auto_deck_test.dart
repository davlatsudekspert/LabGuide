// Avtomatik taqdimot builder (D-47): faqat manbali mazmun, mazmun yetmasa
// slayd chiqmaydi, har slaydda manba, uch til (tillar aralashmaydi).
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/auto_deck.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_slide.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/microscopy/microscopy_atlas.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';

const _langs = ['uz', 'ru', 'en'];

Map<String, Object?> _json(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, Object?>();

AppLocalizations _l(String lang) => lookupAppLocalizations(Locale(lang));

// ---- sintetik karta (tekshiruv uchun to'g'ridan-to'g'ri qurilgan) ----

const _src = ContentSource(
  id: 's1',
  kind: 'web',
  title: 'Test page',
  publisher: 'Test publisher',
  url: 'https://example.org/page',
  accessed: '2026-10-01',
  reuseRights: 'verify_before_distribution',
);

LocalizedText _t(String uz, String ru, String en) =>
    LocalizedText({'uz': uz, 'ru': ru, 'en': en});

Claim _claim(String section, LocalizedText text, {List<SourceRef>? refs}) =>
    Claim(
      section: section,
      text: text,
      refs: refs ?? const [SourceRef('s1', locator: 'Sec 1')],
    );

Analyte _card({
  String id = 'card-1',
  LocalizedText? names,
  ContentState state = ContentState.sourcedSample,
  List<String> sections = const ['purpose', 'high_result', 'low_result'],
  List<Claim> claims = const [],
  List<String> sourceIds = const ['s1'],
}) => Analyte(
  id: id,
  status: ContentStatus.draft,
  contentState: state,
  names: names ?? _t('Karta', 'Карта', 'Card'),
  synonyms: const [],
  group: 'g',
  units: const ['mg/dL'],
  sections: sections,
  claims: claims,
  decisionLimits: const [],
  referenceIntervals: const [],
  sourceIds: sourceIds,
  reviewState: ReviewState.pending,
  translationReview: const {},
  related: const [],
  instrumentBinding: const InstrumentBinding(),
);

ContentPack _pack(
  List<Analyte> analytes, {
  List<QuizQuestion> quiz = const [],
}) => ContentPack(
  packId: 'test',
  schemaVersion: 1,
  contentVersion: 'test-1',
  groups: [AnalyteGroup(id: 'g', names: _t('Guruh', 'Группа', 'Group'))],
  analytes: analytes,
  sources: const [_src],
  quiz: quiz,
  ifuRecords: const [],
);

QuizQuestion _quiz(String id, String analyte, {List<SourceRef>? refs}) =>
    QuizQuestion(
      id: id,
      prompt: _t('Savol $id', 'Вопрос $id', 'Question $id'),
      options: [
        QuizOption(
          text: _t('A uz', 'A ru', 'A en'),
          explanation: _t('Ha uz', 'Да ru', 'Yes en'),
        ),
        QuizOption(
          text: _t('B uz', 'B ru', 'B en'),
          explanation: _t('Yo‘q uz', 'Нет ru', 'No en'),
        ),
      ],
      correctIndex: 0,
      basis: _t('asos', 'основа', 'basis'),
      refs: refs ?? const [SourceRef('s1')],
      reviewState: ReviewState.pending,
      topicIds: [analyte],
    );

void main() {
  late ContentPack pack;
  late MicroAtlas atlas;
  late Curriculum cur;
  setUpAll(() {
    pack = ContentPack.fromJson(_json('assets/content/core/pack.json'));
    atlas = MicroAtlas.fromJson(_json('assets/microscopy/atlas.json'));
    cur = Curriculum.parse(
      File('assets/curriculum/curriculum.json').readAsStringSync(),
    );
  });

  AutoDeck build(
    String lang,
    AutoDeckSpec spec, {
    ContentPack? p,
    bool withTopic = false,
  }) => buildAutoDeck(
    l: _l(lang),
    pack: p ?? pack,
    spec: spec,
    curriculum: withTopic ? cur : null,
    atlas: atlas,
  );

  const ids = ['glucose-plasma-fasting', 'ldl-c', 'ferritin'];

  group('haqiqiy kontent paketidan (uz/ru/en)', () {
    for (final lang in _langs) {
      test('faqat kartadagi matn; har slaydda manba ($lang)', () {
        final l = _l(lang);
        final deck = build(lang, const AutoDeckSpec(analyteIds: ids));
        expect(deck.isEmpty, isFalse);
        expect(deck.slides.first.kind, AutoSlideKind.title);
        expect(deck.slides.first.slide.template, SlideTemplate.title);

        // Kartalardagi barcha tekshirilgan matnlar (shu tilda).
        final allowed = <String>{};
        for (final id in ids) {
          final a = pack.analyte(id)!;
          for (final c in a.claims) {
            allowed.add(c.text.values[lang]!.trim());
          }
        }
        final bulletKinds = {
          AutoSlideKind.definition,
          AutoSlideKind.increase,
          AutoSlideKind.decrease,
          AutoSlideKind.result,
          AutoSlideKind.preanalytics,
          AutoSlideKind.interference,
        };
        var claimSlides = 0;
        for (final s in deck.slides) {
          // Har slaydda manba: ko'rinadigan qator ham, ro'yxat ham.
          expect(s.slide.source, isNotNull, reason: s.slide.title);
          expect(
            s.slide.source!.trim().length,
            greaterThan(l.autoPresSourceLine('').length),
            reason: s.slide.title,
          );
          expect(s.sources, isNotEmpty, reason: s.slide.title);
          if (bulletKinds.contains(s.kind)) {
            claimSlides++;
            expect(s.slide.bullets, isNotEmpty);
            for (final b in s.slide.bullets) {
              expect(allowed, contains(b), reason: '"$b" kartada yo‘q');
            }
          }
        }
        expect(claimSlides, greaterThan(4));
      });
    }

    test(
      'qaror chegarasi jadvali: manbadagi qiymat va birlik, "me‘yor emas"',
      () {
        for (final lang in _langs) {
          final l = _l(lang);
          final deck = build(
            lang,
            const AutoDeckSpec(analyteIds: ['glucose-plasma-fasting']),
          );
          final table = deck.slides.firstWhere(
            (s) => s.kind == AutoSlideKind.limits,
          );
          expect(table.slide.template, SlideTemplate.table);
          expect(table.slide.title, startsWith(l.analyteDecisionLimits));
          final a = pack.analyte('glucose-plasma-fasting')!;
          final labels = {
            for (final d in a.decisionLimits) d.label.values[lang],
          };
          for (final row in table.slide.tableRows) {
            expect(labels, contains(row[0]));
            expect(
              row[1].replaceAll('\u2060', ''),
              contains('mg/dL'),
            ); // birlik manbadagidek
          }
          // Chegara referens interval emas — slaydning o'zida aytiladi.
          expect(table.slide.note, l.analyteDecisionNotRef);
        }
      },
    );

    test('davolash maqsadlari: eskirgan yo‘riqnoma kirmaydi', () {
      final deck = build('ru', const AutoDeckSpec(analyteIds: ['ldl-c']));
      final goals = deck.slides.where((s) => s.kind == AutoSlideKind.goals);
      expect(goals, isNotEmpty);
      final ldl = pack.analyte('ldl-c')!;
      final historical = {
        for (final g in ldl.treatmentGoals)
          if (g.historical) g.guidelineName,
      };
      expect(historical, isNotEmpty);
      for (final s in goals) {
        for (final h in historical) {
          expect(s.slide.eyebrow, isNot(contains(h)));
        }
        expect(s.slide.note, contains(_l('ru').analyteTreatmentGoalsNotRef));
      }
    });

    test('slayd hajmi cheklangan (bandlar ≤ 3, jadval qatorlari ≤ 4)', () {
      for (final lang in _langs) {
        final deck = build(
          lang,
          const AutoDeckSpec(
            topicId: 'd007-P',
            includeGeneralPreanalytics: true,
          ),
          withTopic: true,
        );
        for (final s in deck.slides) {
          expect(s.slide.bullets.length, lessThanOrEqualTo(7));
          if (s.slide.template == SlideTemplate.bullets) {
            expect(s.slide.bullets.length, lessThanOrEqualTo(3));
          }
          expect(s.slide.tableRows.length, lessThanOrEqualTo(4));
          for (final r in s.slide.tableRows) {
            expect(r.length, greaterThanOrEqualTo(2));
          }
        }
      }
    });

    test('mavzu: 5 shablonning hammasi, atlas fayli mavjud', () {
      final deck = build(
        'ru',
        const AutoDeckSpec(topicId: 'd014-P', includeGeneralPreanalytics: true),
        withTopic: true,
      );
      final templates = {for (final s in deck.slides) s.slide.template};
      expect(templates, SlideTemplate.values.toSet());
      final figure = deck.slides.firstWhere(
        (s) => s.slide.template == SlideTemplate.figure,
      );
      expect(File(figure.slide.figure!).existsSync(), isTrue);
      expect(figure.slide.figureCaption, isNotEmpty);
      // Rasm litsenziyasi manbada ko'rsatiladi.
      expect(figure.slide.source, anyOf(contains('CC'), contains('CDC PHIL')));
      // Probirka jadvali rang belgilari bilan, JSST manbasi.
      final tubes = deck.slides.firstWhere(
        (s) => s.slide.rowSwatches.isNotEmpty,
      );
      expect(tubes.slide.rowSwatches.length, tubes.slide.tableRows.length);
      expect(tubes.sources.single.id, 'who-phlebotomy-2010');
    });

    test('mavzu: klinik holat va jadvallar manbalari', () {
      final deck = build(
        'en',
        const AutoDeckSpec(topicId: 'd007-P', includeQuiz: false),
        withTopic: true,
      );
      expect(
        deck.slides.where((s) => s.kind == AutoSlideKind.condition),
        isNotEmpty,
      );
      final refs = deck.slides.where((s) => s.kind == AutoSlideKind.reference);
      expect(refs, isNotEmpty);
      for (final s in refs) {
        expect(s.sources, isNotEmpty);
        expect(s.slide.source, isNotEmpty);
      }
    });
  });

  group('savol-javob', () {
    test('faqat manbali savol; kalit va tushuntirish; o‘chirish mumkin', () {
      for (final lang in _langs) {
        final deck = build(lang, const AutoDeckSpec(analyteIds: ids));
        final qa = deck.slides.where((s) => s.kind == AutoSlideKind.quiz);
        expect(qa, isNotEmpty);
        expect(qa.length, lessThanOrEqualTo(ids.length * autoQuizPerAnalyte));
        for (final s in qa) {
          expect(s.slide.template, SlideTemplate.qa);
          expect(s.slide.options.length, greaterThanOrEqualTo(2));
          expect(
            s.slide.correctIndex,
            inInclusiveRange(0, s.slide.options.length - 1),
          );
          expect(s.slide.answerExplanation, isNotEmpty);
          expect(s.sources, isNotEmpty);
        }
        final off = build(
          lang,
          const AutoDeckSpec(analyteIds: ids, includeQuiz: false),
        );
        expect(off.slides.where((s) => s.kind == AutoSlideKind.quiz), isEmpty);
      }
    });

    test('manbasiz yoki manbasi paketda yo‘q savol chiqmaydi', () {
      final card = _card(
        claims: [_claim('purpose', _t('uz matn', 'ru текст', 'en text'))],
      );
      final p = _pack(
        [card],
        quiz: [
          _quiz('ok', 'card-1'),
          _quiz('nosrc', 'card-1', refs: const []),
          _quiz('ghost', 'card-1', refs: const [SourceRef('missing')]),
        ],
      );
      final deck = build(
        'en',
        const AutoDeckSpec(analyteIds: ['card-1']),
        p: p,
      );
      final qa = deck.slides.where((s) => s.kind == AutoSlideKind.quiz);
      expect(qa.map((s) => s.slide.title), ['Question ok']);
    });
  });

  group('mazmun yetmasa slayd chiqmaydi', () {
    test('noma‘lum tahlil — bo‘sh taqdimot (sarlavha ham yo‘q)', () {
      final deck = build('ru', const AutoDeckSpec(analyteIds: ['nope']));
      expect(deck.isEmpty, isTrue);
      expect(deck.slides, isEmpty);
    });

    test('faqat tuzilmali karta — o‘tkaziladi va aytiladi', () {
      final l = _l('uz');
      final empty = _card(
        id: 'empty',
        names: _t('Bo‘sh karta', 'Пустая', 'Empty card'),
        state: ContentState.structureOnly,
        sourceIds: const [],
      );
      final full = _card(
        claims: [_claim('purpose', _t('uz matn', 'ru текст', 'en text'))],
      );
      final p = _pack([empty, full]);
      final deck = build(
        'uz',
        const AutoDeckSpec(analyteIds: ['empty', 'card-1']),
        p: p,
      );
      expect(
        deck.notices,
        contains(l.autoPresNoticeStructureOnly('Bo‘sh karta')),
      );
      expect(deck.slides.where((s) => s.slide.title == 'Bo‘sh karta'), isEmpty);
      expect(deck.slides.any((s) => s.slide.title == 'Karta'), isTrue);
      final only = build('uz', const AutoDeckSpec(analyteIds: ['empty']), p: p);
      expect(only.isEmpty, isTrue);
    });

    test(
      'da‘vosi yo‘q bo‘limlar uchun slayd yo‘q (oshishi/pasayishi to‘qilmaydi)',
      () {
        final card = _card(
          claims: [_claim('purpose', _t('uz matn', 'ru текст', 'en text'))],
        );
        final deck = build(
          'en',
          const AutoDeckSpec(analyteIds: ['card-1'], includeQuiz: false),
          p: _pack([card]),
        );
        final kinds = deck.slides.map((s) => s.kind).toSet();
        expect(kinds, {
          AutoSlideKind.title,
          AutoSlideKind.intro,
          AutoSlideKind.definition,
        });
      },
    );

    test('kartada matn yo‘q (faqat umumiy qator) — butunlay o‘tkaziladi', () {
      final l = _l('en');
      final deck = build(
        'en',
        const AutoDeckSpec(analyteIds: ['card-1']),
        p: _pack([_card()]),
      );
      expect(deck.isEmpty, isTrue);
      expect(deck.notices, contains(l.autoPresNoticeNoContent('Card')));
    });

    test('manbasi paketda yo‘q da‘vo olinmaydi', () {
      final card = _card(
        claims: [
          _claim('purpose', _t('uz yaxshi', 'ru хорошо', 'en good')),
          _claim(
            'purpose',
            _t('uz manbasiz', 'ru без источника', 'en unsourced'),
            refs: const [SourceRef('ghost')],
          ),
          _claim(
            'purpose',
            _t('uz bo‘sh', 'ru пусто', 'en empty'),
            refs: const [],
          ),
        ],
      );
      final deck = build(
        'en',
        const AutoDeckSpec(analyteIds: ['card-1']),
        p: _pack([card]),
      );
      final texts = [for (final s in deck.slides) ...s.slide.bullets];
      expect(texts, contains('en good'));
      expect(texts, isNot(contains('en unsourced')));
      expect(texts, isNot(contains('en empty')));
    });
  });

  group('til: aralashtirilmaydi', () {
    test('tilda yo‘q matn tashlanadi va aytiladi', () {
      final card = _card(
        claims: [
          _claim('purpose', _t('uz bor', 'ru есть', 'en has')),
          _claim(
            'purpose',
            const LocalizedText({'uz': 'faqat uz', 'en': 'only en'}),
          ),
        ],
      );
      final p = _pack([card]);
      const spec = AutoDeckSpec(analyteIds: ['card-1'], includeQuiz: false);

      final ru = build('ru', spec, p: p);
      final ruTexts = [for (final s in ru.slides) ...s.slide.bullets];
      expect(ruTexts, contains('ru есть'));
      expect(ruTexts, isNot(contains('faqat uz')));
      expect(ruTexts, isNot(contains('only en')));
      expect(ru.skippedForLanguage, greaterThan(0));
      expect(
        ru.notices,
        contains(_l('ru').autoPresNoticeLang(ru.skippedForLanguage)),
      );
      // Sarlavha slaydida ham aytiladi.
      expect(
        ru.slides.first.slide.note,
        contains(_l('ru').autoPresNoticeLang(ru.skippedForLanguage)),
      );

      final uz = build('uz', spec, p: p);
      expect([
        for (final s in uz.slides) ...s.slide.bullets,
      ], contains('faqat uz'));
      expect(uz.skippedForLanguage, 0);
      expect(uz.notices, isEmpty);
    });

    test('nomi tilda yo‘q karta — butunlay o‘tkaziladi', () {
      final card = _card(
        names: const LocalizedText({'uz': 'Nom', 'en': 'Name'}),
        claims: [_claim('purpose', _t('uz', 'ru', 'en'))],
      );
      final deck = build(
        'ru',
        const AutoDeckSpec(analyteIds: ['card-1']),
        p: _pack([card]),
      );
      expect(deck.isEmpty, isTrue);
      expect(deck.skippedForLanguage, greaterThan(0));
    });

    test('ru: ruscha matn (kirillcha), uz: o‘zbekcha (lotin)', () {
      final ru = build('ru', const AutoDeckSpec(analyteIds: ['ferritin']));
      expect(ru.slides.first.slide.title, 'Лабораторные анализы');
      expect(RegExp('[а-яА-Я]').hasMatch(ru.slides[1].slide.title), isTrue);
      final uz = build('uz', const AutoDeckSpec(analyteIds: ['ferritin']));
      expect(uz.slides.first.slide.title, 'Laboratoriya tahlillari');
    });
  });

  group('yakuniy deck va manbalar slaydi', () {
    test('qolgan slaydlarning manbalari, olib tashlanganlari yo‘q', () {
      for (final lang in _langs) {
        final l = _l(lang);
        final deck = build(
          lang,
          const AutoDeckSpec(
            analyteIds: ['glucose-plasma-fasting', 'ldl-c'],
            includeQuiz: false,
          ),
        );
        final glucose = pack.analyte('glucose-plasma-fasting')!;
        final ldlOnly = deck.slides
            .where(
              (s) =>
                  s.kind == AutoSlideKind.title ||
                  s.slide.eyebrow ==
                      pack.analyte('ldl-c')!.names.values[lang] ||
                  (s.slide.eyebrow ?? '').startsWith(
                    pack.analyte('ldl-c')!.names.values[lang]!,
                  ),
            )
            .toList();
        expect(ldlOnly.length, lessThan(deck.slides.length));
        final all = assembleAutoDeck(l, deck, deck.slides);
        final some = assembleAutoDeck(l, deck, ldlOnly);

        String sourcesText(List<LectureSlide> s) => s
            .where((x) => x.title.startsWith(l.analyteSources))
            .expand((x) => x.bullets)
            .join('\n');
        // Hamma slaydlar: glyukoza manbasi bor; faqat LDL: yo'q.
        final glucoseLabel = pack.source(glucose.sourceIds.first)!.title;
        expect(sourcesText(all), contains(glucoseLabel));
        expect(sourcesText(some), isNot(contains(glucoseLabel)));
        // Manbalar slaydi har doim oxirida va o'zining manbasi bor.
        expect(some.last.title, startsWith(l.analyteSources));
        expect(some.last.source, isNotEmpty);
        // Tarkibiy slaydlar o'z tartibida, oxirida faqat manbalar.
        expect(
          some.sublist(0, ldlOnly.length).map((s) => s.title),
          ldlOnly.map((s) => s.slide.title),
        );
        for (final s in some.sublist(ldlOnly.length)) {
          expect(s.title, startsWith(l.analyteSources));
        }
      }
    });

    test('hamma slayd olib tashlansa — bo‘sh', () {
      final deck = build('en', const AutoDeckSpec(analyteIds: ids));
      expect(assembleAutoDeck(_l('en'), deck, const []), isEmpty);
    });

    test('umumiy preanalitika: JSST manbasi, faqat yoqilganda', () {
      final off = build('uz', const AutoDeckSpec(analyteIds: ids));
      expect(off.slides.where((s) => s.kind == AutoSlideKind.general), isEmpty);
      final on = build(
        'uz',
        const AutoDeckSpec(analyteIds: ids, includeGeneralPreanalytics: true),
      );
      final gen = on.slides.where((s) => s.kind == AutoSlideKind.general);
      expect(gen, isNotEmpty);
      for (final s in gen) {
        expect(s.sources.single.id, 'who-phlebotomy-2010');
        expect(s.slide.source, contains('WHO'));
      }
    });
  });
}
