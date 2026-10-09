import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/ui/content_widgets.dart';
import '../toifa/toifa_bank.dart';
import '../toifa/toifa_controller.dart';
import 'exam_question.dart';
import 'exam_session.dart';

/// `07:45` yoki `1:02:05` — taymer va sarflangan vaqt uchun.
String formatClock(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = (s % 60).toString().padLeft(2, '0');
  return h > 0
      ? '$h:${m.toString().padLeft(2, '0')}:$sec'
      : '$m:$sec'.padLeft(5, '0');
}

/// Sessiya savollari banki: kontent paketi yoki toifa imtihoni banki.
class ExamSourceGate extends StatelessWidget {
  const ExamSourceGate({
    super.key,
    required this.sourceId,
    required this.builder,
  });

  final String sourceId;
  final Widget Function(BuildContext context, ExamQuestionSource source)
  builder;

  @override
  Widget build(BuildContext context) {
    if (sourceId == PackQuestionSource.sourceId) {
      return ContentGate(
        builder: (context, pack) =>
            builder(context, PackQuestionSource.of(pack)),
      );
    }
    if (sourceId == ToifaQuestionSource.sourceId) {
      return ToifaBankGate(
        builder: (context, bank) => builder(context, bank.source),
      );
    }
    final l = AppLocalizations.of(context);
    return LgStateView(kind: StateKind.error, title: l.examSourceMissing);
  }
}

/// Toifa banki yuklanguncha — holat bloki; buzilgan bo'lsa — xato va qayta
/// urinish.
class ToifaBankGate extends StatefulWidget {
  const ToifaBankGate({super.key, required this.builder});

  final Widget Function(BuildContext context, ToifaBank bank) builder;

  @override
  State<ToifaBankGate> createState() => _ToifaBankGateState();
}

class _ToifaBankGateState extends State<ToifaBankGate> {
  @override
  void initState() {
    super.initState();
    context.services.toifa.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.services.toifa;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final bank = c.bank;
        if (bank != null) return widget.builder(context, bank);
        if (c.state == ToifaLoadState.failed) {
          return LgStateView(
            kind: StateKind.error,
            title: l.toifaLoadError,
            actionLabel: l.actionRetry,
            onAction: c.retry,
          );
        }
        return const LgStateView(kind: StateKind.loading, title: '');
      },
    );
  }
}

/// Joriy savollar manbasi (yuklanmagan bo'lsa — null).
ExamQuestionSource? examSourceOf(BuildContext context, String sourceId) {
  if (sourceId == ToifaQuestionSource.sourceId) {
    return context.services.toifa.bank?.source;
  }
  if (sourceId != PackQuestionSource.sourceId) return null;
  final pack = context.services.content.pack;
  return pack == null ? null : PackQuestionSource.of(pack);
}

/// Imtihon bo'limi manzili: toifa testi o'z bo'limida ochiladi va yakunlanadi.
String examBase(String sourceId) => sourceId == ToifaQuestionSource.sourceId
    ? '/learn/toifa/test'
    : '/learn/exam';

