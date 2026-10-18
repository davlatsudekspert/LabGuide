import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart' show openInTab;
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../daily/daily_reminder.dart';
import '../daily/daily_streak.dart' show dateOfDay;
import 'toifa_bank.dart';
import 'toifa_daily.dart';

/// Bo'lim manzili (O'rganish tabi ichida).
const toifaBase = '/learn/toifa';

/// "Davom ettirish": davom etayotgan imtihon → mashq testi → og'zaki bilet;
/// hech biri bo'lmasa — test sahifasi.
String toifaContinueLocation(AppServices services) {
  if (services.exams.active?.sourceId == ToifaQuestionSource.sourceId) {
    return '$toifaBase/test/run';
  }
  if (services.toifa.activeDrill != null) return '$toifaBase/test/practice';
  final t = services.toifa.ticket;
  if (t != null && !t.done) return '$toifaBase/oral';
  return '$toifaBase/test';
}

String _time(BuildContext context, int hour, int minute) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: hour, minute: minute),
      alwaysUse24HourFormat: true,
    );

/// "Bugun" kartasi: bugungi mashg'ulot (savollar, to'g'ri %, biletlar),
/// ketma-ket kunlar, so'nggi 7 kun va "Davom ettirish". Hub'da ([compact]
/// false) — kunlik maqsad va eslatma sozlamasi ham.
class ToifaTodayCard extends StatelessWidget {
  const ToifaTodayCard({super.key, this.compact = false});

