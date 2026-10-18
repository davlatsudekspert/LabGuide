// Deck matnidan olingan mavzu testi savollari (provenance `derived`,
// content_src/additions/derived_topic_quiz.json → pack.json):
//
// * har savolning `derived_from` ko'rsatkichi ochiladi: uz deckda shu
//   sarlavhali slayd bor va gap (fact.uz) o'sha slayd matnida; ru/en gap shu
//   deckning ru/en faylida; `also_decks` dagi decklarda ham uchala tilda;
// * kalit gapda: to'g'ri uz variantdagi har raqam gapda ham bor;
// * variantlar har tilda takrorlanmaydi, uz/ru/en variantlar soni teng;
// * manba (`refs`) paketda bor; savol mavzu testi filtridan o'tadi;
// * curriculum `derived_quiz_ids` faqat mavjud derived savollarga ishora
//   qiladi, har derived savol kamida bitta mavzuda, faqat o'z deck(lar)i
//   mavzularida; decksiz umumiy amaliyot kunlari bo'sh qoladi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/curriculum.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/topic_test.dart';
import 'package:labguide/features/content/analyte_search.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/learn/exam_question.dart';

const _langs = ['uz', 'ru', 'en'];

/// Slayd matniga kirmaydigan maydonlar (indeks, rasm, shablon).
const _skipKeys = {
  'src',
  'ref',
  'image',
  'images',
  'credit',
  'side',
  'cat',
  'template',
};

Object? _read(String path) => jsonDecode(File(path).readAsStringSync());

String _norm(String s) => s
    .replaceAll(' ', ' ')
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .join(' ');

void _strings(Object? v, List<String> out) {
  switch (v) {
    case final String s:
      out.add(s);
    case final List<Object?> l:
      for (final x in l) {
        _strings(x, out);
      }
    case final Map<Object?, Object?> m:
      for (final e in m.entries) {
        if (_skipKeys.contains(e.key)) continue;
        _strings(e.value, out);
      }
  }
}

String _text(Object? v) {
  final out = <String>[];
  _strings(v, out);
  return _norm(out.join(' '));
}

final _deckCache = <String, List<Map<String, Object?>>>{};

List<Map<String, Object?>>? _slides(String deck, String lang) {
  final key = '$deck.$lang';
  if (_deckCache.containsKey(key)) return _deckCache[key];
  final f = File('assets/lectures/decks/$key.json');
  if (!f.existsSync()) return null;
  final j = (_read(f.path)! as Map).cast<String, Object?>();
  return _deckCache[key] = [
    for (final s in (j['slides']! as List)) (s as Map).cast<String, Object?>(),
  ];
}

String? _deckText(String deck, String lang) {
  final s = _slides(deck, lang);
  return s == null ? null : _text(s);
}

final _num = RegExp(r'\d+(?:[.,]\d+)?');

