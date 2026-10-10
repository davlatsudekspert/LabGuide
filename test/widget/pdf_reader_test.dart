import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import '../helpers/harness.dart';
import '../helpers/library_fixtures.dart';
import '../helpers/reader_helpers.dart';
import '../helpers/test_pdf.dart';

final _uz = lookupAppLocalizations(const Locale('uz'));

/// Material sahifasidan o'quvchini ochadi va birinchi kadrni kutadi.
Future<void> _openReader(
  WidgetTester tester,
  AppLocalizations l, {
  required String button,
  required int page,
}) async {
  await goTo(tester, '/library/books/item/$testPdfItemId');
  final f = find.text(button);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tapReader(tester, f);
  await waitForFinder(tester, find.text(l.readerPageOf(page, 10)));
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
    setUpPdfiumForTests();
  });

  testWidgets('reader: TOC, bookmark, close and resume at the last page', (
    tester,
  ) async {
    final store = MemoryKeyValueStore();
    final s = await makeServices(
      tester,
      store: store,
      bundle: LibraryTestBundle(),
    );
    await pumpApp(tester, s);
    await _openReader(tester, _uz, button: _uz.libItemRead, page: 1);
    expect(find.byType(PdfViewer), findsOneWidget);

    // Mundarija: PDF outline'idagi barcha bandlar (ichki bo'lim ham).
    await tapReader(tester, find.text(_uz.readerToc));
    await waitForFinder(tester, find.text("2.1. Ichki bo'lim"));
    for (final title in ['1. Kirish', "3. Xatcho'plar sinovi", '4. Yakun']) {
      expect(find.text(title), findsOneWidget);
    }
    await tapReader(tester, find.text("3. Xatcho'plar sinovi"));
    await waitForFinder(tester, find.text(_uz.readerPageOf(6, 10)));

    // Nomli xatcho'p.
    await tapReader(tester, find.byTooltip(_uz.readerAddBookmark));
    await tester.enterText(find.byType(TextField), 'Muhim jadval');
    await tapReader(tester, find.text(_uz.readerSave));
    final sha = s.content.pack!.libraryItem(testPdfItemId)!.file!.sha256;
    final state = s.reading.stateOf(testPdfItemId, sha)!;
    expect(state.bookmarks.single.page, 6);
    expect(state.bookmarks.single.name, 'Muhim jadval');
    expect(find.byTooltip(_uz.readerBookmarkRemove), findsOneWidget);

    // Yopish — oxirgi sahifa omborga yozilgan.
    await tapReader(tester, find.byTooltip(_uz.actionBack));
    await tester.pumpAndSettle();
    expect(find.byType(PdfViewer), findsNothing);
    expect(s.reading.stateOf(testPdfItemId, sha)!.lastPage, 6);
    expect(store.getString(StoreKeys.libraryReading), contains('Muhim jadval'));

    // “Qayta ochish”: shu ombor bilan yangi servislar — 6-sahifadan davom.
    await tester.pumpWidget(const SizedBox());
    final reopened = await makeServices(
      tester,
      store: store,
      bundle: LibraryTestBundle(),
    );
    await pumpApp(tester, reopened);
    await goTo(tester, '/library');
    expect(find.text(_uz.libContinueReading), findsOneWidget);
    await _openReader(tester, _uz, button: _uz.libItemContinue(6), page: 6);
    expect(find.text(_uz.readerResumed(6)), findsOneWidget);

    // Sahifaga o'tish: noto'g'ri raqam rad etiladi, 9 qabul qilinadi.
    await tapReader(tester, find.text(_uz.readerGoToShort));
    await tester.enterText(find.byType(TextField), '42');
    await tapReader(tester, find.text(_uz.readerGo));
    expect(find.text(_uz.readerGoToError(10)), findsOneWidget);
    await tester.enterText(find.byType(TextField), '9');
    await tapReader(tester, find.text(_uz.readerGo));
    await waitForFinder(tester, find.text(_uz.readerPageOf(9, 10)));

    // Xatcho'plar ro'yxatidan bir bosishda 6-sahifaga.
    await tapReader(tester, find.text(_uz.readerBookmarks));
    expect(find.text('Muhim jadval'), findsOneWidget);
    await tapReader(tester, find.text('Muhim jadval'));
    await waitForFinder(tester, find.text(_uz.readerPageOf(6, 10)));

    // Kattalashtirish ishlaydi.
    final viewer = tester.widget<PdfViewer>(find.byType(PdfViewer));
    final before = viewer.controller!.currentZoom;
    await tapReader(tester, find.byTooltip(_uz.readerZoomIn));
    expect(viewer.controller!.currentZoom, greaterThan(before));
  });

  testWidgets('a file that fails the checksum is not opened', (tester) async {
    final pdf = buildTestPdf();
    final tampered = Uint8List.fromList(pdf)..[pdf.length ~/ 2] ^= 0x01;
    final s = await makeServices(
      tester,
      bundle: LibraryTestBundle(pdf: pdf, servedPdf: tampered),
    );
    await pumpApp(tester, s);
    await goTo(tester, '/library/books/item/$testPdfItemId/read');
    expect(find.text(_uz.readerFileCorrupted), findsOneWidget);
    expect(find.byType(PdfViewer), findsNothing);
  });

  testWidgets('pending, downloadable and personal items never open', (
    tester,
  ) async {
    final s = await makeServices(tester, bundle: LibraryTestBundle());
    await pumpApp(tester, s);
    for (final id in [pendingItemId, downloadItemId, personalItemId]) {
      await goTo(tester, '/library/books/item/$id/read');
      expect(find.byType(PdfViewer), findsNothing, reason: id);
      expect(
        find.text(_uz.libOpenPending).evaluate().isNotEmpty ||
            find.text(_uz.readerBlockedTitle).evaluate().isNotEmpty,
        isTrue,
        reason: id,
      );
    }
    // Katalogdagi ochiq havola ham o'quvchida ochilmaydi.
    await goTo(tester, '/library/books/item/lib-openstax-biology-2e/read');
    expect(find.text(_uz.readerBlockedTitle), findsOneWidget);
    expect(find.text(_uz.libOpenSource), findsOneWidget);
  });

  testWidgets('deleting local data clears reading state', (tester) async {
    final s = await makeServices(tester, bundle: LibraryTestBundle());
    final sha = s.content.pack!.libraryItem(testPdfItemId)!.file!.sha256;
    await s.reading.setLastPage(testPdfItemId, sha, 4, pageCount: 10);
    await s.reading.addBookmark(testPdfItemId, sha, 4, name: 'x');
    expect(s.store.getString(StoreKeys.libraryReading), isNotNull);
    await tester.runAsync(() => s.deleteLocalData(const [Locale('uz')]));
    expect(s.reading.stateOf(testPdfItemId, sha), isNull);
    expect(s.reading.lastRead, isNull);
    expect(s.store.getString(StoreKeys.libraryReading), isNull);
  });

  for (final (width, scale, theme, lang) in [
    (320.0, 2.0, ThemeMode.light, AppLanguage.uz),
    (390.0, 1.35, ThemeMode.dark, AppLanguage.ru),
    (430.0, 1.0, ThemeMode.light, AppLanguage.en),
  ]) {
    testWidgets('reader layout ${width.toInt()}px ×$scale ${lang.name}', (
      tester,
    ) async {
      final l = lookupAppLocalizations(Locale(lang.name));
      final s = await makeServices(
        tester,
        language: lang,
        themeMode: theme,
        // Kutubxona faqat interfeys tilidagi materialni ko'rsatadi.
        bundle: LibraryTestBundle(pdfLanguage: lang.name),
      );
      await pumpApp(tester, s, size: Size(width, 760), textScale: scale);
      await _openReader(tester, l, button: l.libItemRead, page: 1);
      expect(tester.takeException(), isNull);
      await tapReader(tester, find.text(l.readerToc));
      await waitForFinder(tester, find.text('4. Yakun'));
      expect(tester.takeException(), isNull);
      await tapReader(tester, find.text('1. Kirish'));
      await tapReader(tester, find.text(l.readerBookmarks));
      expect(find.text(l.readerBookmarksEmpty), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