  /// Bosh sahifada — sozlamalarsiz; tugma toifa bo'limiga olib boradi.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return ListenableBuilder(
      listenable: Listenable.merge([
        services.toifa,
        services.exams,
        services.reminders,
      ]),
      builder: (context, _) => _build(context, services),
    );
  }

  Widget _build(BuildContext context, AppServices services) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final toifa = services.toifa;
    final today = toifa.todayStats;
    final goal = toifa.goalQuestions;
    final done = toifa.todayGoalMet;
    final streak = toifa.streak;
    final stats = [
      l.toifaTodayProgress(today.answered, goal),
      if (today.answered > 0) l.toifaTodayCorrect(today.percent),
      l.toifaTodayTickets(today.tickets),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DecoratedBox(
        key: const ValueKey('toifa-today'),
        decoration: BoxDecoration(
          color: p.paper,
          borderRadius: BorderRadius.circular(LgRadius.card),
          // Kunlik savol kartasi bilan bir xil: soya, tunda xira chet.
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(color: p.brand.withValues(alpha: 0.14))
              : null,
          boxShadow: LgShadow.card(context),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  LgEyebrow(
                    compact
                        ? '${l.toifaTitle} · ${l.toifaTodayEyebrow}'
                        : l.toifaTodayEyebrow,
                  ),
                  if (streak > 0)
                    LgTag(
                      l.toifaStreakDays(streak),
                      icon: Icons.local_fire_department_rounded,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Semantics(
                header: true,
                child: Text(
                  done ? l.toifaTodayDone : l.toifaTodayGoal(goal),
                  style: text.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: today.progress(goal),
                  minHeight: 6,
                  color: p.brand,
                  backgroundColor: p.line,
                ),
              ),
              const SizedBox(height: 6),
              Text(stats, style: text.bodySmall),
              if (today.isEmpty || done) ...[
                const SizedBox(height: 4),
                Text(
                  done ? l.toifaTodayTomorrow : l.toifaTodayNone,
                  style: text.bodySmall!.copyWith(color: p.sub),
                ),
              ],
              const SizedBox(height: 12),
              ToifaWeekStrip(
                days: toifa.lastDays(),
                goal: goal,
                today: toifa.today,
              ),
              if (!compact) ...[
                const SizedBox(height: 12),
                Text(l.toifaGoalLabel, style: text.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final n in ToifaGoal.options)
                      LgChoiceChip(
                        label: l.toifaGoalOption(n),
                        selected: goal == n,
                        onTap: () => toifa.setGoal(n),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(l.toifaGoalHint, style: text.bodySmall),
                const SizedBox(height: 6),
                const ToifaReminderRow(),
              ],
              const SizedBox(height: 12),
              LgButton(
                label: l.toifaContinue,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _continue(context, services, home: compact),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Davom etayotgan imtihon/mashq/bilet bo'lsa — o'sha joyga. Aks holda
/// hub'da — test sahifasi, bosh sahifada — toifa bo'limi (O'rganish tabida
/// boshqa sahifa ochiq qolgan bo'lsa ham bo'limning o'zi).
void _continue(
  BuildContext context,
  AppServices services, {
  required bool home,
}) {
  final target = toifaContinueLocation(services);
  if (!home || target != '$toifaBase/test') {
    context.go(target);
  } else {
    openInTab(context, toifaBase, exact: true);
  }
}

/// So'nggi 7 kun: har kun ustuni — maqsadga yaqinlik, bugungisi ajratilgan.
class ToifaWeekStrip extends StatelessWidget {
  const ToifaWeekStrip({
    super.key,
    required this.days,
    required this.goal,
    required this.today,
  });

  final List<(int, ToifaDay)> days;
  final int goal;
  final int today;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weekday = DateFormat.E(locale);
    const height = 36.0;
    String label(int day) {
      final s = weekday.format(dateOfDay(day));
      return s.length > 2 ? s.substring(0, 2) : s;
    }

    return Semantics(
      label: l.toifaWeekLabel(
        [
          for (final (d, s) in days)
            '${label(d)} ${(s.progress(goal) * 100).round()}%',
        ].join(', '),
      ),
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (i, (d, s)) in days.indexed) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: height,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 4 + (height - 4) * s.progress(goal),
                          decoration: BoxDecoration(
                            color: s.meets(goal)
                                ? p.brand
                                : s.isEmpty
                                ? p.line
                                : p.brand.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label(d),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: text.labelSmall!.copyWith(
                        color: d == today ? p.brand : p.sub,
                        fontWeight: d == today ? FontWeight.w700 : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _pickToifaTime(BuildContext context) async {
  final r = context.services.reminders;
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: r.toifaHour, minute: r.toifaMinute),
    helpText: AppLocalizations.of(context).dailyReminderTime,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (picked != null) await r.setToifaTime(picked.hour, picked.minute);
}

Widget _deniedNotice(AppLocalizations l, ReminderPermission p) => LgNotice(
  p == ReminderPermission.denied
      ? l.dailyReminderDenied
      : l.dailyReminderUnavailable,
);

/// Toifa eslatmasi: kalit (yoqish — tizim ruxsati bilan) va vaqt.
class ToifaReminderRow extends StatelessWidget {
  const ToifaReminderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = context.services.reminders;
    return ListenableBuilder(
      listenable: r,
      builder: (context, _) {
        final time = _time(context, r.toifaHour, r.toifaMinute);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: LgRow(
                title: l.toifaReminderChannel,
                subtitle: r.toifaEnabled
                    ? l.dailyReminderAt(time)
                    : l.dailyReminderOff,
                icon: r.toifaEnabled
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                onTap: () =>
                    r.toifaEnabled ? r.disableToifa() : r.enableToifa(),
                trailing: Switch(
                  value: r.toifaEnabled,
                  onChanged: (on) => on ? r.enableToifa() : r.disableToifa(),
                ),
                divider: r.toifaEnabled,
              ),
            ),
            if (r.toifaEnabled)
              LgRow(
                title: l.dailyReminderTime,
                subtitle: time,
                icon: Icons.schedule_rounded,
                onTap: () => _pickToifaTime(context),
                divider: false,
              ),
            if (r.toifaDenied != null) _deniedNotice(l, r.toifaDenied!),
          ],
        );
      },
    );
  }
}

/// Kunlik maqsad bajarilgach (natija sahifalarida): "Ertaga davom
/// etamizmi? Eslatma vaqtini tanlang" — vaqt (sukut 20:00) va kalit.
/// Eslatma standart o'chiq; faqat foydalanuvchi yoqsa rejalashtiriladi.
class ToifaReminderOffer extends StatelessWidget {
  const ToifaReminderOffer({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    return ListenableBuilder(
      listenable: Listenable.merge([services.reminders, services.toifa]),
      builder: (context, _) {
        final r = services.reminders;
        if (!r.shouldOfferToifa) return const SizedBox.shrink();
        final l = AppLocalizations.of(context);
        final p = LgPalette.of(context);
        final text = Theme.of(context).textTheme;
        final time = _time(context, r.toifaHour, r.toifaMinute);
        return LgPanel(
          key: const ValueKey('toifa-reminder-offer'),
          soft: true,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
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
                      child: Text(l.toifaOfferTitle, style: text.titleMedium),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(l.toifaOfferBody, style: text.bodyMedium),
              const SizedBox(height: 4),
              MergeSemantics(
                child: LgRow(
                  title: l.toifaReminderChannel,
                  subtitle: r.toifaEnabled
                      ? l.toifaOfferOn(time)
                      : l.dailyReminderOff,
                  icon: r.toifaEnabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  onTap: () =>
                      r.toifaEnabled ? r.disableToifa() : r.enableToifa(),
                  trailing: Switch(
                    key: const ValueKey('toifa-offer-switch'),
                    value: r.toifaEnabled,
                    onChanged: (on) => on ? r.enableToifa() : r.disableToifa(),
                  ),
                ),
              ),
              LgRow(
                title: l.dailyReminderTime,
                subtitle: time,
                icon: Icons.schedule_rounded,
                onTap: () => _pickToifaTime(context),
                divider: false,
              ),
              if (r.toifaDenied != null) _deniedNotice(l, r.toifaDenied!),
              const SizedBox(height: 4),
              Text(
                l.dailyReminderNote,
                style: text.bodySmall!.copyWith(color: p.sub),
              ),
              if (!r.toifaEnabled) ...[
                const SizedBox(height: 4),
                LgButton.link(
                  label: l.dailyOfferNo,
                  onPressed: r.closeToifaOffer,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
