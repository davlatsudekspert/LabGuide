// “Qanday foydalaniladi?” ro‘yxati qorovuli: har bo‘limda uz/ru/en sarlavha,
// kamida 3 ta qadam, bo‘sh bo‘lmagan matn; noma’lum id — FormatException;
// matnlarda to‘lov, “kafolat”, “tez orada video” va imtihon natijasi haqida
// va’da yo‘q; har mavzu uchun storyboard hujjati bor.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/howto/howto_registry.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

final _langs = [
  for (final c in ['uz', 'ru', 'en']) lookupAppLocalizations(Locale(c)),
];

Iterable<String> _texts(HowToContent c, AppLocalizations l) => [
  c.title(l),
  for (final s in c.steps) s(l),
  c.result(l),
];

/// To‘lov / “kafolat” / video va’dasi (uz, ru, en; kichik harfda).
final _forbidden = RegExp(
  r'\bpro\b|premium|obuna|подписк|subscri|paywall|'
  r'kafolat|гарант|guarantee|'
  r'tez orada|скоро|coming soon|video|видео',
  caseSensitive: false,
);

/// Bilim va malakani baholash: imtihon natijasi haqida da’vo yo‘q.
final _examClaims = RegExp(
  r'o[‘’]tasiz|topshirasiz|muvaffaqiyatli|sertifikat|attestatsiyadan|'
  r'сдадите|сдать|успешно|сертификат|аттестаци|'
  r'pass the exam|you will pass|certif|succeed',
  caseSensitive: false,
);

void main() {
  test('har bo‘lim ro‘yxatda, id lar takrorlanmaydi', () {
    expect(HowToRegistry.all.keys.toSet(), HowToSection.values.toSet());
    final ids = [for (final s in HowToSection.values) s.id];
    expect(ids.toSet().length, ids.length);
    for (final s in HowToSection.values) {
      expect(HowToRegistry.of(s).section, s);
      expect(HowToRegistry.byId(s.id), same(HowToRegistry.of(s)));
    }
  });

  test('noma’lum id — FormatException', () {
    expect(() => HowToRegistry.byId('pro'), throwsFormatException);
    expect(() => HowToRegistry.byId(''), throwsFormatException);
    expect(() => HowToRegistry.byId('Calibration'), throwsFormatException);
  });

  test('uz/ru/en: sarlavha, 3–7 qadam, natija — bo‘sh emas, tillar farqli', () {
    for (final c in HowToRegistry.all.values) {
      expect(c.steps.length, inInclusiveRange(3, 7), reason: c.id);
      expect(c.routes, isNotEmpty, reason: c.id);
      for (final l in _langs) {
        for (final t in _texts(c, l)) {
          expect(t.trim(), isNotEmpty, reason: '${c.id} ${l.localeName}');
        }
        expect(_texts(c, l).toSet().length, c.steps.length + 2, reason: c.id);
      }
      // Qadamlar har tilda tarjima qilingan (uz matni ru/en ga ko‘chmagan).
      for (var i = 0; i < c.steps.length; i++) {
        final [uz, ru, en] = [for (final l in _langs) c.steps[i](l)];
        expect({uz, ru, en}.length, 3, reason: '${c.id} qadam ${i + 1}');
      }
    }
  });

  test('hozir hech bir bo‘limga video qo‘shilmagan (joy egallovchi yo‘q)', () {
    for (final c in HowToRegistry.all.values) {
      expect(c.videoUrl, isNull, reason: c.id);
    }
  });

  test('to‘lov, “kafolat”, video va’dasi yo‘q', () {
    for (final c in HowToRegistry.all.values) {
      for (final l in _langs) {
        for (final t in _texts(c, l)) {
          expect(_forbidden.hasMatch(t), isFalse, reason: '${c.id}: $t');
        }
      }
    }
  });

  test('Bilim va malakani baholash: imtihon natijasi haqida da’vo yo‘q', () {
    final c = HowToRegistry.of(HowToSection.assessment);
    for (final l in _langs) {
      for (final t in _texts(c, l)) {
        expect(_examClaims.hasMatch(t), isFalse, reason: t);
      }
    }
  });

  test('uz matnlarida o‘/g‘ (U+2018) va tutuq (U+2019) to‘g‘ri', () {
    final uz = _langs.first;
    for (final c in HowToRegistry.all.values) {
      for (final t in _texts(c, uz)) {
        expect(t.contains("'"), isFalse, reason: t);
        expect(RegExp('(?<=[oOgG])’(?=[a-z])').hasMatch(t), isFalse, reason: t);
      }
    }
  });

  test('har video mavzusi uchun storyboard hujjati va reja bor', () {
    expect(File('docs/video/PLAN.md').existsSync(), isTrue);
    const topics = [
      '01_kalibrlash',
      '02_sifat_nazorati',
      '03_preanalitika',
      '04_kalkulyatorlar',
      '05_apparatlar',
      '06_mikroskopiya',
      '07_najas_parazitologiya',
      '08_bilim_baholash',
      '09_testlar_natijalar',
      '10_boshqa_funksiyalar',
    ];
    for (final t in topics) {
      final f = File('docs/video/$t.md');
      expect(f.existsSync(), isTrue, reason: t);
      final md = f.readAsStringSync();
      expect(md, contains('STORYBOARD'), reason: t);
      expect(md, contains('ovozsiz'), reason: t);
    }
  });
}
