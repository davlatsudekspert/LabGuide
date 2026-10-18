import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/build_flags.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../auth/ui/role_screen.dart';
import '../auth/ui/welcome_screen.dart';
import '../classroom/lecture_catalog.dart';
import '../classroom/topic_test_screens.dart' show AssignedTestsCard;
import '../community/community_screens.dart';
import '../content/ui/conditions_screens.dart';
import '../content/ui/content_widgets.dart';
import '../daily/daily_screens.dart';
import '../partners/partner_widgets.dart';
import 'global_search.dart';
import 'resume_history.dart';
import '../settings/settings_controller.dart';
import '../toifa/toifa_screens.dart';
import '../toifa/toifa_today.dart' show ToifaTodayCard;

/// Bosh sahifadagi bitta tezkor amal.
class HomeAction {
  const HomeAction(this.label, this.icon, this.location, this.caption);

  final String label;
  final IconData icon;

  /// Kartadagi bir qatorli izoh: ichida nima borligini aytadi (hamma
  /// kartada bir xil "Ochish" emas).
  final String caption;

  /// `context.go` bilan ochiladi: tegishli tab o'z stacki bilan tanlanadi.
  final String location;
}

/// Rolga mos bosh sahifa tarkibi. Rol faqat ustuvorlikni o'zgartiradi —
/// kontent va ruxsatlar hamma uchun bir xil.
class RoleHome {
  const RoleHome({
    required this.heroTitle,
    required this.heroBody,
    required this.heroCta,
    required this.heroLocation,
    required this.actions,
    required this.usefulAnalytes,
    this.featuredConditions = const [],
  });

  final String heroTitle;
  final String heroBody;

  /// Hero tugmasi: oxirgi ochilgan narsa bo'lmasa — rolning boshlang'ich
  /// amali (1-plitkadan farqli, D-68 Q3). Tarix bo'lsa — “Davom ettirish”.
  final String heroCta;
  final String heroLocation;
  final List<HomeAction> actions;
  final List<String> usefulAnalytes;

  /// Bo'sh bo'lmasa — bosh sahifada “Kasallik bo'yicha tahlillar”
  /// qo'llanmasi kartasi (shu holatlar bir bosishda ochiladi).
  final List<String> featuredConditions;

