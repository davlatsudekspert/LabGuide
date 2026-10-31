import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/content/ui/content_widgets.dart';
import 'package:labguide/features/content/ui/conditions_screens.dart';
import 'package:labguide/features/home/global_search.dart';
import 'package:labguide/features/home/search_sections.dart';
import 'package:labguide/features/instruments/instrument_screens.dart';
import 'package:labguide/features/home/home_screen.dart';
import 'package:labguide/features/partners/partner_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> type(WidgetTester tester, String q) async {
    await tester.enterText(find.byType(TextField).first, q);
    await tester.pumpAndSettle();
  }

  // ------------------------------------------------------------ yordamchilar
  Future<AppLocalizations> openSearch(
    WidgetTester tester, {
    AppLanguage language = AppLanguage.uz,
    AppRole role = AppRole.lab,
  }) async {
    final s = await makeServices(tester, language: language);
    await s.settings.setRole(role);
    await pumpApp(tester, s, size: const Size(390, 3200));
    await goTo(tester, '/home');
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    expect(find.byType(GlobalSearchScreen), findsOne);
    return lookupAppLocalizations(language.locale);
  }

  Finder analyteRow(String id) =>
      find.byWidgetPredicate((w) => w is AnalyteRow && w.analyte.id == id);
  Finder conditionRow(String id) =>
      find.byWidgetPredicate((w) => w is ConditionRow && w.condition.id == id);

  testWidgets('bosh sahifa qidiruvi: bo\'sh holat, topilmadi, apparat', (
    tester,
  ) async {
    final l = await openSearch(tester);
    expect(find.text(l.searchPrompt), findsOne);
    await type(tester, 'Mindray');
    expect(find.textContaining(l.labInstruments), findsWidgets);
    await type(tester, 'zzzqqq');
    expect(find.text(l.testsEmptyTitle), findsOne);
    expect(tester.takeException(), isNull);
  });

  // ------------------------------------------------------------ tahlillar
  // Har bir yozuv turi uchun alohida so'zlar: o'zbek kirill va rus tilida
  // BIR XIL so'z ishlatilmaydi (aks holda ikkinchisi birinchisini yopib
  // qo'yadi). Siydik kislotasi: uz “siydik kislotasi” / “сийдик кислотаси”,
  // ru “мочевая кислота”.
  group('tahlillar: lotin / o\'zbek kirill / ruscha / inglizcha', () {
    const queries = {
      'kreatinin': 'creatinine', // uz lotin
      'креатинин': 'creatinine', // kirill (uz/ru umumiy)
      'siydik kislotasi': 'uric-acid', // uz lotin
      'сийдик кислотаси': 'uric-acid', // uz kirill (ruscha emas!)
      'мочевая кислота': 'uric-acid', // ruscha
      'uric acid': 'uric-acid', // inglizcha
      'mochevina': 'urea', // uz lotin (ruscha so'z lotinda)
      'мочевина': 'urea', // ruscha
      'karbamid': 'urea', // sinonim
    };
    for (final e in queries.entries) {
      testWidgets('"${e.key}" -> ${e.value}', (tester) async {
        await openSearch(tester);
        await type(tester, e.key);
        expect(analyteRow(e.value), findsWidgets);
      });
    }
    testWidgets('ruscha interfeys: ruscha va lotincha so\'rov', (tester) async {
      final l = await openSearch(tester, language: AppLanguage.ru);
      await type(tester, 'мочевая кислота');
      expect(analyteRow('uric-acid'), findsWidgets);
      expect(find.textContaining(l.featureTests), findsWidgets);
      await type(tester, 'urat');
      expect(analyteRow('uric-acid'), findsWidgets);
    });
  });

  // -------------------------------------------------------------- holatlar
  group('holatlar (shifokor qo\'llanmasi)', () {
    const queries = {
      'qandli diabet': 'type-2-diabetes', // uz lotin
      'қандли диабет': 'type-2-diabetes', // uz kirill
      'сахарный диабет': 'type-2-diabetes', // ruscha
      'type 2 diabetes': 'type-2-diabetes', // inglizcha
      'gipotireoz': 'hypothyroidism',
      'гипотиреоз': 'hypothyroidism',
    };
    for (final e in queries.entries) {
      testWidgets('"${e.key}" -> ${e.value}', (tester) async {
        final l = await openSearch(tester);
        await type(tester, e.key);
        expect(find.textContaining(l.condSearchSection), findsWidgets);
        expect(conditionRow(e.value), findsOneWidget);
      });
    }
    testWidgets('holat qatori holat sahifasini ochadi', (tester) async {
      await openSearch(tester);
      await type(tester, 'qandli diabet');
      await tester.tap(conditionRow('type-2-diabetes'));
      await tester.pumpAndSettle();
      expect(
        routerOf(tester).state.matchedLocation,
        '/home/conditions/type-2-diabetes',
      );
    });
  });

  // ----------------------------------------------------------- kutubxona
  testWidgets('kutubxona (o\'quv materiallari) guruhi', (tester) async {
    final l = await openSearch(tester);
    await type(tester, 'Microbiology');
    expect(find.textContaining(l.searchSectionLibrary), findsOneWidget);
    expect(find.textContaining('Microbiology'), findsWidgets);
    await tester.tap(find.textContaining('Microbiology').last);
    await tester.pumpAndSettle();
    expect(
      routerOf(tester).state.matchedLocation,
      '/library/books/item/lib-openstax-microbiology',
    );
  });

  // -------------------------------------------------------------- apparatlar
  group('apparatlar', () {
    testWidgets('ishlab chiqaruvchi nomi uning modellarini sanaydi', (
      tester,
    ) async {
      final l = await openSearch(tester);
      await type(tester, 'Mindray');
      // Sarlavhada jami 8 ta model; ro\'yxat 6 tagacha.
      expect(find.text('${l.labInstruments} · 8'), findsOneWidget);
      expect(find.byType(ModelRow), findsNWidgets(6));
      for (final w in tester.widgetList<ModelRow>(find.byType(ModelRow))) {
        expect(w.model.makerId, 'mindray');
      }
      await type(tester, 'Roche');
      expect(find.text('${l.labInstruments} · 6'), findsOneWidget);
      expect(find.byType(ModelRow), findsNWidgets(6));
    });

    testWidgets(
      'modeli yo\'q ishlab chiqaruvchi (Sysmex): yolg\'on natija yo\'q',
      (tester) async {
        final l = await openSearch(tester);
        await type(tester, 'Sysmex');
        expect(find.byType(ModelRow), findsNothing);
        expect(find.text(l.testsEmptyTitle), findsOne);
      },
    );

    testWidgets('model nomi aniq: BS-240', (tester) async {
      await openSearch(tester);
      await type(tester, 'BS-240');
      expect(find.byType(ModelRow), findsWidgets);
      expect(
        tester.widget<ModelRow>(find.byType(ModelRow).first).model.id,
        'mindray-bs-240',
      );
    });
  });

  // ------------------------------------------------------------- bo'limlar
  group('bo\'limlar (laboratoriya bo\'limlari va vositalari)', () {
    // so'rov -> (kutilgan bo'lim id, manzil)
    const cases = <(String, String, String)>[
      ('leykoformula', 'differential', '/lab/differential'),
      ('лейкоформула', 'differential', '/lab/differential'),
      ('differential', 'differential', '/lab/differential'),
      ('sitologiya', 'cytology', '/lab/cytology'),
      ('цитология', 'cytology', '/lab/cytology'),
      ('pap test', 'cytology', '/lab/cytology'),
      ('spermogramma', 'semen', '/lab/spermogram'),
      ('спермограмма', 'semen', '/lab/spermogram'),
      ('qon guruhi', 'bloodgroup', '/lab/bloodgroup'),
      ('қон гуруҳи', 'bloodgroup', '/lab/bloodgroup'),
      ('группа крови', 'bloodgroup', '/lab/bloodgroup'),
      ('rezus', 'bloodgroup', '/lab/bloodgroup'),
      ('gistologiya', 'histology', '/lab/histology'),
      ('гистология', 'histology', '/lab/histology'),
      ('siydik tahlili', 'urinalysis', '/lab/urinalysis'),
      ('сийдик таҳлили', 'urinalysis', '/lab/urinalysis'),
      ('анализ мочи', 'urinalysis', '/lab/urinalysis'),
      ('urinalysis', 'urinalysis', '/lab/urinalysis'),
      ('qon morfologiyasi', 'bloodmorph', '/lab/bloodmorph'),
      ('морфология крови', 'bloodmorph', '/lab/bloodmorph'),
      ('eritrotsitlar', 'bloodmorph', '/lab/bloodmorph'),
      ('QC', 'qc', '/lab/qc'),
      ('sifat nazorati', 'qc', '/lab/qc'),
      ('сифат назорати', 'qc', '/lab/qc'),
      ('контроль качества', 'qc', '/lab/qc'),
      ('westgard', 'qc', '/lab/qc'),
      ('preanalitika', 'preanalytics', '/lab/preanalytics'),
      ('преаналитика', 'preanalytics', '/lab/preanalytics'),
      ('preanalytics', 'preanalytics', '/lab/preanalytics'),
      ('kalibrlash', 'calibration', '/lab/calibration'),
      ('калибровка', 'calibration', '/lab/calibration'),
      ('kalkulyatorlar', 'calculators', '/lab/calculators'),
      ('калькуляторы', 'calculators', '/lab/calculators'),
      ('suyultirish', 'calculators', '/lab/calculators'),
      ('apparatlar', 'instruments', '/lab/instruments'),
      ('приборы', 'instruments', '/lab/instruments'),
      ('mikroskopiya atlasi', 'microscopy', '/lab/microscopy'),
      ('атлас микроскопии', 'microscopy', '/lab/microscopy'),
      ('kunlik savol', 'daily', '/learn/daily'),
      ('кунлик савол', 'daily', '/learn/daily'),
      ('вопросы дня', 'daily', '/learn/daily'),
      ('toifa', 'toifa', '/learn/toifa'),
      ('attestatsiya', 'toifa', '/learn/toifa'),
    ];
    for (final (query, id, route) in cases) {
      testWidgets('"$query" -> $id', (tester) async {
        final l = await openSearch(tester);
        await type(tester, query);
        expect(find.textContaining(l.searchSectionSections), findsOneWidget);
        final section = kSearchSections.firstWhere((x) => x.id == id);
        expect(section.route, route);
        // Bo'lim qatori birinchi guruhda; bosilsa kerakli manzil ochiladi.
        final row = find.widgetWithText(LgRow, section.title(l));
        expect(row, findsWidgets);
        await tester.tap(row.first);
        await tester.pumpAndSettle();
        expect(routerOf(tester).state.matchedLocation, startsWith(route));
      });
    }

    testWidgets('ruscha interfeysda nomlar ruscha', (tester) async {
      final l = await openSearch(tester, language: AppLanguage.ru);
      await type(tester, 'leykoformula');
      expect(find.text('${l.searchSectionSections} · 1'), findsOneWidget);
      expect(find.widgetWithText(LgRow, l.diffTitle), findsOneWidget);
      expect(l.diffTitle, 'Лейкоформула');
    });

    testWidgets('inglizcha interfeysda inglizcha nomlar', (tester) async {
      final l = await openSearch(tester, language: AppLanguage.en);
      await type(tester, 'QC');
      expect(find.widgetWithText(LgRow, l.featureQc), findsOneWidget);
    });

    // D-79: hamma rol, til va davlatda; faqat `none` yashiradi.
    for (final role in AppRole.values) {
      for (final language in AppLanguage.values) {
        testWidgets('toifa bo\'limi qidiruvda: ${role.name}, ${language.name}', (
          tester,
        ) async {
          final l = await openSearch(tester, language: language, role: role);
          await type(tester, 'toifa');
          expect(find.widgetWithText(LgRow, l.toifaTitle), findsWidgets);
        });
      }
    }

    testWidgets('toifa bo\'limi sozlama none bo\'lsa qidiruvda yo\'q', (
      tester,
    ) async {
      final s = await makeServices(tester, language: AppLanguage.en);
      await s.settings.setAttestationRegion(AttestationRegion.none);
      await pumpApp(tester, s, size: const Size(390, 3200));
      await goTo(tester, '/home');
      await tester.tap(find.byType(HomeSearchField));
      await tester.pumpAndSettle();
      await type(tester, 'toifa');
      expect(
        find.widgetWithText(
          LgRow,
          lookupAppLocalizations(const Locale('en')).toifaTitle,
        ),
        findsNothing,
      );
    });

    // D-69 Q4: Ma'ruza hamma rolga (O'rganish tabidagi qator bilan bir xil).
    for (final role in AppRole.values) {
      testWidgets('ma\'ruza qidiruvda: ${role.name}', (tester) async {
        final l = await openSearch(tester, role: role);
        await type(tester, 'maruza');
        expect(find.widgetWithText(LgRow, l.lectureTitle), findsOneWidget);
      });
    }

    testWidgets('bir belgilik so\'rov bo\'limlarga shovqin bermaydi', (
      tester,
    ) async {
      final l = await openSearch(tester);
      await type(tester, 'q');
      expect(find.textContaining(l.searchSectionSections), findsNothing);
    });
  });

  // Sof qidiruv (vidjetsiz): sinonim/qisqartma moslik tartibi.
  group('SectionSearch (sof)', () {
    List<String> ids(String q, {bool toifa = true, bool teacher = false}) => [
      for (final s in SectionSearch.instance.search(
        q,
        lang: 'uz',
        toifa: toifa,
        teacher: teacher,
      ))
        s.id,
    ];

    test('aniq nom birinchi', () {
      expect(ids('qc').first, 'qc');
      expect(ids('leykoformula').first, 'differential');
      expect(ids('kalibrlash').first, 'calibration');
    });
    test('har bir bo\'lim kamida o\'z nomi bilan topiladi (3 tilda)', () {
      for (final code in ['uz', 'ru', 'en']) {
        final l = lookupAppLocalizations(Locale(code));
        for (final s in kSearchSections) {
          final found = SectionSearch.instance
              .search(s.title(l), lang: code, toifa: true, teacher: true)
              .map((x) => x.id);
          expect(found, contains(s.id), reason: '$code ${s.title(l)}');
        }
      }
    });
    test('bo\'sh va qisqa so\'rov', () {
      expect(ids(''), isEmpty);
      expect(ids(' '), isEmpty);
      expect(ids('q'), isEmpty);
    });
    test('cheklangan bo\'limlar', () {
      expect(ids('toifa', toifa: false), isEmpty);
      expect(ids('maruza'), ['lecture']);
      expect(ids('maruza', teacher: true), ['lecture']);
    });
  });

  /// Rolning tezkor tugmalari: [count] ta birinchi plitka (bir qator = 2).
  List<Finder> tiles(AppRole role, AppLocalizations l, int count) {
    final actions = RoleHome.of(role, l).actions;
    return [
      for (final a in actions.take(count)) find.widgetWithText(LgTile, a.label),
    ];
  }

  double navTop(WidgetTester t) =>
      t.getRect(find.byKey(const ValueKey('nav-pill'))).top;

  for (final role in AppRole.values) {
    testWidgets('bosh sahifa ${role.name}: qidiruv va tezkor tugmalar '
        "birinchi ekranda (390x844, reklama o'chiq)", (tester) async {
      final s = await makeServices(tester);
      await s.settings.setRole(role);
      await pumpApp(tester, s, size: const Size(390, 844));
      await goTo(tester, '/home');
      final l = lookupAppLocalizations(const Locale('uz'));
      expect(find.byType(HomeSearchField).hitTestable(), findsOne);
      final nav = navTop(tester);
      final search = tester.getRect(find.byType(HomeSearchField));
      final actions = RoleHome.of(role, l).actions;
      // Birinchi qator (2 plitka) to'liq ko'rinadi va menyu ostida emas;
      // ular qidiruvdan keyin darhol keladi (orasida hech narsa yo'q).
      for (final f in tiles(role, l, 2)) {
        expect(f, findsOne);
        final r = tester.getRect(f);
        expect(r.bottom, lessThanOrEqualTo(nav), reason: '${role.name} row 1');
        expect(r.top, greaterThanOrEqualTo(search.bottom));
        expect(r.top - search.bottom, lessThan(24), reason: 'nothing between');
      }
      // Rol 4 ta tugmali bo'lsa (shifokor, ustoz) — barchasi birinchi ekranda.
      if (actions.length == 4) {
        for (final f in tiles(role, l, 4)) {
          expect(
            tester.getRect(f).bottom,
            lessThanOrEqualTo(nav),
            reason: '${role.name} all 4 tiles',
          );
        }
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('bosh sahifa ${role.name}: tor ekranda (320x640 ×1.3) birinchi '
        "qator qisman ko'rinadi", (tester) async {
      final s = await makeServices(tester);
      await s.settings.setRole(role);
      await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.3);
      await goTo(tester, '/home');
      final l = lookupAppLocalizations(const Locale('uz'));
      final nav = navTop(tester);
      final f = tiles(role, l, 1).single;
      expect(f, findsOne);
      final r = tester.getRect(f);
      // Qator menyu ustida kamida 24 px ko'rinadi.
      expect(nav - r.top, greaterThan(24), reason: '${role.name} row 1');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reklama yoqilgan buildda juftlik qidiruvdan keyin, plitkalar '
      'undan keyin', (tester) async {
    final s = await makeServices(tester, partnerAds: true);
    await pumpApp(tester, s, size: const Size(390, 2400));
    await goTo(tester, '/home');
    final l = lookupAppLocalizations(const Locale('uz'));
    final search = tester.getRect(find.byType(HomeSearchField));
    final pair = tester.getRect(find.byType(HomePartnerPair));
    final tile = tester.getRect(tiles(AppRole.lab, l, 1).single);
    expect(pair.top, greaterThanOrEqualTo(search.bottom));
    expect(tile.top, greaterThanOrEqualTo(pair.bottom));
  });
}
