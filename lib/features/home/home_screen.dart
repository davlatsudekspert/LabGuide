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
import '../community/community_screens.dart';
import '../content/ui/conditions_screens.dart';
import '../content/ui/content_widgets.dart';
import '../daily/daily_screens.dart';
import '../partners/partner_widgets.dart';
import 'global_search.dart';
import '../settings/settings_controller.dart';
import '../toifa/toifa_screens.dart';

/// Bosh sahifadagi bitta tezkor amal.
class HomeAction {
  const HomeAction(this.label, this.icon, this.location);

  final String label;
  final IconData icon;

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
      heroLocation: '/tests',
      actions: [
        HomeAction(l.featureTests, Icons.biotech_outlined, '/tests'),
        HomeAction(
          l.featureCalculators,
          Icons.calculate_outlined,
          '/lab/calculators',
        ),
        HomeAction(
          l.featureSampleFactors,
          Icons.vaccines_outlined,
          '/lab/preanalytics',
        ),
        HomeAction(l.featureSaved, Icons.bookmark_outline, '/library/saved'),
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
        HomeAction(l.featureQc, Icons.show_chart_rounded, '/lab/qc'),
        HomeAction(
          l.diffTitle,
          Icons.bubble_chart_outlined,
          '/lab/differential',
        ),
        HomeAction(
          l.featureCalibration,
          Icons.tune_rounded,
          '/lab/calibration',
        ),
        HomeAction(
          l.featureCalculators,
          Icons.calculate_outlined,
          '/lab/calculators',
        ),
        HomeAction(
          l.featureSampling,
          Icons.science_outlined,
          '/lab/preanalytics',
        ),
        HomeAction(
          l.labInstruments,
          Icons.precision_manufacturing_outlined,
          '/lab/instruments',
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
      heroLocation: '/learn',
      actions: [
        HomeAction(l.featureTests, Icons.menu_book_outlined, '/tests'),
        HomeAction(l.featureQuiz, Icons.quiz_outlined, '/learn/quiz'),
        HomeAction(
          l.featureMicroscopy,
          Icons.biotech_outlined,
          '/lab/microscopy',
        ),
        HomeAction(l.featureExam, Icons.timer_outlined, '/learn/exam'),
        HomeAction(l.dailyTitle, Icons.today_outlined, '/learn/daily'),
        HomeAction(l.featureTopics, Icons.school_outlined, '/learn'),
      ],
      usefulAnalytes: const ['glucose-plasma-fasting', 'hba1c', 'egfr'],
    ),
    AppRole.teacher => RoleHome(
      heroTitle: l.homeHeroTeacherTitle,
      heroBody: l.homeHeroTeacherBody,
      heroCta: l.homeHeroTeacherCta,
      heroLocation: '/learn/classes',
      actions: [
        HomeAction(l.featureClasses, Icons.groups_outlined, '/learn/classes'),
        // Ma'ruza rejimi (D-45/47).
        HomeAction(l.lectureTitle, Icons.co_present_outlined, '/learn/lecture'),
        HomeAction(
          l.featureSources,
          Icons.fact_check_outlined,
          '/library/sources',
        ),
        HomeAction(
          l.featureResearch,
          Icons.edit_note_rounded,
          '/library/research',
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
                  LgTile(
                    title: config.actions[i].label,
                    caption: l.actionOpen,
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
              ],
            ),
            const SizedBox(height: 8),
            if (config.featuredConditions.isNotEmpty)
              ConditionGuideCard(
                base: '/home',
                featured: config.featuredConditions,
              ),
            LgHeroCard(
              compact: true,
              image: kHeroImage,
              title: config.heroTitle,
              body: config.heroBody,
              action: LgButton(
                label: config.heroCta,
                onPressed: () => openInTab(context, config.heroLocation),
              ),
            ),
            // Kunlik 5 ta savol — har kuni qaytish uchun ixcham karta.
            const DailyCard(),
            // Hamjamiyat (faqat server ulangan buildda; aks holda yo'q).
            const CommunityHomeCard(),
            // Laborant uchun tezkor amal: toifa imtihoniga tayyorgarlik
            // (faqat O'zbekiston foydalanuvchilariga).
            if (role == AppRole.lab && toifaVisible(context))
              const ToifaEntryCard(compact: true),
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

bool _keepsStack(String location) =>
    location == '/lab/qc' || location == '/lab/calibration';
