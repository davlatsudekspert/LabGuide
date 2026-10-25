import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../core/entitlements/feature.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../profile/pro_gate.dart';
import '../content/content_model.dart';
import '../learn/quiz_session.dart';
import '../tools/calc_info.dart';
import '../tools/clinical_calc_screens.dart' show CalcSourceTile;
import '../tools/sources_panel.dart';
import 'histology_content.dart';
import '../howto/howto_registry.dart';
import '../howto/howto_widgets.dart';

const histoBase = '/lab/histology';
const histoCardImage = 'assets/histology/card.png';

extension on BuildContext {
  String get _lang => Localizations.localeOf(this).languageCode;

  /// Matn joriy tilda.
  String tr(LocalizedText t) => t.of(_lang);
}

/// Manbalar ro'yxati (takrorsiz, lokator bilan).
class _Refs extends StatelessWidget {
  const _Refs(this.refs);

  final List<CalcRef> refs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, r) in refs.indexed) CalcSourceTile(index: i + 1, ref: r),
      ],
    );
  }
}

/// Mikrofoto: nisbati saqlanadi, bosilsa kattalashtirib ko'rish.
class HistoPhoto extends StatelessWidget {
  const HistoPhoto({
    super.key,
    required this.image,
    required this.semanticLabel,
    this.maxHeight = 360,
    this.zoom = true,
  });

  final HistoImage image;
  final String semanticLabel;
  final double maxHeight;
  final bool zoom;

  @override
  Widget build(BuildContext context) {
    final picture = ClipRRect(
      borderRadius: BorderRadius.circular(LgRadius.card),
      child: Image.asset(
        image.asset,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: maxHeight * image.width / image.height,
        ),
        child: AspectRatio(
          aspectRatio: image.width / image.height,
          child: Semantics(
            image: true,
            label: semanticLabel,
            child: zoom
                ? GestureDetector(
                    key: ValueKey('histo-photo-${image.file}'),
                    onTap: () => _openZoom(context),
                    child: picture,
                  )
                : picture,
          ),
        ),
      ),
    );
  }

  void _openZoom(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: Image.asset(image.asset, semanticLabel: semanticLabel),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: IconButton.filled(
                  tooltip: l.micClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rasm muallifi, litsenziyasi va manba sahifasi.
class HistoCredit extends StatelessWidget {
  const HistoCredit({super.key, required this.image});

  final HistoImage image;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      key: ValueKey('histo-credit-${image.file}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgMetric(
          label: context.tr(HisL.stain),
          value: context.tr(image.stain ?? HisL.stainNotStated),
        ),
        LgMetric(label: l.micAuthor, value: image.author),
        LgMetric(label: l.micLicense, value: image.license),
        LgMetric(label: context.tr(HisL.checked), value: histoCheckedAt),
        const SizedBox(height: 8),
        Text(context.tr(HisL.captionTitle), style: text.labelLarge),
        const SizedBox(height: 2),
        Text('“${image.caption}”', style: text.bodySmall),
        const SizedBox(height: 4),
        Text(context.tr(image.captionTr), style: text.bodyMedium),
        if (image.labels case final labels?) ...[
          const SizedBox(height: 6),
          Text(context.tr(labels), style: text.bodyMedium),
        ],
        const SizedBox(height: 4),
        LgRow(
          title: l.micSourcePage,
          subtitle: 'File:${image.commonsTitle}',
          icon: Icons.open_in_new_rounded,
          onTap: () => openExternalLink(context, image.sourcePage),
        ),
        LgRow(
          title: l.micLicenseText(image.license),
          subtitle: Uri.parse(image.licenseUrl).host,
          icon: Icons.gavel_rounded,
          onTap: () => openExternalLink(context, image.licenseUrl),
          divider: false,
        ),
        Text(
          '${context.tr(HisL.resized)}: ${image.width}×${image.height} px '
          '(${image.originalWidth}×${image.originalHeight} px).',
          style: text.bodySmall,
        ),
      ],
    );
  }
}

// ───────────────────────── Bosh sahifa ─────────────────────────

