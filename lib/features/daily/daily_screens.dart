import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/ui/content_widgets.dart';
import '../learn/exam_question.dart';
import '../learn/exam_widgets.dart';
import '../settings/settings_controller.dart';
import '../share/result_share.dart';
import '../toifa/toifa_bank.dart';
import '../toifa/toifa_screens.dart';
import 'daily_controller.dart';
import 'daily_reminder.dart';
import 'daily_streak.dart';

/// Kunlik savol sahifasi (O'rganish tabi ichida).
const kDailyLocation = '/learn/daily';

/// Rolga mos mavzular (kontent paketi guruhlari) — kunlik to'plamda
/// ustuvor. Talaba va ustoz uchun — barcha mavzular teng.
const _rolePriority = <AppRole, Set<String>>{
  AppRole.doctor: {
    'carbohydrate',
    'kidney',
    'liver',
    'lipids',
    'proteins',
    'endocrine',
    'cardiac',
    'iron-vitamins',
    'infection-serology',
  },
  AppRole.lab: {
    PackQuestionSource.generalTopic,
    'hematology',
    'coagulation',
    'urine',
    'electrolytes',
    'enzymes',
    'stool-parasitology',
    'body-fluids',
    'cytology',
  },
};

/// Kunlik to'plam uchun savollar hovuzi.
///
/// Toifa banki: faqat ball hisoblanadigan (rasmiy kaliti bor, mutaxassis
/// tekshiruvi kutilayotganlari chiqarilgan) va kaliti LabGuide tekshiruvidan
/// o'tgan (bahsli/noaniq yoki manbasiz izohli emas) savollar.
/// Kontent paketi: manbasi ko'rsatilgan savollar; rolga mos mavzular ustuvor.
DailyPool dailyPoolFor(ExamQuestionSource source, AppRole role) {
  if (source is ToifaQuestionSource) {
    return DailyPool(
      sourceId: source.id,
      priority: const [],
      others: [
        for (final q in source.bank.scorable)
          if (q.keyCheck.verdict == KeyVerdict.ok && !q.keyCheck.unverified)
            q.id,
      ],
    );
  }
  final topics = _rolePriority[role] ?? const <String>{};
  final priority = <String>[];
  final others = <String>[];
  for (final q in source.questions) {
    if (q.refs.isEmpty) continue;
    (q.topicIds.any(topics.contains) ? priority : others).add(q.id);
  }
  return DailyPool(sourceId: source.id, priority: priority, others: others);
}

/// Savollar manbasi: O'zbekiston foydalanuvchisiga (shifokordan tashqari)
/// toifa banki, qolganlarga
/// kontent paketi mashq savollari.
class _DailySourceGate extends StatelessWidget {
  const _DailySourceGate({required this.builder});

  final Widget Function(BuildContext context, ExamQuestionSource source)
  builder;

  @override
  Widget build(BuildContext context) => toifaVisible(context)
      ? ToifaBankGate(builder: (context, bank) => builder(context, bank.source))
      : ContentGate(
          builder: (context, pack) =>
              builder(context, PackQuestionSource.of(pack)),
        );
}

String _time(BuildContext context, int hour, int minute) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: hour, minute: minute),
      alwaysUse24HourFormat: true,
    );

// ─────────────────────────────── Karta ───────────────────────────────

