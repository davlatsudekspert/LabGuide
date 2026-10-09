import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

String backendErrorText(Object e, AppLocalizations l) => switch (e) {
  BackendException(failure: BackendFailure.network) => l.errNetwork,
  BackendException(failure: BackendFailure.rateLimited) => l.errRateLimited,
  BackendException(failure: BackendFailure.invalid) => l.errInvalidSupport,
  BackendException(failure: BackendFailure.forbidden) => l.errForbidden,
  BackendException(failure: BackendFailure.unauthorized) => l.errSessionExpired,
  BackendException(failure: BackendFailure.unavailable) =>
    l.supportUnavailableBody,
  _ => l.errGeneric,
};

String supportKindLabel(SupportKind k, AppLocalizations l) => switch (k) {
  SupportKind.suggestion => l.supportKindSuggestion,
  SupportKind.bug => l.supportKindBug,
  SupportKind.question => l.supportKindQuestion,
};

String supportStatusLabel(SupportStatus s, AppLocalizations l) => switch (s) {
  SupportStatus.newThread => l.supportStatusNew,
  SupportStatus.inReview => l.supportStatusInReview,
  SupportStatus.answered => l.supportStatusAnswered,
  SupportStatus.closed => l.supportStatusClosed,
};

LgTone supportStatusTone(SupportStatus s) => switch (s) {
  SupportStatus.newThread || SupportStatus.inReview => LgTone.warning,
  SupportStatus.answered => LgTone.brand,
  SupportStatus.closed => LgTone.neutral,
};

String formatWhen(DateTime t, BuildContext context) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMd(locale).add_Hm().format(t.toLocal());
}

/// Hisob va server holatiga qarab ko'rsatiladigan to'siq: server ulanmagan
/// yoki foydalanuvchi kirmagan bo'lsa — halol holat, aks holda [child].
class SignedInGate extends StatelessWidget {
  const SignedInGate({super.key, required this.child});

  final Widget child;

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
      listenable: services.auth,
      builder: (context, _) => services.auth.hasAccount
          ? child
          : LgStateView(
              kind: StateKind.empty,
              title: l.supportSignInTitle,
              message: l.supportSignInBody,
              actionLabel: l.profileSignIn,
              onAction: () => context.push('/profile/auth'),
            ),
    );
  }
}

class SupportListScreen extends StatefulWidget {
  const SupportListScreen({super.key});

  @override
  State<SupportListScreen> createState() => _SupportListScreenState();
}

