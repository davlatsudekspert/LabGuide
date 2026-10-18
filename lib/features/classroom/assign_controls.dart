import 'package:material_ui/material_ui.dart';

import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../learn/exam_question.dart';
import '../support/support_screens.dart' show formatWhen;

// Guruhga test topshirish sahifalari uchun umumiy boshqaruvlar: mavzu testi
// (“Guruhga topshirish”) va umumiy test bir xil ko'rinish va bir xil
// tanlovlarga ega bo'lsin (vaqt, ochiq turish muddati, javoblar qachon
// ochiladi, variantli rejim, tanlangan savollar ro'yxati).

/// “Test qancha vaqt ochiq turadi”.
enum AssignDue { none, d1, d3, d7, custom }

/// Har talabaga vaqt tanlovlari (daqiqa); ulardan tashqari — “Vaqtsiz”.
const kAssignLimits = [10, 15, 20, 30, 45, 60];

/// Standart vaqt (daqiqa).
const kAssignDefaultLimit = 10;

/// Muddat — tanlangan kunning oxiri (23:59, qurilma vaqti).
DateTime? assignDueAt(AssignDue due, DateTime? custom, DateTime now) {
  DateTime endOf(int days) =>
      DateTime(now.year, now.month, now.day + days, 23, 59);
  return switch (due) {
    AssignDue.none => null,
    AssignDue.d1 => endOf(1),
    AssignDue.d3 => endOf(3),
    AssignDue.d7 => endOf(7),
    AssignDue.custom => custom,
  };
}

/// Sana tanlash (bir yil ichida); natija — o'sha kunning 23:59 i.
Future<DateTime?> pickAssignDueDate(
  BuildContext context,
  DateTime now,
  DateTime? current,
) async {
  final date = await showDatePicker(
    context: context,
    initialDate: current ?? now.add(const Duration(days: 1)),
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
  );
  if (date == null) return null;
  return DateTime(date.year, date.month, date.day, 23, 59);
}

/// “Har bir talabaga boshqa savollar” (D-66).
class AssignVariantSwitch extends StatelessWidget {
  const AssignVariantSwitch({
    super.key,
    required this.supported,
    required this.allowed,
    required this.value,
    required this.poolSize,
    required this.count,
    required this.onChanged,
  });

  /// Server variantli testni qo'llaydimi.
  final bool supported;

  /// Hovuz ≥ 2 × N (va son to'g'ri).
  final bool allowed;
  final bool value;
  final int poolSize;
  final int count;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SwitchListTile.adaptive(
      key: const ValueKey('assign-variant'),
      contentPadding: EdgeInsets.zero,
      title: Text(l.variantToggle),
      subtitle: Text(
        !supported
            ? l.variantUnsupported
            : !allowed
            ? l.variantDisabledBody(poolSize, count < 1 ? 2 : count * 2)
            : value
            ? l.variantOnBody(poolSize, count)
            : l.variantOffBody,
        key: const ValueKey('assign-variant-note'),
      ),
      value: value,
      onChanged: allowed ? onChanged : null,
    );
  }
}

/// Vaqt (har talabaga), test ochiq turish muddati va javoblar qachon
/// ochilishi — bitta blok.
class AssignTimingControls extends StatelessWidget {
  const AssignTimingControls({
    super.key,
    required this.limit,
    required this.onLimit,
    required this.due,
    required this.dueAt,
    required this.onDue,
    required this.onPickDate,
    required this.afterDue,
    required this.onAfterDue,
  });

  /// Daqiqa; null — vaqtsiz.
  final int? limit;
  final ValueChanged<int?> onLimit;
  final AssignDue due;
  final DateTime? dueAt;
  final ValueChanged<AssignDue> onDue;
  final VoidCallback onPickDate;
  final bool afterDue;
  final ValueChanged<bool> onAfterDue;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final needsDue = afterDue && dueAt == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.classesTimeLimit),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in kAssignLimits)
              LgChoiceChip(
                key: ValueKey('assign-limit-$m'),
                label: l.examMinutes(m),
                selected: limit == m,
                onTap: () => onLimit(m),
              ),
            LgChoiceChip(
              key: const ValueKey('assign-limit-none'),
              label: l.classesNoLimit,
              selected: limit == null,
              onTap: () => onLimit(null),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          limit == null
              ? l.topicTestLimitNoneBody
              : l.topicTestLimitBody(limit!),
          key: const ValueKey('assign-limit-note'),
          style: text.bodyMedium,
        ),
        LgSectionTitle(l.topicTestOpenFor),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (d, label) in [
              (AssignDue.none, l.classesDueNone),
              (AssignDue.d1, l.classesDueDays(1)),
              (AssignDue.d3, l.classesDueDays(3)),
              (AssignDue.d7, l.classesDueDays(7)),
            ])
              LgChoiceChip(
                key: ValueKey('assign-due-${d.name}'),
                label: label,
                selected: due == d,
                onTap: () => onDue(d),
              ),
            LgChoiceChip(
              label: l.classesDuePick,
              selected: due == AssignDue.custom,
              onTap: onPickDate,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          dueAt == null
              ? l.classesDueNoneBody
              : l.classesDueAt(formatWhen(dueAt!, context)),
          style: text.bodyMedium,
        ),
        LgSectionTitle(l.topicTestReveal),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LgChoiceChip(
              key: const ValueKey('assign-reveal-now'),
              label: l.topicTestRevealNow,
              selected: !afterDue,
              onTap: () => onAfterDue(false),
            ),
            LgChoiceChip(
              key: const ValueKey('assign-reveal-after'),
              label: l.topicTestRevealAfterDue,
              selected: afterDue,
              onTap: () => onAfterDue(true),
            ),
          ],
        ),
        if (needsDue) ...[
          const SizedBox(height: 8),
          LgNotice(l.topicTestRevealNeedsDue, kind: NoticeKind.error),
        ],
      ],
    );
  }
}

/// Raqamlangan savollar ro'yxati (“Tanlangan savollar” / variant hovuzi).
class AssignQuestionList extends StatelessWidget {
  const AssignQuestionList({
    super.key,
    required this.questions,
    this.dense = false,
  });

  final List<ExamQuestion> questions;

  /// Uzun ro'yxat (variant hovuzi) — qatorlar zichroq.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return LgPanel(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, q) in questions.indexed)
            Padding(
              padding: EdgeInsets.symmetric(vertical: dense ? 6 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Text('${i + 1}.', style: text.labelLarge),
                  ),
                  Expanded(child: Text(q.prompt(lang), style: text.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
