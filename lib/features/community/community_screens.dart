import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../core/backend/community_backend.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../admin/admin_screens.dart' show AdminGate;
import '../learn/exam_widgets.dart' show confirmDialog;
import 'community_rules.dart';
import '../support/support_screens.dart'
    show SignedInGate, backendErrorText, formatWhen;

// ---------------------------------------------------------------- helpers

/// Hamjamiyat yo'llari (Profil steki ichida — orqaga kelgan joyga qaytadi).
abstract final class CommunityRoutes {
  static const base = '/profile/community';
  static String list({String? topic}) =>
      topic == null ? base : '$base?topic=${Uri.encodeComponent(topic)}';
  static const mine = '$base?mine=1';
  static String ask({String? topic}) => topic == null
      ? '$base/ask'
      : '$base/ask?topic=${Uri.encodeComponent(topic)}';
  static String question(String id) => '$base/q/${Uri.encodeComponent(id)}';
  static const verify = '$base/verify';
  static const admin = '/profile/admin/community';
}

String communityErrorText(Object e, AppLocalizations l) {
  if (e is CommunityException) {
    switch (e.code) {
      case 'not_verified':
        return l.cmErrNotVerified;
      case 'suspended':
        return l.cmStatusSuspended;
      case 'contact_data':
        return l.cmErrContact;
      case 'too_large':
        return l.cmErrTooLarge;
      case 'pdf_not_supported' || 'unsupported_media_type':
        return l.cmErrType;
      case 'ai_unavailable':
        return l.cmErrAi;
      case 'already_verified':
        return l.cmErrAlreadyVerified;
      case 'revoked':
        return l.cmErrRevoked;
      case 'invalid_title' || 'invalid_body':
        return l.cmErrLength;
    }
  }
  return backendErrorText(e, l);
}

String specialistRoleLabel(SpecialistRole r, AppLocalizations l) => switch (r) {
  SpecialistRole.laborant => l.cmRoleLaborant,
  SpecialistRole.biochemist => l.cmRoleBiochemist,
  SpecialistRole.kdlDoctor => l.cmRoleKdlDoctor,
  SpecialistRole.teacher => l.cmRoleTeacher,
  SpecialistRole.other => l.cmRoleOther,
  SpecialistRole.clinicalLabDiagnostics => l.cmRoleClinicalLab,
};

String reportReasonLabel(ReportReason r, AppLocalizations l) => switch (r) {
  ReportReason.spam => l.cmReasonSpam,
  ReportReason.wrong => l.cmReasonWrong,
  ReportReason.abuse => l.cmReasonAbuse,
  ReportReason.fakeSpecialist => l.cmReasonFake,
  ReportReason.patientData => l.cmReasonPatient,
  ReportReason.other => l.cmReasonOther,
};

/// Halol belgi: AI tekshirgan — “hujjat avtomatik tekshirilgan”; qo'lda
/// tekshirilgan — “Tasdiqlangan mutaxassis”.
String specialistBadge(VerifyMethod? m, AppLocalizations l) =>
    m == VerifyMethod.manual ? l.cmBadgeManual : l.cmBadgeAi;

/// `analyte:<id>` / `condition:<id>` → kontentdagi nom (bo'lmasa — id).
String topicName(BuildContext context, String topic) {
  final lang = Localizations.localeOf(context).languageCode;
  final pack = context.services.content.pack;
  final i = topic.indexOf(':');
  final kind = topic.substring(0, i);
  final id = topic.substring(i + 1);
  if (kind == 'analyte') return pack?.analyte(id)?.names.of(lang) ?? id;
  return pack?.condition(id)?.names.of(lang) ?? id;
}

String _uiLang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

void _snack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Server ulanmagan buildda hamjamiyat yo'q (yo'lni bilish ham ochmaydi).
class _CommunityAvailable extends StatelessWidget {
  const _CommunityAvailable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!context.services.community.available) {
      return LgStateView(
        kind: StateKind.unavailable,
        title: l.supportUnavailableTitle,
        message: l.supportUnavailableBody,
      );
    }
    return child;
  }
}

// ---------------------------------------------------------- author line

class CommunityAuthorLine extends StatelessWidget {
  const CommunityAuthorLine({
    super.key,
    required this.author,
    required this.createdAt,
  });

  final CommunityAuthor author;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final parts = <String>[
      if (author.kind == AuthorKind.specialist && author.role != null)
        specialistRoleLabel(author.role!, l),
      if (author.kind == AuthorKind.specialist && author.country != null)
        author.country!,
      if (author.kind == AuthorKind.member) l.cmMember,
      if (author.isMe) l.cmYou,
      formatWhen(createdAt, context),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (author.kind == AuthorKind.owner)
          LgTag(author.name ?? 'LabGuide', tone: LgTone.neutral),
        if (author.verified)
          LgTag(
            specialistBadge(author.method, l),
            icon: Icons.verified_outlined,
          ),
        Text(parts.join(' · '), style: text.bodySmall),
      ],
    );
  }
}

