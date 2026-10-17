import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/partner_models.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/daily/daily_screens.dart';
import 'package:labguide/features/home/global_search.dart';
import 'package:labguide/features/partners/become_partner_screen.dart';
import 'package:labguide/features/partners/partner_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/partner_fixtures.dart';

/// Bosh sahifadagi ikki reklama joyi: 1 — laboratoriya xizmati, 2 — apparat
/// firmasi. Uch holat:
///  (a) haqiqiy faol hamkor — hamkor kartasi (+ hisoblagich);
///  (b) hamkor yo'q, demo/test build — “Namuna / Demo” o'rni (hisoblagichsiz);
///  (c) hamkor yo'q, do'kon build — hech narsa.

/// Dastlabki ekran emas, butun bosh sahifa chiziladigan baland ekran.
const _tall = Size(390, 6000);

Size _sizeOf(Element e) => (e.renderObject! as RenderBox).size;

AppLocalizations _l(AppLanguage lang) => lookupAppLocalizations(lang.locale);

Partner _lab({
  String id = 'lab-1',
  String name = 'Sinov Laboratoriya MChJ',
  PartnerStatus status = PartnerStatus.published,
}) => testPartner(
  id: id,
  name: name,
  kind: PartnerKind.laboratory,
  status: status,
  links: const [],
);

Partner _equipment({
  String id = 'eq-1',
  String name = 'Sinov Apparat MChJ',
  PartnerKind kind = PartnerKind.distributor,
  PartnerStatus status = PartnerStatus.published,
}) => testPartner(id: id, name: name, kind: kind, status: status);

