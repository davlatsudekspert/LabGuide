// Qorovul (guard) testlari: tibbiy tuzatishlar va "Manbalar" paneli.
//
// docs/AUDIT_2026-10-18_MEDICAL_REVIEW.md va docs/AUDIT_2026-10-17.md da
// tuzatilgan har band qaytib kelmasligi kerak. Ko'p bandlar bo'lim
// testlarida (test/widget/{cytology,bloodgroup,bloodmorph,histology}_test.dart,
// "tibbiy ko‘rib chiqish 2026-10-18"); bu yerda — o'sha yerda yo'q bo'lganlari
// va D-65 "Manbalar" paneli. Jadval: docs/GUARDS.md.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/bloodgroup/bloodgroup_content.dart';
import 'package:labguide/features/bloodmorph/bloodmorph_content.dart';
import 'package:labguide/features/coagulogram/coag_content.dart';
import 'package:labguide/features/coprology/copro_content.dart';
import 'package:labguide/features/cytology/cytology_content.dart';
import 'package:labguide/features/cytology/cytology_more.dart';
import 'package:labguide/features/cytology/cytology_screens.dart';
import 'package:labguide/features/histology/histology_content.dart';
import 'package:labguide/features/reference/reference_screens.dart';
import 'package:labguide/features/spermogram/spermogram_content.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/features/tools/sources_panel.dart';
import 'package:labguide/features/urinalysis/urinalysis_content.dart';

final _year = RegExp(r'\b(1[89]|20)\d\d\b');

/// Doim yangilanadigan, nashr yili ko'rsatilmagan veb-sahifalar (yo'riqnoma,
/// atlas, lug'at): panelda "Muallif, «nom»" — yil o'ylab topilmaydi. Yangi
/// manba qo'shilsa, yili bo'lsin yoki shu ro'yxatga sababi bilan yozilsin.
const _undatedWebPages = {
  'cyto-iarc-atlas-unsatisfactory',
  'cyto-nci-abnormal-hpv-pap',
  'cyto-nci-pdq-screening',
  'histo-hpa-kidney',
  'histo-hpa-liver',
  'sperm-eau-male-infertility',
};

