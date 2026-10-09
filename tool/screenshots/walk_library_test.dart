// Kutubxona — foydalanuvchi sifatida (walk_helper.dart).
//
//   flutter test tool/screenshots/walk_library_test.dart --update-goldens
//
// Haqiqiy katalog (25 manba) + test ichida yaratilgan “LabGuide sinov
// hujjati” PDF'i (mundarija bilan) va kutilayotgan / yuklab olinadigan /
// shaxsiy sinov yozuvlari — barcha holatlar ko'rinsin.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import '../../test/helpers/library_fixtures.dart';
import '../../test/helpers/reader_helpers.dart';
import 'walk_helper.dart';

Future<AppServices> _start(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.uz,
  ThemeMode theme = ThemeMode.light,
  double textScale = 1,
  AppRole role = AppRole.student,
}) async {
  final s = await makeServices(
    tester,
    language: lang,
    themeMode: theme,
    role: role,
    bundle: LibraryTestBundle(),
  );
  await pumpApp(tester, s, textScale: textScale);
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(Scaffold).first);
    await precacheImage(const AssetImage('assets/images/logo_mark.png'), ctx);
  });
  return s;
}

/// O'quvchi ochiq paytda: sahifa rasmlari chizilishini kutib, rasmga olish.
Future<void> _snapReader(WidgetTester tester, Walk w, String step) async {
  await pumpReal(tester, frames: 30);
  await w.snap(step);
}

Future<void> _openReader(
  WidgetTester tester,
  Walk w,
  AppLocalizations l,
  String button,
) async {
  await w.tester.ensureVisible(find.text(button));
  await tester.pumpAndSettle();
  await tapReader(tester, find.text(button));
  await waitUntil(
    tester,
    () =>
        find.textContaining(' / 10').evaluate().isNotEmpty ||
        find.textContaining(' из 10').evaluate().isNotEmpty ||
        find.textContaining(' of 10').evaluate().isNotEmpty,
  );
}

/// Ekranda ko'rinib turgan tugmani joyida bosish (ro'yxatni surmasdan —
/// foydalanuvchi ham shunday bosadi).
Future<void> _tapInPlace(WidgetTester tester, String text) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).hitTestable().last);
  await tester.pumpAndSettle();
}