class _SupportListScreenState extends State<SupportListScreen> {
  List<SupportThread>? _threads;
  Object? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final services = context.services;
    if (!services.backend.isConfigured || !services.auth.hasAccount) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final threads = await services.backend.myThreads();
      if (!mounted) return;
      setState(() => _threads = threads);
      unawaited(services.access.refresh());
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openNew() async {
    final sent = await context.push<bool>('/profile/support/new');
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).supportSent)),
        );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final threads = _threads;
    return LgPage(
      title: l.supportTitle,
      showProfile: false,
      children: [
        SignedInGate(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgButton(
                label: l.supportNew,
                icon: Icons.edit_outlined,
                onPressed: _openNew,
              ),
              const SizedBox(height: 8),
              Text(l.supportHumanReplies, style: text.bodySmall),
              const SizedBox(height: 8),
              if (_error != null)
                LgStateView(
                  kind: StateKind.error,
                  title: backendErrorText(_error!, l),
                  actionLabel: l.actionRetry,
                  onAction: _load,
                )
              else if (threads == null && _loading)
                const LgStateView(kind: StateKind.loading, title: '')
              else if (threads != null && threads.isEmpty)
                LgStateView(
                  kind: StateKind.empty,
                  title: l.supportEmptyTitle,
                  message: l.supportEmptyBody,
                )
              else if (threads != null)
                for (final (i, t) in threads.indexed)
                  LgRow(
                    title: t.subject,
                    subtitle:
                        '${supportKindLabel(t.kind, l)} · '
                        '${supportStatusLabel(t.status, l)} · '
                        '${formatWhen(t.updatedAt, context)}',
                    icon: switch (t.kind) {
                      SupportKind.suggestion => Icons.lightbulb_outline_rounded,
                      SupportKind.bug => Icons.bug_report_outlined,
                      SupportKind.question => Icons.help_outline_rounded,
                    },
                    trailing: t.unreadForUser
                        ? Semantics(
                            label: l.supportUnread,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: p.brand,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                    divider: i < threads.length - 1,
                    onTap: () async {
                      await context.push('/profile/support/thread/${t.id}');
                      await _load();
                    },
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Galereyadan rasm tanlash: turi va hajmi serverdagi chegaralar bilan.
Future<(SupportAttachment?, String?)> pickSupportImage(
  AppLocalizations l,
) async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 2000,
    imageQuality: 85,
  );
  if (file == null) return (null, null);
  final bytes = await file.readAsBytes();
  final lower = file.name.toLowerCase();
  final mime = file.mimeType ??
      (lower.endsWith('.png') ? 'image/png' : 'image/jpeg');
  if (!SupportAttachment.allowedTypes.contains(mime)) {
    return (null, l.supportAttachType);
  }
  if (bytes.length > SupportAttachment.maxBytes) {
    return (null, l.supportAttachTooLarge);
  }
  return (SupportAttachment(bytes: bytes, mimeType: mime), null);
}

class _AttachmentPicker extends StatelessWidget {
  const _AttachmentPicker({
    required this.attachment,
    required this.error,
    required this.onPick,
    required this.onRemove,
  });

  final SupportAttachment? attachment;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = attachment;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgNotice(l.supportPhiNotice),
        if (a == null)
          LgButton.secondary(
            label: l.supportAttach,
            icon: Icons.image_outlined,
            onPressed: onPick,
          )
        else
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  a.bytes,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  semanticLabel: l.supportAttach,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LgButton.secondary(
                  label: l.supportAttachRemove,
                  icon: Icons.close_rounded,
                  onPressed: onRemove,
                ),
              ),
            ],
          ),
        if (error != null) LgNotice(error!, kind: NoticeKind.error),
      ],
    );
  }
}

class NewSupportThreadScreen extends StatefulWidget {
  const NewSupportThreadScreen({super.key});

  @override
  State<NewSupportThreadScreen> createState() => _NewSupportThreadScreenState();
}

class _NewSupportThreadScreenState extends State<NewSupportThreadScreen> {
  SupportKind _kind = SupportKind.suggestion;
  final _subject = TextEditingController();
  final _body = TextEditingController();
  SupportAttachment? _attachment;
  String? _attachError;
  Object? _error;
  bool _busy = false;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final (a, err) = await pickSupportImage(AppLocalizations.of(context));
    if (!mounted) return;
    setState(() {
      if (a != null) _attachment = a;
      _attachError = err;
    });
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (_subject.text.trim().length < 3 || _body.text.trim().isEmpty) {
      setState(
        () => _error = const BackendException(BackendFailure.invalid),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.services.backend.createThread(
        kind: _kind,
        subject: _subject.text,
        body: _body.text,
        attachment: _attachment,
      );
      if (mounted) context.pop(true);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.supportNew,
      showProfile: false,
      children: [
        SignedInGate(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.supportKind, style: text.titleSmall),
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in SupportKind.values)
                    LgChoiceChip(
                      label: supportKindLabel(k, l),
                      selected: _kind == k,
                      onTap: () => setState(() => _kind = k),
                    ),
                ],
              ),
              LgField(
                label: l.supportSubject,
                controller: _subject,
                hint: l.supportSubjectHint,
                maxLength: 120,
                textInputAction: TextInputAction.next,
              ),
              LgField(
                label: l.supportMessage,
                controller: _body,
                hint: l.supportMessageHint,
                maxLines: 6,
                maxLength: 4000,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 12),
              _AttachmentPicker(
                attachment: _attachment,
                error: _attachError,
                onPick: _pick,
                onRemove: () => setState(() => _attachment = null),
              ),
              if (_error != null)
                LgNotice(backendErrorText(_error!, l), kind: NoticeKind.error),
              const SizedBox(height: 12),
              LgButton(
                label: l.supportSend,
                icon: Icons.send_rounded,
                busy: _busy,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Yozishma (foydalanuvchi yoki admin nuqtai nazaridan).
class SupportConversation extends StatelessWidget {
  const SupportConversation({
    super.key,
    required this.messages,
    required this.asAdmin,
  });

  final List<SupportMessage> messages;
  final bool asAdmin;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final m in messages)
          Align(
            alignment: m.fromAdmin == asAdmin
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: m.fromAdmin == asAdmin ? p.soft : p.paper,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${m.fromAdmin ? l.supportTeam : (asAdmin ? l.supportUser : l.supportYou)}'
                      ' · ${formatWhen(m.createdAt, context)}',
                      style: text.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(m.body, style: text.bodyMedium),
                    if (m.attachmentPath != null) ...[
                      const SizedBox(height: 8),
                      _RemoteImage(path: m.attachmentPath!),
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

class _RemoteImage extends StatefulWidget {
  const _RemoteImage({required this.path});

  final String path;

  @override
  State<_RemoteImage> createState() => _RemoteImageState();
}

class _RemoteImageState extends State<_RemoteImage> {
  late final Future<Uint8List> _bytes = context.services.backend.attachment(
    widget.path,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text(backendErrorText(snap.error!, l));
        }
        if (!snap.hasData) {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            snap.data!,
            height: 180,
            fit: BoxFit.contain,
            semanticLabel: l.supportAttach,
          ),
        );
      },
    );
  }
}