/// Sessiya sarlavhasi: topshiriq nomi yoki tanlangan mavzular.
String examSessionTitle(
  ExamSession s,
  ExamQuestionSource? source,
  AppLocalizations l,
  String lang,
) {
  if (s.title != null) return s.title!;
  if (s.mode == ExamMode.rework) return l.examReworkTitle;
  if (s.sourceId == ToifaQuestionSource.sourceId && s.topicIds.isEmpty) {
    return l.toifaTestTitle;
  }
  if (s.topicIds.isEmpty || source == null) return l.examTitleAll;
  final topics = {for (final t in source.topics) t.id: t};
  final names = [
    for (final id in s.topicIds)
      if (topics[id] case final t?) t.name(l, lang),
  ];
  if (names.isEmpty) return l.examTitleAll;
  return names.length == 1
      ? names.single
      : l.examTitleTopics(names.first, names.length - 1);
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Imtihon javoblari “xatolar ustida ishlash” uchun mashq tarixiga ham
/// yoziladi (faqat javob berilganlari).
Future<void> recordExamProgress(AppServices services, ExamSession s) async {
  if (s.sourceId != PackQuestionSource.sourceId &&
      s.sourceId != ToifaQuestionSource.sourceId) {
    return;
  }
  for (var i = 0; i < s.items.length; i++) {
    if (!s.isAnswered(i)) continue;
    await services.quizProgress.record(
      s.items[i].questionId,
      correct: s.isCorrect(i),
    );
  }
}

/// Mavzular: ko'p tanlovli chiplar. Bo'sh tanlov — “Hammasi”.
class TopicChips extends StatelessWidget {
  const TopicChips({
    super.key,
    required this.source,
    required this.selected,
    required this.onChanged,
  });

  final ExamQuestionSource source;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        LgChoiceChip(
          label: '${l.examAllTopics} · ${source.questions.length}',
          selected: selected.isEmpty,
          onTap: () => onChanged(const {}),
        ),
        for (final t in source.topics)
          LgChoiceChip(
            label: '${t.name(l, lang)} · ${t.questions.length}',
            selected: selected.contains(t.id),
            onTap: () {
              final next = Set.of(selected);
              if (!next.remove(t.id)) next.add(t.id);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

/// Raqam maydoni (raqamli klaviatura, faqat raqam) va tezkor qiymatlar.
class NumberPresetField extends StatelessWidget {
  const NumberPresetField({
    super.key,
    required this.label,
    required this.controller,
    required this.presets,
    required this.onChanged,
    this.hint,
    this.errorText,
    this.helper,
  });

  final String label;
  final TextEditingController controller;

  /// (yorliq, qiymat) — qiymat bo'sh satr bo'lishi mumkin (masalan, “vaqtsiz”).
  final List<(String, String)> presets;
  final VoidCallback onChanged;
  final String? hint;
  final String? errorText;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgField(
          label: label,
          controller: controller,
          hint: hint,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          errorText: errorText,
          onChanged: (_) => onChanged(),
        ),
        if (helper != null && errorText == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(helper!, style: text.bodySmall),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (label, value) in presets)
              LgChoiceChip(
                label: label,
                selected: controller.text == value,
                onTap: () {
                  controller.text = value;
                  FocusScope.of(context).unfocus();
                  onChanged();
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// Imtihonni yechish ekrani: savol, aralashtirilgan variantlar, belgilash,
/// savollar xaritasi va pastda doim ko'rinadigan taymer + oldinga/orqaga.
/// Har o'zgarish darhol qurilmaga yoziladi; vaqt tugasa — o'zi yakunlanadi.
class ExamRunner extends StatefulWidget {
  const ExamRunner({
    super.key,
    required this.session,
    required this.title,
    required this.onFinish,
  });

  final ExamSession session;
  final String title;
  final Future<void> Function({required bool timedOut}) onFinish;

  @override
  State<ExamRunner> createState() => _ExamRunnerState();
}

class _ExamRunnerState extends State<ExamRunner> {
  Timer? _ticker;
  late final AppLifecycleListener _lifecycle;
  bool _finishing = false;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    // Ilova fondan qaytdi — vaqt tugagan bo'lsa darhol yakun.
    _lifecycle = AppLifecycleListener(onResume: _tick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _lifecycle.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _tick() {
    if (!mounted || _finishing) return;
    final now = context.services.exams.now();
    if (widget.session.expired(now)) {
      unawaited(_finish(timedOut: true));
    } else {
      setState(() {});
    }
  }

  Future<void> _finish({required bool timedOut}) async {
    if (_finishing) return;
    _finishing = true;
    _ticker?.cancel();
    try {
      await widget.onFinish(timedOut: timedOut);
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  Future<void> _confirmFinish() async {
    final l = AppLocalizations.of(context);
    final s = widget.session;
    final ok = await confirmDialog(
      context,
      title: l.examFinishTitle,
      body: s.unansweredCount == 0 && s.flags.isEmpty
          ? l.examFinishBodyAll
          : l.examFinishBody(s.unansweredCount, s.flags.length),
      action: l.examFinish,
    );
    if (ok && mounted) await _finish(timedOut: false);
  }

  void _changed() {
    setState(() {});
    unawaited(context.services.exams.save(widget.session));
  }

  void _go(int i) {
    widget.session.goTo(i);
    _changed();
    // Yangi savol tepadan boshlanadi.
    if (_scroll.hasClients) {
      final d = LgMotion.of(context, LgMotion.page);
      if (d == Duration.zero) {
        _scroll.jumpTo(0);
      } else {
        unawaited(_scroll.animateTo(0, duration: d, curve: Curves.easeOut));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final s = widget.session;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, c) {
            final gutter = LgSpace.gutter(c.maxWidth);
            final side = (c.maxWidth - LgSpace.maxContentWidth) / 2;
            final h = side > gutter ? side : gutter;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RunHeader(title: widget.title, session: s, horizontal: h),
                Expanded(
                  child: Scrollbar(
                    controller: _scroll,
                    child: ListView(
                      controller: _scroll,
                      padding: EdgeInsets.fromLTRB(h, 18, h, 28),
                      children: [
                        ExamSourceGate(
                          sourceId: s.sourceId,
                          builder: (context, source) {
                            final q = source.question(s.current.questionId);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    LgEyebrow(
                                      l.quizProgress(s.index + 1, s.length),
                                    ),
                                    if (q?.isDraft ?? false)
                                      LgTag(
                                        l.quizDraftTag,
                                        tone: LgTone.warning,
                                      ),
                                    // Rasmiy ro'yxatdagi raqam.
                                    if (q is OfficialKeyQuestion)
                                      LgTag(
                                        l.toifaListNumber(q.number),
                                        tone: LgTone.neutral,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (q == null)
                                  LgNotice(l.examQuestionMissing)
                                else
                                  _QuestionBody(
                                    session: s,
                                    question: q,
                                    onChoose: (i) {
                                      s.choose(i);
                                      _changed();
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                        LgSectionTitle(l.examMap),
                        _QuestionMap(session: s, onTap: _go),
                        const SizedBox(height: 12),
                        const _MapLegend(),
                        const SizedBox(height: 18),
                        LgButton.secondary(
                          label: l.examFinish,
                          icon: Icons.flag_circle_outlined,
                          busy: _finishing,
                          onPressed: _confirmFinish,
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  color: p.paper,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: p.line)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(h, 10, h, 12),
                        child: _BottomBar(
                          session: s,
                          now: context.services.exams.now(),
                          busy: _finishing,
                          onFlag: () {
                            s.toggleFlag();
                            _changed();
                          },
                          onPrev: s.isFirst ? null : () => _go(s.index - 1),
                          onNext: s.isLast
                              ? _confirmFinish
                              : () => _go(s.index + 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Ixcham sarlavha: orqaga, imtihon nomi va javoblar progressi. Katta
/// sarlavha yo'q — savolga ko'proq joy qoladi.
class _RunHeader extends StatelessWidget {
  const _RunHeader({
    required this.title,
    required this.session,
    required this.horizontal,
  });

  final String title;
  final ExamSession session;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final done = session.answeredCount;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal - 10, 6, horizontal, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l.actionBack,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium,
                      ),
                    ),
                    Text(
                      l.examAnsweredOf(done, session.length),
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 8),
            child: ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: session.length == 0 ? 0 : done / session.length,
                  minHeight: 5,
                  color: p.brand,
                  backgroundColor: p.line,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    required this.session,
    required this.question,
    required this.onChoose,
  });

  final ExamSession session;
  final ExamQuestion question;
  final ValueChanged<int> onChoose;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final item = session.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(question.prompt(lang), style: text.headlineSmall),
        ),
        if (item.multi) ...[
          const SizedBox(height: 8),
          LgTag(
            AppLocalizations.of(context).examMultiHint,
            icon: Icons.checklist_rounded,
          ),
        ],
        const SizedBox(height: 16),
        for (var d = 0; d < item.order.length; d++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChoiceTile(
              letter: String.fromCharCode(65 + d),
              label: question.option(item.order[d], lang),
              multi: item.multi,
              selected: session.isSelected(session.index, d),
              onTap: () => onChoose(d),
            ),
          ),
      ],
    );
  }
}

/// Variant: harf belgisi, tanlangan holat rang + belgi bilan (rangga
/// tayanmaydi). Imtihonda to'g'ri/xato yakunda ko'rsatiladi.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multi = false,
  });

  final String letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Ko'p javobli savol: belgi kvadrat (checkbox kabi), doira emas.
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPressable(
      onTap: onTap,
      selected: selected,
      color: selected ? p.soft : p.paper,
      border: Border.all(
        color: selected ? p.brand : p.line,
        width: selected ? 2 : 1,
      ),
      borderRadius: BorderRadius.circular(LgRadius.button),
      semanticLabel: '$letter. $label',
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: multi ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: multi ? BorderRadius.circular(8) : null,
                    color: selected ? p.brand : Colors.transparent,
                    border: Border.all(
                      color: selected ? p.brand : p.outline,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded, size: 18, color: p.onBrand)
                      : Text(
                          letter,
                          style: text.labelLarge!.copyWith(color: p.ink),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: text.bodyLarge)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionMap extends StatelessWidget {
  const _QuestionMap({required this.session, required this.onTap});

  final ExamSession session;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        for (var i = 0; i < session.length; i++)
          () {
            final answered = session.isAnswered(i);
            final flagged = session.isFlagged(i);
            final current = i == session.index;
            final state = [
              answered ? l.examLegendAnswered : l.examLegendEmpty,
              if (flagged) l.examLegendFlagged,
            ].join(', ');
            // Joriy savol — tashqi halqa (javob berilgan/berilmaganidan
            // qat'i nazar ko'rinadi).
            // 54 = 44 px bosish maydoni + halqa (2) + oraliq (3).
            return Container(
              width: 54,
              height: 54,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: current ? p.brand : Colors.transparent,
                  width: 2,
                ),
              ),
              child: LgPressable(
                onTap: () => onTap(i),
                selected: current,
                color: answered ? p.brand : p.paper,
                border: answered ? null : Border.all(color: p.outline),
                borderRadius: BorderRadius.circular(12),
                semanticLabel: '${l.examQuestionN(i + 1)}: $state',
                child: ExcludeSemantics(
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${i + 1}',
                          style: text.labelLarge!.copyWith(
                            color: answered ? p.onBrand : p.ink,
                            fontWeight: current
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (flagged)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Icons.bookmark_rounded,
                            size: 13,
                            color: answered ? p.onBrand : p.amber,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }(),
      ],
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme.bodySmall!;
    Widget item(Widget mark, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 6),
        Flexible(child: Text(label, style: text)),
      ],
    );
    Widget box(Color fill, Color? border) => Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(4),
        border: border == null ? null : Border.all(color: border),
      ),
    );
    return ExcludeSemantics(
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          item(box(p.brand, null), l.examLegendAnswered),
          item(box(p.paper, p.outline), l.examLegendEmpty),
          item(
            Icon(Icons.bookmark_rounded, size: 14, color: p.amber),
            l.examLegendFlagged,
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.session,
    required this.now,
    required this.busy,
    required this.onFlag,
    required this.onPrev,
    required this.onNext,
  });

  final ExamSession session;
  final DateTime now;
  final bool busy;
  final VoidCallback onFlag;
  final VoidCallback? onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Juda tor ekran / katta shriftda belgilash tugmasi faqat belgi
        // bilan (nomi screen reader uchun qoladi).
        LayoutBuilder(
          builder: (context, c) {
            final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
            return Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: TimerPill(session: session, now: now),
                  ),
                ),
                const Spacer(),
                _FlagButton(
                  flagged: session.isFlagged(session.index),
                  compact: c.maxWidth / scale < 230,
                  onTap: onFlag,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: LgButton.secondary(
                label: l.examPrev,
                icon: Icons.arrow_back_rounded,
                onPressed: onPrev,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LgButton(
                label: session.isLast ? l.examFinish : l.examNext,
                busy: busy && session.isLast,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Savolni keyin qaytish uchun belgilash (rang + belgi + matn).
class _FlagButton extends StatelessWidget {
  const _FlagButton({
    required this.flagged,
    required this.onTap,
    this.compact = false,
  });

  final bool flagged;
  final VoidCallback onTap;

  /// Faqat belgi (tor ekran).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final fg = flagged ? p.amber : p.ink;
    return LgPressable(
      onTap: onTap,
      selected: flagged,
      color: flagged ? p.amberBg : p.paper,
      border: Border.all(color: flagged ? p.amber : p.outline),
      borderRadius: BorderRadius.circular(LgRadius.chip),
      semanticLabel: l.examFlag,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinTap,
            minWidth: kMinTap,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  flagged
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                  color: fg,
                ),
                if (!compact) ...[
                  const SizedBox(width: 6),
                  Text(
                    flagged ? l.examFlagged : l.examFlag,
                    style: Theme.of(context).textTheme.labelMedium!
                        .copyWith(color: fg),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Qolgan vaqt (vaqtsiz imtihonda — o'tgan vaqt). Oxirgi daqiqada rang va
/// belgi o'zgaradi.
class TimerPill extends StatelessWidget {
  const TimerPill({super.key, required this.session, required this.now});

  final ExamSession session;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final left = session.remaining(now);
    final urgent = left != null && left.inSeconds < 60;
    final value = formatClock(left ?? session.spent(now));
    final fg = urgent ? p.amber : p.brand;
    return Semantics(
      label: left == null ? l.examElapsed(value) : l.examTimeLeft(value),
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: urgent ? p.amberBg : p.soft,
            borderRadius: BorderRadius.circular(LgRadius.tag),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  left == null
                      ? Icons.timelapse_rounded
                      : (urgent ? Icons.alarm_rounded : Icons.timer_outlined),
                  size: 18,
                  color: fg,
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: fg,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Natija: foiz halqasi, motivatsion sarlavha, to'g'ri/xato/javobsiz/vaqt.
class ScoreHero extends StatelessWidget {
  const ScoreHero({
    super.key,
    required this.correct,
    required this.total,
    this.wrong,
    this.unanswered,
    this.spent,
    this.limit,
    this.badges = const [],
    this.caption,
    this.title,
    this.ringLabel,
  });

  final int correct;
  final int total;
  final int? wrong;
  final int? unanswered;
  final Duration? spent;
  final Duration? limit;
  final List<Widget> badges;
  final String? caption;

  /// Halqa ichidagi izoh (berilmasa — “to'g'ri / jami”; bo'sh — izohsiz).
  final String? ringLabel;

  /// Sarlavha (berilmasa — natijaga qarab motivatsion jumla; ustoz
  /// talaba natijasini ko'rganda — neytral sarlavha).
  final String? title;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final band =
        title ??
        (percent >= 90
            ? l.examBand90
            : percent >= 70
            ? l.examBand70
            : percent >= 50
            ? l.examBand50
            : l.examBand0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LgRadius.hero),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.soft, p.paper],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              Semantics(
                label: ringLabel == null
                    ? '$percent%. ${l.quizScore(correct, total)}'
                    : '$percent%',
                child: ExcludeSemantics(
                  child: _ScoreRing(
                    percent: percent,
                    label: ringLabel ?? '$correct / $total',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  band,
                  textAlign: TextAlign.center,
                  style: text.headlineSmall,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                caption ?? l.quizScore(correct, total),
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
              if (badges.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: badges,
                ),
              ],
              if (wrong != null || spent != null) ...[
                const SizedBox(height: 18),
                _StatGrid(
                  stats: [
                    (l.examCorrectN, '$correct', Icons.check_circle_rounded),
                    if (wrong != null)
                      (l.examWrongN, '$wrong', Icons.cancel_rounded),
                    if (unanswered != null)
                      (
                        l.examSkippedN,
                        '$unanswered',
                        Icons.radio_button_unchecked_rounded,
                      ),
                    if (spent != null)
                      (
                        l.examSpent,
                        limit == null
                            ? formatClock(spent!)
                            : '${formatClock(spent!)} / ${formatClock(limit!)}',
                        Icons.timer_outlined,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.percent, required this.label});

  final int percent;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final color = percent >= 50 ? p.brand : p.amber;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent / 100),
      duration: LgMotion.of(context, const Duration(milliseconds: 700)),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => SizedBox.square(
        dimension: 148,
        child: CustomPaint(
          painter: _RingPainter(value: t, track: p.line, color: color),
          // Halqa ichida: katta shriftda ham sig'adi (kichrayadi).
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(t * 100).round()}%',
                    style: text.displaySmall!.copyWith(
                      fontSize: 38,
                      color: p.ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (label.isNotEmpty) Text(label, style: text.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.track, required this.color});

  final double value;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(arc, 0, math.pi * 2, false, base);
    if (value <= 0) return;
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(arc, -math.pi / 2, math.pi * 2 * value, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<(String, String, IconData)> stats;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, c) {
        final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
        final columns = c.maxWidth / scale >= 340 ? stats.length : 2;
        const gap = 8.0;
        final w = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (label, value, icon) in stats)
              SizedBox(
                width: w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: p.paper,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        Icon(icon, size: 18, color: p.brand),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          textAlign: TextAlign.center,
                          style: text.titleMedium!.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Xatolar tahlili kartasi: savol, berilgan va to'g'ri javob(lar), izohlar,
/// asos va manba (manba yoki izoh bo'lmasa — shuni ochiq aytadi).
class ExamReviewCard extends StatelessWidget {
  const ExamReviewCard({
    super.key,
    required this.number,
    required this.question,
    required this.chosen,
    required this.correct,
    this.chosenLabel,
    this.showChosen = true,
  });

  final int number;
  final ExamQuestion? question;

  /// Tanlangan asl variant(lar) (javobsiz — null yoki bo'sh).
  final List<int>? chosen;

  /// Asl to'g'ri variant(lar).
  final List<int> correct;

  /// “Sizning javobingiz” o'rniga (ustoz ko'rinishida — “Talaba javobi”).
  final String? chosenLabel;

  /// Berilgan javob ma'lum emas (masalan, xatolar ro'yxati) — holat va
  /// javob qatori ko'rsatilmaydi, faqat kalit.
  final bool showChosen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final q = question;
    final check = q?.officialKeyCheck;
    final picked = [...?chosen]..sort();
    final right = [...correct]..sort();
    final ok = listEquals(picked, right);
    final none = picked.isEmpty;
    // Rasmiy ro'yxat savollarida variantlar aralashtirilmaydi — izohlar
    // A–D harflariga tayanadi, shuning uchun harf bilan ko'rsatiladi.
    String options(List<int> idx) => [
      for (final i in idx)
        if (q != null && i >= 0 && i < q.optionCount)
          check == null
              ? q.option(i, lang)
              : '${optionLetter(i)}) ${q.option(i, lang)}',
    ].join('; ');
    final status = ok
        ? LgTag(l.examCorrectN, icon: Icons.check_rounded)
        : LgTag(
            none ? l.examNoAnswer : l.examWrongTag,
            tone: LgTone.warning,
            icon: none ? Icons.remove_rounded : Icons.close_rounded,
          );
    final wrongPicked = [
      for (final i in picked)
        if (!right.contains(i)) i,
    ];
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              LgEyebrow(l.examQuestionN(number)),
              if (showChosen) status,
              if (q?.isDraft ?? false)
                LgTag(l.quizDraftTag, tone: LgTone.neutral),
              if (check != null && check.flagged)
                KeyVerdictTag(verdict: check.verdict),
            ],
          ),
          const SizedBox(height: 8),
          if (q == null)
            Text(l.examQuestionMissing, style: text.bodyMedium)
          else ...[
            Text(q.prompt(lang), style: text.titleMedium),
            const SizedBox(height: 12),
            if (!ok && showChosen)
              _AnswerLine(
                icon: none
                    ? Icons.remove_circle_outline_rounded
                    : Icons.cancel_rounded,
                color: p.amber,
                label: chosenLabel ?? l.quizYourAnswer,
                value: none ? l.examNoAnswer : options(picked),
              ),
            _AnswerLine(
              icon: Icons.check_circle_rounded,
              color: p.brand,
              label: check != null && check.flagged
                  ? l.toifaOfficialKey
                  : l.quizCorrectAnswer,
              value: options(right),
            ),
            if (q is OfficialKeyQuestion) ...[
              KeyCheckNote(question: q),
              const OfficialListSource(),
            ] else ...[
              const SizedBox(height: 8),
              for (final i in right)
                if (q.explanation(i, lang) case final e?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(e, style: text.bodyMedium),
                  ),
              if (!ok)
                for (final i in wrongPicked)
                  if (q.explanation(i, lang) case final e?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${l.examWhyWrong}: $e',
                        style: text.bodyMedium!.copyWith(color: p.sub),
                      ),
                    ),
              if (right.every((i) => q.explanation(i, lang) == null))
                Text(
                  l.examNoExplanation,
                  style: text.bodySmall!.copyWith(color: p.amber),
                ),
              if (q.basis(lang) case final b?) ...[
                const SizedBox(height: 4),
                Text(
                  l.quizBasis(b),
                  style: text.bodySmall!.copyWith(color: p.sub),
                ),
              ],
              ExamSources(question: q),
            ],
          ],
        ],
      ),
    );
  }
}

/// Variant harfi (asl indeks bo'yicha): 0 → A.
String optionLetter(int index) => String.fromCharCode(65 + index);

/// Kalit holati belgisi: bahsli yoki noaniq.
class KeyVerdictTag extends StatelessWidget {
  const KeyVerdictTag({super.key, required this.verdict});

  final KeyVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgTag(
      verdict == KeyVerdict.disputed
          ? l.toifaVerdictDisputed
          : l.toifaVerdictAmbiguous,
      tone: LgTone.warning,
      icon: Icons.rate_review_outlined,
    );
  }
}

/// LabGuide izohi rasmiy kalit yonida: kalit bahsli/noaniq bo'lsa — izoh,
/// LabGuide fikricha to'g'ri variant, manbalar va ball qoidasi; kalit to'g'ri
/// bo'lsa — faqat qo'shimcha izoh (bo'lsa).
class KeyCheckNote extends StatelessWidget {
  const KeyCheckNote({super.key, required this.question});

  final OfficialKeyQuestion question;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final check = question.keyCheck;
    final note = check.note;
    // Manba bilan tasdiqlanmagan izoh — belgi bilan, taklifsiz.
    final unverifiedTag = check.unverified
        ? Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              l.toifaUnverifiedNote,
              style: text.bodySmall!.copyWith(color: p.amber),
            ),
          )
        : null;
    if (!check.flagged) {
      if (note == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgNotice(note, title: l.toifaLabGuideNote, kind: NoticeKind.info),
          ?unverifiedTag,
        ],
      );
    }
    final suggested = [
      if (!check.unverified)
        for (final i in check.suggested)
          if (i >= 0 && i < question.optionCount)
            '${optionLetter(i)}) ${question.option(i, lang)}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgNotice(
          [
            ?note,
            if (suggested.isNotEmpty) l.toifaSuggested(suggested.join('; ')),
            if (question.correct.isEmpty)
              l.toifaNoOfficialKey
            else
              l.toifaScoredByOfficial,
          ].join('\n\n'),
          title: l.toifaLabGuideNote,
        ),
        ?unverifiedTag,
        if (check.links.isEmpty && !check.unverified)
          Text(
            l.toifaNoteNoSource,
            style: text.bodySmall!.copyWith(color: p.amber),
          )
        else
          for (final link in check.links) ExamLinkRow(link: link),
      ],
    );
  }
}

/// Tashqi manba qatori (bosilsa — brauzerda ochiladi).
class ExamLinkRow extends StatelessWidget {
  const ExamLinkRow({super.key, required this.link});

  final ExamLink link;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final host = Uri.tryParse(link.url)?.host ?? link.url;
    return InkWell(
      onTap: () => openExternalLink(context, link.url),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${l.quizSources}: $host'
                  '${link.locator == null ? '' : ' · ${link.locator}'}',
                  style: text.bodySmall!.copyWith(color: p.brand),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.open_in_new_rounded, size: 16, color: p.brand),
            ],
          ),
        ),
      ),
    );
  }
}

/// Savol manbasi: rasmiy attestatsiya savollari ro'yxati.
class OfficialListSource extends StatelessWidget {
  const OfficialListSource({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.verified_outlined, size: 16, color: p.sub),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l.toifaListSource,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: text.bodyMedium!.copyWith(color: color),
                  ),
                  TextSpan(text: value, style: text.titleSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Savol manbalari (kontent paketidan; bo'lmasa — "manba yo'q").
class ExamSources extends StatelessWidget {
  const ExamSources({super.key, required this.question});

  final ExamQuestion question;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final pack = context.services.content.pack;
    final sources = [
      for (final r in question.refs)
        if (pack?.source(r.sourceId) case final src?) (src, r.locator),
    ];
    if (sources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          l.examNoSource,
          style: text.bodySmall!.copyWith(color: p.amber),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (src, locator) in sources)
          InkWell(
            onTap: src.url == null
                ? null
                : () => openExternalLink(context, src.url!),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kMinTap),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l.quizSources}: ${src.publisher} — ${src.title}'
                        '${locator == null ? '' : ' · $locator'}',
                        style: text.bodySmall!.copyWith(color: p.brand),
                      ),
                    ),
                    if (src.url != null) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.open_in_new_rounded, size: 16, color: p.brand),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Ekran bo'yi holat (masalan, “faol imtihon yo'q”) — sahifa ichida.
class ExamStatePage extends StatelessWidget {
  const ExamStatePage({super.key, required this.title, required this.state});

  final String title;
  final Widget state;

  @override
  Widget build(BuildContext context) =>
      LgPage(title: title, showProfile: false, children: [state]);
}

/// Mavzu bo'yicha natija: eng zaif mavzu birinchi (qayerdan boshlashni
/// ko'rsatadi). Bitta mavzuli imtihonda ko'rsatilmaydi.
class TopicBreakdown extends StatelessWidget {
  const TopicBreakdown({
    super.key,
    required this.session,
    required this.source,
  });

  final ExamSession session;
  final ExamQuestionSource source;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final scores = session.topicBreakdown();
    if (scores.length < 2) return const SizedBox.shrink();
    final names = {for (final t in source.topics) t.id: t.name(l, lang)};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.examByTopic),
        Text(l.examByTopicNote, style: text.bodySmall),
        const SizedBox(height: 6),
        LgPanel(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            children: [
              for (final t in scores)
                Semantics(
                  container: true,
                  label:
                      '${names[t.topicId] ?? t.topicId}: '
                      '${t.correct}/${t.total}, ${t.percent}%',
                  child: ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  names[t.topicId] ?? t.topicId,
                                  style: text.titleSmall,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${t.correct}/${t.total} · ${t.percent}%',
                                style: text.bodyMedium!.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: t.total == 0 ? 0 : t.correct / t.total,
                              minHeight: 6,
                              color: t.percent >= 50 ? p.brand : p.amber,
                              backgroundColor: p.line,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