void main() {
  group('tibbiy ko‘rik 2026-10-18 (qo‘shimcha regressiya)', () {
    test('#6 jigar: uz «o‘rtacha oltita» (oltitagacha emas)', () {
      final liver = histoItems.firstWhere((i) => i.id == 'liver');
      final facts = [
        ...liver.look,
        liver.key,
        liver.function,
        ?liver.where,
        ?liver.confuse,
      ];
      final uz = [for (final f in facts) f.text.of('uz')];
      expect(uz.any((t) => t.contains('o‘rtacha oltita')), isTrue);
      expect(uz.where((t) => t.contains('oltitagacha')), isEmpty);
      final en = [for (final f in facts) f.text.of('en')];
      expect(en.any((t) => t.contains('on average six')), isTrue);
    });

    test('1a tozalik darajasi: manbasiz pH oraliqlari qaytmaydi', () {
      final ph = RegExp(r'\bpH\b|\d,\d\s*[–-]\s*\d,\d');
      for (final d in cytoDegrees) {
        for (final t in [d.picture, d.meaning]) {
          for (final lang in ['uz', 'ru', 'en']) {
            expect(ph.hasMatch(t.of(lang)), isFalse, reason: '${d.n} $lang');
          }
        }
      }
    });

    test('#1 trombotsit: «500–1000 eritrotsitga bitta» qaytmaydi', () {
      for (final f in bmPlateletIntro) {
        for (final lang in ['uz', 'ru', 'en']) {
          expect(f.text.of(lang), isNot(contains('500–1000')));
        }
      }
    });
  });

  group('audit 2026-10-17', () {
    test('#5 tozalik darajasi: leykotsit ko‘p bo‘lsa — hech qachon I–II '
        '(norma) emas', () {
      for (final lacto in CytoLacto.values) {
        for (final leuko in CytoLeuko.values) {
          for (final flora in CytoFlora.values) {
            final n = cytoDegreeOf(lacto, leuko, flora);
            expect(n, inInclusiveRange(1, 4));
            if (leuko != CytoLeuko.single) {
              expect(
                n,
                greaterThanOrEqualTo(3),
                reason: '$lacto $leuko $flora',
              );
            }
            if (flora == CytoFlora.pathogenic) {
              expect(n, 4, reason: '$lacto $leuko $flora');
            }
          }
        }
      }
    });

    test('#7 gemoxromatoz: HFE C282Y "tasdiqlaydi" emas, '
        '"qo‘llab-quvvatlaydi"', () {
      final pack = File('assets/content/core/pack.json').readAsStringSync();
      expect(pack, contains('supports HFE hemochromatosis'));
      expect(pack, contains('поддерживает HFE-гемохроматоз'));
      expect(
        RegExp(r'C282Y[^"]{0,80}(confirms|подтверждает|tasdiqlaydi)')
            .hasMatch(pack),
        isFalse,
      );
    });
  });

  group('D-65: har Lab bo‘limida "Manbalar" paneli — muallif va yil', () {
    // Bo'lim ekrani → panelga beriladigan ro'yxat.
    final sections = <String, (String, List<CalcRef>)>{
      'siydik tahlili': (
        'lib/features/urinalysis/urinalysis_screens.dart',
        urLeadRefs,
      ),
      'spermogramma': (
        'lib/features/spermogram/spermogram_screens.dart',
        spermLeadRefs,
      ),
      'qon guruhi': (
        'lib/features/bloodgroup/bloodgroup_screens.dart',
        bgLeadRefs,
      ),
      'gistologiya': (
        'lib/features/histology/histology_screens.dart',
        histoLeadRefs,
      ),
      'qon morfologiyasi': (
        'lib/features/bloodmorph/bloodmorph_screens.dart',
        bmLeadRefs,
      ),
      'koagulogramma': (
        'lib/features/coagulogram/coag_screens.dart',
        cgLeadRefs,
      ),
      'koprologiya': ('lib/features/coprology/copro_screens.dart', cpLeadRefs),
      'sitologiya (yaroqlilik)': (
        'lib/features/cytology/cytology_more_screens.dart',
        cytoAdequacyRefs,
      ),
      'sitologiya (Bethesda)': (
        'lib/features/cytology/cytology_screens.dart',
        bethesdaRefs(),
      ),
      'jadvallar va algoritmlar': (
        'lib/features/reference/reference_screens.dart',
        refLeadRefs,
      ),
    };

    for (final MapEntry(key: name, value: (path, refs)) in sections.entries) {
      test(name, () {
        expect(File(path).readAsStringSync(), contains('SourcesPanel('));
        expect(refs, isNotEmpty);
        for (final r in distinctSources(refs)) {
          final line = shortCitation(r.source, locator: r.locator);
          final parts = citationParts(r.source.citation);
          expect(parts, isNotNull, reason: r.source.citation);
          expect(parts!.authors, isNotEmpty, reason: r.source.citation);
          if (_undatedWebPages.contains(r.source.id)) {
            expect(r.source.url, startsWith('https://'), reason: line);
          } else {
            expect(_year.hasMatch(line), isTrue, reason: line);
          }
        }
      });
    }

    test('yilsiz veb-sahifalar ro‘yxati eskirmagan', () {
      final shown = {
        for (final (_, refs) in sections.values)
          for (final r in refs) r.source.id: r.source,
      };
      for (final id in _undatedWebPages) {
        final s = shown[id];
        expect(
          s,
          isNotNull,
          reason: '$id panelda yo‘q — ro‘yxatdan olib tashlang',
        );
        expect(
          _year.hasMatch(shortCitation(s!)),
          isFalse,
          reason: '$id endi yilli — ro‘yxatdan olib tashlang',
        );
      }
    });
  });
}
