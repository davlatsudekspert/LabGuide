import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/library/library_catalog.dart';
import 'package:labguide/features/library/library_screens.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

Map<String, Object?> _item(String id, String title, String language) => {
  'id': id,
  'kind': 'book',
  'title': title,
  'authors': ['Sinov'],
  'language': language,
  'categories': ['methods'],
  'topics': [],
  'import_state': 'cataloged',
  'rights': {'distribution': 'unknown'},
};

class _LangBundle extends CachingAssetBundle {
  _LangBundle() {
    _inner = PatchedPackBundle(rootBundle, (json) {
      json['library'] = [
        ...(json['library']! as List),
        _item('t-uz', 'Zzuzonly kitob', 'uz'),
        _item('t-ru', 'Zzruonly kniga', 'ru'),
        _item('t-en', 'Zzenonly book', 'en'),
        _item('t-multi', 'Zzmulti kitob', 'multi'),
      ];
    });
  }
  late final PatchedPackBundle _inner;

  @override
  Future<ByteData> load(String key) => _inner.load(key);
}

bool _has(AppServices s, String lang, String id) =>
    LibraryCatalog(s.content.pack!, lang: lang).items.any((i) => i.id == id);

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('library visibility follows UI language (${lang.name})', (
      tester,
    ) async {
      final l = lookupAppLocalizations(Locale(lang.name));
      final s = await makeServices(
        tester,
        language: lang,
        bundle: _LangBundle(),
      );
      final pack = s.content.pack!;
      final visible = pack.library
          .where((i) => libraryItemAvailableIn(i, lang.name))
          .length;
      final all = pack.library.length;

      // Model darajasi.
      expect(_has(s, lang.name, 't-multi'), isTrue);
      expect(_has(s, lang.name, 't-uz'), lang == AppLanguage.uz);
      expect(_has(s, lang.name, 't-ru'), lang != AppLanguage.en);
      expect(_has(s, lang.name, 't-en'), lang != AppLanguage.ru);
      if (lang != AppLanguage.uz) {
        expect(visible, lessThan(all));
        final c = LibraryCatalog(pack, lang: lang.name);
        expect(c.languages, isNot(contains('uz')));
        expect(c.count(LibraryFilter.none), visible);
        expect(c.count(const LibraryFilter(query: 'Zzuzonly')), 0);
        expect(c.count(const LibraryFilter(language: 'uz')), 0);
      } else {
        expect(visible, all);
      }

      await pumpApp(tester, s, size: const Size(390, 4000));

      // Bo'lim sanog'i.
      await goTo(tester, '/library');
      expect(find.text(l.libBooksCount(visible)), findsWidgets);

      // Ro'yxat va qidiruv.
      await goTo(tester, '/library/books');
      expect(find.text(l.libResultCount(visible, visible)), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Zzuzonly');
      await tester.pumpAndSettle();
      expect(
        find.byType(LibraryItemCard),
        lang == AppLanguage.uz ? findsOneWidget : findsNothing,
      );
      await tester.enterText(find.byType(TextField), 'Zzmulti');
      await tester.pumpAndSettle();
      expect(find.byType(LibraryItemCard), findsOneWidget);

      // To'g'ridan-to'g'ri manzil: halol holat.
      await goTo(tester, '/library/books/item/t-uz');
      if (lang == AppLanguage.uz) {
        expect(find.text(l.libItemUnavailable), findsNothing);
      } else {
        expect(find.text(l.libItemUnavailable), findsOneWidget);
        expect(find.text(l.libItemUnavailableBody), findsOneWidget);
      }
      await goTo(tester, '/library/books/item/t-multi');
      expect(find.text(l.libItemUnavailable), findsNothing);
    });
  }
}