Future<void> _signIn(WidgetTester tester, AppServices s) async {
  await s.auth.requestCode('lab.user@example.com');
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

void _expectDemo(AppLocalizations l, {bool lab = true, bool equipment = true}) {
  expect(
    find.text(l.homeAdDemoTitle),
    findsNWidgets((lab ? 1 : 0) + (equipment ? 1 : 0)),
  );
  expect(find.text(l.homeAdDemoLabBody), lab ? findsOneWidget : findsNothing);
  expect(
    find.text(l.homeAdDemoEquipmentBody),
    equipment ? findsOneWidget : findsNothing,
  );
  expect(
    find.textContaining(l.homeAdDemoCta),
    findsNWidgets((lab ? 1 : 0) + (equipment ? 1 : 0)),
  );
}

void _expectNoDemo(AppLocalizations l) {
  expect(find.text(l.homeAdDemoTitle), findsNothing);
  expect(find.text(l.homeAdDemoLabBody), findsNothing);
  expect(find.text(l.homeAdDemoEquipmentBody), findsNothing);
  expect(find.textContaining(l.homeAdDemoCta), findsNothing);
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    final l = _l(lang);

    group('bosh sahifa reklama joylari (${lang.name})', () {
      testWidgets(
        '(a) haqiqiy hamkorlar: karta, “Reklama” yorlig‘i, demo yo‘q',
        (tester) async {
          final backend = FakeLabBackend()
            ..seedPartner(_lab())
            ..seedPartner(_equipment());
          final s = await makeServices(
            tester,
            language: lang,
            backend: backend,
            allFeaturesOpen: true,
          );
          await pumpApp(tester, s, size: _tall);
          await goTo(tester, '/home');
          expect(find.text('Sinov Laboratoriya MChJ'), findsOneWidget);
          expect(find.text('Sinov Apparat MChJ'), findsOneWidget);
          expect(find.textContaining(l.partnerKindLaboratory), findsWidgets);
          expect(find.textContaining(l.partnerKindDistributor), findsWidgets);
          // Har kartada “Reklama” yorlig'i.
          expect(find.text(l.partnerAdLabel), findsNWidgets(2));
          _expectNoDemo(l);
          expect(tester.takeException(), isNull);

          // Karta hamkor sahifasini ochadi.
          await tester.tap(find.text('Sinov Laboratoriya MChJ'));
          await tester.pumpAndSettle();
          expect(find.byType(PartnerScreen), findsOneWidget);
        },
      );

      testWidgets(
        '(a) faqat apparat hamkori: laboratoriya joyi demo, apparat joyi haqiqiy',
        (tester) async {
          final backend = FakeLabBackend()
            ..seedPartner(_equipment(kind: PartnerKind.manufacturer));
          final s = await makeServices(
            tester,
            language: lang,
            backend: backend,
            allFeaturesOpen: true,
          );
          await pumpApp(tester, s, size: _tall);
          await goTo(tester, '/home');
          expect(find.text('Sinov Apparat MChJ'), findsOneWidget);
          _expectDemo(l, equipment: false);
        },
      );

      testWidgets('(b) hamkor yo‘q + demo build: aniq “Namuna / Demo” o‘rni', (
        tester,
      ) async {
        // Server ulangan, lekin faol hamkor yo'q (qoralama/to'xtatilgan/
        // muddati o'tgan ham hisobga olinmaydi).
        final backend = FakeLabBackend()
          ..seedPartner(_lab(id: 'd1', status: PartnerStatus.draft))
          ..seedPartner(_equipment(id: 'p1', status: PartnerStatus.paused));
        final s = await makeServices(
          tester,
          language: lang,
          backend: backend,
          allFeaturesOpen: true,
        );
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        _expectDemo(l);
        // Har ikkalasida “Reklama” yorlig'i; soxta kompaniya/aloqa yo'q.
        expect(find.text(l.partnerAdLabel), findsNWidgets(2));
        expect(find.byType(PartnerLogo), findsNothing);
        expect(find.text(l.partnerCall), findsNothing);
        expect(find.text(l.partnerTelegram), findsNothing);
        expect(find.textContaining('MChJ'), findsNothing);
        expect(find.textContaining('+998'), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('(b) demo build, server sozlanmagan: namuna ko‘rinadi', (
        tester,
      ) async {
        final s = await makeServices(
          tester,
          language: lang,
          allFeaturesOpen: true,
        );
        expect(s.partners.enabled, isFalse);
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        _expectDemo(l);
      });

      testWidgets('(b) “Reklama joylashtirish” — Hamkor bo‘lish sahifasi', (
        tester,
      ) async {
        final s = await makeServices(
          tester,
          language: lang,
          allFeaturesOpen: true,
        );
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        final cta = find.textContaining(l.homeAdDemoCta).first;
        await tester.ensureVisible(cta);
        await tester.pumpAndSettle();
        await tester.tap(cta);
        await tester.pumpAndSettle();
        expect(find.byType(BecomePartnerScreen), findsOneWidget);
        expect(find.text(l.partnerOfferTitle), findsOneWidget);
      });

      testWidgets('(c) hamkor yo‘q + do‘kon build: hech narsa chizilmaydi', (
        tester,
      ) async {
        for (final backend in [
          // Server ulangan, faol hamkor yo'q.
          FakeLabBackend()
            ..seedPartner(_lab(id: 'd1', status: PartnerStatus.draft)),
          // Server ulanmagan.
          null,
        ]) {
          final s = await makeServices(
            tester,
            language: lang,
            backend: backend,
            allFeaturesOpen: false,
          );
          await pumpApp(tester, s, size: _tall);
          await goTo(tester, '/home');
          _expectNoDemo(l);
          expect(find.byType(PartnerTag), findsNothing);
          expect(find.text(l.partnerAdLabel), findsNothing);
          expect(find.byType(HomePartnerSlot), findsNWidgets(2));
          for (final slot in find.byType(HomePartnerSlot).evaluate()) {
            expect(_sizeOf(slot).height, 0);
          }
          await tester.pumpWidget(const SizedBox());
        }
      });

      testWidgets('(c) do‘kon build, haqiqiy hamkor bor: u ko‘rinadi', (
        tester,
      ) async {
        final backend = FakeLabBackend()..seedPartner(_lab());
        final s = await makeServices(
          tester,
          language: lang,
          backend: backend,
          allFeaturesOpen: false,
        );
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        expect(find.text('Sinov Laboratoriya MChJ'), findsOneWidget);
        // Apparat joyida hamkor yo'q va build do'kon — demo ham yo'q.
        _expectNoDemo(l);
      });

      testWidgets('layout: 320 px, 1.3× shrift, demo va haqiqiy kartalar', (
        tester,
      ) async {
        const long =
            'Laboratoriya Uskunalari va Diagnostika Servisi Sinov '
            'Hamkor Mas’uliyati Cheklangan Jamiyati MChJ';
        for (final backend in [
          null,
          FakeLabBackend()
            ..seedPartner(_lab(name: long))
            ..seedPartner(_equipment(name: long, kind: PartnerKind.service)),
        ]) {
          final s = await makeServices(
            tester,
            language: lang,
            backend: backend,
            allFeaturesOpen: true,
          );
          await pumpApp(tester, s, size: const Size(320, 6000), textScale: 1.3);
          await goTo(tester, '/home');
          expect(find.byType(HomePartnerSlot), findsNWidgets(2));
          for (final card in find.byType(HomePartnerSlot).evaluate()) {
            expect(_sizeOf(card).width, lessThanOrEqualTo(320));
            expect(_sizeOf(card).height, greaterThan(0));
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        }
      });
    });
  }

  group('joylashuv', () {
    for (final role in AppRole.values) {
      testWidgets('${role.name}: reklama tezkor tugmalar to‘ri ostida, ixcham; '
          'tugmalar ko‘rinishi reklamaga bog‘liq emas', (tester) async {
        // 390x844: do'kon buildda (reklamasiz) va demo/haqiqiy hamkor bilan
        // birinchi ekrandagi tezkor tugmalar aynan bir xil.
        Future<List<int>> visibleTiles({
          required bool open,
          bool real = false,
        }) async {
          final backend = FakeLabBackend();
          if (real) {
            backend
              ..seedPartner(_lab())
              ..seedPartner(_equipment());
          }
          final s = await makeServices(
            tester,
            role: role,
            backend: backend,
            allFeaturesOpen: open,
          );
          await pumpApp(tester, s);
          await goTo(tester, '/home');
          expect(find.byType(HomeSearchField).hitTestable(), findsOne);
          final tiles = find.byType(LgTile);
          final visible = [
            for (var i = 0; i < tiles.evaluate().length; i++)
              if (tiles.at(i).hitTestable().evaluate().isNotEmpty) i,
          ];
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          return visible;
        }

        final base = await visibleTiles(open: false);
        expect(await visibleTiles(open: true), base);
        expect(await visibleTiles(open: true, real: true), base);
        expect(await visibleTiles(open: false, real: true), base);

        // Joylashuv (baland ekranda): har ikkala joy to'rdan darhol keyin,
        // bir qatorli ixcham (60..96 px).
        for (final real in [false, true]) {
          final backend = FakeLabBackend();
          if (real) {
            backend
              ..seedPartner(_lab())
              ..seedPartner(_equipment());
          }
          final s = await makeServices(
            tester,
            role: role,
            backend: backend,
            allFeaturesOpen: true,
          );
          await pumpApp(tester, s, size: _tall);
          await goTo(tester, '/home');
          final grid = find.byType(LgTwoColumnGrid);
          final gridBottom = tester.getBottomLeft(grid).dy;
          final slots = find.byType(HomePartnerSlot).evaluate().toList();
          expect(slots, hasLength(2));
          var top = gridBottom;
          for (final slot in slots) {
            final box = slot.renderObject! as RenderBox;
            final y = box.localToGlobal(Offset.zero).dy;
            expect(y - top, lessThanOrEqualTo(12), reason: 'real=$real');
            expect(box.size.height, inInclusiveRange(60, 96));
            top = y + box.size.height;
          }
          await tester.pumpWidget(const SizedBox());
        }
      });

      testWidgets('${role.name}: tartib — tugmalar, reklama 1-2, kunlik karta, '
          'tahlillar', (tester) async {
        final l = _l(AppLanguage.uz);
        final s = await makeServices(tester, role: role, allFeaturesOpen: true);
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        final lastTile = tester.getBottomLeft(find.byType(LgTile).last).dy;
        final labSlot = tester.getTopLeft(find.byType(HomePartnerSlot).first);
        final eqSlot = tester.getTopLeft(find.byType(HomePartnerSlot).last);
        final daily = tester.getTopLeft(find.byType(DailyCard)).dy;
        final useful = tester.getTopLeft(find.text(l.homeUsefulTests)).dy;
        expect(labSlot.dy, greaterThanOrEqualTo(lastTile));
        expect(eqSlot.dy, greaterThan(labSlot.dy));
        expect(daily, greaterThan(eqSlot.dy));
        expect(useful, greaterThan(daily));
        // Tugmalar orasida reklama yo'q: grid ichida HomePartnerSlot yo'q.
        expect(
          find.descendant(
            of: find.byType(LgTwoColumnGrid),
            matching: find.byType(HomePartnerSlot),
          ),
          findsNothing,
        );
      });

      testWidgets('${role.name}: do‘kon build, hamkor yo‘q — reklama yo‘q', (
        tester,
      ) async {
        final s = await makeServices(
          tester,
          role: role,
          allFeaturesOpen: false,
        );
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        expect(find.byType(LgTile), findsWidgets);
        expect(find.text(_l(AppLanguage.uz).partnerAdLabel), findsNothing);
        for (final slot in find.byType(HomePartnerSlot).evaluate()) {
          expect(_sizeOf(slot).height, 0);
        }
      });
    }
  });

  group('hisoblagich', () {
    testWidgets(
      'demo kartalar ko‘rsatilish yubormaydi (hisobli foydalanuvchi)',
      (tester) async {
        final backend = FakeLabBackend();
        final s = await makeServices(
          tester,
          backend: backend,
          allFeaturesOpen: true,
        );
        await _signIn(tester, s);
        expect(backend.hasSession, isTrue);
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        _expectDemo(_l(AppLanguage.uz));
        // Demo kartada bosish ham sanalmaydi.
        await tester.pump(const Duration(seconds: 1));
        expect(backend.partnerTrackCalls, 0);
      },
    );

    testWidgets('haqiqiy hamkor: joy bo‘yicha bir martadan sanaladi', (
      tester,
    ) async {
      final backend = FakeLabBackend()
        ..seedPartner(_lab())
        ..seedPartner(_equipment());
      final s = await makeServices(
        tester,
        backend: backend,
        allFeaturesOpen: false,
      );
      await _signIn(tester, s);
      await pumpApp(tester, s, size: _tall);
      await goTo(tester, '/home');
      expect(
        backend.partnerImpressionsAt('lab-1', PartnerPlacement.homeLab),
        1,
      );
      expect(
        backend.partnerImpressionsAt('eq-1', PartnerPlacement.homeEquipment),
        1,
      );
      // Ikkalasi bir kadrda — bitta so'rov; boshqa joy sanalmagan.
      expect(backend.partnerTrackCalls, 1);
      expect(
        backend.partnerImpressionsAt('lab-1', PartnerPlacement.labHome),
        0,
      );
      // Qayta ochish o'sha kunda qayta sanalmaydi.
      await goTo(tester, '/lab');
      await goTo(tester, '/home');
      expect(
        backend.partnerImpressionsAt('lab-1', PartnerPlacement.homeLab),
        1,
      );
    });
  });
}