// ------------------------------------------------------- translatable post

/// Post matni + “Tarjima qilish” (post tili ≠ interfeys tili). Tarjimadan
/// keyin “Mashina tarjimasi” belgisi va “Asl matn” almashtirgichi (toifa
/// savollaridagi kabi).
class TranslatablePost extends StatefulWidget {
  const TranslatablePost({
    super.key,
    required this.kind,
    required this.id,
    required this.lang,
    required this.body,
    this.title,
  });

  final PostKind kind;
  final String id;
  final String lang;
  final String? title;
  final String body;

  @override
  State<TranslatablePost> createState() => _TranslatablePostState();
}

class _TranslatablePostState extends State<TranslatablePost> {
  PostTranslation? _tr;
  bool _showOriginal = false;
  bool _busy = false;
  String? _error;

  Future<void> _translate() async {
    final l = AppLocalizations.of(context);
    final api = context.services.community.api;
    if (api == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final t = await api.translate(
        kind: widget.kind,
        id: widget.id,
        lang: _uiLang(context),
      );
      if (mounted) setState(() => _tr = t);
    } on Object catch (e) {
      if (mounted) setState(() => _error = communityErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final ui = _uiLang(context);
    final tr = _tr?.lang == ui ? _tr : null;
    final showTr = tr != null && !_showOriginal;
    final title = showTr ? tr.title ?? widget.title : widget.title;
    final body = showTr ? tr.body : widget.body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title, style: text.titleMedium),
          const SizedBox(height: 6),
        ],
        Text(
          body,
          style: text.bodyMedium!.copyWith(color: p.ink, height: 1.45),
        ),
        if (widget.lang != ui)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (tr == null)
                  LgButton.link(
                    key: ValueKey('cm-translate-${widget.id}'),
                    label: _busy ? '…' : l.cmTranslate,
                    icon: Icons.translate_rounded,
                    expand: false,
                    onPressed: _busy ? null : _translate,
                  )
                else ...[
                  if (showTr)
                    LgTag(
                      l.cmMachineTranslation,
                      tone: LgTone.neutral,
                      icon: Icons.translate_rounded,
                    ),
                  LgButton.link(
                    key: ValueKey('cm-original-${widget.id}'),
                    label: showTr ? l.cmShowOriginal : l.cmShowTranslation,
                    icon: showTr
                        ? Icons.visibility_outlined
                        : Icons.translate_rounded,
                    expand: false,
                    onPressed: () =>
                        setState(() => _showOriginal = !_showOriginal),
                  ),
                ],
              ],
            ),
          ),
        if (_error != null) LgNotice(_error!, kind: NoticeKind.error),
      ],
    );
  }
}

// ----------------------------------------------------------- home + links

/// Bosh sahifa: oxirgi 3 savol va “Savol berish”. Server ulanmagan
/// buildda umuman chiqmaydi.
class CommunityHomeCard extends StatefulWidget {
  const CommunityHomeCard({super.key});

  @override
  State<CommunityHomeCard> createState() => _CommunityHomeCardState();
}

class _CommunityHomeCardState extends State<CommunityHomeCard> {
  Future<QuestionPage>? _future;

  void _load() {
    final api = context.services.community.api;
    if (api != null) _future = api.questions(limit: 3);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_future == null) _load();
  }

  @override
  Widget build(BuildContext context) {
    final community = context.services.community;
    if (!community.available) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: community,
      builder: (context, _) => Column(
        key: const ValueKey('community-home-card'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgSectionTitle(
            l.cmTitle,
            trailing: LgButton.link(
              label: l.cmAllQuestions,
              expand: false,
              onPressed: () => context.push(CommunityRoutes.list()),
            ),
          ),
          Text(l.cmHomeSub, style: text.bodySmall),
          const SizedBox(height: 4),
          FutureBuilder<QuestionPage>(
            future: _future,
            builder: (context, snap) {
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: LgButton.link(
                    label:
                        '${communityErrorText(snap.error!, l)} · ${l.actionRetry}',
                    onPressed: () => setState(_load),
                  ),
                );
              }
              final page = snap.data;
              if (page == null) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: [
                  for (final (i, q) in page.items.indexed)
                    _QuestionRow(
                      q: q,
                      divider: i < page.items.length - 1,
                      onReturn: () => setState(_load),
                    ),
                  if (page.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(l.cmEmptyBody, style: text.bodyMedium),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          LgButton.secondary(
            label: l.cmAsk,
            icon: Icons.edit_outlined,
            onPressed: () async {
              await context.push(CommunityRoutes.ask());
              if (mounted) setState(_load);
            },
          ),
        ],
      ),
    );
  }
}

