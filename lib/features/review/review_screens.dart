import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/shell.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import '../content/ui/analyte_screen.dart' show SourceTile;
import '../content/ui/content_widgets.dart';
import '../support/support_screens.dart' show backendErrorText;

/// Tekshiruv bo'limi faqat server tekshiruvchi (yoki admin hisobi) deb
/// tasdiqlagan foydalanuvchiga ochiladi. Ilovadagi rol (masalan, “Ustoz”)
/// hech narsa bermaydi; qaror yozishni server yana tekshiradi.
class ReviewerGate extends StatefulWidget {
  const ReviewerGate({super.key, required this.builder});

  final Widget Function(BuildContext context, AccessInfo access) builder;

  @override
  State<ReviewerGate> createState() => _ReviewerGateState();
}

class _ReviewerGateState extends State<ReviewerGate> {
  @override
  void initState() {
    super.initState();
    // Vakolat o'zgargan bo'lishi mumkin — ochilganda serverdan yangilanadi.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.services.refreshAccess(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    if (!services.backend.isConfigured) {
      return LgStateView(
        kind: StateKind.unavailable,
        title: l.supportUnavailableTitle,
        message: l.supportUnavailableBody,
      );
    }
    return ListenableBuilder(
      listenable: Listenable.merge([services.auth, services.access]),
      builder: (context, _) {
        if (!services.auth.hasAccount) {
          return LgStateView(
            kind: StateKind.empty,
            title: l.rvSignInTitle,
            message: l.rvGateBody,
            actionLabel: l.profileSignIn,
            onAction: () => context.push('/profile/auth'),
          );
        }
        final a = services.access.access;
        if (!a.reviewer && !a.adminAccount) {
          return LgStateView(
            kind: StateKind.unavailable,
            title: l.rvGateTitle,
            message: l.rvGateBody,
          );
        }
        return widget.builder(context, a);
      },
    );
  }
}

String decisionLabel(ReviewDecision d, AppLocalizations l) => switch (d) {
  ReviewDecision.approve => l.rvDecisionApprove,
  ReviewDecision.changes => l.rvDecisionChanges,
};

enum _Tab { cards, questions, discrepancies }

/// Tekshiruv navbati: tekshirilmagan kartalar va savollar, manbalar orasidagi
/// farqlar. Har element yonida — sizning qaroringiz va jami qarorlar.
class ReviewQueueScreen extends StatefulWidget {
  const ReviewQueueScreen({super.key});

  @override
  State<ReviewQueueScreen> createState() => _ReviewQueueScreenState();
}

class _ReviewQueueScreenState extends State<ReviewQueueScreen> {
  _Tab _tab = _Tab.cards;
  List<ContentReview>? _reviews;
  Object? _error;