  static RoleHome of(AppRole role, AppLocalizations l) => switch (role) {
    AppRole.doctor => RoleHome(
      heroTitle: l.homeHeroDoctorTitle,
      heroBody: l.homeHeroDoctorBody,
      heroCta: l.homeHeroDoctorCta,
      // Tahlil qidiruvi (maydon fokusda) — 1-plitka "Tahlillar" ro'yxatini
      // takrorlamaydi (D-68 Q3).
      heroLocation: '/tests?search=1',
      actions: [
        HomeAction(
          l.featureTests,
          Icons.biotech_outlined,
          '/tests',
          l.homeTileTests,
        ),
        HomeAction(
          l.featureCalculators,
          Icons.calculate_outlined,
          '/lab/calculators',
          l.homeTileCalculators,
        ),
        HomeAction(
          l.labPreanalytics,
          Icons.vaccines_outlined,
          '/lab/preanalytics',
          l.homeTileSampling,
        ),
        HomeAction(
          l.featureSaved,
          Icons.bookmark_outline,
          '/library/saved',
          l.homeTileSaved,
        ),
      ],
      usefulAnalytes: const ['glucose-plasma-fasting', 'creatinine', 'alt'],
      featuredConditions: const [
        'type-2-diabetes',
        'iron-deficiency-anemia',
        'hypothyroidism',
        'chronic-kidney-disease',
      ],
    ),
    AppRole.lab => RoleHome(
      heroTitle: l.homeHeroLabTitle,
      heroBody: l.homeHeroLabBody,
      heroCta: l.homeHeroLabCta,
      heroLocation: '/lab/qc',
      actions: [
        HomeAction(
          l.featureQc,
          Icons.show_chart_rounded,
          '/lab/qc',
          l.labQcSub,
        ),
        HomeAction(
          l.diffTitle,
          Icons.bubble_chart_outlined,
          '/lab/differential',
          l.homeTileDiff,
        ),
        HomeAction(
          l.featureCalibration,
          Icons.tune_rounded,
          '/lab/calibration',
          l.homeTileCalibration,
        ),
        HomeAction(
          l.featureCalculators,
          Icons.calculate_outlined,
          '/lab/calculators',
          l.homeTileCalculators,
        ),
        HomeAction(
          l.labPreanalytics,
          Icons.science_outlined,
          '/lab/preanalytics',
          l.homeTileSampling,
        ),
        HomeAction(
          l.labInstruments,
          Icons.precision_manufacturing_outlined,
          '/lab/instruments',
          l.homeTileInstruments,
        ),
      ],
      usefulAnalytes: const [
        'glucose-plasma-fasting',
        'potassium',
        'urine-microscopy',
      ],
    ),
    AppRole.student => RoleHome(
      heroTitle: l.homeHeroStudentTitle,
      heroBody: l.homeHeroStudentBody,
      heroCta: l.homeHeroStudentCta,
      heroLocation: '/learn/daily',
      actions: [
        HomeAction(
          l.featureTests,
          Icons.menu_book_outlined,
          '/tests',
          l.homeTileTests,
        ),
        HomeAction(
          l.learnQuiz,
          Icons.quiz_outlined,
          '/learn/quiz',
          l.analytePracticeSub,
        ),
        HomeAction(
          l.featureMicroscopy,
          Icons.biotech_outlined,
          '/lab/microscopy',
          l.labMicroscopySub,
        ),
        HomeAction(
          l.featureExam,
          Icons.timer_outlined,
          '/learn/exam',
          l.homeTileExam,
        ),
        // "Kunlik savol" plitkasi yo'q: shu sahifada Kunlik karta bor
        // (D-68 Q3).
        HomeAction(
          l.featureTopics,
          Icons.school_outlined,
          '/learn',
          l.homeTileTopics,
        ),
      ],
      usefulAnalytes: const ['glucose-plasma-fasting', 'hba1c', 'egfr'],
    ),
    AppRole.teacher => RoleHome(
      heroTitle: l.homeHeroTeacherTitle,
      heroBody: l.homeHeroTeacherBody,
      heroCta: l.homeHeroTeacherCta,
      heroLocation: '/learn/classes',
      actions: [
        HomeAction(
          l.featureClasses,
          Icons.groups_outlined,
          '/learn/classes',
          l.homeTileClasses,
        ),
        // Ma'ruza rejimi (D-45/47).
        HomeAction(
          l.lectureTitle,
          Icons.co_present_outlined,
          '/learn/lecture',
          l.homeTileLecture,
        ),
        HomeAction(
          l.featureSources,
          Icons.fact_check_outlined,
          '/library/sources',
          l.libSourcesSub,
        ),
        HomeAction(
          l.featureResearch,
          Icons.edit_note_rounded,
          '/library/research',
          l.libResearchSub,
        ),
      ],
      usefulAnalytes: const ['glucose-plasma-fasting', 'hba1c', 'crp'],
    ),
  };
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.services.settings;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final role = settings.effectiveRole;
        final config = RoleHome.of(role, l);
        return LgPage(
          // Rol almashganda sarlavha holati ham yangidan boshlanadi.
          key: ValueKey(role),
          title: l.homeTitle,
          eyebrow: role.title(l),
          showBrand: true,
          compactTitle: true,
          children: [
            const HomeSearchField(),
            // Reklama joylari (“Reklama” yorlig'i bilan): 1 — laboratoriya
            // xizmati, 2 — apparat firmasi; yonma-yon ixcham juftlik —
            // ilova ochilganda birinchi ekranda. Faqat hamkor UI yoqilgan
            // (test) buildda; do'kon buildida umuman yo'q.
            if (BuildFlags.partnerAds) const HomePartnerPair(),
            // Rolning tezkor tugmalari qidiruvdan keyin darhol: birinchi
            // ekranda (rasm/shifokor qo'llanmasi kartasi ularni pastga
            // surib yubormasin).
            LgTwoColumnGrid(
              children: [
                for (var i = 0; i < config.actions.length; i++)
                  LgFadeIn(
                    delay: i * 0.08,
                    child: LgTile(
                      title: config.actions[i].label,
                      caption: config.actions[i].caption,
                      icon: config.actions[i].icon,
                      highlighted: i == 0,
                      // Yorliq bo'limning o'zini va'da qiladi (masalan,
                      // "Kalkulyatorlar" — ro'yxat, oxirgi kalkulyator emas).
                      // QC va kalibrlash — tab steki tiklanadi: kiritilgan,
                      // hali saqlanmagan qiymatlar yo'qolmasin.
                      onTap: () => openInTab(
                        context,
                        config.actions[i].location,
                        exact: !_keepsStack(config.actions[i].location),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (config.featuredConditions.isNotEmpty)
              ConditionGuideCard(
                base: '/home',
                featured: config.featuredConditions,
              ),
            _HomeHero(config: config, role: role),
            // Kunlik 5 ta savol — har kuni qaytish uchun ixcham karta.
            const DailyCard(),
            // Talabaga guruhda berilgan testlar (muddati bilan).
            const AssignedTestsCard(),
            // Hamjamiyat (faqat server ulangan buildda; aks holda yo'q).
            const CommunityHomeCard(),
            // Laborant uchun tezkor amal: toifa imtihoniga tayyorgarlik
            // (faqat O'zbekiston foydalanuvchilariga). Bo'lim ochilgach —
            // "Bugun" kartasi (laborant va toifani ochgan har kim).
            if (toifaVisible(context)) _ToifaHomeSlot(lab: role == AppRole.lab),
            LgSectionTitle(l.homeUsefulTests),
            ContentGate(
              builder: (context, pack) {
                final analytes = [
                  for (final id in config.usefulAnalytes) ?pack.analyte(id),
                ];
                return Column(
                  children: [
                    for (var i = 0; i < analytes.length; i++)
                      AnalyteRow(
                        analyte: analytes[i],
                        divider: i < analytes.length - 1,
                        onTap: () =>
                            context.push('/home/analyte/${analytes[i].id}'),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Bosh sahifa hero kartasi (D-68 Q3): “Davom ettirish” — oxirgi ochilgan
/// taqdimot, mavzu testi yoki bo'lim (shu qurilma tarixi); tarix bo'lmasa —
/// rolning boshlang'ich amali: talaba — kunlik savollar, ustoz — guruhlar,
/// laborant — bugungi toifa mashg'uloti (toifa ko'rinsa) yoki QC, shifokor —
/// tahlil qidiruvi.
class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.config, required this.role});

  final RoleHome config;
  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    final history = ResumeHistory.of(services.store);
    final bundle = services.curriculum.bundle ?? rootBundle;
    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final last = history.last;
        if (last == null || !last.fullScreen) return _card(context, last, null);
        return FutureBuilder<DeckCatalog>(
          future: DeckCatalog.load(bundle),
          initialData: DeckCatalog.peek(bundle),
          builder: (context, snap) => _card(context, last, snap.data),
        );
      },
    );
  }

  Widget _card(BuildContext context, ResumeEntry? last, DeckCatalog? catalog) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    // Toifa bo'limi yopiq foydalanuvchiga toifa yozuvi ko'rsatilmaydi.
    final usable =
        last != null &&
        !(last.kind == ResumeKind.section &&
            last.id == 'toifa' &&
            !toifaVisible(context));
    final title = usable ? resumeTitle(last, l, lang, catalog) : null;
    final location = usable ? last.location : null;
    if (title != null && location != null) {
      final fullScreen = last!.fullScreen;
      return LgHeroCard(
        compact: true,
        image: kHeroImage,
        title: config.heroTitle,
        body: l.homeResumeBody(title),
        action: LgButton(
          key: const ValueKey('home-hero-cta'),
          label: l.homeResumeCta,
          icon: Icons.play_arrow_rounded,
          // Bo'lim — o'z tabida, ichkaridagi ochiq sahifasi bilan
          // (stek tiklanadi); taqdimot va test — to'liq ekran.
          onPressed: () => fullScreen
              ? context.push(location)
              : openInTab(context, location),
        ),
      );
    }
    final toifa = role == AppRole.lab && toifaVisible(context);
    return LgHeroCard(
      compact: true,
      image: kHeroImage,
      title: config.heroTitle,
      body: config.heroBody,
      action: LgButton(
        key: const ValueKey('home-hero-cta'),
        label: toifa ? l.homeHeroLabToifaCta : config.heroCta,
        onPressed: () =>
            openInTab(context, toifa ? toifaBase : config.heroLocation),
      ),
    );
  }
}

bool _keepsStack(String location) =>
    location == '/lab/qc' || location == '/lab/calibration';

/// Bosh sahifadagi toifa kartasi: bo'lim hali ochilmagan laborantga —
/// kirish kartasi; ochilgan bo'lsa (har qanday rol) — "Bugun" kartasi.
class _ToifaHomeSlot extends StatelessWidget {
  const _ToifaHomeSlot({required this.lab});

  final bool lab;

  @override
  Widget build(BuildContext context) {
    final toifa = context.services.toifa;
    return ListenableBuilder(
      listenable: toifa,
      builder: (context, _) => toifa.opened
          ? const ToifaTodayCard(compact: true)
          : lab
          ? const ToifaEntryCard(compact: true)
          : const SizedBox.shrink(),
    );
  }
}