class HistologyScreen extends StatelessWidget {
  const HistologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      (HisL.atlasTitle, HisL.atlasSub, Icons.biotech_outlined, 'items'),
      (HisL.stainsTitle, HisL.stainsSub, Icons.palette_outlined, 'stains'),
      (HisL.quizTitle, HisL.quizSub, Icons.quiz_outlined, 'quiz'),
      (HisL.creditsTitle, HisL.creditsSub, Icons.copyright_outlined, 'credits'),
    ];
    return LgPage(
      title: l.histoTitle,
      subtitle: context.tr(HisL.subtitle),
      children: [
        const HowToButton(HowToSection.histology),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  histoCardImage,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const SourcesPanel(histoLeadRefs),
        Text(
          context.tr(HisL.photoNote),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        for (final (i, (title, sub, icon, path)) in rows.indexed)
          LgRow(
            key: ValueKey('histo-row-$path'),
            title: context.tr(title),
            subtitle: context.tr(sub),
            icon: icon,
            // Bo'lim ochiq; ichidagi sahifa/vosita — [Feature.labSections] (D-76).
            // Rasm mualliflari (litsenziya) har doim ochiq.
            onTap: () => path == 'credits'
                ? context.push('$histoBase/$path')
                : pushGated(context, Feature.labSections, '$histoBase/$path'),
            divider: i < rows.length - 1,
          ),
        LgSectionTitle(l.diffSourcesTitle),
        for (final (i, s) in HistoSources.all.indexed)
          CalcSourceTile(index: i + 1, ref: CalcRef(s, '')),
      ],
    );
  }
}

// ───────────────────────── Ro'yxat ─────────────────────────

class HistoItemsScreen extends StatelessWidget {
  const HistoItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: context.tr(HisL.atlasTitle),
      subtitle: AppLocalizations.of(context).histoTitle,
      children: [
        Text(context.tr(HisL.classification), style: text.bodyMedium),
        for (final g in HistoGroup.values) ...[
          LgSectionTitle(context.tr(HisL.groups[g]!)),
          for (final item in histoItems.where((i) => i.group == g))
            _ItemRow(item: item),
        ],
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final HistoItem item;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final name = context.tr(item.name);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: p.line.withValues(alpha: 0.7)),
        ),
      ),
      child: LgPressable(
        key: ValueKey('histo-item-${item.id}'),
        onTap: () => context.push('$histoBase/items/${item.id}'),
        borderRadius: BorderRadius.circular(14),
        semanticLabel: name,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.image == null
                      ? Container(
                          width: 64,
                          height: 64,
                          color: p.soft,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: p.sub,
                          ),
                        )
                      : Image.asset(
                          item.image!.asset,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: text.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(item.key.text),
                        style: text.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: p.sub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Karta ─────────────────────────

class HistoItemScreen extends StatelessWidget {
  const HistoItemScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final item = histoItem(itemId);
    if (item == null) {
      return LgPage(
        title: context.tr(HisL.atlasTitle),
        children: [
          LgStateView(
            kind: StateKind.empty,
            title: context.tr(HisL.atlasTitle),
          ),
        ],
      );
    }
    final refs = item.refs;
    // Har da'vo yonida manba raqami: [1], [2].
    String marks(HistoFact f) {
      final n = {
        for (final r in f.refs)
          refs.indexWhere(
                (x) => x.source.id == r.source.id && x.locator == r.locator,
              ) +
              1,
      }.toList()..sort();
      return ' [${n.join(', ')}]';
    }

    Widget fact(HistoFact f) => Text(
      context.tr(f.text) + marks(f),
      style: Theme.of(context).textTheme.bodyMedium,
    );
    final image = item.image;
    return LgPage(
      title: context.tr(item.name),
      subtitle: context.tr(HisL.groups[item.group]!),
      children: [
        if (image != null)
          HistoPhoto(
            image: image,
            semanticLabel:
                '${context.tr(item.name)}. ${context.tr(image.captionTr)}',
          )
        else
          LgNotice(
            context.tr(HisL.noPhoto),
            kind: NoticeKind.info,
            key: const ValueKey('histo-no-photo'),
          ),
        if (image != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${context.tr(HisL.stain)}:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              LgTag(
                context.tr(image.stain ?? HisL.stainNotStated),
                tone: LgTone.neutral,
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        LgNotice(
          context.tr(item.key.text) + marks(item.key),
          title: context.tr(HisL.keyTitle),
          kind: NoticeKind.info,
        ),
        LgSectionTitle(context.tr(HisL.lookTitle)),
        for (final f in item.look)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExcludeSemantics(child: Text('•  ')),
                Expanded(child: fact(f)),
              ],
            ),
          ),
        LgSectionTitle(context.tr(HisL.functionTitle)),
        fact(item.function),
        if (item.where case final w?) ...[
          LgSectionTitle(context.tr(HisL.whereTitle)),
          fact(w),
        ],
        if (item.confuse case final c?) ...[
          LgSectionTitle(context.tr(HisL.confuseTitle)),
          fact(c),
        ],
        if (image != null) ...[
          LgSectionTitle(context.tr(HisL.imageTitle)),
          if (item.imageNote case final n?) ...[
            fact(n),
            const SizedBox(height: 6),
          ],
          HistoCredit(image: image),
        ],
        const SizedBox(height: 6),
        _Refs(refs),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            l.quizReviewNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Bo'yash usullari ─────────────────────────

class HistoStainsScreen extends StatelessWidget {
  const HistoStainsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final seen = <String>{};
    final refs = [
      for (final s in histoStains)
        for (final f in s.facts)
          for (final r in f.refs)
            if (seen.add('${r.source.id}|${r.locator}')) r,
    ];
    return LgPage(
      title: context.tr(HisL.stainsTitle),
      subtitle: AppLocalizations.of(context).histoTitle,
      children: [
        Text(context.tr(HisL.stainsIntro), style: text.bodyMedium),
        for (final s in histoStains) ...[
          LgSectionTitle(context.tr(s.name)),
          for (final f in s.facts)
            Padding(
              key: ValueKey('histo-stain-${s.id}-${s.facts.indexOf(f)}'),
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ExcludeSemantics(child: Text('•  ')),
                  Expanded(
                    child: Text(context.tr(f.text), style: text.bodyMedium),
                  ),
                ],
              ),
            ),
          if (s.example case final img?) ...[
            const SizedBox(height: 4),
            Text(context.tr(HisL.stainExample), style: text.labelLarge),
            const SizedBox(height: 4),
            HistoPhoto(
              image: img,
              semanticLabel: context.tr(img.captionTr),
              maxHeight: 220,
            ),
            const SizedBox(height: 4),
            Text(
              '${context.tr(img.captionTr)} — ${img.author}, ${img.license}',
              style: text.bodySmall,
            ),
          ],
        ],
        const SizedBox(height: 8),
        _Refs(refs),
      ],
    );
  }
}