/// Analit / holat kartasi oxirida: “Bu tahlil bo‘yicha savollar (N)”.
class CommunityTopicLink extends StatefulWidget {
  const CommunityTopicLink({super.key, required this.topic});

  /// `analyte:<id>` yoki `condition:<id>`.
  final String topic;

  @override
  State<CommunityTopicLink> createState() => _CommunityTopicLinkState();
}

class _CommunityTopicLinkState extends State<CommunityTopicLink> {
  int? _count;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    // Kadr oxirigacha ro'yxat elementni tashlab yuborgan bo'lishi mumkin.
    if (!mounted) return;
    final c = context.services.community;
    if (!c.available) return;
    try {
      final n = await c.count(widget.topic);
      if (mounted) setState(() => _count = n);
    } on Object catch (e) {
      // Son ko'rinmaydi, havola baribir ochiladi (u yerda xato holati bor).
      debugPrint('community count: ${e.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.services.community;
    if (!c.available) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final n = _count ?? c.cachedCount(widget.topic);
    final label = widget.topic.startsWith('condition:')
        ? l.cmTopicLinkCondition(n ?? 0)
        : l.cmTopicLinkAnalyte(n ?? 0);
    return LgRow(
      key: ValueKey('community-topic-${widget.topic}'),
      // Son hali kelmagan bo'lsa — “(0)” deb yolg'on ko'rsatilmaydi.
      title: n == null ? label.replaceAll(RegExp(r'\s*\(\d+\)'), '') : label,
      subtitle: l.cmTopicLinkSub,
      icon: Icons.forum_outlined,
      divider: false,
      onTap: () async {
        await context.push(CommunityRoutes.list(topic: widget.topic));
        if (mounted) unawaited(_load());
      },
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.q, this.divider = true, this.onReturn});

  final QuestionSummary q;
  final bool divider;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final who = switch (q.author.kind) {
      AuthorKind.owner => q.author.name ?? 'LabGuide',
      AuthorKind.specialist => specialistBadge(q.author.method, l),
      AuthorKind.member => l.cmMember,
    };
    return LgRow(
      title: q.title,
      subtitle: [
        if (q.pinned) l.cmPinned,
        l.cmAnswers(q.answerCount),
        if (q.bestAnswerId != null) '✓ ${l.cmBest}',
        who,
      ].join(' · '),
      icon: q.pinned ? Icons.push_pin_outlined : Icons.forum_outlined,
      divider: divider,
      onTap: () async {
        await context.push(CommunityRoutes.question(q.id));
        onReturn?.call();
      },
    );
  }
}

// ------------------------------------------------------------- list screen

class CommunityListScreen extends StatefulWidget {
  const CommunityListScreen({super.key, this.topic, this.mine = false});

  final String? topic;
  final bool mine;