void main() {
  final rawPack = (_read('assets/content/core/pack.json')! as Map)
      .cast<String, Object?>();
  final pack = ContentPack.fromJson(rawPack);
  final source = PackQuestionSource.of(pack);
  final sourceIds = {for (final s in pack.sources) s.id};
  final derived = [
    for (final q in (rawPack['quiz']! as List))
      if ((q as Map)['provenance'] == 'derived') q.cast<String, Object?>(),
  ];
  final cur = Curriculum.parse(
    File('assets/curriculum/curriculum.json').readAsStringSync(),
  );
  final catalog = DeckCatalog.parse(
    File('assets/lectures/index_v2.json').readAsStringSync(),
  );

  test('derived savollar bor va id lari drv- bilan boshlanadi', () {
    expect(derived, isNotEmpty);
    for (final q in derived) {
      expect(q['id'], startsWith('drv-'));
    }
  });

  test('derived_from ko‘rsatkichi ochiladi va gap slayd matnida', () {
    final problems = <String>[];
    for (final q in derived) {
      final id = q['id']! as String;
      final from = (q['derived_from']! as Map).cast<String, Object?>();
      final deck = from['deck']! as String;
      final title = from['slide']! as String;
      final fact = (from['fact']! as Map).cast<String, Object?>();
      expect((from['source_label'] as String?) ?? '', isNotEmpty, reason: id);
      for (final l in _langs) {
        final f = _norm(fact[l]! as String);
        if (f.length < 18) problems.add('$id: $l gap juda qisqa');
      }
      final uz = _slides(deck, 'uz');
      if (uz == null) {
        problems.add('$id: $deck.uz.json yo‘q');
        continue;
      }
      final titled = uz.where((s) => s['title'] == title).toList();
      if (titled.isEmpty) {
        problems.add('$id: $deck da «$title» slaydi yo‘q');
      } else if (!_text(titled).contains(_norm(fact['uz']! as String))) {
        problems.add('$id: uz gap «$title» slaydida yo‘q');
      }
      for (final l in ['ru', 'en']) {
        final t = _deckText(deck, l);
        if (t == null || !t.contains(_norm(fact[l]! as String))) {
          problems.add('$id: $l gap $deck.$l.json da yo‘q');
        }
      }
      for (final other in (from['also_decks'] as List? ?? const [])) {
        for (final l in _langs) {
          final t = _deckText(other as String, l);
          if (t == null || !t.contains(_norm(fact[l]! as String))) {
            problems.add('$id: $l gap $other.$l.json da yo‘q');
          }
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('kalit gapda: to‘g‘ri uz variantdagi raqamlar gapda bor', () {
    final problems = <String>[];
    for (final q in derived) {
      final id = q['id']! as String;
      final fact =
          ((q['derived_from']! as Map)['fact']! as Map)['uz']! as String;
      final factNums = _num.allMatches(fact).map((m) => m.group(0)).toSet();
      final options = q['options']! as List;
      final correct = q['correct_index']! as int;
      final text =
          (((options[correct] as Map)['text']! as Map)['uz']! as String);
      for (final m in _num.allMatches(text)) {
        if (!factNums.contains(m.group(0))) {
          problems.add('$id: «${m.group(0)}» gapda yo‘q');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('variantlar: uch tilda soni teng, takrorlanmaydi; manba va filtr', () {
    final problems = <String>[];
    for (final raw in derived) {
      final id = raw['id']! as String;
      final options = raw['options']! as List;
      final counts = {
        for (final l in _langs)
          l: options
              .where(
                (o) => (((o as Map)['text'] as Map?)?[l] as String? ?? '')
                    .trim()
                    .isNotEmpty,
              )
              .length,
      };
      if (counts.values.toSet().length != 1 || counts['uz'] != 4) {
        problems.add('$id: variantlar soni $counts');
      }
      for (final l in _langs) {
        final seen = <String>{};
        for (final o in options) {
          final t = normalizeForSearch(
            (((o as Map)['text']! as Map)[l] as String?) ?? '',
          );
          if (!seen.add(t)) problems.add('$id: $l da takroriy variant');
        }
      }
      final refs = raw['refs']! as List;
      if (refs.isEmpty) problems.add('$id: refs bo‘sh');
      for (final r in refs) {
        final sid = (r as Map)['source_id'];
        if (!sourceIds.contains(sid)) problems.add('$id: manba $sid yo‘q');
      }
      final q = source.question(id);
      if (q == null || !isVerifiedTopicQuestion(q)) {
        problems.add('$id: mavzu testi filtridan o‘tmaydi');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('curriculum derived_quiz_ids — faqat o‘z decklari mavzularida', () {
    final byId = {for (final q in derived) q['id']! as String: q};
    final used = <String>{};
    final problems = <String>[];
    for (final t in cur.topics) {
      final deck = catalog.byTopic(t.id);
      if (deck == null) {
        if (t.derivedQuizCandidates.isNotEmpty) {
          problems.add('${t.id}: decksiz mavzuda derived savol');
        }
        continue;
      }
      for (final id in t.derivedQuizCandidates) {
        final q = byId[id];
        if (q == null) {
          problems.add('${t.id}: $id paketda derived savol emas');
          continue;
        }
        used.add(id);
        final from = (q['derived_from']! as Map).cast<String, Object?>();
        final decks = {
          from['deck']! as String,
          for (final d in (from['also_decks'] as List? ?? const []))
            d as String,
        };
        final topicDecks = {
          for (final d in catalog.decks)
            if (d.topics.contains(t.id)) d.id,
        };
        if (decks.intersection(topicDecks).isEmpty) {
          problems.add('${t.id}: $id boshqa deckdan ($decks)');
        }
      }
    }
    final orphan = byId.keys.where((id) => !used.contains(id)).toList();
    expect(problems, isEmpty, reason: problems.join('\n'));
    expect(orphan, isEmpty, reason: 'hech qaysi mavzuda emas: $orphan');
  });
}