// ───────────────────────── Mualliflar ─────────────────────────

/// Bo'limdagi barcha rasmlar (karta + bo'yash namunasi), takrorsiz.
List<HistoImage> histoAllImages() {
  final seen = <String>{};
  return [
    for (final i in histoItems)
      if (i.image case final img? when seen.add(img.file)) img,
    for (final s in histoStains)
      if (s.example case final img? when seen.add(img.file)) img,
  ];
}

class HistoCreditsScreen extends StatelessWidget {
  const HistoCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final images = histoAllImages();
    String nameOf(HistoImage img) {
      for (final i in histoItems) {
        if (i.image?.file == img.file) return context.tr(i.name);
      }
      for (final s in histoStains) {
        if (s.example?.file == img.file) return context.tr(s.name);
      }
      return img.commonsTitle;
    }

    return LgPage(
      title: context.tr(HisL.creditsTitle),
      subtitle: AppLocalizations.of(context).histoTitle,
      children: [
        Text(context.tr(HisL.creditsIntro), style: text.bodyMedium),
        for (final img in images) ...[
          LgSectionTitle(nameOf(img)),
          HistoPhoto(
            image: img,
            semanticLabel: nameOf(img),
            maxHeight: 140,
            zoom: false,
          ),
          const SizedBox(height: 6),
          HistoCredit(image: img),
        ],
      ],
    );
  }
}

// ───────────────────────── Mashq ─────────────────────────

class HistoQuizItem {
  const HistoQuizItem(this.item, this.question);

  final HistoItem item;
  final QuizQuestion question;
}

/// Mashqqa kiradigan kartalar: rasmi bor, `quiz` belgilangan va
/// chalg'ituvchilari yozilgan.
List<HistoItem> histoQuizPool() => [
  for (final i in histoItems)
    if (i.image != null && i.quiz && histoDistractors.containsKey(i.id)) i,
];

List<HistoQuizItem> buildHistoQuiz(Random rnd) {
  final pool = histoQuizPool()..shuffle(rnd);
  return [
    for (final item in pool.take(histoQuizSize))
      () {
        final ids = [item.id, ...histoDistractors[item.id]!]..shuffle(rnd);
        return HistoQuizItem(
          item,
          QuizQuestion(
            id: 'histo-${item.id}',
            prompt: HisL.quizPrompt,
            options: [
              for (final id in ids)
                QuizOption(
                  text: histoItem(id)!.name,
                  explanation: histoItem(id)!.key.text,
                ),
            ],
            correctIndex: ids.indexOf(item.id),
            basis: item.key.text,
            refs: const [],
            reviewState: ReviewState.pending,
          ),
        );
      }(),
  ];
}

class HistoQuizScreen extends StatefulWidget {
  const HistoQuizScreen({super.key, this.random});

  final Random? random;

  @override
  State<HistoQuizScreen> createState() => _HistoQuizScreenState();
}

