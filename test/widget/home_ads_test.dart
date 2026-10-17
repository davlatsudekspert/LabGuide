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
///  (a) hamkor UI yoqilgan (test) build, haqiqiy faol hamkor — hamkor kartasi
///      (+ hisoblagich);
///  (b) hamkor UI yoqilgan build, hamkor yo'q — “Namuna / Demo” o'rni
///      (hisoblagichsiz);
///  (c) do'kon build (`LG_PARTNER_ADS` o'chiq) — hamkor bo'lsa ham hech
///      narsa (reklama UI kompilyatsiyadan chiqariladi).

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
            partnerAds: true,
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
            partnerAds: true,
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
          partnerAds: true,
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
        final s = await makeServices(tester, language: lang, partnerAds: true);
        expect(s.partners.enabled, isFalse);
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        _expectDemo(l);
      });

      testWidgets('(b) “Reklama joylashtirish” — Hamkor bo‘lish sahifasi', (
        tester,
      ) async {
        final s = await makeServices(tester, language: lang, partnerAds: true);
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

      testWidgets('(c) do‘kon build: hamkor bo‘lsa ham reklama yo‘q', (
        tester,
      ) async {
        for (final backend in [
          // Server ulangan, faol hamkorlar bor.
          FakeLabBackend()
            ..seedPartner(_lab())
            ..seedPartner(_equipment()),
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
          );
          await pumpApp(tester, s, size: _tall);
          await goTo(tester, '/home');
          _expectNoDemo(l);
          expect(find.text('Sinov Laboratoriya MChJ'), findsNothing);
          expect(find.byType(PartnerTag), findsNothing);
          expect(find.text(l.partnerAdLabel), findsNothing);
          expect(find.byType(HomePartnerPair), findsNothing);
          expect(find.byType(HomeAdSlotCard), findsNothing);
          if (backend != null) expect(backend.partnerTrackCalls, 0);
          await tester.pumpWidget(const SizedBox());
        }
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
            partnerAds: true,
          );
          await pumpApp(tester, s, size: const Size(320, 6000), textScale: 1.3);
          await goTo(tester, '/home');
          expect(find.byType(HomeAdSlotCard), findsNWidgets(2));
          for (final card in find.byType(HomeAdSlotCard).evaluate()) {
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
      testWidgets(
        '${role.name}: 390x844, 1.0x — ikkala reklama yonma-yon, qidiruvdan '
        'keyin, birinchi ekranda',
        (tester) async {
          const screen = Size(390, 844);
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
              partnerAds: true,
            );
            await pumpApp(tester, s);
            await goTo(tester, '/home');
            final cards = find.byType(HomeAdSlotCard);
            expect(cards, findsNWidgets(2), reason: 'real=$real');
            final rects = [
              for (final e in cards.evaluate())
                (e.renderObject! as RenderBox).localToGlobal(Offset.zero) &
                    (e.renderObject! as RenderBox).size,
            ];
            // Pastki menyu (~90 px) ustiga chiqmaydi, ikkalasi ham ko'rinadi.
            for (final (i, r) in rects.indexed) {
              expect(r.height, inInclusiveRange(60, 104), reason: '$r');
              expect(r.bottom, lessThanOrEqualTo(screen.height - 90));
              expect(cards.at(i).hitTestable(), findsOne);
            }
            // Yonma-yon, teng kenglikda.
            expect(rects[0].top, rects[1].top);
            expect(rects[0].width, closeTo(rects[1].width, 0.5));
            expect(rects[0].right, lessThan(rects[1].left));
            // Qidiruv maydonidan keyin, hero/tezkor tugmalardan oldin.
            final search = tester.getBottomLeft(find.byType(HomeSearchField));
            expect(rects[0].top - search.dy, lessThanOrEqualTo(12));
            // Doktorda hero/tugmalar (ostidagi “Kasallik bo'yicha tahlillar”
            // kartasi bilan) birinchi ekrandan pastga tushadi — bu kutilgan.
            if (role != AppRole.doctor) {
              final hero = tester.getTopLeft(find.byType(LgHeroCard)).dy;
              expect(hero, greaterThanOrEqualTo(rects[0].bottom));
              // Tezkor amallarning birinchi qatori hech bo'lmasa qisman
              // ko'rinadi.
              final firstTile = tester.getTopLeft(find.byType(LgTile).first).dy;
              expect(firstTile, lessThan(screen.height - 90));
            }
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          }
        },
      );

      testWidgets(
        '${role.name}: tor ekran (320) yoki katta shrift (1.3×) — ustma-ust',
        (tester) async {
          for (final (width, scale) in [(320.0, 1.0), (390.0, 1.3)]) {
            final s = await makeServices(tester, role: role, partnerAds: true);
            await pumpApp(tester, s, size: Size(width, 3000), textScale: scale);
            await goTo(tester, '/home');
            final cards = find.byType(HomeAdSlotCard);
            expect(cards, findsNWidgets(2));
            final a = tester.getTopLeft(cards.first);
            final b = tester.getTopLeft(cards.last);
            expect(b.dx, a.dx);
            expect(b.dy, greaterThan(a.dy));
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          }
        },
      );

      testWidgets('${role.name}: tartib — qidiruv, reklama, hero, tugmalar, '
          'kunlik karta, tahlillar', (tester) async {
        final l = _l(AppLanguage.uz);
        final s = await makeServices(tester, role: role, partnerAds: true);
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        final search = tester.getBottomLeft(find.byType(HomeSearchField)).dy;
        final ads = tester.getTopLeft(find.byType(HomePartnerPair)).dy;
        final hero = tester.getTopLeft(find.byType(LgHeroCard)).dy;
        final firstTile = tester.getTopLeft(find.byType(LgTile).first).dy;
        final daily = tester.getTopLeft(find.byType(DailyCard)).dy;
        final useful = tester.getTopLeft(find.text(l.homeUsefulTests)).dy;
        expect(ads, greaterThanOrEqualTo(search));
        expect(hero, greaterThan(ads));
        expect(firstTile, greaterThan(hero));
        expect(daily, greaterThan(firstTile));
        expect(useful, greaterThan(daily));
        // Tugmalar orasida reklama yo'q.
        expect(
          find.descendant(
            of: find.byType(LgTwoColumnGrid),
            matching: find.byType(HomeAdSlotCard),
          ),
          findsNothing,
        );
      });

      testWidgets('${role.name}: do‘kon build, hamkor yo‘q — reklama yo‘q', (
        tester,
      ) async {
        final s = await makeServices(tester, role: role);
        await pumpApp(tester, s, size: _tall);
        await goTo(tester, '/home');
        expect(find.byType(LgTile), findsWidgets);
        expect(find.text(_l(AppLanguage.uz).partnerAdLabel), findsNothing);
        expect(find.byType(HomeAdSlotCard), findsNothing);
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
          partnerAds: true,
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
      final s = await makeServices(tester, backend: backend, partnerAds: true);
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