  Future<void> _load() async {
    try {
      final r = await context.services.backend.contentReviews();
      if (mounted) setState(() => _reviews = r);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.libReview,
      children: [
        ReviewerGate(
          builder: (context, access) => _Loader(
            onLoad: _load,
            child: ContentGate(
              builder: (context, pack) => _body(context, pack, access),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, ContentPack pack, AccessInfo access) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final uid = context.services.backend.userId;
    final reviews = _reviews ?? const <ContentReview>[];
    final cards = [
      for (final a in pack.analytes)
        if (!a.isReviewerApproved) a,
    ];
    final questions = [
      for (final q in pack.quiz)
        if (q.isDraft) q,
    ];
    final open = pack.openDiscrepancies;

    String status(String kind, String id) {
      final mine = reviews
          .where(
            (r) => r.itemKind == kind && r.itemId == id && r.reviewerId == uid,
          )
          .firstOrNull;
      final n = reviews
          .where((r) => r.itemKind == kind && r.itemId == id)
          .length;
      return [
        if (mine != null)
          l.rvMine(decisionLabel(mine.decision, l))
        else
          l.rvNotSeen,
        l.rvCount(n),
      ].join(' · ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!access.reviewer)
          LgNotice(l.rvAdminReadOnly, kind: NoticeKind.info),
        if (_error != null)
          LgNotice(backendErrorText(_error!, l), kind: NoticeKind.error),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (t, label, n) in [
              (_Tab.cards, l.rvTabCards, cards.length),
              (_Tab.questions, l.rvTabQuestions, questions.length),
              (_Tab.discrepancies, l.rvTabDiscrepancies, open.length),
            ])
              LgChoiceChip(
                label: '$label · $n',
                selected: _tab == t,
                onTap: () => setState(() => _tab = t),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_reviews == null && _error == null)
          const LgStateView(kind: StateKind.loading, title: '')
        else
          switch (_tab) {
            _Tab.cards when cards.isEmpty => LgStateView(
              kind: StateKind.success,
              title: l.rvAllDone,
            ),
            _Tab.cards => Column(
              children: [
                for (final (i, a) in cards.indexed)
                  LgRow(
                    title: a.names.of(lang),
                    subtitle: status('analyte', a.id),
                    icon: Icons.biotech_outlined,
                    divider: i < cards.length - 1,
                    onTap: () async {
                      await context.push('/library/review/analyte/${a.id}');
                      await _load();
                    },
                  ),
              ],
            ),
            _Tab.questions when questions.isEmpty => LgStateView(
              kind: StateKind.success,
              title: l.rvAllDone,
            ),
            _Tab.questions => Column(
              children: [
                for (final (i, q) in questions.indexed)
                  LgRow(
                    title: q.prompt.of(lang),
                    subtitle: status('quiz', q.id),
                    icon: Icons.quiz_outlined,
                    divider: i < questions.length - 1,
                    onTap: () async {
                      await context.push('/library/review/quiz/${q.id}');
                      await _load();
                    },
                  ),
              ],
            ),
            _Tab.discrepancies => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.reviewDiscrepanciesBody, style: text.bodyMedium),
                const SizedBox(height: 8),
                if (open.isEmpty)
                  LgStateView(
                    kind: StateKind.empty,
                    title: l.reviewNoDiscrepancies,
                  )
                else
                  for (final d in open) _DiscrepancyCard(pack: pack, d: d),
              ],
            ),
          },
      ],
    );
  }
}

/// Bola birinchi chizilganda bir marta yuklaydi.
class _Loader extends StatefulWidget {
  const _Loader({required this.onLoad, required this.child});

  final Future<void> Function() onLoad;
  final Widget child;

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onLoad());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Bitta karta yoki savolni ko'rib chiqish va qaror yozish.
class ReviewItemScreen extends StatefulWidget {
  const ReviewItemScreen({super.key, required this.kind, required this.itemId});

  /// `analyte` yoki `quiz`.
  final String kind;
  final String itemId;

  @override
  State<ReviewItemScreen> createState() => _ReviewItemScreenState();
}