Future<void> _closeSheet(WidgetTester tester) async {
  await tester.tapAt(const Offset(200, 20));
  await pumpReal(tester);
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
    setUpPdfiumForTests();
  });

  testWidgets('kutubxona — talaba (uz, yorug‘)', (tester) async {
    final l = lookupAppLocalizations(const Locale('uz'));
    final s = await _start(tester);
    final w = Walk(tester, 'library_student_uz');
    await goTo(tester, '/library');
    await w.snap('kutubxona');
    await w.tapText(l.libSearchEntry);
    await w.snap('katalog_qidiruv_fokus');
    await tester.enterText(find.byType(TextField), 'siydik');
    await w.snap('qidiruv_siydik');
    await tester.enterText(find.byType(TextField), '');
    await _tapInPlace(tester, l.libFilterLanguage);
    await w.snap('til_varaq');
    await w.tapText('O‘zbekcha');
    await w.snap('til_ozbekcha');
    await _tapInPlace(tester, l.libFilterTopic);
    await w.snap('mavzu_varaq');
    await w.tapText(s.content.pack!.group('kidney')!.names.of('uz'));
    await w.snap('mavzu_buyrak');
    await _tapInPlace(tester, l.libFilterType);
    await w.snap('turi_varaq');
    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzqq');
    await w.snap('bosh_natija');
    await w.tapText(l.booksResetFilters);
    await w.snap('tozalandi');
    await w.tapText('Klinik laborator tashxislash va tekshiruv usullari');
    await w.snap('material_havola');
    await w.scroll(600);
    await w.snap('material_malumot');
    await w.tap(find.byTooltip(l.actionBack).first);
    await tester.enterText(find.byType(TextField), 'sinov');
    await w.snap('sinov_materiallari');
    await w.tap(find.text('Kutilayotgan sinov kitobi'));
    await w.snap('material_kutilmoqda');
    await w.tap(find.byTooltip(l.actionBack).first);
    await w.tap(find.text('Yuklab olinadigan sinov kitobi'));
    await w.snap('material_yuklab_olinadigan');
    await w.tap(find.byTooltip(l.actionBack).first);
    await w.tap(find.text('LabGuide sinov hujjati'));
    await w.snap('material_ilova_ichida');

    // O'quvchi: mundarija → bo'lim → xatcho'p → yopib qayta ochish.
    await _openReader(tester, w, l, l.libItemRead);
    await _snapReader(tester, w, 'oquvchi_1');
    await tapReader(tester, find.text(l.readerToc));
    await _snapReader(tester, w, 'mundarija');
    await tapReader(tester, find.text("3. Xatcho'plar sinovi"));
    await waitForFinder(tester, find.text(l.readerPageOf(6, 10)));
    await _snapReader(tester, w, 'oquvchi_6');
    await tapReader(tester, find.byTooltip(l.readerAddBookmark));
    await tester.enterText(find.byType(TextField), 'Muhim jadval');
    await _snapReader(tester, w, 'xatchop_nomi');
    await tapReader(tester, find.text(l.readerSave));
    await _snapReader(tester, w, 'xatchop_saqlandi');
    await tapReader(tester, find.text(l.readerBookmarks));
    await _snapReader(tester, w, 'xatchoplar');
    await _closeSheet(tester);
    await tapReader(tester, find.byTooltip(l.readerZoomIn));
    await _snapReader(tester, w, 'kattalashtirish');
    await tapReader(tester, find.byTooltip(l.actionBack));
    await tester.pumpAndSettle();
    await w.snap('material_davom_tugmasi');
    await _openReader(tester, w, l, l.libItemContinue(6));
    await _snapReader(tester, w, 'qayta_ochildi_6');
    await tapReader(tester, find.text(l.readerGoToShort));
    await tester.enterText(find.byType(TextField), '9');
    await _snapReader(tester, w, 'sahifaga_otish');
    await tapReader(tester, find.text(l.readerGo));
    await waitForFinder(tester, find.text(l.readerPageOf(9, 10)));
    await _snapReader(tester, w, 'oquvchi_9');
    await tapReader(tester, find.byTooltip(l.actionBack));
    await tester.pumpAndSettle();
    await goTo(tester, '/library');
    await w.snap('kutubxona_davom_ettirish');
  });

  testWidgets('kutubxona — ustoz (ru, qorong‘i, katta shrift)', (tester) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    await _start(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      textScale: 1.35,
      role: AppRole.teacher,
    );
    final w = Walk(tester, 'library_teacher_ru_dark_large');
    await goTo(tester, '/library');
    await w.snap('kutubxona');
    await w.tapText(l.libIntake);
    await w.snap('qabul_tartibi');
    await w.scroll(700);
    await w.snap('qabul_huquq');
    await w.scroll(900);
    await w.snap('qabul_tekshiruv');
    await w.scroll(1400);
    await w.snap('qabul_boglanish');
    await goTo(tester, '/library/books');
    await w.snap('katalog');
    await _tapInPlace(tester, l.libFilterType);
    await w.snap('turi_varaq');
    await w.tapText(l.libOpenInAppShort);
    await w.snap('ilova_ichida');
    await w.tap(find.text('LabGuide sinov hujjati'));
    await w.snap('material');
    await _openReader(tester, w, l, l.libItemRead);
    await _snapReader(tester, w, 'oquvchi');
    await tapReader(tester, find.text(l.readerToc));
    await _snapReader(tester, w, 'mundarija');
    await tapReader(tester, find.text("2.1. Ichki bo'lim"));
    await waitForFinder(tester, find.text(l.readerPageOf(4, 10)));
    await tapReader(tester, find.text(l.readerBookmarks));
    await _snapReader(tester, w, 'xatchoplar_bosh');
    await tapReader(tester, find.text(l.readerAddBookmark));
    await tapReader(tester, find.text(l.readerSave));
    await tapReader(tester, find.text(l.readerBookmarks));
    await _snapReader(tester, w, 'xatchoplar_bitta');
    await _closeSheet(tester);
    await tapReader(tester, find.byTooltip(l.actionBack));
    await tester.pumpAndSettle();
  });

  testWidgets('kutubxona — en', (tester) async {
    final l = lookupAppLocalizations(const Locale('en'));
    await _start(tester, lang: AppLanguage.en, role: AppRole.doctor);
    final w = Walk(tester, 'library_en');
    await goTo(tester, '/library');
    await w.snap('library');
    await goTo(tester, '/library/books');
    await w.snap('catalog');
    await tester.enterText(find.byType(TextField), 'kidney');
    await w.snap('search_kidney');
    await tester.enterText(find.byType(TextField), 'nothing-like-this');
    await w.snap('nothing_found');
    await goTo(tester, '/library/books/item/lib-tietz-textbook-lab-medicine-7');
    await w.snap('paid_book_link');
    await goTo(tester, '/library/books/item/$testPdfItemId');
    await _openReader(tester, w, l, l.libItemRead);
    await _snapReader(tester, w, 'reader');
    await tapReader(tester, find.text(l.readerGoToShort));
    await tester.enterText(find.byType(TextField), '42');
    await tapReader(tester, find.text(l.readerGo));
    await _snapReader(tester, w, 'go_to_page_error');
    await tapReader(tester, find.text(l.actionCancel));
    await tapReader(tester, find.byTooltip(l.actionBack));
    await tester.pumpAndSettle();
  });
}