class SupportThreadScreen extends StatefulWidget {
  const SupportThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<SupportThreadScreen> createState() => _SupportThreadScreenState();
}

class _SupportThreadScreenState extends State<SupportThreadScreen> {
  SupportThread? _thread;
  List<SupportMessage>? _messages;
  Object? _error;
  final _reply = TextEditingController();
  SupportAttachment? _attachment;
  String? _attachError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(markRead: true));
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load({bool markRead = false}) async {
    final backend = context.services.backend;
    final access = context.services.access;
    try {
      final threads = await backend.myThreads();
      // Boshqa hisobning murojaati ro'yxatda bo'lmaydi (RLS) — “topilmadi”.
      final thread =
          threads.where((t) => t.id == widget.threadId).firstOrNull ??
          (throw const BackendException(BackendFailure.notFound));
      final messages = await backend.messages(widget.threadId);
      if (markRead && thread.unreadForUser) {
        await backend.markRead(widget.threadId);
        access.markThreadRead();
      }
      if (!mounted) return;
      setState(() {
        _thread = thread;
        _messages = messages;
        _error = null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _send() async {
    if (_reply.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.services.backend.postMessage(
        widget.threadId,
        _reply.text,
        attachment: _attachment,
      );
      _reply.clear();
      _attachment = null;
      await _load();
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final thread = _thread;
    final messages = _messages;
    return LgPage(
      title: thread?.subject ?? l.supportTitle,
      showProfile: false,
      children: [
        SignedInGate(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (thread != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: LgTag(
                    '${supportKindLabel(thread.kind, l)} · '
                    '${supportStatusLabel(thread.status, l)}',
                    tone: supportStatusTone(thread.status),
                  ),
                ),
              if (messages == null && _error == null)
                const LgStateView(kind: StateKind.loading, title: ''),
              if (messages != null)
                SupportConversation(messages: messages, asAdmin: false),
              if (_error != null)
                LgNotice(backendErrorText(_error!, l), kind: NoticeKind.error),
              if (messages != null) ...[
                LgField(
                  label: l.supportMessage,
                  controller: _reply,
                  hint: l.supportReplyHint,
                  maxLines: 4,
                  maxLength: 4000,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 10),
                _AttachmentPicker(
                  attachment: _attachment,
                  error: _attachError,
                  onPick: () async {
                    final (a, err) = await pickSupportImage(l);
                    if (!mounted) return;
                    setState(() {
                      if (a != null) _attachment = a;
                      _attachError = err;
                    });
                  },
                  onRemove: () => setState(() => _attachment = null),
                ),
                const SizedBox(height: 10),
                LgButton(
                  label: l.supportSend,
                  icon: Icons.send_rounded,
                  busy: _busy,
                  onPressed: _send,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