class _ReviewItemScreenState extends State<ReviewItemScreen> {
  List<ContentReview>? _reviews;
  Object? _error;
  ReviewDecision? _decision;
  final _comment = TextEditingController();
  String? _formError;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final all = await context.services.backend.contentReviews();
      if (!mounted) return;
      setState(
        () => _reviews = [
          for (final r in all)
            if (r.itemKind == widget.kind && r.itemId == widget.itemId) r,
        ],
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _submit(ContentPack pack) async {
    final l = AppLocalizations.of(context);
    final d = _decision;
    if (d == null) return;
    if (d == ReviewDecision.changes && _comment.text.trim().isEmpty) {
      setState(() => _formError = l.rvCommentRequired);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _formError = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.services.backend.submitReview(
        kind: widget.kind,
        itemId: widget.itemId,
        contentVersion: pack.contentVersion,
        decision: d,
        comment: _comment.text,
      );
      _comment.clear();
      setState(() => _decision = null);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.rvSubmitted)));
      await _load();
    } on Object catch (e) {
      if (mounted) setState(() => _formError = backendErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final pack = context.services.content.pack;
    final title = switch (widget.kind) {
      'analyte' => pack?.analyte(widget.itemId)?.names.of(lang),
      _ => l.rvTabQuestions,
    };
    return LgPage(
      title: title ?? l.libReview,
      children: [
        ReviewerGate(
          builder: (context, access) => _Loader(
            onLoad: _load,
            child: ContentGate(
              builder: (context, pack) => _body(context, pack, access),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, ContentPack pack, AccessInfo access) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final analyte = widget.kind == 'analyte'
        ? pack.analyte(widget.itemId)
        : null;
    final question = widget.kind == 'quiz'
        ? pack.quiz.where((q) => q.id == widget.itemId).firstOrNull
        : null;
    if (analyte == null && question == null) {
      return LgStateView(kind: StateKind.empty, title: l.rvNoHistory);
    }
    final sourceIds = analyte?.sourceIds ?? question!.sourceIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: LgTag(l.analyteReviewPending, tone: LgTone.warning),
        ),
        const SizedBox(height: 10),
        if (analyte != null) ...[
          if (pack.group(analyte.group) case final g?)
            Text(g.names.of(lang), style: text.bodyMedium),
          const SizedBox(height: 8),
          LgButton.secondary(
            label: l.rvOpenCard,
            icon: Icons.open_in_new_rounded,
            onPressed: () => openInTab(context, '/tests/analyte/${analyte.id}'),
          ),
        ],
        if (question != null)
          LgPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question.prompt.of(lang), style: text.titleMedium),
                const SizedBox(height: 8),
                for (final (i, o) in question.options.indexed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          i == question.correctIndex
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20,
                          semanticLabel: i == question.correctIndex
                              ? l.rvCorrect
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(o.text.of(lang), style: text.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(l.rvBasis, style: text.titleSmall),
                Text(question.basis.of(lang), style: text.bodyMedium),
              ],
            ),
          ),
        if (sourceIds.isNotEmpty) ...[
          LgSectionTitle(l.analyteSources),
          for (final (i, id) in sourceIds.indexed)
            if (pack.source(id) case final s?)
              SourceTile(index: i + 1, source: s),
        ],
        LgSectionTitle(l.rvHistory),
        if (_error != null)
          LgNotice(backendErrorText(_error!, l), kind: NoticeKind.error)
        else if (_reviews == null)
          const LgStateView(kind: StateKind.loading, title: '')
        else if (_reviews!.isEmpty)
          Text(l.rvNoHistory, style: text.bodyMedium)
        else
          for (final r in _reviews!) _ReviewTile(review: r),
        if (access.reviewer) ...[
          LgSectionTitle(l.rvYourDecision),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              LgChoiceChip(
                label: l.rvApprove,
                selected: _decision == ReviewDecision.approve,
                onTap: () => setState(() => _decision = ReviewDecision.approve),
              ),
              LgChoiceChip(
                label: l.rvChanges,
                selected: _decision == ReviewDecision.changes,
                onTap: () => setState(() => _decision = ReviewDecision.changes),
              ),
            ],
          ),
          LgField(
            label: l.rvComment,
            hint: l.rvCommentHint,
            controller: _comment,
            maxLines: 4,
            maxLength: 2000,
            keyboardType: TextInputType.multiline,
          ),
          if (_formError != null) LgNotice(_formError!, kind: NoticeKind.error),
          const SizedBox(height: 12),
          LgButton(
            label: l.rvSubmit,
            icon: Icons.send_rounded,
            busy: _busy,
            onPressed: _decision == null ? null : () => _submit(pack),
          ),
        ] else
          LgNotice(l.rvAdminReadOnly, kind: NoticeKind.info),
        LgNotice(l.rvNotAuto, kind: NoticeKind.info),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ContentReview review;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final mine = review.reviewerId == context.services.backend.userId;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${mine ? l.rvYou : l.rvReviewer} · '
            '${decisionLabel(review.decision, l)} · '
            '${DateFormat.yMd(locale).format(review.createdAt.toLocal())}',
            style: text.titleSmall,
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 4),
            Text(review.comment!, style: text.bodyMedium),
          ],
          Text(
            l.analyteContentVersion(review.contentVersion),
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DiscrepancyCard extends StatelessWidget {
  const _DiscrepancyCard({required this.pack, required this.d});

  final ContentPack pack;
  final Discrepancy d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final subject =
        pack.analyte(d.subjectId)?.names.of(lang) ??
        pack.lessons
            .where((x) => x.id == d.subjectId)
            .firstOrNull
            ?.title
            .of(lang) ??
        d.subjectId;
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject, style: text.titleMedium),
          Text(l.reviewField(d.field), style: text.bodySmall),
          for (final pos in d.positions) ...[
            const SizedBox(height: 10),
            Text(
              [
                pack.source(pos.ref.sourceId)?.title ?? pos.ref.sourceId,
                if (pos.ref.pages != null) l.citePage(pos.ref.pages!),
              ].join(' · '),
              style: text.titleSmall,
            ),
            Text(pos.statement, style: text.bodyMedium),
          ],
        ],
      ),
    );
  }
}