class _HistoQuizScreenState extends State<HistoQuizScreen> {
  List<HistoQuizItem>? _items;
  QuizSession? _session;

  void _start() => setState(() {
    _items = buildHistoQuiz(widget.random ?? Random());
    _session = QuizSession([for (final i in _items!) i.question]);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final s = _session;
    return LgPage(
      key: ValueKey((s == null, s?.index, s?.finished)),
      title: context.tr(HisL.quizTitle),
      subtitle: l.histoTitle,
      children: [
        if (s == null) ...[
          Text(context.tr(HisL.quizIntro), style: text.bodyLarge),
          const SizedBox(height: 16),
          LgButton(
            key: const ValueKey('histo-quiz-start'),
            label: context.tr(HisL.quizStart),
            onPressed: _start,
          ),
          const SizedBox(height: 14),
          Text(l.quizReviewNote, style: text.bodySmall),
        ] else if (s.finished) ...[
          LgStateView(
            kind: StateKind.success,
            title: l.quizDoneTitle,
            message: l.quizScore(s.correctCount, s.questions.length),
          ),
          LgSectionTitle(l.quizMistakes),
          if (s.mistakes.isEmpty)
            Text(l.quizNoMistakes, style: text.bodyMedium)
          else
            for (final (q, chosen) in s.mistakes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LgPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.quizYourAnswer}: '
                        '${context.tr(q.options[chosen].text)}',
                        style: text.bodyMedium,
                      ),
                      Text(
                        '${l.quizCorrectAnswer}: '
                        '${context.tr(q.options[q.correctIndex].text)}',
                        style: text.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(context.tr(q.basis), style: text.bodySmall),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 16),
          LgButton(label: l.quizRestart, onPressed: _start),
        ] else
          _Question(
            session: s,
            item: _items![s.index].item,
            onChanged: () => setState(() {}),
          ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.session,
    required this.item,
    required this.onChanged,
  });

  final QuizSession session;
  final HistoItem item;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final q = session.current;
    final answer = session.answerFor(session.index);
    final answered = answer != null;
    final total = session.questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [LgEyebrow(l.quizProgress(session.index + 1, total))],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (session.index + 1) / total,
              minHeight: 6,
              semanticsLabel: l.quizProgress(session.index + 1, total),
            ),
          ),
        ),
        // Javobni oshkor qilmaslik uchun ekran o'quvchiga nom aytilmaydi.
        HistoPhoto(
          key: ValueKey('histo-quiz-photo-${item.id}'),
          image: item.image!,
          semanticLabel: context.tr(HisL.quizImageLabel),
          maxHeight: 260,
        ),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(context.tr(q.prompt), style: text.headlineSmall),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LgPressable(
              key: ValueKey('histo-opt-$i'),
              onTap: answered
                  ? null
                  : () {
                      if (session.answer(i)) onChanged();
                    },
              color: !answered
                  ? p.paper
                  : i == q.correctIndex
                  ? p.soft
                  : i == answer
                  ? p.amberBg
                  : p.paper,
              border: Border.all(
                color: !answered
                    ? p.line
                    : i == q.correctIndex
                    ? p.brand
                    : i == answer
                    ? p.amber
                    : p.line,
                width: answered && (i == q.correctIndex || i == answer) ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(LgRadius.button),
              semanticLabel: [
                context.tr(q.options[i].text),
                if (answered && i == q.correctIndex) l.quizCorrectAnswer,
                if (answered && i == answer && i != q.correctIndex)
                  l.quizYourAnswer,
              ].join('. '),
              child: ExcludeSemantics(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(q.options[i].text),
                            style: text.bodyLarge,
                          ),
                        ),
                        if (answered && i == q.correctIndex)
                          Icon(Icons.check_circle_rounded, color: p.brand)
                        else if (answered && i == answer)
                          Icon(Icons.cancel_rounded, color: p.amber),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (answered) ...[
          LgNotice(
            [
              if (answer != q.correctIndex)
                '${context.tr(q.options[answer].text)}: '
                    '${context.tr(q.options[answer].explanation)}',
              '${context.tr(q.options[q.correctIndex].text)}: '
                  '${context.tr(q.options[q.correctIndex].explanation)}',
            ].join('\n\n'),
            title: answer == q.correctIndex ? l.quizCorrect : l.quizIncorrect,
            kind: answer == q.correctIndex
                ? NoticeKind.info
                : NoticeKind.warning,
          ),
          const SizedBox(height: 8),
          LgButton(
            label: session.isLast ? l.quizFinish : l.quizNext,
            onPressed: () {
              session.next();
              onChanged();
            },
          ),
        ],
      ],
    );
  }
}