/// Ixcham karta: bosh sahifada va O'rganish tabida. Manba yuklanishini
/// kutmaydi — faqat saqlangan holatdan o'qiydi.
class DailyCard extends StatelessWidget {
  const DailyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final daily = context.services.daily;
    return ListenableBuilder(
      listenable: daily,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        final p = LgPalette.of(context);
        final text = Theme.of(context).textTheme;
        final set = daily.todaySet;
        final streak = daily.streak;
        final started = set != null && set.answeredCount > 0;
        final done = set?.done ?? false;
        final (title, body, cta) = done
            ? (
                l.dailyCardDone(set!.correctCount, set.ids.length),
                l.dailyCardDoneSub,
                l.dailyShowResult,
              )
            : started
            ? (
                l.dailyCardProgress(set.answeredCount, set.ids.length),
                streak.current > 0 ? l.dailyKeepStreak : l.dailyCardStartSub,
                l.dailyContinue,
              )
            : (
                l.dailyCardStart,
                streak.current > 0 ? l.dailyKeepStreak : l.dailyCardStartSub,
                l.dailyStart,
              );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: p.paper,
              borderRadius: BorderRadius.circular(LgRadius.card),
              border: Border.all(color: p.brand.withValues(alpha: 0.22)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: done ? p.soft : p.brand,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            done
                                ? Icons.check_rounded
                                : Icons.wb_sunny_outlined,
                            color: done ? p.brand : p.onBrand,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LgEyebrow(l.dailyTitle),
                            Semantics(
                              header: true,
                              child: Text(title, style: text.titleMedium),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(body, style: text.bodyMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Dots(set: set),
                      if (streak.current > 0) _StreakChip(days: streak.current),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LgButton(
                    label: cta,
                    icon: done
                        ? Icons.insights_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: () => openInTab(context, kDailyLocation),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Besh nuqta: javob berilmagan / to'g'ri / noto'g'ri (shakl bilan ham
/// farqlanadi — faqat rangga tayanmaydi).
class _Dots extends StatelessWidget {
  const _Dots({required this.set, this.current});

  final DailySet? set;
  final int? current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final s = set;
    final n = s?.ids.length ?? 5;
    return Semantics(
      label: l.dailyCardProgress(s?.answeredCount ?? 0, n),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < n; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Builder(
                builder: (context) {
                  final a = s == null ? null : s.answers[s.ids[i]];
                  final isCurrent = i == current && a == null;
                  final color = a == null
                      ? (isCurrent ? p.brand : p.line)
                      : a.correct
                      ? p.brand
                      : p.amber;
                  return Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: a == null ? null : color,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: a == null
                        ? null
                        : Icon(
                            a.correct
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 14,
                            color: a.correct ? p.onBrand : p.paper,
                          ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) => LgTag(
    AppLocalizations.of(context).dailyStreakDays(days),
    icon: Icons.local_fire_department_rounded,
  );
}

// ─────────────────────────────── Sahifa ───────────────────────────────

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  /// Ko'rilayotgan savol. null — birinchi javobsiz savol (hammasi
  /// javoblangan bo'lsa — natija).
  int? _index;
  int? _day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return ListenableBuilder(
      listenable: Listenable.merge([
        services.daily,
        services.reminders,
        services.settings,
      ]),
      builder: (context, _) => _DailySourceGate(
        builder: (context, source) {
          final daily = services.daily;
          final set = daily.ensureToday(
            dailyPoolFor(source, services.settings.effectiveRole),
            exists: (id) => source.question(id) != null,
          );
          // Yarim tunda yangi kun — yangi to'plam boshidan.
          if (set != null && _day != set.day) {
            _day = set.day;
            _index = null;
          }
          final subtitle = DateFormat.yMMMMEEEEd(locale)
              .format(dateOfDay(daily.today));
          if (set == null) {
            return LgPage(
              title: l.dailyTitle,
              subtitle: subtitle,
              showProfile: false,
              children: [
                LgStateView(kind: StateKind.empty, title: l.dailyEmpty),
              ],
            );
          }
          final showResult = set.done && _index == null;
          final index = _index ?? set.nextIndex;
          return LgPage(
            key: ValueKey((index, showResult)),
            title: l.dailyTitle,
            subtitle: subtitle,
            showProfile: false,
            children: showResult
                ? _result(context, set, source)
                : _question(context, set, source, index),
          );
        },
      ),
    );
  }

  List<Widget> _question(
    BuildContext context,
    DailySet set,
    ExamQuestionSource source,
    int index,
  ) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final id = set.ids[index];
    final q = source.question(id)!;
    final answer = set.answers[id];
    final answered = answer != null;
    final official = q is OfficialKeyQuestion ? q : null;
    final last = index == set.ids.length - 1 || set.done;
    return [
      Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          LgEyebrow(l.quizProgress(index + 1, set.ids.length)),
          if (official != null)
            LgTag(l.toifaListNumber(official.number), tone: LgTone.neutral),
          if (q.isDraft) LgTag(l.quizDraftTag, tone: LgTone.warning),
          if (official != null) const UzbekOnlyTag(),
        ],
      ),
      const SizedBox(height: 8),
      _Dots(set: set, current: index),
      const SizedBox(height: 14),
      Semantics(
        header: true,
        child: Text(q.prompt(lang), style: text.headlineSmall),
      ),
      if (official != null)
        OfficialTextToggle(question: official, showTag: false),
      const SizedBox(height: 14),
      for (var i = 0; i < q.optionCount; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _Option(
            letter: optionLetter(i),
            label: q.option(i, lang),
            state: !answered
                ? _Opt.idle
                : q.correct.contains(i)
                ? _Opt.key
                : i == answer.chosen
                ? _Opt.wrong
                : _Opt.idle,
            onTap: answered ? null : () => _answer(set, q, i),
          ),
        ),
      if (answered) ..._feedback(context, q, answer),
      if (answered) ...[
        const SizedBox(height: 14),
        LgButton(
          label: last && set.done ? l.dailyShowResult : l.quizNext,
          icon: Icons.arrow_forward_rounded,
          onPressed: () => setState(() {
            _index = set.done ? null : set.nextIndex;
          }),
        ),
      ],
      const SizedBox(height: 14),
      Text(
        official != null ? l.dailySourceToifa : l.quizReviewNote,
        style: text.bodySmall!.copyWith(color: p.sub),
      ),
    ];
  }

  Future<void> _answer(DailySet set, ExamQuestion q, int i) async {
    final services = context.services;
    final correct = q.correct.contains(i);
    setState(() => _index = set.ids.indexOf(q.id));
    await services.daily.answer(q.id, i, correct: correct);
    // "Xatolar ustida ishlash" uchun umumiy mashq tarixiga ham.
    await services.quizProgress.record(q.id, correct: correct);
  }

  List<Widget> _feedback(BuildContext context, ExamQuestion q, DailyAnswer a) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    if (q is OfficialKeyQuestion) {
      return [
        LgNotice(
          a.correct ? l.toifaPracticeRight : l.toifaPracticeWrong,
          title: a.correct ? l.quizCorrect : l.quizIncorrect,
          kind: a.correct ? NoticeKind.info : NoticeKind.warning,
        ),
        KeyCheckNote(question: q),
        const OfficialListSource(),
      ];
    }
    final explanations = [
      ?q.explanation(a.chosen, lang),
      if (!a.correct)
        for (final i in q.correct) ?q.explanation(i, lang),
    ];
    return [
      LgNotice(
        explanations.isEmpty ? l.examNoExplanation : explanations.join('\n\n'),
        title: a.correct ? l.quizCorrect : l.quizIncorrect,
        kind: a.correct ? NoticeKind.info : NoticeKind.warning,
      ),
      if (q.basis(lang) case final b?)
        Text(l.quizBasis(b), style: text.bodySmall!.copyWith(color: p.sub)),
      ExamSources(question: q),
    ];
  }

  List<Widget> _result(
    BuildContext context,
    DailySet set,
    ExamQuestionSource source,
  ) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final services = context.services;
    final streak = services.daily.streak;
    return [
      ScoreHero(correct: set.correctCount, total: set.ids.length),
      ShareResultButton(
        primary: true,
        data: ShareData(
          kind: ShareKind.daily,
          correct: set.correctCount,
          total: set.ids.length,
          date: services.daily.now(),
          streak: streak.current,
        ),
      ),
      const SizedBox(height: 6),
      _StreakPanel(stats: streak, today: services.daily.today),
      // Birinchi marta — taklif; keyin (yoki rad etilgach) — sozlama.
      if (services.reminders.shouldOffer)
        const _ReminderOffer()
      else
        const _ReminderSettings(),
      const SizedBox(height: 6),
      Text(l.dailyCardDoneSub, style: text.bodyMedium),
      LgSectionTitle(l.dailyReviewTitle),
      for (final (i, id) in set.ids.indexed)
        ExamReviewCard(
          number: i + 1,
          question: source.question(id),
          chosen: [?set.answers[id]?.chosen],
          correct: source.question(id)?.correct.toList() ?? const [],
        ),
    ];
  }
}

enum _Opt { idle, key, wrong }

class _Option extends StatelessWidget {
  const _Option({
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String label;
  final _Opt state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final (Color bg, Color border, String? suffix) = switch (state) {
      _Opt.idle => (p.paper, p.line, null),
      _Opt.key => (p.soft, p.brand, l.quizCorrectAnswer),
      _Opt.wrong => (p.amberBg, p.amber, l.quizYourAnswer),
    };
    final fg = state == _Opt.wrong ? p.amber : p.brand;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LgRadius.button),
        border: Border.all(color: border, width: state == _Opt.idle ? 1 : 2),
      ),
      child: LgPressable(
        onTap: onTap,
        color: bg,
        borderRadius: BorderRadius.circular(LgRadius.button),
        semanticLabel: suffix == null
            ? '$letter. $label'
            : '$letter. $label. $suffix',
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state == _Opt.idle ? null : fg,
                      border: Border.all(
                        color: state == _Opt.idle ? p.outline : fg,
                        width: 1.5,
                      ),
                    ),
                    child: state == _Opt.idle
                        ? Text(letter, style: text.labelLarge)
                        : Icon(
                            state == _Opt.key
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 18,
                            color: p.onBrand,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: text.bodyLarge),
                        if (suffix != null)
                          Text(
                            suffix,
                            style: text.bodySmall!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Seriya: joriy, eng uzun, haftalik muzlatish va qoida.
class _StreakPanel extends StatelessWidget {
  const _StreakPanel({required this.stats, required this.today});

  final StreakStats stats;
  final int today;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    Widget stat(String value, String label, {bool main = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: text.headlineSmall!.copyWith(
            color: main ? p.brand : p.ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(label, style: text.bodySmall),
      ],
    );
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: p.brand,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(l.dailyStreakTitle, style: text.titleMedium),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 28,
            runSpacing: 10,
            children: [
              stat(
                l.dailyDaysShort(stats.current),
                l.dailyStreakCurrent,
                main: true,
              ),
              stat(l.dailyDaysShort(stats.best), l.dailyStreakBest),
            ],
          ),
          const SizedBox(height: 12),
          LgTag(
            stats.freezeUsedThisWeek
                ? l.dailyFreezeUsed
                : l.dailyFreezeAvailable,
            tone: stats.freezeUsedThisWeek ? LgTone.neutral : LgTone.brand,
            icon: Icons.ac_unit_rounded,
          ),
          if (stats.frozen.contains(today - 1)) ...[
            const SizedBox(height: 8),
            Text(
              l.dailyFreezeSaved,
              style: text.bodySmall!.copyWith(color: p.brand),
            ),
          ],
          const SizedBox(height: 8),
          Text(l.dailyFreezeRule, style: text.bodySmall),
        ],
      ),
    );
  }
}

Future<void> _enableReminder(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final r = context.services.reminders;
  final result = await r.enable();
  if (result == ReminderPermission.granted && context.mounted) {
    showSnack(
      context,
      l.dailyReminderOnSnack(_time(context, r.hour, r.minute)),
    );
  }
}

/// Birinchi bajarilgan to'plamdan keyin — muloyim taklif (bir marta).
class _ReminderOffer extends StatelessWidget {
  const _ReminderOffer();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final r = context.services.reminders;
    // const vidjet — eslatma holati o'zgarsa o'zi qayta chiziladi.
    return ListenableBuilder(
      listenable: r,
      builder: (context, _) => LgPanel(
        soft: true,
        margin: const EdgeInsets.only(top: 12, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: p.brand,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(l.dailyOfferTitle, style: text.titleMedium),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l.dailyOfferBody, style: text.bodyMedium),
            const SizedBox(height: 4),
            Text(
              l.dailyReminderAt(_time(context, r.hour, r.minute)),
              style: text.bodySmall!.copyWith(color: p.brand),
            ),
            if (r.lastDenied != null) _deniedNotice(l, r.lastDenied!),
            const SizedBox(height: 12),
            LgButton(
              label: l.dailyOfferYes,
              icon: Icons.notifications_active_outlined,
              onPressed: () => _enableReminder(context),
            ),
            const SizedBox(height: 8),
            LgButton.link(label: l.dailyOfferNo, onPressed: r.closeOffer),
          ],
        ),
      ),
    );
  }
}

