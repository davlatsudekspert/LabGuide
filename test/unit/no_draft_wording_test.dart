// D-65 (egasi qarori, 2026-10-18): ilova kontentni "qoralama / mutaxassis
// tekshiruvidan o'tmagan" deb ko'rsatmaydi — o'rniga adabiyot ("Manba:
// Muallif, yil, «nom», bob/bet") va bitta neytral tibbiy eslatma. Bu test
// shunday so'zlar ARB matnlariga yoki lib/ dagi ekran matnlariga qaytib
// kirmasligini kafolatlaydi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/bloodgroup/bloodgroup_content.dart';
import 'package:labguide/features/histology/histology_content.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/features/tools/sources_panel.dart';
import 'package:labguide/features/urinalysis/urinalysis_content.dart';

/// Kontent holati haqidagi taqiqlangan so'zlar (kichik harfda).
const _forbidden = [
  'draft',
  'qoralama',
  'черновик',
  'tekshiruvidan o‘tmagan',
  "tekshiruvidan o'tmagan",
  'tekshiruvidan hali',
  'tekshiruvi kutil',
  'tekshiruvini kut',
  'tekshirilmagan',
  'tekshirmagan',
  'mutaxassis tekshiruvida',
  'экспертн',
  'ждёт проверки',
  'ждут проверки',
  'ожидает проверки',
  'ожидает экспертиз',
  'not yet reviewed',
  'not reviewed',
  'not expert',
  'awaiting expert',
  'expert review',
  'expert-review',
  'pending review',
  'review pending',
  'unreviewed',
  'not yet independently',
];

/// Kontent holati haqida EMAS — shuning uchun ruxsat etilgan kalitlar.
const _allowed = {
  // Foydalanuvchining o'z qoralamasi (ilmiy ish / dars rejasi) va maxfiylik.
  'researchSave', 'researchSaved', 'researchAutosave',
  'privacyDeleteLocalSub', 'privacyDeleteConfirmBody',
  // Paket/fayl butunligi (SHA-256), asbob katalogi holati.
  'contentErrorBody', 'instLoginUnknown', 'instStatusExpert',
  // Ijobiy holat ("mutaxassis tekshirgan" paket) — qoralama da'vosi emas.
  'packsStatusReviewed',
  // Faqat tekshiruvchi/admin ko'radigan ish oqimi.
  'analyteReviewPending', 'reviewDraftQuestions', 'reviewDraftCards',
  'reviewDiscrepanciesBody', 'rvNotSeen', 'libReviewSub', 'admReviewSub',
  'admReportsRowSub', 'admStatsReportsOpen',
  'adminPartnerStatusDraft', 'adminActionPartnerDraft',
};

/// lib/ dagi ekran matnlarida (izoh emas) bo'lmasligi kerak.
const _forbiddenInCode = [
  'Qoralama',
  'qoralama',
  'Черновик',
  'черновик',
  'Draft:',
  'Draft ·',
  'tekshiruvidan hali',
  'tekshiruvidan o‘tmagan',
  'не прошёл экспертную',
  'не проверен экспертом',
  'not yet expert',
  'reviewed by an expert',
  'awaiting expert',
];

void main() {
  test('ARB matnlarida "qoralama / tekshirilmagan" so‘zlari yo‘q', () {
    final hits = <String>[];
    for (final lang in ['uz', 'ru', 'en']) {
      final arb = jsonDecode(
        File('lib/l10n/app_$lang.arb').readAsStringSync(),
      ) as Map<String, Object?>;
      for (final MapEntry(:key, :value) in arb.entries) {
        if (key.startsWith('@') || value is! String) continue;
        if (_allowed.contains(key)) continue;
        final v = value.toLowerCase();
        for (final w in _forbidden) {
          if (v.contains(w)) hits.add('$lang.$key: "$w"');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  test('ruxsat ro‘yxatidagi kalitlar mavjud (eskirgan istisno qolmasin)', () {
    final arb = jsonDecode(
      File('lib/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, Object?>;
    for (final k in _allowed) {
      expect(arb.containsKey(k), isTrue, reason: k);
    }
  });

  test('lib/ ekran matnlarida qoralama belgisi yo‘q', () {
    final hits = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        // ARB'dan yasalgan; ARB yuqoridagi test bilan tekshiriladi.
        .where((f) => !f.path.contains('l10n/gen'));
    for (final f in files) {
      final lines = f.readAsLinesSync();
      for (final (i, line) in lines.indexed) {
        if (line.trimLeft().startsWith('//')) continue;
        for (final w in _forbiddenInCode) {
          if (line.contains(w)) hits.add('${f.path}:${i + 1}: "$w"');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  group('shortCitation: Muallif, yil, «nom», bob/bet', () {
    String page(String p) => '$p-bet';

    test('jurnal maqolasi', () {
      expect(
        shortCitation(UrSources.delanghe2014),
        'Delanghe J, Speeckaert M, 2014, '
        '«Preanalytical requirements of urinalysis»',
      );
    });

    test('qo‘llanma: bob va bet (interfeys tilida)', () {
      final who = urLeadRefs.first;
      expect(
        shortCitation(who.source, locator: who.locator, citePage: page),
        'WHO, 2003, «Manual of basic techniques for a health laboratory, '
        '2nd ed.», Ch. 7 Examination of urine, 233–252-bet',
      );
    });

    test('"et al." va kirill initsiallari saqlanadi', () {
      expect(
        shortCitation(HistoSources.umich),
        'Hortsch M, et al., 2025, '
        '«University of Michigan Histology Laboratory Manual»',
      );
      expect(
        shortCitation(CalcSources.lyubina1984),
        startsWith(
          'Любина А.Я., Ильичева Л.П., Катасонова Т.В., '
          'Петросова С.А., 1984, «Клинические лабораторные исследования»',
        ),
      );
    });

    test('ajratib bo‘lmaydigan iqtibos — o‘zgarmasdan', () {
      expect(shortCitation(BgSources.ru1134), BgSources.ru1134.citation);
    });

    test('takrorsiz: lokatorlar har xil bo‘lsa — lokatorsiz', () {
      const a = CalcRef(UrSources.delanghe2014, 'A');
      const b = CalcRef(UrSources.delanghe2014, 'B');
      const c = CalcRef(UrSources.hitzeman2022, 'Table 1');
      final d = distinctSources([a, b, c, c]);
      expect(d.length, 2);
      expect(d.first.locator, '');
      expect(d.last.locator, 'Table 1');
    });
  });
}
