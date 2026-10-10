import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/content/content_model.dart';
import 'package:labguide/features/library/library_catalog.dart';
import 'package:labguide/features/library/library_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/library_fixtures.dart';

final _uz = lookupAppLocalizations(const Locale('uz'));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) =>
    _tap(tester, find.text(text).hitTestable().last);

int _count(AppServices s, LibraryFilter f) =>
    LibraryCatalog(s.content.pack!).count(f);

void main() {
  setUpAll(loadAppFonts);

  testWidgets('search → filter → empty state → clear', (tester) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s, size: const Size(390, 4000));
    final total = s.content.pack!.library.length;
    await goTo(tester, '/library/books');
    expect(find.text(_uz.libResultCount(total, total)), findsOneWidget);
    expect(find.text(_uz.libClearFilters), findsNothing);

    // Qidiruv: natija soni darhol yangilanadi.
    await tester.enterText(find.byType(TextField), 'siydik');
    await tester.pumpAndSettle();
    final bySearch = _count(s, const LibraryFilter(query: 'siydik'));
    expect(bySearch, greaterThan(0));
    expect(find.text(_uz.libResultCount(bySearch, total)), findsOneWidget);
    expect(find.byType(LibraryItemCard), findsNWidgets(bySearch));
    expect(find.text(_uz.libClearFilters), findsOneWidget);

    // Mavzu filtri — tanlangan qiymat tugmada ko'rinadi.
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await _tapText(tester, _uz.libFilterTopic);
    final kidney = s.content.pack!.group('kidney')!.names.of('uz');
    await _tapText(tester, kidney);
    final byGroup = _count(s, const LibraryFilter(group: 'kidney'));
    expect(find.text('${_uz.libFilterTopic}: $kidney'), findsOneWidget);
    expect(find.byType(LibraryItemCard), findsNWidgets(byGroup));

    // Tur filtri: “ilova ichida” hozircha 0 — variant o'chiq.
    await _tapText(tester, _uz.libFilterType);
    expect(find.text(_uz.libOpenInAppShort), findsNothing);
    await _tapText(tester, _uz.kindWebsite);
    // Buyrak + veb-resurs: MedlinePlus.
    final combo = _count(
      s,
      const LibraryFilter(group: 'kidney', kind: LibraryItemKind.website),
    );
    expect(find.byType(LibraryItemCard), findsNWidgets(combo));

    // Bo'sh natija: nima qilish kerakligi va bir bosishda tozalash.
    await tester.enterText(find.byType(TextField), 'zzqqxx');
    await tester.pumpAndSettle();
    expect(find.text(_uz.libFilteredEmptyTitle), findsOneWidget);
    expect(find.text(_uz.libFilteredEmptyBody), findsOneWidget);
    await _tapText(tester, _uz.booksResetFilters);
    expect(find.text(_uz.libResultCount(total, total)), findsOneWidget);
    expect(find.text(_uz.libFilterTopic), findsOneWidget);
    expect(find.text('zzqqxx'), findsNothing);
  });

  testWidgets('library search entry opens the catalog with the keyboard', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s);
    await goTo(tester, '/library');
    await _tapText(tester, _uz.libSearchEntry);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
  });

  testWidgets('each material says what happens; pending cannot be opened', (
    tester,
  ) async {
    final s = await makeServices(tester, bundle: LibraryTestBundle());
    await pumpApp(tester, s, size: const Size(390, 2000));

    await goTo(tester, '/library/books/item/$pendingItemId');
    expect(find.text(_uz.libOpenPending), findsOneWidget);
    expect(find.text(_uz.libOpenPendingHint), findsOneWidget);
    expect(find.text(_uz.libItemRead), findsNothing);
    expect(find.text(_uz.libOpenSource), findsNothing);
    final cannot = find.widgetWithText(InkWell, _uz.libItemCannotOpen);
    expect(tester.widget<InkWell>(cannot).onTap, isNull);

    await goTo(tester, '/library/books/item/$downloadItemId');
    expect(find.text(_uz.libOpenDownload), findsOneWidget);
    expect(find.text(_uz.libDownloadUnavailable), findsOneWidget);

    await goTo(tester, '/library/books/item/$personalItemId');
    expect(find.text(_uz.libOpenRecordHint), findsOneWidget);
    expect(find.textContaining(_uz.rightsPersonal), findsOneWidget);

    await goTo(tester, '/library/books/item/$testPdfItemId');
    expect(find.text(_uz.libOpenInApp), findsOneWidget);
    expect(find.text(_uz.libOpenInAppHint), findsOneWidget);
    expect(find.text(_uz.libItemRead), findsOneWidget);

    // Katalogda ham: kutilayotgan material “mavjud” deb ko'rsatilmaydi.
    await goTo(tester, '/library/books');
    await _tapText(tester, _uz.libFilterType);
    await _tapText(tester, _uz.libOpenPending);
    expect(find.byType(LibraryItemCard), findsOneWidget);
    expect(find.text('Kutilayotgan sinov kitobi'), findsOneWidget);
  });

  testWidgets('library home puts the most useful sections first per role', (
    tester,
  ) async {
    final s = await makeServices(tester, role: AppRole.doctor);
    await pumpApp(tester, s, size: const Size(390, 2000));
    await goTo(tester, '/library');
    double y(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(y(_uz.featureSaved), lessThan(y(_uz.libBooks)));
    expect(y(_uz.libBooks), lessThan(y(_uz.libMoreSections)));

    await s.settings.setRole(AppRole.student);
    await tester.pumpAndSettle();
    expect(y(_uz.libBooks), lessThan(y(_uz.featureSaved)));
    expect(y(_uz.researchTitle), lessThan(y(_uz.libMoreSections)));

    await s.settings.setRole(AppRole.teacher);
    await tester.pumpAndSettle();
    expect(y(_uz.libIntake), lessThan(y(_uz.libMoreSections)));
    // “Ustoz” roli tekshiruv navbatini ochmaydi.
    expect(find.text(_uz.libReview), findsNothing);

    await s.settings.setRole(AppRole.lab);
    await tester.pumpAndSettle();
    expect(y(_uz.libPacks), lessThan(y(_uz.libMoreSections)));
    // Barcha bo'limlar joyida.
    for (final t in [
      _uz.libBooks,
      _uz.featureSaved,
      _uz.researchTitle,
      _uz.libSources,
      _uz.libPacks,
      _uz.libIntake,
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
  });

  testWidgets('review queue row only for a server-confirmed admin/reviewer', (
    tester,
  ) async {
    final backend = FakeLabBackend();
    final s = await makeServices(
      tester,
      backend: backend,
      role: AppRole.teacher,
    );
    await pumpApp(tester, s, size: const Size(390, 2000));
    await goTo(tester, '/library');
    expect(find.text(_uz.libReview), findsNothing);

    await s.auth.requestCode('teacher@example.com');
    await s.auth.verifyCode(FakeLabBackend.otpCode);
    await tester.pumpAndSettle();
    expect(find.text(_uz.libReview), findsNothing);
    await s.auth.signOut();
    await tester.pumpAndSettle();

    await s.auth.requestCode('davlatsudekspert@gmail.com');
    await s.auth.verifyCode(FakeLabBackend.otpCode);
    await tester.pumpAndSettle();
    await goTo(tester, '/library');
    expect(s.access.access.adminAccount, isTrue);
    expect(find.text(_uz.libReview), findsOneWidget);
  });

  for (final lang in AppLanguage.values) {
    testWidgets('filter sheets and material pages fit at 320 px ×2 ($lang)', (
      tester,
    ) async {
      final l = lookupAppLocalizations(Locale(lang.name));
      final s = await makeServices(
        tester,
        language: lang,
        bundle: LibraryTestBundle(),
      );
      await pumpApp(tester, s, size: const Size(320, 3200), textScale: 2.0);
      await goTo(tester, '/library/books');
      final urine = s.content.pack!.group('urine')!.names.of(lang.name);
      for (final (filter, option) in [
        (l.libFilterLanguage, 'O‘zbekcha'),
        (l.libFilterTopic, urine),
        (l.libFilterType, l.kindManual),
      ]) {
        await _tapText(tester, filter);
        expect(tester.takeException(), isNull, reason: filter);
        // Variant tanlanadi — tugma qiymat bilan (uzun matn) sig'adi.
        await _tapText(tester, option);
        expect(tester.takeException(), isNull, reason: filter);
        expect(find.text('$filter: $option'), findsOneWidget);
      }
      for (final id in [
        testPdfItemId,
        pendingItemId,
        downloadItemId,
        personalItemId,
      ]) {
        await goTo(tester, '/library/books/item/$id');
        expect(tester.takeException(), isNull, reason: id);
      }
    });
  }

  testWidgets('intake guide: honest count, rights, steps, contact', (
    tester,
  ) async {
    final s = await makeServices(tester, role: AppRole.teacher);
    await pumpApp(tester, s, size: const Size(390, 4000));
    await goTo(tester, '/library');
    await _tapText(tester, _uz.libIntake);
    expect(find.text(_uz.intakeTitle), findsWidgets);
    final fromTeachers = s.content.pack!.library
        .where((i) => i.providedBy == 'teacher')
        .length;
    expect(find.text(_uz.intakeStatus(fromTeachers)), findsOneWidget);
    for (final t in [
      _uz.intakeRights2,
      _uz.intakeStep1,
      _uz.intakeStep5,
      _uz.intakeNever1,
      _uz.intakeContactAction,
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    await _tapText(tester, _uz.intakeContactAction);
    // Server ulanmagan buildda halol holat (murojaat yuborilmaydi).
    expect(find.text(_uz.supportUnavailableTitle), findsOneWidget);
  });
}