  @override
  State<CommunityListScreen> createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends State<CommunityListScreen> {
  final List<QuestionSummary> _items = [];
  int? _next = 0;
  int _total = 0;
  bool _loading = false;
  bool _loaded = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload();
    });
  }

  Future<void> _reload() async {
    _items.clear();
    _next = 0;
    _loaded = false;
    await _more();
  }

  Future<void> _more() async {
    final services = context.services;
    final api = services.community.api;
    final offset = _next;
    if (api == null || offset == null || _loading) return;
    if (widget.mine && !api.hasSession) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await api.questions(
        topic: widget.topic,
        mine: widget.mine,
        offset: offset,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _next = page.nextOffset;
        _total = page.total;
        _loaded = true;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ask() async {
    final created = await context.push<String>(
      CommunityRoutes.ask(topic: widget.topic),
    );
    if (!mounted || created == null) return;
    context.services.community.invalidate();
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final topic = widget.topic;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topic != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: LgTag(
                l.cmTopicLabel(topicName(context, topic)),
                tone: LgTone.neutral,
                icon: Icons.biotech_outlined,
              ),
            ),
          ),
        if (!widget.mine) const CommunityRulesCard(),
        Text(l.cmNotAdvice, style: text.bodySmall),
        const SizedBox(height: 10),
        if (!widget.mine)
          LgButton(label: l.cmAsk, icon: Icons.edit_outlined, onPressed: _ask),
        const SizedBox(height: 6),
        if (_error != null && _items.isEmpty)
          LgStateView(
            kind: StateKind.error,
            title: communityErrorText(_error!, l),
            actionLabel: l.actionRetry,
            onAction: _reload,
          )
        else if (!_loaded)
          const LgStateView(kind: StateKind.loading, title: '')
        else if (_items.isEmpty)
          LgStateView(
            kind: StateKind.empty,
            title: l.cmEmptyTitle,
            message: widget.mine ? null : l.cmEmptyBody,
          )
        else ...[
          for (final (i, q) in _items.indexed)
            _QuestionRow(
              q: q,
              divider: i < _items.length - 1,
              onReturn: _reload,
            ),
          if (_next != null && _items.length < _total)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LgButton.secondary(
                label: l.cmLoadMore,
                busy: _loading,
                onPressed: _more,
              ),
            ),
          if (_error != null) LgNotice(communityErrorText(_error!, l)),
        ],
      ],
    );
    return LgPage(
      title: widget.mine ? l.cmMyQuestions : l.cmTitle,
      showProfile: false,
      children: [
        _CommunityAvailable(
          child: widget.mine ? SignedInGate(child: body) : body,
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- ask screen

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key, this.topic});

  final String? topic;

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final api = context.services.community.api;
    if (api == null) return;
    final t = _title.text.trim();
    final b = _body.text.trim();
    if (t.length < 10 || t.length > 200 || b.length < 10 || b.length > 4000) {
      setState(() => _error = l.cmErrLength);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await api.askQuestion(
        title: t,
        body: b,
        topic: widget.topic,
        lang: _uiLang(context),
      );
      if (!mounted) return;
      context.services.community.invalidate();
      _snack(context, l.cmAskSent);
      context.pop(id);
    } on Object catch (e) {
      if (mounted) setState(() => _error = communityErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final topic = widget.topic;
    return LgPage(
      title: l.cmAsk,
      showProfile: false,
      children: [
        _CommunityAvailable(
          child: SignedInGate(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (topic != null)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: LgTag(
                      l.cmTopicLabel(topicName(context, topic)),
                      tone: LgTone.neutral,
                      icon: Icons.biotech_outlined,
                    ),
                  ),
                LgNotice(l.cmAskNoPatient),
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: CommunityRulesLink(),
                ),
                LgField(
                  key: const ValueKey('cm-ask-title'),
                  label: l.cmAskTitleField,
                  controller: _title,
                  maxLength: 200,
                  textInputAction: TextInputAction.next,
                ),
                LgField(
                  key: const ValueKey('cm-ask-body'),
                  label: l.cmAskBodyField,
                  controller: _body,
                  maxLines: 6,
                  maxLength: 4000,
                ),
                if (_error != null) LgNotice(_error!, kind: NoticeKind.error),
                const SizedBox(height: 12),
                LgButton(
                  key: const ValueKey('cm-ask-send'),
                  label: l.cmAskSend,
                  busy: _busy,
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------- question screen

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key, required this.questionId});

  final String questionId;

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  QuestionThread? _thread;
  Object? _error;
  final _answer = TextEditingController();
  bool _sending = false;
  String? _answerError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  CommunityBackend? get _api => context.services.community.api;

  Future<void> _load() async {
    final api = _api;
    if (api == null) return;
    try {
      final t = await api.question(widget.questionId);
      if (mounted) {
        setState(() {
          _thread = t;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _act(
    Future<void> Function(CommunityBackend api) f, {
    String? done,
  }) async {
    final l = AppLocalizations.of(context);
    final api = _api;
    if (api == null) return;
    try {
      await f(api);
      if (!mounted) return;
      if (done != null) _snack(context, done);
      await _load();
    } on Object catch (e) {
      if (mounted) _snack(context, communityErrorText(e, l));
    }
  }

  Future<void> _sendAnswer() async {
    final l = AppLocalizations.of(context);
    final api = _api;
    final b = _answer.text.trim();
    if (api == null) return;
    if (b.length < 10 || b.length > 4000) {
      setState(() => _answerError = l.cmErrLength);
      return;
    }
    setState(() {
      _sending = true;
      _answerError = null;
    });
    try {
      await api.answer(widget.questionId, b, lang: _uiLang(context));
      _answer.clear();
      await _load();
    } on Object catch (e) {
      if (mounted) setState(() => _answerError = communityErrorText(e, l));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _report(PostKind kind, String id) async {
    final l = AppLocalizations.of(context);
    final reason = await showDialog<ReportReason>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.cmReportTitle),
        children: [
          for (final r in ReportReason.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(r),
              child: Text(reportReasonLabel(r, l)),
            ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    await _act(
      (api) => api.report(kind: kind, id: id, reason: reason),
      done: l.cmReportSent,
    );
  }

  Future<bool> _confirmDelete() async {
    final l = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l.cmDeleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l.actionCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l.cmDelete),
              ),
            ],
          ),
        ) ==
        true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final t = _thread;
    final signedIn = _api?.hasSession ?? false;
    Widget content;
    if (_error != null) {
      content = LgStateView(
        kind:
            _error is BackendException &&
                (_error! as BackendException).failure == BackendFailure.notFound
            ? StateKind.empty
            : StateKind.error,
        title: communityErrorText(_error!, l),
        actionLabel: l.actionRetry,
        onAction: _load,
      );
    } else if (t == null) {
      content = const LgStateView(kind: StateKind.loading, title: '');
    } else {
      final q = t.question;
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (q.pinned) LgTag(l.cmPinned, icon: Icons.push_pin_outlined),
              if (q.topic case final topic?)
                LgTag(
                  l.cmTopicLabel(topicName(context, topic)),
                  tone: LgTone.neutral,
                  icon: Icons.biotech_outlined,
                ),
            ],
          ),
          LgPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatablePost(
                  key: ValueKey('cm-q-${q.id}'),
                  kind: PostKind.question,
                  id: q.id,
                  lang: q.lang,
                  title: q.title,
                  body: q.text,
                ),
                const SizedBox(height: 10),
                CommunityAuthorLine(author: q.author, createdAt: q.createdAt),
                Wrap(
                  spacing: 4,
                  children: [
                    if (signedIn && !q.author.isMe)
                      LgButton.link(
                        label: l.cmReport,
                        icon: Icons.flag_outlined,
                        expand: false,
                        onPressed: () => _report(PostKind.question, q.id),
                      ),
                    if (t.admin) ...[
                      LgButton.link(
                        label: q.pinned ? l.cmUnpin : l.cmPin,
                        icon: Icons.push_pin_outlined,
                        expand: false,
                        onPressed: () => _act(
                          (api) => api.pinQuestion(q.id, pinned: !q.pinned),
                        ),
                      ),
                      LgButton.link(
                        label: l.cmDelete,
                        icon: Icons.delete_outline_rounded,
                        expand: false,
                        onPressed: () async {
                          if (!await _confirmDelete() || !context.mounted) {
                            return;
                          }
                          try {
                            await _api!.deleteQuestion(q.id);
                            if (!context.mounted) return;
                            context.services.community.invalidate();
                            _snack(context, l.cmDeleted);
                            context.pop();
                          } on Object catch (e) {
                            if (context.mounted) {
                              _snack(context, communityErrorText(e, l));
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          LgSectionTitle(l.cmAnswers(t.answers.length)),
          for (final a in t.answers) _answerCard(context, t, a),
          const SizedBox(height: 8),
          if (t.canAnswer) ...[
            LgField(
              key: const ValueKey('cm-answer-field'),
              label: l.cmAnswerField,
              controller: _answer,
              maxLines: 5,
              maxLength: 4000,
            ),
            if (_answerError != null)
              LgNotice(_answerError!, kind: NoticeKind.error),
            const SizedBox(height: 8),
            LgButton(
              key: const ValueKey('cm-answer-send'),
              label: l.cmAnswerSend,
              busy: _sending,
              onPressed: _sendAnswer,
            ),
          ] else
            LgPanel(
              soft: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.cmAnswerOnlySpecialists, style: text.bodyMedium),
                  const SizedBox(height: 8),
                  if (signedIn)
                    LgButton.secondary(
                      label: l.cmVerifyTitle,
                      icon: Icons.verified_outlined,
                      onPressed: () async {
                        await context.push(CommunityRoutes.verify);
                        await _load();
                      },
                    )
                  else
                    LgButton.secondary(
                      label: l.profileSignIn,
                      icon: Icons.mail_outline_rounded,
                      onPressed: () => context.push('/profile/auth'),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Text(l.cmNotAdvice, style: text.bodySmall),
          // Izoh faqat AI belgisi ko'ringanda (qo'lda tekshirilgan — boshqa).
          if ([
            q.author,
            for (final a in t.answers) a.author,
          ].any((x) => x.verified && x.method != VerifyMethod.manual)) ...[
            const SizedBox(height: 4),
            Text(l.cmBadgeInfo, style: text.bodySmall),
          ],
        ],
      );
    }
    return LgPage(
      title: l.cmTitle,
      showProfile: false,
      children: [_CommunityAvailable(child: content)],
    );
  }

  Widget _answerCard(
    BuildContext context,
    QuestionThread t,
    CommunityAnswer a,
  ) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final signedIn = _api?.hasSession ?? false;
    final canVote = t.canVote && !a.author.isMe;
    return LgPanel(
      key: ValueKey('cm-answer-${a.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (a.isBest)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LgTag(l.cmBest, icon: Icons.check_circle_outline),
            ),
          TranslatablePost(
            key: ValueKey('cm-a-${a.id}'),
            kind: PostKind.answer,
            id: a.id,
            lang: a.lang,
            body: a.body,
          ),
          const SizedBox(height: 10),
          CommunityAuthorLine(author: a.author, createdAt: a.createdAt),
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (canVote)
                LgButton.link(
                  key: ValueKey('cm-vote-${a.id}'),
                  label: l.cmUpvote(a.upvotes),
                  icon: a.voted
                      ? Icons.thumb_up_alt_rounded
                      : Icons.thumb_up_alt_outlined,
                  expand: false,
                  onPressed: () => _act((api) => api.vote(a.id, up: !a.voted)),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(l.cmUpvote(a.upvotes), style: text.bodySmall),
                ),
              if (t.isAuthor)
                LgButton.link(
                  key: ValueKey('cm-best-${a.id}'),
                  label: a.isBest ? l.cmUnmarkBest : l.cmMarkBest,
                  icon: Icons.check_circle_outline,
                  expand: false,
                  onPressed: () => _act(
                    (api) => api.setBestAnswer(
                      t.question.id,
                      a.isBest ? null : a.id,
                    ),
                  ),
                ),
              if (signedIn && !a.author.isMe)
                LgButton.link(
                  label: l.cmReport,
                  icon: Icons.flag_outlined,
                  expand: false,
                  onPressed: () => _report(PostKind.answer, a.id),
                ),
              if (t.admin)
                LgButton.link(
                  label: l.cmDelete,
                  icon: Icons.delete_outline_rounded,
                  expand: false,
                  onPressed: () async {
                    if (!await _confirmDelete()) return;
                    await _act(
                      (api) => api.deleteAnswer(a.id),
                      done: l.cmDeleted,
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- verify screen

/// Rasm tanlash (testlarda almashtiriladi — plagin yo'q).
typedef DocumentPicker = Future<(Uint8List, String)?> Function(
  ImageSource source,
);

Future<(Uint8List, String)?> _pickDocument(ImageSource source) async {
  final file = await ImagePicker().pickImage(
    source: source,
    maxWidth: 2400,
    imageQuality: 85,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  // Hujjat surati qurilmada ham qolmasin: image_picker kesh/tmp ga yozgan
  // nusxani (kamera surati yoki kichraytirilgan nusxa) darhol o'chiramiz.
  if (!kIsWeb) {
    try {
      await File(file.path).delete();
    } on Object {
      // Fayl allaqachon yo'q yoki ruxsat yo'q — bayt xotirada, davom etamiz.
    }
  }
  final lower = file.name.toLowerCase();
  final mime =
      file.mimeType ?? (lower.endsWith('.png') ? 'image/png' : 'image/jpeg');
  return (bytes, mime);
}

class VerifySpecialistScreen extends StatefulWidget {
  const VerifySpecialistScreen({super.key});

  /// Testlar uchun: plaginsiz rasm.
  @visibleForTesting
  static DocumentPicker? pickerOverride;

  static const maxBytes = 5 * 1024 * 1024;

  @override
  State<VerifySpecialistScreen> createState() => _VerifySpecialistScreenState();
}

class _VerifySpecialistScreenState extends State<VerifySpecialistScreen> {
  SpecialistRole _role = SpecialistRole.laborant;
  final _country = TextEditingController(text: 'UZ');
  (Uint8List, String)? _doc;
  bool _busy = false;
  bool _loaded = false;
  String? _error;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _country.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final c = context.services.community;
    if (!c.available || !(c.api?.hasSession ?? false)) return;
    try {
      await c.refreshMe();
      if (mounted) setState(() => _loaded = true);
    } on Object catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  Future<void> _pick(ImageSource source) async {
    final l = AppLocalizations.of(context);
    final picked =
        await (VerifySpecialistScreen.pickerOverride ?? _pickDocument)(source);
    if (picked == null || !mounted) return;
    final (bytes, mime) = picked;
    if (mime != 'image/jpeg' && mime != 'image/png') {
      setState(() => _error = l.cmErrType);
      return;
    }
    if (bytes.length > VerifySpecialistScreen.maxBytes) {
      setState(() => _error = l.cmErrTooLarge);
      return;
    }
    setState(() {
      _doc = picked;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final c = context.services.community;
    final doc = _doc;
    final country = _country.text.trim().toUpperCase();
    if (doc == null || c.api == null) return;
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
      setState(() => _error = l.cmVerifyCountryError);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final me = await c.api!.verifySpecialist(
        role: _role,
        country: country,
        bytes: doc.$1,
        mimeType: doc.$2,
      );
      c.setMe(me);
      if (mounted) setState(() => _doc = null);
    } on Object catch (e) {
      if (mounted) setState(() => _error = communityErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.services.community;
    return LgPage(
      title: l.cmVerifyTitle,
      showProfile: false,
      children: [
        _CommunityAvailable(
          child: SignedInGate(
            child: ListenableBuilder(
              listenable: c,
              builder: (context, _) {
                if (_loadError != null) {
                  return LgStateView(
                    kind: StateKind.error,
                    title: communityErrorText(_loadError!, l),
                    actionLabel: l.actionRetry,
                    onAction: () {
                      setState(() => _loadError = null);
                      _load();
                    },
                  );
                }
                final me = c.me;
                if (!_loaded || me == null) {
                  return const LgStateView(kind: StateKind.loading, title: '');
                }
                return _body(context, l, me);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, AppLocalizations l, CommunityMe me) {
    final text = Theme.of(context).textTheme;
    final status = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgPanel(
          key: const ValueKey('cm-verify-status'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (me.status == MemberStatus.verified) ...[
                LgTag(
                  specialistBadge(me.method, l),
                  icon: Icons.verified_outlined,
                ),
                const SizedBox(height: 10),
                if (me.role != null)
                  Text(
                    [specialistRoleLabel(me.role!, l), ?me.country].join(' · '),
                    style: text.titleSmall,
                  ),
                for (final line in [
                  ?me.institution,
                  ?me.specialtyCode,
                  if (me.credential != null)
                    [
                      me.credential!,
                      if (me.year != null) '${me.year}',
                    ].join(' · '),
                ])
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(line, style: text.bodyMedium),
                  ),
                const SizedBox(height: 6),
                Text(
                  me.method == VerifyMethod.manual
                      ? l.cmMethodManual
                      : l.cmMethodAi,
                  style: text.bodySmall,
                ),
                if (me.verifiedAt != null)
                  Text(
                    l.cmVerifiedAt(formatWhen(me.verifiedAt!, context)),
                    style: text.bodySmall,
                  ),
              ] else
                Text(switch (me.status) {
                  MemberStatus.rejected => l.cmStatusRejected,
                  MemberStatus.suspended => l.cmStatusSuspended,
                  _ => l.cmStatusNone,
                }, style: text.bodyMedium),
            ],
          ),
        ),
      ],
    );
    if (me.status == MemberStatus.verified ||
        me.status == MemberStatus.suspended) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          status,
          const SizedBox(height: 8),
          Text(l.cmBadgeInfo, style: text.bodySmall),
        ],
      );
    }
    final doc = _doc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        status,
        LgNotice(
          l.cmVerifyInfo,
          title: l.cmVerifyInfoTitle,
          kind: NoticeKind.info,
        ),
        LgSectionTitle(l.cmVerifyRole),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final r in SpecialistRole.selectable)
              LgChoiceChip(
                label: specialistRoleLabel(r, l),
                selected: _role == r,
                onTap: () => setState(() => _role = r),
              ),
          ],
        ),
        LgField(
          key: const ValueKey('cm-verify-country'),
          label: l.cmVerifyCountry,
          controller: _country,
          maxLength: 2,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
          ],
        ),
        const SizedBox(height: 6),
        Text(l.cmVerifyDocHint, style: text.bodySmall),
        const SizedBox(height: 10),
        if (doc == null) ...[
          LgButton.secondary(
            key: const ValueKey('cm-verify-camera'),
            label: l.cmVerifyCamera,
            icon: Icons.photo_camera_outlined,
            onPressed: () => _pick(ImageSource.camera),
          ),
          const SizedBox(height: 8),
          LgButton.secondary(
            key: const ValueKey('cm-verify-gallery'),
            label: l.cmVerifyGallery,
            icon: Icons.image_outlined,
            onPressed: () => _pick(ImageSource.gallery),
          ),
        ] else
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  doc.$1,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  semanticLabel: l.cmVerifyTitle,
                  errorBuilder: (context, error, stack) => const SizedBox(
                    width: 72,
                    height: 72,
                    child: Icon(Icons.description_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LgButton.secondary(
                  label: l.cmVerifyRemove,
                  icon: Icons.close_rounded,
                  onPressed: () => setState(() => _doc = null),
                ),
              ),
            ],
          ),
        if (_error != null) LgNotice(_error!, kind: NoticeKind.error),
        const SizedBox(height: 12),
        LgButton(
          key: const ValueKey('cm-verify-submit'),
          label: l.cmVerifySubmit,
          busy: _busy,
          onPressed: doc == null ? null : _submit,
        ),
        const SizedBox(height: 6),
        Text(l.cmVerifyAttempts, style: text.bodySmall),
      ],
    );
  }
}

// ------------------------------------------------------------ admin screen

class AdminCommunityScreen extends StatefulWidget {
  const AdminCommunityScreen({super.key});

  @override
  State<AdminCommunityScreen> createState() => _AdminCommunityScreenState();
}

class _AdminCommunityScreenState extends State<AdminCommunityScreen> {
  MemberStatus _filter = MemberStatus.suspended;
  List<CommunityMemberAdmin>? _items;
  Object? _error;

  Future<void> _load() async {
    final api = context.services.community.api;
    if (api == null) return;
    try {
      final items = await api.adminMembers(status: _filter);
      if (mounted) {
        setState(() {
          _items = items;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _act(
    Future<void> Function() f, {
    required String confirmTitle,
    required String confirmBody,
    required String action,
  }) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: confirmTitle,
      body: confirmBody,
      action: action,
    );
    if (!ok || !mounted) return;
    try {
      await f();
      if (!mounted) return;
      _snack(context, l.cmAdminDone);
      await _load();
    } on Object catch (e) {
      if (mounted) _snack(context, communityErrorText(e, l));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final api = context.services.community.api;
    final items = _items;
    return LgPage(
      title: l.cmAdminTitle,
      showProfile: false,
      children: [
        _CommunityAvailable(
          child: SignedInGate(
            child: AdminGate(
              mfaHint: l.cmLaunchMfaHint,
              child: _Loader(
                onLoad: _load,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bir tugma faqat egasi uchun (server ham faqat
                    // LG_ADMIN_EMAILS dagi hisobga ruxsat beradi).
                    Builder(
                      builder: (context) =>
                          AdminGate.accessOf(context)?.superAdmin ?? false
                          ? const _LaunchCard()
                          : const SizedBox.shrink(),
                    ),
                    LgSectionTitle(l.admReportsQueue),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final (s, label) in [
                          (MemberStatus.suspended, l.cmAdminSuspended),
                          (MemberStatus.verified, l.cmAdminVerified),
                          (MemberStatus.rejected, l.cmAdminRejected),
                        ])
                          LgChoiceChip(
                            label: label,
                            selected: _filter == s,
                            onTap: () {
                              setState(() {
                                _filter = s;
                                _items = null;
                              });
                              _load();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_error != null)
                      LgStateView(
                        kind: StateKind.error,
                        title: communityErrorText(_error!, l),
                        actionLabel: l.actionRetry,
                        onAction: _load,
                      )
                    else if (items == null)
                      const LgStateView(kind: StateKind.loading, title: '')
                    else if (items.isEmpty)
                      LgStateView(kind: StateKind.empty, title: l.cmAdminEmpty)
                    else
                      for (final m in items)
                        LgPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                [
                                  if (m.role != null)
                                    specialistRoleLabel(m.role!, l),
                                  ?m.country,
                                  if (m.method != null)
                                    m.method == VerifyMethod.manual
                                        ? l.cmMethodManual
                                        : l.cmMethodAi,
                                  if (m.isOwner) l.cmOwnerTag,
                                ].join(' · '),
                                style: text.titleSmall,
                              ),
                              Text(
                                '#${m.userHash.substring(0, 10)} · ${l.cmAdminReporters(m.reporters)}',
                                style: text.bodySmall,
                              ),
                              for (final r in m.reports)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${reportReasonLabel(r.reason, l)}: ${r.excerpt ?? '—'}',
                                    style: text.bodyMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (m.status == MemberStatus.suspended)
                                LgButton.secondary(
                                  label: l.cmAdminRestore,
                                  icon: Icons.restore_rounded,
                                  onPressed: () => _act(
                                    () => api!.adminRestore(m.userHash),
                                    confirmTitle: l.cmAdminRestoreTitle,
                                    confirmBody: l.cmAdminRestoreBody,
                                    action: l.cmAdminRestore,
                                  ),
                                ),
                              if (m.status != MemberStatus.rejected &&
                                  !m.isOwner) ...[
                                const SizedBox(height: 6),
                                LgButton.secondary(
                                  label: l.cmAdminRevoke,
                                  icon: Icons.remove_moderator_outlined,
                                  onPressed: () => _act(
                                    () => api!.adminRevoke(m.userHash),
                                    confirmTitle: l.cmAdminRevokeTitle,
                                    confirmBody: l.cmAdminRevokeBody,
                                    action: l.cmAdminRevoke,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Egasi uchun bir tugma: tasdiq + boshlang'ich savol-javoblar (idempotent).
class _LaunchCard extends StatefulWidget {
  const _LaunchCard();

  @override
  State<_LaunchCard> createState() => _LaunchCardState();
}

class _LaunchCardState extends State<_LaunchCard> {
  bool _busy = false;
  CommunityLaunchResult? _result;
  String? _error;

  Future<void> _run() async {
    final api = context.services.community.api;
    if (api == null) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await api.adminCommunityLaunch();
      if (mounted) setState(() => _result = r);
    } on Object catch (e) {
      if (mounted) {
        setState(
          () => _error = e is CommunityException && e.code == 'not_allowlisted'
              ? l.cmLaunchNotOwner
              : communityErrorText(e, l),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final r = _result;
    return LgPanel(
      key: const ValueKey('cm-launch-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.cmLaunchTitle, style: text.titleMedium),
          const SizedBox(height: 6),
          Text(l.cmLaunchBody, style: text.bodyMedium),
          const SizedBox(height: 12),
          LgButton(
            key: const ValueKey('cm-launch-button'),
            label: l.cmLaunchButton,
            icon: Icons.rocket_launch_outlined,
            busy: _busy,
            onPressed: _run,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            LgNotice(_error!, kind: NoticeKind.error),
          ],
          if (r != null) ...[
            const SizedBox(height: 8),
            LgNotice(
              r.questionsAdded == 0 && r.answersAdded == 0
                  ? l.cmLaunchAlready
                  : l.cmLaunchDone(r.questionsAdded, r.answersAdded),
              kind: NoticeKind.info,
            ),
          ],
        ],
      ),
    );
  }
}

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLoad();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