Widget _deniedNotice(AppLocalizations l, ReminderPermission p) => LgNotice(
  p == ReminderPermission.denied
      ? l.dailyReminderDenied
      : l.dailyReminderUnavailable,
);

/// Eslatma sozlamasi: yoqish/o'chirish va vaqt.
class _ReminderSettings extends StatelessWidget {
  const _ReminderSettings();

  Future<void> _pickTime(BuildContext context) async {
    final r = context.services.reminders;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: r.hour, minute: r.minute),
      helpText: AppLocalizations.of(context).dailyReminderTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) await r.setTime(picked.hour, picked.minute);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final r = context.services.reminders;
    return ListenableBuilder(
      listenable: r,
      builder: (context, _) => _build(context, l, p, text, r),
    );
  }

  Widget _build(
    BuildContext context,
    AppLocalizations l,
    LgPalette p,
    TextTheme text,
    ReminderController r,
  ) {
    final time = _time(context, r.hour, r.minute);
    return LgPanel(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: LgRow(
              title: l.dailyReminderSetting,
              subtitle: r.enabled
                  ? l.dailyReminderAt(time)
                  : l.dailyReminderOff,
              icon: r.enabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              onTap: () => r.enabled ? r.disable() : _enableReminder(context),
              trailing: Switch(
                value: r.enabled,
                onChanged: (on) => on ? _enableReminder(context) : r.disable(),
              ),
              divider: r.enabled,
            ),
          ),
          if (r.enabled)
            LgRow(
              title: l.dailyReminderTime,
              subtitle: time,
              icon: Icons.schedule_rounded,
              onTap: () => _pickTime(context),
              divider: false,
            ),
          if (r.lastDenied != null && !r.shouldOffer)
            _deniedNotice(l, r.lastDenied!),
          const SizedBox(height: 6),
          Text(
            l.dailyReminderNote,
            style: text.bodySmall!.copyWith(color: p.sub),
          ),
        ],
      ),
    );
  }
}

/// Bildirishnoma bosilganda kunlik savolni ochish.
void openDailyFromReminder(GoRouter router) => router.go(kDailyLocation);
