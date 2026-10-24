import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../core/backend/lab_backend.dart' show LabBackend;
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../classroom/general_test_screen.dart'
    show generalTestLocation, groupGeneralTestLocation;
import '../classroom/invite_link.dart';
import '../classroom/qr_code_view.dart';
import '../classroom/qr_scan_screen.dart';
import '../classroom/topic_questions.dart';
import '../classroom/topic_test_screens.dart' show SlideLink, deckOfAssignment;
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../settings/settings_controller.dart';
import '../support/support_screens.dart' show formatWhen;
import 'exam_question.dart';
import 'exam_session.dart';
import 'exam_widgets.dart';

// Ustoz–talaba guruhlari. Har amal serverda tekshiriladi (RLS + funksiyalar):
// guruhni yaratgan hisob — o'sha guruh ustozi; ilovadagi “Ustoz” roli hech
// qanday server huquqi bermaydi. Server ulanmagan buildda — halol holat.

String classesErrorText(Object e, AppLocalizations l) => switch (e) {
  BackendException(code: 'nickname_taken') => l.classesNicknameTaken,
  BackendException(code: 'abusive_language') => l.classesNicknameAbusive,
  // Avval umumiy “Server ma'lumotni qabul qilmadi” / “Juda ko'p so'rov”
  // chiqardi — talaba nima qilishni bilmasdi (iPhone xatosi, 2026-10-18).
  BackendException(code: 'invalid_nickname') => l.classesNicknameInvalid,
  BackendException(code: 'group_full') => l.classesGroupFull,
  BackendException(failure: BackendFailure.network) => l.errNetwork,
  BackendException(failure: BackendFailure.rateLimited) => l.errRateLimited,
  BackendException(failure: BackendFailure.invalid) => l.classesInvalid,
  BackendException(failure: BackendFailure.notFound) => l.classesCodeNotFound,
  BackendException(failure: BackendFailure.forbidden) => l.errForbidden,
  BackendException(failure: BackendFailure.unauthorized) => l.errSessionExpired,
  BackendException(failure: BackendFailure.unavailable) =>
    l.classesUnavailableTitle,
  _ => l.errGeneric,
};

/// Server ulanmagan — halol holat; hisob yo'q — kirish taklifi.
class ClassesGate extends StatelessWidget {
  const ClassesGate({
    super.key,
    required this.child,
    this.signInTitle,
    this.signInBody,
  });

  final Widget child;

  /// Hisobsiz holat matni (standart — umumiy “Guruhlar uchun kiring”).
  final String? signInTitle;
  final String? signInBody;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    if (!services.backend.isConfigured) {
      return LgStateView(
        kind: StateKind.unavailable,
        title: l.classesUnavailableTitle,
        message: l.classesUnavailableBody,
        secondary: LgButton.secondary(
          label: l.classesTryExam,
          icon: Icons.timer_outlined,
          onPressed: () => context.push('/learn/exam'),
        ),
      );
    }
    return ListenableBuilder(
      listenable: services.auth,
      builder: (context, _) => services.auth.hasAccount
          ? child
          : LgStateView(
              kind: StateKind.empty,
              title: signInTitle ?? l.classesSignInTitle,
              message: signInBody ?? l.classesSignInBody,
              actionLabel: l.classesSignIn,
              onAction: () => context.push('/profile/auth'),
            ),
    );
  }
}

/// Server so'rovi holati: yuklanmoqda / xato (qayta urinish) / ma'lumot.
class _Loaded<T> {
  T? data;
  Object? error;
  bool loading = false;
}

Widget _loadState<T>(
  BuildContext context,
  _Loaded<T> s,
  VoidCallback retry,
  Widget Function(T data) builder,
) {
  final l = AppLocalizations.of(context);
  if (s.error != null) {
    return LgStateView(
      kind:
          s.error is BackendException &&
              (s.error! as BackendException).failure == BackendFailure.network
          ? StateKind.offline
          : StateKind.error,
      title: classesErrorText(s.error!, l),
      actionLabel: l.actionRetry,
      onAction: retry,
    );
  }
  final data = s.data;
  if (data == null) {
    return LgSkeleton(caption: l.classesLoading);
  }
  return builder(data);
}

/// Topshiriq savollari id bo'yicha: kontent paketi va (yuklangan bo'lsa)
/// toifa banki — mavzu testida ikkalasidan ham savol bo'lishi mumkin.
Map<String, ExamQuestion> _byId(BuildContext context, ContentPack pack) =>
    classQuestionIndex(pack, context.services.toifa.bank);

/// Guruhda ko'rinadigan nom: taxallus yoki tartib raqami (“Talaba 07”).
/// Ustoz qurilmasida o'zi yozgan lokal belgi (masalan, real ism) oldinda —
/// u serverga yuborilmaydi.
String memberLabel(BuildContext context, String groupId, GroupMember m) {
  final l = AppLocalizations.of(context);
  final base =
      m.alias ??
      (m.seatNo == null
          ? l.classesRoleTeacher
          : l.classesSeat(m.seatNo!.toString().padLeft(2, '0')));
  final local = context.services.classroom.localName(groupId, m.userId);
  return local == null ? base : '$local · $base';
}

bool _ready(BuildContext context) =>
    context.services.backend.isConfigured && context.services.auth.hasAccount;

/// Hisob almashsa (chiqib, boshqasi bilan kirilsa) sahifa ma'lumoti qayta
/// yuklanadi — oldingi hisobniki ko'rinib qolmasin.
mixin _AccountReload<T extends StatefulWidget> on State<T> {
  String? _uid;
  bool _uidSeen = false;

  void resetForAccount();
  Future<void> reloadForAccount();

  Widget watchAccount(Widget Function(BuildContext context) builder) =>
      ListenableBuilder(
        listenable: context.services.auth,
        builder: (context, _) {
          final uid = context.services.backend.userId;
          if (_uidSeen && uid != _uid) {
            resetForAccount();
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => reloadForAccount(),
            );
          }
          _uidSeen = true;
          _uid = uid;
          return builder(context);
        },
      );
}

// ------------------------------------------------------------ guruhlar ro'yxati

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final _groups = _Loaded<List<StudyGroup>>();

  /// Ro'yxat qaysi hisob uchun yuklangan (hisob almashsa — qayta).
  String? _loadedFor = '';

  Future<void> _load() async {
    if (!_ready(context) || _groups.loading) return;
    setState(() {
      _groups
        ..loading = true
        ..error = null;
    });
    try {
      final g = await context.services.backend.myGroups();
      if (mounted) setState(() => _groups.data = g);
    } on Object catch (e) {
      if (mounted) setState(() => _groups.error = e);
    } finally {
      if (mounted) setState(() => _groups.loading = false);
    }
  }

  Future<void> _open(String location, {Object? extra}) async {
    await context.push(location, extra: extra);
    if (mounted) await _load();
  }

  /// QR skaner (D-68): topilgan taklif bilan qo'shilish ekrani darhol
  /// qo'shiladi (taxallus ixtiyoriy) va test bo'lsa — uni ochadi.
  Future<void> _scan() async {
    final outcome = await openInviteScanner(context);
    if (!mounted) return;
    switch (outcome) {
      case QrScanInvite(:final invite):
        await _open(
          Uri(
            path: '/learn/classes/join',
            queryParameters: {'code': invite.code, 'a': ?invite.assignmentId},
          ).toString(),
          extra: JoinGroupScreen.autoJoinExtra,
        );
      case QrScanTypeInstead():
        await _open('/learn/classes/join');
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = context.services.auth;
    return LgPage(
      title: l.classesTitle,
      subtitle: l.classesSubtitle,
      children: [
        ClassesGate(
          child: ListenableBuilder(
            listenable: auth,
            builder: (context, _) {
              // Kirish/chiqish yoki hisob almashganda qayta yuklanadi.
              final uid = context.services.backend.userId;
              if (_loadedFor != uid) {
                _loadedFor = uid;
                _groups
                  ..data = null
                  ..error = null;
                WidgetsBinding.instance.addPostFrameCallback((_) => _load());
              }
              return _body(context, l);
            },
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, AppLocalizations l) {
    final text = Theme.of(context).textTheme;
    final teacherFirst = context.services.settings.role == AppRole.teacher;
    final create = LgTile(
      title: l.classesCreate,
      caption: l.classesCreateSub,
      icon: Icons.school_outlined,
      highlighted: teacherFirst,
      onTap: () => _open('/learn/classes/new'),
    );
    final join = LgTile(
      title: l.classesJoin,
      caption: l.classesJoinSub,
      icon: Icons.vpn_key_outlined,
      highlighted: !teacherFirst,
      onTap: () => _open('/learn/classes/join'),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        LgTwoColumnGrid(
          children: teacherFirst ? [create, join] : [join, create],
        ),
        if (context.services.qrScanner.isSupported) ...[
          LgButton.secondary(
            key: const ValueKey('classes-scan'),
            label: l.qrScanAction,
            icon: Icons.qr_code_scanner_rounded,
            onPressed: _scan,
          ),
          const SizedBox(height: 10),
        ],
        Text(l.classesRoleNote, style: text.bodySmall),
        LgSectionTitle(l.classesMine),
        _loadState(context, _groups, _load, (groups) {
          if (groups.isEmpty) {
            return LgStateView(
              kind: StateKind.empty,
              title: l.classesEmpty,
              message: l.classesEmptyBody,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, g) in groups.indexed)
                LgRow(
                  title: g.name,
                  // Talaba boshqa a'zolarni ko'rmaydi — son faqat ustozga.
                  subtitle: g.isTeacher
                      ? '${l.classesRoleTeacher} · ${l.classesMembers(g.memberCount)}'
                      : l.classesRoleStudent,
                  icon: g.isTeacher
                      ? Icons.school_outlined
                      : Icons.groups_outlined,
                  divider: i < groups.length - 1,
                  onTap: () => _open('/learn/classes/g/${g.id}'),
                ),
              // Ustoz: umumiy test — bir nechta mavzudan, guruh(lar) tanlanadi.
              if (groups.any((g) => g.isTeacher)) ...[
                const SizedBox(height: 12),
                LgButton.secondary(
                  key: const ValueKey('classes-general-test'),
                  label: l.classesGiveGeneralTest,
                  icon: Icons.add_task_rounded,
                  onPressed: () => _open(generalTestLocation),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}

// ------------------------------------------------------- yaratish / qo'shilish

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key, this.popOnCreate = false});

  /// Boshqa sahifadan (masalan, “Guruhga topshirish”) ochilgan: yaratilgach
  /// guruh sahifasiga o'tmay, chaqirgan sahifaga qaytadi.
  final bool popOnCreate;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _name = TextEditingController();
  bool _tried = false;
  bool _busy = false;
  bool _registering = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    // Ustoz holati serverdan (ilovadagi rol tanlovi huquq bermaydi).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _ready(context)) context.services.refreshAccess();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _nameOk {
    final n = _name.text.trim().length;
    return n >= 3 && n <= 80;
  }

  Future<void> _register() async {
    setState(() {
      _registering = true;
      _error = null;
    });
    final services = context.services;
    try {
      await services.backend.registerTeacher();
      await services.refreshAccess();
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (!_nameOk) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final g = await context.services.backend.createGroup(_name.text.trim());
      if (!mounted) return;
      showSnack(context, AppLocalizations.of(context).classesCreated);
      if (widget.popOnCreate) {
        context.pop(g);
      } else {
        context.pushReplacement('/learn/classes/g/${g.id}');
      }
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
    final access = context.services.access;
    return LgPage(
      title: l.classesCreate,
      subtitle: l.classesCreateIntro,
      showProfile: false,
      children: [
        ClassesGate(
          child: ListenableBuilder(
            listenable: access,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!access.access.teacher) ...[
                  LgPanel(
                    soft: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LgEyebrow(l.classesTeacherRegisterEyebrow),
                        Text(
                          l.classesTeacherRegisterTitle,
                          style: text.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.classesTeacherRegisterBody,
                          style: text.bodyMedium,
                        ),
                        const SizedBox(height: 14),
                        LgButton(
                          label: l.classesTeacherRegister,
                          icon: Icons.school_outlined,
                          busy: _registering,
                          onPressed: _register,
                        ),
                      ],
                    ),
                  ),
                  if (_error != null)
                    LgNotice(
                      classesErrorText(_error!, l),
                      kind: NoticeKind.error,
                    ),
                ] else ...[
                  LgField(
                    label: l.classesGroupName,
                    controller: _name,
                    hint: l.classesGroupNameHint,
                    maxLength: 80,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    errorText: _tried && !_nameOk
                        ? l.classesLengthError(3, 80)
                        : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Text(l.classesDisplayNameNote, style: text.bodySmall),
                  if (_error != null)
                    LgNotice(
                      classesErrorText(_error!, l),
                      kind: NoticeKind.error,
                    ),
                  const SizedBox(height: 16),
                  LgButton(
                    label: l.classesCreateAction,
                    icon: Icons.add_rounded,
                    busy: _busy,
                    onPressed: _submit,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Taklif kodi: faqat ruxsat etilgan 32 belgi, katta harf. Butun havola
/// yoki taklif matni qo'yilsa (paste) — kod (va test id) shu yerda
/// ajratiladi ([onInvite]).
class _CodeFormatter extends TextInputFormatter {
  _CodeFormatter({this.onInvite});

  final void Function(InviteTarget invite)? onInvite;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length - oldValue.text.length > 1) {
      final invite = parseInvite(newValue.text);
      if (invite != null) {
        onInvite?.call(invite);
        return TextEditingValue(
          text: invite.code,
          selection: TextSelection.collapsed(offset: invite.code.length),
        );
      }
    }
    final clean = newValue.text.toUpperCase().replaceAll(
      RegExp('[^A-Z0-9]'),
      '',
    );
    final text = clean.length > 8 ? clean.substring(0, 8) : clean;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({
    super.key,
    this.initialCode,
    this.assignmentId,
    this.autoJoin = false,
  });

  /// Route `extra`: QR skanerdan kelindi — darhol qo'shiladi. Faqat ilova
  /// ichidan beriladi (havola/deep link bilan avtomatik qo'shilish yo'q).
  static const autoJoinExtra = 'qr-scan-auto-join';

  /// QR yoki havoladan kelgan kod (`/learn/classes/join?code=...&a=...`).
  final String? initialCode;

  /// “Test QR”: qo'shilgach darhol ochiladigan test.
  final String? assignmentId;

  /// QR skanerdan kelgan: taxallus oldindan to'ldirilgach — darhol qo'shilish.
  final bool autoJoin;

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  late final _formatter = _CodeFormatter(onInvite: _adopt);
  late final _code = TextEditingController(
    text: normalizeInviteCode(widget.initialCode) ?? '',
  );
  final _display = TextEditingController();
  final _codeFocus = FocusNode();
  final _nickFocus = FocusNode();

  /// QR'dan keldi, lekin taxallus yo'q: darhol qo'shilmay, avval taxallus
  /// so'raladi (aks holda ustozda faqat “Talaba 07” ko'rinardi).
  bool _askNick = false;
  late String? _assignment = widget.assignmentId;
  late bool _autoJoin = widget.autoJoin;
  bool _tried = false;
  bool _busy = false;
  bool _nickLoaded = false;
  Object? _error;

  /// Shu hisobning guruhlari (taxallus va “o'z guruhi” tekshiruvi uchun).
  List<StudyGroup>? _myGroups;

  /// Kiritilgan kod — shu hisob USTOZ bo'lgan guruhniki: talaba bo'lib
  /// qo'shilib bo'lmaydi, aniq sabab va yo'l ko'rsatiladi.
  StudyGroup? _ownGroup;

  StudyGroup? _teacherGroupFor(String code) =>
      _myGroups?.where((g) => g.isTeacher && g.joinCode == code).firstOrNull;

  /// Ekran ochiq turganda yangi havola/QR kodi kelsa — maydon yangilanadi.
  @override
  void didUpdateWidget(JoinGroupScreen old) {
    super.didUpdateWidget(old);
    final c = widget.initialCode;
    if (c != null && c != old.initialCode) {
      _code.text = normalizeInviteCode(c) ?? '';
      _assignment = widget.assignmentId;
      _error = null;
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _display.dispose();
    _codeFocus.dispose();
    _nickFocus.dispose();
    super.dispose();
  }

  void _adopt(InviteTarget invite) {
    // Formatter ichidan: kadrdan keyin (build paytida setState emas).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _assignment = invite.assignmentId ?? _assignment;
        _error = null;
      });
    });
  }

  /// Oldingi guruhdagi taxallus — yangi guruhda ham (o'zgartirish mumkin).
  Future<void> _prefillNickname() async {
    if (_nickLoaded) return;
    _nickLoaded = true;
    try {
      await _loadNickname();
    } finally {
      // QR skanerdan kelgan bo'lsa — taxallusdan keyin bir marta qo'shiladi
      // (taxallus hali yo'q bo'lsa — avval so'raladi).
      if (_autoJoin && mounted && _codeOk) {
        _autoJoin = false;
        _submitOrAskNick();
      }
    }
  }

  Future<void> _loadNickname() async {
    try {
      final groups = await context.services.backend.myGroups();
      _myGroups = groups;
      final nick = groups
          .where((g) => !g.isTeacher && (g.myNickname ?? '').isNotEmpty)
          .map((g) => g.myNickname!)
          .firstOrNull;
      if (nick != null && mounted && _display.text.isEmpty) {
        setState(() => _display.text = nick);
      }
    } on Object {
      // Majburiy emas — talaba o'zi yozadi.
    }
  }

  Future<void> _paste() async {
    final l = AppLocalizations.of(context);
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final invite = parseInvite(data?.text);
    if (invite == null) {
      showSnack(context, l.classesPasteNoCode);
      return;
    }
    setState(() {
      _code.text = invite.code;
      _assignment = invite.assignmentId ?? _assignment;
      _error = null;
    });
  }

  /// QR skaner (D-68): taklif topilsa — maydon to'ldiriladi va darhol
  /// qo'shiladi; "Kodni yozish" — kod maydoniga fokus.
  Future<void> _scan() async {
    final outcome = await openInviteScanner(context);
    if (!mounted) return;
    switch (outcome) {
      case QrScanInvite(:final invite):
        setState(() {
          _code.text = invite.code;
          // Skanerlangan QR ustun: unda test bo'lmasa — avvalgisi ham yo'q.
          _assignment = invite.assignmentId;
          _error = null;
        });
        if (!_busy) _submitOrAskNick();
      case QrScanTypeInstead():
        _codeFocus.requestFocus();
      case null:
        break;
    }
  }

  /// QR bilan: oldingi guruhdagi taxallus bo'lsa — darhol qo'shiladi;
  /// bo'lmasa — taxallus maydoni ochiladi (ixtiyoriy, bo'sh qoldirsa ham
  /// “Qo'shilish” ishlaydi).
  void _submitOrAskNick() {
    if (normalizeNickname(_display.text).isNotEmpty) {
      unawaited(_submit());
      return;
    }
    setState(() => _askNick = true);
    _nickFocus.requestFocus();
  }

  bool get _codeOk =>
      _code.text.length == 8 && !inviteCodeHasAmbiguous(_code.text);

  String? _codeError(AppLocalizations l) {
    final c = _code.text;
    // 0/O/1/I — serverda hech qachon bo'lmaydi: “topilmadi” o'rniga sabab.
    if ((c.length == 8 || _tried) && inviteCodeHasAmbiguous(c)) {
      return l.classesCodeAmbiguous;
    }
    return _tried && c.length != 8 ? l.classesCodeError : null;
  }

  bool get _nameLengthOk {
    final n = normalizeNickname(_display.text).length;
    return n == 0 || (n >= 2 && n <= 24);
  }

  /// Taxallus ixtiyoriy: bo'sh — tartib raqami ko'rinadi. Belgilar server
  /// qoidasi bilan bir xil tekshiriladi (iPhone apostrofi ’ — ruxsat).
  bool get _nameOk => _nameLengthOk && nicknameAllowed(_display.text);

  String? _nameError(AppLocalizations l) {
    if (!_tried) return null;
    if (!_nameLengthOk) return l.classesLengthError(2, 24);
    return nicknameAllowed(_display.text) ? null : l.classesNicknameInvalid;
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (!_codeOk || !_nameOk) return;
    // Ustoz o'z guruhi kodini kiritdi — serverga bormasdan aniq javob.
    final own = _teacherGroupFor(_code.text);
    if (own != null) {
      setState(() {
        _ownGroup = own;
        _error = null;
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _ownGroup = null;
    });
    final services = context.services;
    try {
      final alias = normalizeNickname(_display.text);
      final id = await services.backend.joinGroup(
        _code.text,
        displayName: alias.isEmpty ? null : alias,
      );
      // Guruhlar ro'yxati yuklanmagan bo'lsa (tarmoq) — server “qo'shildi”
      // deganda ham bu ustozning o'z guruhi bo'lishi mumkin: tekshiriladi.
      if (_myGroups == null) {
        try {
          _myGroups = await services.backend.myGroups();
        } on Object {
          // Tekshirib bo'lmadi — oddiy yo'l (guruh sahifasi rolni ko'rsatadi).
        }
      }
      final mine = _myGroups?.where((g) => g.id == id).firstOrNull;
      if (mine != null && mine.isTeacher) {
        if (mounted) setState(() => _ownGroup = mine);
        return;
      }
      // Havola orqali kelgan yangi foydalanuvchi: rol tanlanmagan bo'lsa —
      // talaba (alohida rol ekrani yo'q).
      if (services.settings.role == null) {
        await services.settings.setRole(AppRole.student);
      }
      if (!mounted) return;
      showSnack(context, AppLocalizations.of(context).classesJoined);
      final a = _assignment;
      context.pushReplacement(
        a == null ? '/learn/classes/g/$id' : '/learn/classes/g/$id/a/$a',
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.classesJoin,
      subtitle: l.classesJoinIntro,
      showProfile: false,
      children: [
        ClassesGate(
          // Havola/QR bilan kelgan, hali kirmagan talaba: kod saqlanadi,
          // kirgach shu ekranga qaytadi.
          signInTitle: l.classesJoinSignInTitle,
          signInBody: l.classesJoinSignInBody,
          child: Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _prefillNickname(),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: MergeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Text(
                              l.classesCode,
                              style: text.titleSmall!.copyWith(fontSize: 14),
                            ),
                          ),
                          TextField(
                            key: const ValueKey('join-code'),
                            controller: _code,
                            focusNode: _codeFocus,
                            autocorrect: false,
                            enableSuggestions: false,
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [_formatter],
                            style: text.headlineSmall!.copyWith(
                              letterSpacing: 4,
                              color: p.ink,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            onChanged: (_) => setState(() {
                              _error = null;
                              _ownGroup = null;
                            }),
                            decoration: InputDecoration(
                              hintText: 'ABCD2345',
                              errorText: _codeError(l),
                              errorMaxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (context.services.qrScanner.isSupported) ...[
                    LgButton(
                      key: const ValueKey('join-scan'),
                      label: l.qrScanAction,
                      icon: Icons.qr_code_scanner_rounded,
                      onPressed: _busy ? null : _scan,
                    ),
                    const SizedBox(height: 8),
                  ],
                  LgButton.secondary(
                    key: const ValueKey('join-paste'),
                    label: l.classesPasteLink,
                    icon: Icons.content_paste_rounded,
                    onPressed: _paste,
                  ),
                  const SizedBox(height: 6),
                  Text(l.classesScanTip, style: text.bodySmall),
                  if (_askNick) ...[
                    const SizedBox(height: 10),
                    LgNotice(
                      l.classesScanAskNick,
                      key: const ValueKey('join-ask-nick'),
                      kind: NoticeKind.info,
                    ),
                  ],
                  LgField(
                    label: l.classesDisplayName,
                    controller: _display,
                    focusNode: _nickFocus,
                    hint: l.classesDisplayNameHint,
                    maxLength: 24,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    errorText: _nameError(l),
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 8),
                  Text(l.classesJoinNote, style: text.bodySmall),
                  if (_assignment != null) ...[
                    const SizedBox(height: 10),
                    LgNotice(
                      l.classesJoinOpensTest,
                      key: const ValueKey('join-opens-test'),
                      kind: NoticeKind.info,
                    ),
                  ],
                  if (_error != null)
                    LgNotice(
                      classesErrorText(_error!, l),
                      kind: NoticeKind.error,
                    ),
                  if (_ownGroup case final own?) ...[
                    const SizedBox(height: 12),
                    _OwnGroupPanel(group: own, assignmentId: _assignment),
                  ],
                  const SizedBox(height: 16),
                  LgButton(
                    key: const ValueKey('join-submit'),
                    label: l.classesJoinAction,
                    icon: Icons.login_rounded,
                    busy: _busy,
                    onPressed: _submit,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Ustoz o'z guruhi kodini (yoki test QR'ini) talaba sifatida ochmoqchi
/// bo'ldi. Server bu hisobni talaba qilmaydi — sabab va keyingi qadamlar.
class _OwnGroupPanel extends StatelessWidget {
  const _OwnGroupPanel({required this.group, this.assignmentId});

  final StudyGroup group;
  final String? assignmentId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final a = assignmentId;
    final base = '/learn/classes/g/${group.id}';
    return LgPanel(
      key: const ValueKey('join-own-group'),
      soft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(l.classesOwnGroupTitle, style: text.titleMedium),
          ),
          const SizedBox(height: 6),
          Text(l.classesOwnGroupBody, style: text.bodyMedium),
          const SizedBox(height: 12),
          LgButton(
            key: const ValueKey('join-own-open'),
            label: a == null
                ? l.classesOwnGroupOpen
                : l.classesPreviewAsStudent,
            icon: a == null ? Icons.school_outlined : Icons.visibility_outlined,
            // Test bilan kelgan bo'lsa — test sahifasi (u yerda “Talaba
            // ko'rinishida sinash”), aks holda guruh sahifasi.
            onPressed: () =>
                context.pushReplacement(a == null ? base : '$base/a/$a'),
          ),
          const SizedBox(height: 8),
          LgButton.secondary(
            key: const ValueKey('join-own-switch'),
            label: l.classesSwitchAccount,
            icon: Icons.switch_account_outlined,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ guruh

/// Guruh sahifasi uchun bir martada yuklanadigan ma'lumot.
class _GroupData {
  _GroupData(this.group, this.assignments, this.submissions, this.members);

  final StudyGroup group;
  final List<GroupAssignment> assignments;
  final List<GroupSubmission> submissions;
  final List<GroupMember> members;

  List<GroupMember> get students => [
    for (final m in members)
      if (!m.isTeacher) m,
  ];
}

Future<_GroupData?> _loadGroup(BuildContext context, String groupId) async {
  final backend = context.services.backend;
  final groups = await backend.myGroups();
  final group = groups.where((g) => g.id == groupId).firstOrNull;
  if (group == null) return null;
  final results = await Future.wait([
    backend.assignments(groupId),
    backend.groupSubmissions(groupId),
    backend.groupMembers(groupId),
  ]);
  return _GroupData(
    group,
    results[0] as List<GroupAssignment>,
    results[1] as List<GroupSubmission>,
    results[2] as List<GroupMember>,
  );
}

/// Topshiriq savollari tayyor bo'lguncha holat: kontent paketi va (mavzu
/// testida toifa savoli bo'lsa) toifa banki.
Widget _questionsGate(
  GroupAssignment a,
  Widget Function(BuildContext context, ContentPack pack) builder,
) => ContentGate(
  builder: (context, pack) => _packOnly(pack, a)
      ? builder(context, pack)
      : ToifaBankGate(builder: (context, _) => builder(context, pack)),
);

/// Topshiriq faqat kontent paketi savollaridan (eski topshiriqlar kabi).
bool _packOnly(ContentPack? pack, GroupAssignment a) {
  if (pack == null) return false;
  final source = PackQuestionSource.of(pack);
  return a.questionIds.every((id) => source.question(id) != null);
}

enum _StudentStatus { fresh, inProgress, pending, done, overdue, closed }

_StudentStatus _statusFor(
  BuildContext context,
  GroupAssignment a,
  GroupSubmission? mine,
) {
  final services = context.services;
  if (mine != null) return _StudentStatus.done;
  final local = services.exams.assignmentSession(a.id, services.backend.userId);
  if (local != null) {
    return local.finished ? _StudentStatus.pending : _StudentStatus.inProgress;
  }
  // Ustoz yakunlagan test: “Boshlash” ko'rsatilmaydi (server baribir rad
  // etadi — `not_open`).
  if (a.closed) return _StudentStatus.closed;
  final due = a.dueAt;
  if (due != null && services.exams.now().isAfter(due)) {
    return _StudentStatus.overdue;
  }
  return _StudentStatus.fresh;
}

String _assignmentMeta(BuildContext context, GroupAssignment a) {
  final l = AppLocalizations.of(context);
  return [
    l.quizQuestionCount(a.questionCount),
    if (a.timeLimitMinutes != null) l.examMinutes(a.timeLimitMinutes!),
    a.dueAt == null
        ? l.classesNoDue
        : l.classesDue(formatWhen(a.dueAt!, context)),
  ].join(' · ');
}

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> with _AccountReload {
  final _data = _Loaded<_GroupData>();
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted || !_ready(context)) return;
    setState(() {
      _data
        ..loading = true
        ..error = null;
    });
    try {
      final d = await _loadGroup(context, widget.groupId);
      if (!mounted) return;
      setState(() {
        _missing = d == null;
        _data.data = d;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _data.error = e);
    } finally {
      if (mounted) setState(() => _data.loading = false);
    }
  }

  Future<void> _open(String location) async {
    await context.push(location);
    if (mounted) await _load();
  }

  @override
  void resetForAccount() {
    _data
      ..data = null
      ..error = null;
    _missing = false;
  }

  @override
  Future<void> reloadForAccount() => _load();

  @override
  Widget build(BuildContext context) => watchAccount(_page);

  Widget _page(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _data.data;
    return LgPage(
      title: d?.group.name ?? l.classesTitle,
      subtitle: d == null
          ? null
          : d.group.isTeacher
          ? l.classesYouTeacher(d.group.memberCount)
          : l.classesYouStudent,
      showProfile: false,
      children: [
        ClassesGate(
          child: _missing
              ? LgStateView(
                  kind: StateKind.empty,
                  title: l.classesGroupMissing,
                  actionLabel: l.classesBackToList,
                  onAction: () => context.go('/learn/classes'),
                )
              : _loadState(
                  context,
                  _data,
                  _load,
                  (d) => d.group.isTeacher ? _teacher(d) : _student(d),
                ),
        ),
      ],
    );
  }

  /// O'quv rejasi: jadval (ustoz) yoki ochilgan mavzular (talaba).
  Widget _planRow(StudyGroup g) {
    final l = AppLocalizations.of(context);
    return LgRow(
      title: g.isTeacher ? l.classroomPlanTitle : l.classroomTopicsTitle,
      subtitle: g.isTeacher ? l.classroomPlanSub : l.classroomTopicsSub,
      icon: Icons.calendar_month_outlined,
      divider: false,
      onTap: () => _open('/learn/classes/g/${g.id}/plan'),
    );
  }

  Widget _teacher(_GroupData d) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final students = d.students;
    // Talaba yo'q — birinchi ish kodni yuborish; keyin esa topshiriqlar va
    // natijalar oldinda, kod pastda.
    final inviteFirst = students.isEmpty;
    final assignments = [
      LgSectionTitle(l.classesAssignments),
      // Mavzu testi (variantli, “javoblar qachon ochiladi” bilan) —
      // to'g'ridan-to'g'ri: mavzuni qidirib tanlash → “Guruhga topshirish”.
      LgButton(
        key: const ValueKey('group-topic-test'),
        label: l.classesGiveTopicTest,
        icon: Icons.quiz_outlined,
        onPressed: () => _open('/learn/classes/g/${d.group.id}/topic-test'),
      ),
      const SizedBox(height: 8),
      // Umumiy test: bir nechta mavzudan (toifa, ma'ruza, analizlar) 50
      // tagacha savol — shu guruh oldindan tanlangan.
      LgButton.secondary(
        key: const ValueKey('group-general-test'),
        label: l.classesGiveGeneralTest,
        icon: Icons.add_task_rounded,
        onPressed: () => _open(groupGeneralTestLocation(d.group.id)),
      ),
      const SizedBox(height: 6),
      if (d.assignments.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(l.classesNoAssignmentsTeacher, style: text.bodyMedium),
        )
      else
        for (final (i, a) in d.assignments.indexed)
          () {
            final done = {
              for (final s in d.submissions)
                if (s.assignmentId == a.id) s.userId,
            }.where((u) => students.any((m) => m.userId == u)).length;
            return _AssignmentTile(
              assignment: a,
              icon: Icons.assignment_outlined,
              tag: students.isEmpty
                  ? null
                  : LgTag(
                      l.classesSubmittedOf(done, students.length),
                      tone: done == students.length
                          ? LgTone.brand
                          : LgTone.neutral,
                    ),
              divider: i < d.assignments.length - 1,
              onTap: () => _open('/learn/classes/g/${d.group.id}/a/${a.id}'),
            );
          }(),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inviteFirst) _InviteCard(group: d.group),
        _planRow(d.group),
        ...assignments,
        LgSectionTitle(l.classesMembersTitle(students.length)),
        if (students.isEmpty)
          Text(l.classesNoStudents, style: text.bodyMedium)
        else
          for (final (i, m) in students.indexed)
            () {
              final mine = [
                for (final s in d.submissions)
                  if (s.userId == m.userId) s,
              ];
              final avg = mine.isEmpty
                  ? null
                  : (mine.map((s) => s.percent).reduce((a, b) => a + b) /
                            mine.length)
                        .round();
              return LgRow(
                title: memberLabel(context, d.group.id, m),
                subtitle: avg == null
                    ? l.classesMemberNoWork
                    : l.classesMemberSummary(
                        mine.length,
                        d.assignments.length,
                        avg,
                      ),
                icon: Icons.person_outline_rounded,
                divider: i < students.length - 1,
                onTap: () => _editLocalName(d.group, m),
                trailing: IconButton(
                  tooltip: l.classesRemove,
                  icon: const Icon(Icons.person_remove_outlined),
                  onPressed: () => _remove(d.group, m),
                ),
              );
            }(),
        if (!inviteFirst) ...[
          LgSectionTitle(l.classesInviteMore),
          _InviteCard(group: d.group),
        ],
        const SizedBox(height: 24),
        LgButton.link(
          key: const ValueKey('group-delete'),
          label: l.classesDeleteGroup,
          icon: Icons.delete_outline_rounded,
          onPressed: () => _deleteGroup(d.group),
        ),
      ],
    );
  }

  /// Ustoz guruhni o'chiradi: topshiriqlar va natijalar ham o'chadi,
  /// shuning uchun tasdiq so'raladi.
  Future<void> _deleteGroup(StudyGroup g) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.classesDeleteGroupTitle(g.name),
      body: l.classesDeleteGroupBody,
      action: l.classesDeleteGroupAction,
    );
    if (!ok || !mounted) return;
    try {
      await context.services.backend.deleteGroup(g.id);
      if (mounted) context.pop();
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    }
  }

  /// Ustoz o'zi uchun belgi yozadi (masalan, real ism) — faqat shu
  /// qurilmada, serverga yuborilmaydi.
  Future<void> _editLocalName(StudyGroup g, GroupMember m) async {
    final l = AppLocalizations.of(context);
    final local = context.services.classroom;
    final c = TextEditingController(text: local.localName(g.id, m.userId));
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.classesLocalNameTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.classesLocalNameBody),
            const SizedBox(height: 8),
            TextField(
              controller: c,
              autofocus: true,
              maxLength: 60,
              decoration: InputDecoration(hintText: l.classesLocalNameHint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: Text(l.classesLocalNameSave),
          ),
        ],
      ),
    );
    c.dispose();
    if (value == null || !mounted) return;
    await local.setLocalName(g.id, m.userId, value);
    if (mounted) setState(() {});
  }

  Future<void> _remove(StudyGroup g, GroupMember m) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.classesRemoveTitle(memberLabel(context, g.id, m)),
      body: l.classesRemoveBody,
      action: l.classesRemoveAction,
    );
    if (!ok || !mounted) return;
    try {
      await context.services.backend.removeMember(g.id, m.userId);
      await _load();
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    }
  }

  Widget _student(_GroupData d) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final me = context.services.backend.userId;
    final mine = [
      for (final s in d.submissions)
        if (s.userId == me) s,
    ];
    final avg = mine.isEmpty
        ? null
        : (mine.map((s) => s.percent).reduce((a, b) => a + b) / mine.length)
              .round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ustoz ko'radigan nom: taxallus (yo'q bo'lsa — tartib raqami).
        // QR bilan darhol qo'shilgan talaba uni keyin shu yerda qo'yadi.
        LgRow(
          key: const ValueKey('group-nickname'),
          title: l.classesMyNickname,
          subtitle: d.group.myNickname ?? l.classesNoNickname,
          icon: Icons.badge_outlined,
          onTap: () => _editNickname(d.group),
        ),
        _planRow(d.group),
        if (d.assignments.isNotEmpty)
          LgPanel(
            soft: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LgEyebrow(l.classesMyProgress),
                Text(
                  l.classesDoneOf(mine.length, d.assignments.length),
                  style: text.titleLarge,
                ),
                const SizedBox(height: 10),
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mine.length / d.assignments.length,
                      minHeight: 6,
                      color: p.brand,
                      backgroundColor: p.paper,
                    ),
                  ),
                ),
                if (avg != null) ...[
                  const SizedBox(height: 8),
                  Text(l.classesAverage(avg), style: text.bodyMedium),
                ],
              ],
            ),
          ),
        LgSectionTitle(l.classesAssignments),
        if (d.assignments.isEmpty)
          LgStateView(
            kind: StateKind.empty,
            title: l.classesNoAssignmentsStudent,
            message: l.classesNoAssignmentsStudentBody,
          )
        else
          for (final (i, a) in d.assignments.indexed)
            () {
              final sub = mine.where((s) => s.assignmentId == a.id).firstOrNull;
              final status = _statusFor(context, a, sub);
              final (label, tone) = switch (status) {
                _StudentStatus.done => (
                  l.classesStatusDone(sub!.score, sub.total),
                  LgTone.brand,
                ),
                _StudentStatus.inProgress => (
                  l.classesStatusInProgress,
                  LgTone.warning,
                ),
                _StudentStatus.pending => (
                  l.classesStatusPending,
                  LgTone.warning,
                ),
                _StudentStatus.overdue => (
                  l.classesStatusOverdue,
                  LgTone.neutral,
                ),
                _StudentStatus.closed => (
                  l.classroomStatusTestDone,
                  LgTone.neutral,
                ),
                _StudentStatus.fresh => (l.classesStatusNew, LgTone.warning),
              };
              return _AssignmentTile(
                assignment: a,
                icon: status == _StudentStatus.done
                    ? Icons.task_alt_rounded
                    : Icons.assignment_outlined,
                tag: LgTag(label, tone: tone),
                divider: i < d.assignments.length - 1,
                onTap: () => _open('/learn/classes/g/${d.group.id}/a/${a.id}'),
              );
            }(),
        const SizedBox(height: 24),
        Text(l.classesStudentNote, style: text.bodySmall),
        const SizedBox(height: 8),
        LgButton.link(
          label: l.classesLeave,
          icon: Icons.logout_rounded,
          onPressed: () => _leave(d.group),
        ),
      ],
    );
  }

  Future<void> _editNickname(StudyGroup g) async {
    final l = AppLocalizations.of(context);
    final alias = await showDialog<String>(
      context: context,
      builder: (context) => _NicknameDialog(initial: g.myNickname ?? ''),
    );
    if (alias == null || !mounted) return;
    try {
      await context.services.backend.setMyAlias(
        g.id,
        alias.isEmpty ? null : alias,
      );
      if (!mounted) return;
      showSnack(context, l.classesNicknameSaved);
      await _load();
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    }
  }

  Future<void> _leave(StudyGroup g) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.classesLeaveTitle,
      body: l.classesLeaveBody,
      action: l.classesLeaveAction,
    );
    if (!ok || !mounted) return;
    try {
      await context.services.backend.leaveGroup(g.id);
      if (mounted) context.pop();
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    }
  }
}

/// Taxallusni o'zgartirish: server qoidasi bilan bir xil tekshiruv; bo'sh —
/// tartib raqami. Natija — normallashtirilgan taxallus ('' — o'chirish).
class _NicknameDialog extends StatefulWidget {
  const _NicknameDialog({required this.initial});

  final String initial;

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late final _c = TextEditingController(text: widget.initial);
  bool _tried = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String? _error(AppLocalizations l) {
    if (!_tried) return null;
    final n = normalizeNickname(_c.text).length;
    if (n != 0 && (n < 2 || n > 24)) return l.classesLengthError(2, 24);
    return nicknameAllowed(_c.text) ? null : l.classesNicknameInvalid;
  }

  void _save() {
    setState(() => _tried = true);
    if (_error(AppLocalizations.of(context)) != null) return;
    Navigator.of(context).pop(normalizeNickname(_c.text));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.classesMyNickname),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('nickname-field'),
            controller: _c,
            autofocus: true,
            maxLength: 24,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l.classesDisplayNameHint,
              errorText: _error(l),
              errorMaxLines: 4,
            ),
          ),
          Text(
            l.classesNicknameNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          key: const ValueKey('nickname-save'),
          onPressed: _save,
          child: Text(MaterialLocalizations.of(context).saveButtonLabel),
        ),
      ],
    );
  }
}

/// Topshiriq qatori: nom, ma'lumot va holat belgisi pastma-past (tor ekran va
/// katta shriftda nom siqilib qolmaydi).
class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({
    required this.assignment,
    required this.icon,
    required this.tag,
    required this.divider,
    required this.onTap,
  });

  final GroupAssignment assignment;
  final IconData icon;
  final Widget? tag;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider
            ? Border(bottom: BorderSide(color: p.line.withValues(alpha: 0.7)))
            : null,
      ),
      child: LgPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: p.soft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 21, color: p.brand),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(assignment.title, style: text.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      _assignmentMeta(context, assignment),
                      style: text.bodySmall!.copyWith(fontSize: 13),
                    ),
                    if (tag != null) ...[const SizedBox(height: 8), tag!],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: p.sub,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final code = group.joinCode ?? '';
    final spaced = code.length == 8
        ? '${code.substring(0, 4)} ${code.substring(4)}'
        : code;
    Future<void> copy(String value) async {
      await Clipboard.setData(ClipboardData(text: value));
      if (context.mounted) showSnack(context, l.classesCopied);
    }

    return LgPanel(
      soft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgEyebrow(l.classesInviteTitle),
          Semantics(
            label: '${l.classesInviteTitle}: ${code.split('').join(' ')}',
            // Kod bitta qatorda: katta shriftda ham bo'linmaydi (kichrayadi).
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  spaced,
                  maxLines: 1,
                  softWrap: false,
                  style: text.displaySmall!.copyWith(
                    fontSize: 34,
                    letterSpacing: 3,
                    color: p.brand,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            // Telefon kamerasi havolani ochadi (site/j/: kod + “Ilovada
            // ochish”); ilovada “Havolani qo'yish” ham shu havolani o'qiydi.
            child: QrCodeView(
              key: const ValueKey('invite-qr'),
              data: inviteUrl(code),
              semanticLabel: l.classesQrLabel(code.split('').join(' ')),
            ),
          ),
          const SizedBox(height: 10),
          Text(l.classesInviteBody, style: text.bodyMedium),
          const SizedBox(height: 14),
          LgButton(
            label: l.classesCopyCode,
            icon: Icons.copy_rounded,
            onPressed: () => copy(code),
          ),
          const SizedBox(height: 8),
          LgButton.secondary(
            label: l.classesCopyInvite,
            icon: Icons.ios_share_rounded,
            onPressed: () => copy(
              '${l.classesInviteText(group.name, code)}\n${inviteUrl(code)}',
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------- topshiriq

/// “Test QR”: talaba skanerlaydi → kiradi → taxallus → shu test ochiladi.
/// Katta QR (proyektorda ham o'qiladi), kod va havolani nusxalash.
Future<void> showTestQr(
  BuildContext context,
  StudyGroup group,
  String code,
  GroupAssignment a,
) {
  final l = AppLocalizations.of(context);
  final url = inviteUrl(code, assignmentId: a.id);
  final spaced = '${code.substring(0, 4)} ${code.substring(4)}';
  return showDialog<void>(
    context: context,
    builder: (context) {
      final text = Theme.of(context).textTheme;
      final side = (MediaQuery.sizeOf(context).shortestSide * 0.62).clamp(
        180.0,
        420.0,
      );
      return AlertDialog(
        key: const ValueKey('test-qr-dialog'),
        title: Text(a.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrCodeView(
                data: url,
                size: side,
                semanticLabel: l.classesQrLabel(code.split('').join(' ')),
              ),
              const SizedBox(height: 12),
              Text(
                spaced,
                style: text.headlineMedium!.copyWith(
                  letterSpacing: 3,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(group.name, style: text.bodyMedium),
              const SizedBox(height: 10),
              Text(l.classesTestQrBody, style: text.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) showSnack(context, l.classesCopied);
            },
            child: Text(l.classesInviteLink),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionClose),
          ),
        ],
      );
    },
  );
}

/// Javoblarni yuborish natijasi.
enum SubmitOutcome { sent, network, rejected, failed }

/// Topshiriq javoblarini serverga yuboradi. Qabul qilinsa yoki server rad
/// etsa (vaqt/muddat tugagan, avval topshirilgan) lokal nusxa o'chiriladi;
/// tarmoq xatosida saqlanib qoladi — keyin qayta yuboriladi.
Future<SubmitOutcome> submitAssignmentSession(
  AppServices services,
  ExamSession s,
) async {
  try {
    await services.backend.submitAssignment(
      s.assignmentId!,
      s.submissionAnswers(),
      questionIds: s.submissionQuestionIds(),
    );
    await recordExamProgress(services, s);
    await services.exams.removeAssignment(s.assignmentId!);
    return SubmitOutcome.sent;
  } on BackendException catch (e) {
    switch (e.failure) {
      case BackendFailure.network:
        return SubmitOutcome.network;
      case BackendFailure.invalid || BackendFailure.forbidden:
        await services.exams.removeAssignment(s.assignmentId!);
        return SubmitOutcome.rejected;
      default:
        return SubmitOutcome.failed;
    }
  }
}

void _reportSubmit(BuildContext context, SubmitOutcome o) {
  final l = AppLocalizations.of(context);
  final msg = switch (o) {
    SubmitOutcome.sent => l.classesSubmitted,
    SubmitOutcome.network => l.classesSubmitNetwork,
    SubmitOutcome.rejected => l.classesSubmitRejected,
    SubmitOutcome.failed => l.errGeneric,
  };
  showSnack(context, msg);
}

class _AssignmentData {
  _AssignmentData({
    required this.group,
    required this.assignment,
    required this.submissions,
    required this.members,
    required this.key,
    this.started = const {},
  });

  final StudyGroup group;
  final GroupAssignment assignment;
  final List<GroupSubmission> submissions;
  final List<GroupMember> members;

  /// Ustoz: testni boshlagan (hali topshirmagan bo'lishi mumkin) talabalar —
  /// katta ekrandagi “Yechmoqda” bilan bir xil manba (progress endpoint).
  final Set<String> started;

  /// Faqat ustozda.
  final List<int>? key;
}

Future<_AssignmentData?> _loadAssignment(
  BuildContext context,
  String groupId,
  String assignmentId,
) async {
  final services = context.services;
  final backend = services.backend;
  final group = (await backend.myGroups())
      .where((g) => g.id == groupId)
      .firstOrNull;
  if (group == null) return null;
  final a = (await backend.assignments(groupId))
      .where((a) => a.id == assignmentId)
      .firstOrNull;
  if (a == null) return null;
  // Mavzu testida toifa banki savollari ham bo'lishi mumkin (sahifa
  // [_questionsGate] bilan bank yuklanishini kutadi).
  if (!_packOnly(services.content.pack, a)) {
    unawaited(services.toifa.ensureLoaded());
  }
  return _AssignmentData(
    group: group,
    assignment: a,
    submissions: await backend.submissions(assignmentId),
    members: group.isTeacher ? await backend.groupMembers(groupId) : const [],
    key: group.isTeacher ? await backend.assignmentKey(assignmentId) : null,
    started: group.isTeacher
        ? await _startedOf(backend, assignmentId)
        : const {},
  );
}

/// Boshlaganlar (progress); xato bo'lsa — bo'sh (natijalar baribir ko'rinadi).
Future<Set<String>> _startedOf(LabBackend backend, String assignmentId) async {
  try {
    return {
      for (final a in await backend.assignmentProgress(assignmentId)) a.userId,
    };
  } on Object {
    return const {};
  }
}

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
  });

  final String groupId;
  final String assignmentId;

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen>
    with _AccountReload {
  final _data = _Loaded<_AssignmentData>();
  bool _missing = false;
  bool _busy = false;
  bool _all = false;

  /// Ustoz natijalari ochiq turganda — har [liveEvery] da jim yangilanadi.
  static const liveEvery = Duration(seconds: 10);
  Timer? _live;

  String get _base =>
      '/learn/classes/g/${widget.groupId}/a/${widget.assignmentId}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _live?.cancel();
    super.dispose();
  }

  /// [quiet] — jonli yangilanish: yuklanish holati va tarmoq xatosi
  /// ko'rsatilmaydi (oldingi natijalar qoladi).
  Future<void> _load({bool quiet = false}) async {
    if (!mounted || !_ready(context)) return;
    if (!quiet) {
      setState(() {
        _data
          ..loading = true
          ..error = null;
      });
    }
    try {
      final d = await _loadAssignment(
        context,
        widget.groupId,
        widget.assignmentId,
      );
      if (!mounted) return;
      setState(() {
        _missing = d == null;
        _data
          ..data = d
          ..error = null;
      });
      _syncLive(d);
      if (d != null && !d.group.isTeacher) await _settleExpired(d);
    } on Object catch (e) {
      if (mounted && !quiet) setState(() => _data.error = e);
    } finally {
      if (mounted && !quiet) setState(() => _data.loading = false);
    }
  }

  /// Faqat ustoz va hali yakunlanmagan test uchun.
  void _syncLive(_AssignmentData? d) {
    final on = d != null && d.group.isTeacher && !d.assignment.closed;
    if (!on) {
      _live?.cancel();
      _live = null;
    } else {
      _live ??= Timer.periodic(liveEvery, (_) => _load(quiet: true));
    }
  }

  /// Ilova yopiq paytda vaqti tugagan topshiriq — javoblar o'zi yuboriladi.
  Future<void> _settleExpired(_AssignmentData d) async {
    final services = context.services;
    final me = services.backend.userId;
    final local = services.exams.assignmentSession(widget.assignmentId, me);
    if (local == null ||
        local.finished ||
        !local.expired(services.exams.now()) ||
        d.submissions.any((s) => s.userId == me)) {
      return;
    }
    await services.exams.finishAssignment(local, timedOut: true);
    final outcome = await submitAssignmentSession(services, local);
    if (!mounted) return;
    _reportSubmit(context, outcome);
    if (outcome != SubmitOutcome.network) {
      final fresh = await _loadAssignment(
        context,
        widget.groupId,
        widget.assignmentId,
      );
      if (mounted) setState(() => _data.data = fresh);
    }
  }

  Future<void> _start(GroupAssignment a, ContentPack pack) async {
    final services = context.services;
    final byId = _byId(context, pack);
    setState(() => _busy = true);
    try {
      final start = await services.backend.startAssignment(a.id);
      final exams = services.exams;
      final localNow = exams.now();
      // Server soati bo'yicha boshlangan vaqt qurilma soatiga o'tkaziladi.
      final startedAt = start.startedAt.add(
        localNow.difference(start.serverNow),
      );
      final limit = a.timeLimitMinutes == null
          ? null
          : Duration(minutes: a.timeLimitMinutes!);
      final due = a.dueAt?.add(localNow.difference(start.serverNow));
      // Variantli test: shu talabaning to'plami (server bergani; ilova ham
      // aynan shuni hisoblaydi — D-66).
      final ids =
          start.questionIds ?? a.questionIdsFor(services.backend.userId);
      final questions = [for (final id in ids) byId[id]!];
      await exams.startAssignment(
        ExamSession.build(
          id: exams.newId(),
          mode: ExamMode.assignment,
          questions: questions,
          // Rasmiy (toifa) savollarda variantlar tartibi saqlanadi
          // (ExamSession.build har savol uchun o'zi hal qiladi).
          sourceId: _packOnly(pack, a)
              ? PackQuestionSource.sourceId
              : ClassQuestionSource.sourceId,
          random: exams.random,
          startedAt: startedAt,
          limit: limit,
          hardDeadline: due,
          title: a.title,
          assignmentId: a.id,
          groupId: a.groupId,
          userId: services.backend.userId,
        ),
      );
      if (mounted) await context.push('$_base/run');
      if (mounted) await _load();
    } on Object catch (e) {
      if (mounted) {
        showSnack(context, classesErrorText(e, AppLocalizations.of(context)));
        await _load();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Ustoz testni talaba ko'rinishida sinaydi: xuddi shu savollar va vaqt
  /// cheklovi, lekin sessiya faqat xotirada — serverga hech narsa
  /// yuborilmaydi va natijalar ro'yxatiga tushmaydi.
  Future<void> _preview(GroupAssignment a, ContentPack pack) async {
    final services = context.services;
    final l = AppLocalizations.of(context);
    final byId = _byId(context, pack);
    final questions = [
      for (final id in a.questionIdsFor(services.backend.userId)) ?byId[id],
    ];
    if (questions.isEmpty) {
      showSnack(context, l.classesOutdatedPack(a.questionCount));
      return;
    }
    final exams = services.exams;
    final session = ExamSession.build(
      id: exams.newId(),
      mode: ExamMode.exam,
      questions: questions,
      sourceId: _packOnly(pack, a)
          ? PackQuestionSource.sourceId
          : ClassQuestionSource.sourceId,
      random: exams.random,
      startedAt: exams.now(),
      limit: a.timeLimitMinutes == null
          ? null
          : Duration(minutes: a.timeLimitMinutes!),
      title: a.title,
    );
    final done = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<ExamSession>(
        builder: (context) => _AssignmentPreviewRun(session: session),
      ),
    );
    if (done != null && mounted) {
      showSnack(
        context,
        l.classesPreviewResult(done.correctCount, done.length),
      );
    }
  }

  /// Ustoz testni yakunlaydi: yangi urinish yo'q; “muddat tugagach”
  /// tanlangan bo'lsa — to'g'ri javoblar talabalarga darhol ochiladi.
  Future<void> _close(GroupAssignment a) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.classroomTestFinishTitle,
      body: l.classroomTestFinishBody,
      action: l.classroomTestFinish,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await context.services.backend.closeAssignment(a.id);
      if (mounted) showSnack(context, l.classroomStatusTestDone);
    } on Object catch (e) {
      if (mounted) showSnack(context, classesErrorText(e, l));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) await _load();
  }

  Future<void> _resend(ExamSession s) async {
    setState(() => _busy = true);
    final outcome = await submitAssignmentSession(context.services, s);
    if (!mounted) return;
    _reportSubmit(context, outcome);
    setState(() => _busy = false);
    await _load();
  }

  @override
  void resetForAccount() {
    _data
      ..data = null
      ..error = null;
    _missing = false;
  }

  @override
  Future<void> reloadForAccount() => _load();

  @override
  Widget build(BuildContext context) => watchAccount(_page);

  Widget _page(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _data.data;
    return RefreshIndicator(
      onRefresh: _load,
      notificationPredicate: (n) => n.depth == 0 && d?.group.isTeacher == true,
      child: _pageBody(context, l, d),
    );
  }

  Widget _pageBody(
    BuildContext context,
    AppLocalizations l,
    _AssignmentData? d,
  ) {
    return LgPage(
      title: d?.assignment.title ?? l.classesAssignments,
      // Uzun mavzu nomi 4 qator olib, “Test QR”ni pastga surardi.
      titleMaxLines: 2,
      subtitle: d == null ? null : _assignmentMeta(context, d.assignment),
      showProfile: false,
      children: [
        ClassesGate(
          child: _missing
              ? LgStateView(
                  kind: StateKind.empty,
                  title: l.classesAssignmentMissing,
                  actionLabel: l.classesBackToList,
                  onAction: () => context.go('/learn/classes'),
                )
              : _loadState(
                  context,
                  _data,
                  _load,
                  (d) => _questionsGate(
                    d.assignment,
                    (context, pack) => ListenableBuilder(
                      listenable: context.services.exams,
                      builder: (context, _) => d.group.isTeacher
                          ? _teacher(d, pack)
                          : _student(d, pack),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _metrics(GroupAssignment a, {List<Widget> extra = const []}) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        ...extra,
        LgMetric(label: l.classesMetricQuestions, value: '${a.questionCount}'),
        LgMetric(
          label: l.classesMetricLimit,
          value: a.timeLimitMinutes == null
              ? l.classesNoLimit
              : l.examMinutes(a.timeLimitMinutes!),
        ),
        LgMetric(
          label: l.classesMetricDue,
          value: a.dueAt == null
              ? l.classesDueNone
              : formatWhen(a.dueAt!, context),
        ),
      ],
    );
  }

  Widget _student(_AssignmentData d, ContentPack pack) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    final a = d.assignment;
    final me = services.backend.userId;
    final mine = d.submissions.where((s) => s.userId == me).firstOrNull;
    if (mine != null) return _studentResult(a, mine, pack);
    final byId = _byId(context, pack);
    final myIds = a.questionIdsFor(me);
    final missing = myIds.where((id) => !byId.containsKey(id)).length;
    final local = services.exams.assignmentSession(a.id, me);
    final status = _statusFor(context, a, mine);
    final Widget action = switch (status) {
      _StudentStatus.pending => LgStateView(
        kind: StateKind.offline,
        title: l.classesPendingTitle,
        message: l.classesPendingBody,
        actionLabel: l.classesResend,
        onAction: _busy ? null : () => _resend(local!),
      ),
      _StudentStatus.inProgress => LgPanel(
        soft: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgEyebrow(l.classesStatusInProgress),
            Text(
              local!.remaining(services.exams.now()) == null
                  ? l.examAnsweredOf(local.answeredCount, local.length)
                  // Vaqt chegarasiz: muddat sana bilan, taymer emas.
                  : deadlineShownAsDate(local, services.exams.now()) != null
                  ? '${l.examAnsweredOf(local.answeredCount, local.length)} · '
                        '${l.examDeadlineAt(formatDeadline(local.deadline!, context))}'
                  : l.examActiveBody(
                      local.answeredCount,
                      local.length,
                      formatClock(local.remaining(services.exams.now())!),
                    ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            LgButton(
              label: l.examResume,
              icon: Icons.play_arrow_rounded,
              onPressed: () async {
                await context.push('$_base/run');
                if (mounted) await _load();
              },
            ),
          ],
        ),
      ),
      _StudentStatus.overdue => LgStateView(
        kind: StateKind.unavailable,
        title: l.classesOverdueTitle,
        message: l.classesOverdueBody,
      ),
      _StudentStatus.closed => LgStateView(
        key: const ValueKey('assignment-closed'),
        kind: StateKind.unavailable,
        title: l.classroomStatusTestDone,
        message: l.classesOverdueBody,
      ),
      _ when missing > 0 => LgNotice(
        l.classesOutdatedPack(missing),
        kind: NoticeKind.error,
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (myIds.any((id) => byId[id]?.isDraft ?? false))
            LgNotice(l.examPracticeNotice, kind: NoticeKind.info),
          LgNotice(
            a.timeLimitMinutes == null
                ? l.classesStartNoticeNoLimit
                : l.classesStartNotice(a.timeLimitMinutes!),
            kind: NoticeKind.info,
          ),
          const SizedBox(height: 12),
          LgButton(
            label: l.classesStart,
            icon: Icons.play_arrow_rounded,
            busy: _busy,
            onPressed: () => _start(a, pack),
          ),
        ],
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_metrics(a), const SizedBox(height: 16), action],
    );
  }

  Widget _studentResult(
    GroupAssignment a,
    GroupSubmission mine,
    ContentPack pack,
  ) {
    final l = AppLocalizations.of(context);
    final byId = _byId(context, pack);
    final ids = a.questionIdsOf(mine);
    bool isRight(int i) =>
        mine.correct?[i] ??
        (byId[ids[i]]?.correct.contains(mine.answers[i]) ?? false);
    final all = [for (var i = 0; i < ids.length; i++) i];
    final wrong = [
      for (final i in all)
        if (!isRight(i)) i,
    ];
    final shown = _all ? all : wrong;
    final unanswered = mine.answers.where((x) => x < 0).length;
    final hero = ScoreHero(
      correct: mine.score,
      total: mine.total,
      wrong: mine.total - mine.score - unanswered,
      unanswered: unanswered,
      caption: l.classesSubmittedAt(formatWhen(mine.submittedAt, context)),
      badges: [LgTag(l.classesServerScore, icon: Icons.verified_outlined)],
    );
    // Ustoz “muddat tugagach” tanlagan: to'g'ri javoblar hozircha yopiq.
    // Server (`correct: null`) hal qiladi: qurilma soati oldinda bo'lsa ham
    // javoblar lokal kalitdan ochib yuborilmaydi.
    final hidden =
        !a.answersOpen(context.services.exams.now()) ||
        (a.revealAfterDue && mine.correct == null);
    if (hidden && a.dueAt != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          hero,
          LgNotice(
            l.topicTestAnswersLater(formatWhen(a.dueAt!, context)),
            kind: NoticeKind.info,
          ),
        ],
      );
    }
    final deck = deckOfAssignment(context, a);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hero,
        LgSectionTitle(l.examAnalysis),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            LgChoiceChip(
              label: l.examFilterMistakes(wrong.length),
              selected: !_all,
              onTap: () => setState(() => _all = false),
            ),
            LgChoiceChip(
              label: l.examFilterAll(all.length),
              selected: _all,
              onTap: () => setState(() => _all = true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          LgStateView(kind: StateKind.success, title: l.quizNoMistakes)
        else
          for (final i in shown)
            () {
              final q = byId[ids[i]];
              final chosen = i < mine.answers.length && mine.answers[i] >= 0
                  ? mine.answers[i]
                  : null;
              final card = ExamReviewCard(
                number: i + 1,
                question: q,
                chosen: chosen == null ? null : [chosen],
                // Server “to'g'ri” desa — tanlangan javob to'g'ri javobdir.
                correct: isRight(i) && chosen != null
                    ? [chosen]
                    : (q?.correct.toList() ?? const []),
              );
              if (deck == null || q == null || isRight(i)) return card;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  card,
                  SlideLink(question: q, deck: deck),
                ],
              );
            }(),
      ],
    );
  }

  Widget _teacher(_AssignmentData d, ContentPack pack) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final a = d.assignment;
    final byId = _byId(context, pack);
    final students = [
      for (final m in d.members)
        if (!m.isTeacher) m,
    ];
    final subs = {
      for (final s in d.submissions)
        if (students.any((m) => m.userId == s.userId)) s.userId: s,
    };
    final avg = subs.isEmpty
        ? null
        : (subs.values.map((s) => s.percent).reduce((a, b) => a + b) /
                  subs.length)
              .round();
    final rows = [...students]
      ..sort((x, y) {
        final sx = subs[x.userId];
        final sy = subs[y.userId];
        if (sx == null || sy == null) {
          return sx == null ? (sy == null ? 0 : 1) : -1;
        }
        return sy.percent.compareTo(sx.percent);
      });
    // Savol bo'yicha — faqat savol tushgan talabalar orasida (D-66).
    final tally = tallyQuestions(a, subs.values, d.key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // “Test QR” va “Katta ekran” — darsda birinchi kerak bo'ladigan
        // amallar: ko'rsatkichlardan oldin, ekran tepasida.
        if (d.group.joinCode case final code?) ...[
          Row(
            children: [
              Expanded(
                child: LgButton.secondary(
                  key: const ValueKey('assignment-test-qr'),
                  label: l.classesTestQr,
                  icon: Icons.qr_code_2_rounded,
                  onPressed: () => showTestQr(context, d.group, code, a),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LgButton.secondary(
                  key: const ValueKey('assignment-board'),
                  label: l.boardOpen,
                  icon: Icons.tv_rounded,
                  onPressed: () => context.push('$_base/board'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        _metrics(
          a,
          extra: [
            LgMetric(
              label: l.classesMetricSubmitted,
              value: '${subs.length} / ${students.length}',
            ),
            LgMetric(
              label: l.classesMetricAverage,
              value: avg == null ? '—' : '$avg%',
            ),
          ],
        ),
        if (a.isVariant) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              LgTag(
                l.variantLabel,
                key: const ValueKey('assignment-variant'),
                icon: Icons.shuffle_rounded,
                tone: LgTone.brand,
              ),
              Text(
                l.variantPerStudent(a.questionCount, a.questionIds.length),
                style: text.bodySmall,
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        // Ustoz o'z guruhiga talaba bo'lib qo'shila olmaydi (server rol
        // bo'yicha): testni talaba ko'rinishida shu yerda sinab ko'radi.
        LgButton.secondary(
          key: const ValueKey('assignment-preview'),
          label: l.classesPreviewAsStudent,
          icon: Icons.visibility_outlined,
          onPressed: () => _preview(a, pack),
        ),
        const SizedBox(height: 6),
        Text(l.classesPreviewNote, style: text.bodySmall),
        const SizedBox(height: 10),
        if (a.closed)
          LgNotice(
            l.classroomStatusTestDone,
            key: const ValueKey('assignment-closed'),
            kind: NoticeKind.info,
          )
        else ...[
          LgButton.secondary(
            key: const ValueKey('assignment-close'),
            label: l.classroomTestFinish,
            icon: Icons.stop_circle_outlined,
            busy: _busy,
            onPressed: () => _close(a),
          ),
          const SizedBox(height: 6),
          Text(l.classesLiveNote, style: text.bodySmall),
        ],
        LgSectionTitle(l.classesResults),
        if (students.isEmpty)
          Text(l.classesNoStudents, style: text.bodyMedium)
        else
          LgPanel(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.classesColStudent,
                            style: text.labelMedium,
                          ),
                        ),
                        Text(l.classesColScore, style: text.labelMedium),
                      ],
                    ),
                  ),
                ),
                for (final m in rows)
                  _ResultRow(
                    name: memberLabel(context, widget.groupId, m),
                    submission: subs[m.userId],
                    solving: d.started.contains(m.userId),
                    onTap: subs[m.userId] == null
                        ? null
                        : () => context.push('$_base/s/${m.userId}'),
                  ),
              ],
            ),
          ),
        if (subs.isNotEmpty) ...[
          LgSectionTitle(l.topicTestDistribution),
          _Distribution(percents: [for (final s in subs.values) s.percent]),
          ..._hardestQuestions(context, d, byId, tally),
        ],
        LgSectionTitle(l.classesByQuestion),
        if (subs.isEmpty)
          Text(l.classesByQuestionEmpty, style: text.bodyMedium)
        else
          for (final t in tally)
            if (t.received > 0 || !a.isVariant)
              () {
                final i = t.index;
                final q = byId[t.questionId];
                final wrong = t.wrong;
                final rate = t.rate;
                final key = d.key?[i];
                return LgPanel(
                  padding: const EdgeInsets.all(16),
                  child: Semantics(
                    container: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: LgEyebrow(l.examQuestionN(i + 1))),
                            LgTag(
                              l.classesWrongOf(wrong, t.received),
                              tone: wrong == 0 ? LgTone.brand : LgTone.warning,
                            ),
                          ],
                        ),
                        if (a.isVariant) ...[
                          const SizedBox(height: 4),
                          Text(
                            l.variantReceived(t.received),
                            key: ValueKey('received-$i'),
                            style: text.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          q?.prompt(lang) ?? l.examQuestionMissing,
                          style: text.bodyMedium,
                        ),
                        if (q != null &&
                            key != null &&
                            key < q.optionCount) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${l.quizCorrectAnswer}: ${q.option(key, lang)}',
                            style: text.bodySmall!.copyWith(color: p.brand),
                          ),
                        ],
                        const SizedBox(height: 10),
                        ExcludeSemantics(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: rate,
                              minHeight: 6,
                              color: p.brand,
                              backgroundColor: p.amberBg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }(),
      ],
    );
  }
}

/// Eng ko'p xato qilingan savollar (5 tagacha) va (deck ma'lum bo'lsa)
/// tegishli slayd havolasi.
List<Widget> _hardestQuestions(
  BuildContext context,
  _AssignmentData d,
  Map<String, ExamQuestion> byId,
  List<QuestionTally> tally,
) {
  final l = AppLocalizations.of(context);
  final text = Theme.of(context).textTheme;
  final lang = Localizations.localeOf(context).languageCode;
  final a = d.assignment;
  final wrong = hardestTallies(tally);
  if (wrong.isEmpty) return const [];
  final deck = deckOfAssignment(context, a);
  return [
    LgSectionTitle(l.topicTestHardest),
    for (final t in wrong.take(5))
      () {
        final i = t.index;
        final q = byId[t.questionId];
        return LgPanel(
          key: ValueKey('hardest-$i'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: LgEyebrow(l.examQuestionN(i + 1))),
                  LgTag(
                    l.classesWrongOf(t.wrong, t.received),
                    tone: LgTone.warning,
                  ),
                ],
              ),
              if (a.isVariant) ...[
                const SizedBox(height: 4),
                Text(l.variantReceived(t.received), style: text.bodySmall),
              ],
              const SizedBox(height: 6),
              Text(
                q?.prompt(lang) ?? l.examQuestionMissing,
                style: text.bodyMedium,
              ),
              if (q != null && deck != null)
                SlideLink(question: q, deck: deck)
              else
                const SizedBox(height: 10),
            ],
          ),
        );
      }(),
  ];
}

/// Natijalar taqsimoti: foiz oraliqlari bo'yicha talabalar soni.
class _Distribution extends StatelessWidget {
  const _Distribution({required this.percents});

  final List<int> percents;

  static const _bands = [(90, 100), (70, 89), (50, 69), (0, 49)];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final total = percents.length;
    return LgPanel(
      key: const ValueKey('score-distribution'),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (from, to) in _bands)
            () {
              final n = percents.where((x) => x >= from && x <= to).length;
              return Semantics(
                label: '$from–$to%: ${l.topicTestStudents(n)}',
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text('$from–$to%', style: text.labelMedium),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : n / total,
                            minHeight: 8,
                            color: from >= 50 ? p.brand : p.amber,
                            backgroundColor: p.paper,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$n',
                          textAlign: TextAlign.end,
                          style: text.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }(),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.name,
    required this.submission,
    required this.onTap,
    this.solving = false,
  });

  final String name;
  final GroupSubmission? submission;
  final VoidCallback? onTap;

  /// Boshlagan, hali topshirmagan (katta ekrandagi kabi “Yechmoqda”).
  final bool solving;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final s = submission;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinTap + 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.titleSmall),
                  if (s != null)
                    Text(
                      formatWhen(s.submittedAt, context),
                      style: text.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (s == null)
              Text(
                solving ? l.boardStarted : l.classesNotSubmitted,
                style: text.bodySmall!.copyWith(
                  color: solving ? p.brand : p.sub,
                  fontWeight: solving ? FontWeight.w600 : null,
                ),
              )
            else
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${s.score}/${s.total}  ',
                      style: text.titleSmall,
                    ),
                    TextSpan(
                      text: '${s.percent}%',
                      style: text.titleSmall!.copyWith(
                        color: s.percent >= 50 ? p.brand : p.amber,
                      ),
                    ),
                  ],
                ),
              ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: p.sub, size: 22),
          ],
        ),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line.withValues(alpha: 0.7))),
      ),
      child: onTap == null
          ? Semantics(container: true, child: row)
          : LgPressable(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: row,
            ),
    );
  }
}

/// Ustoz: bitta talabaning javoblari (server kaliti bo'yicha).
class StudentResultScreen extends StatefulWidget {
  const StudentResultScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
    required this.userId,
  });

  final String groupId;
  final String assignmentId;
  final String userId;

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen>
    with _AccountReload {
  final _data = _Loaded<_AssignmentData>();
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted || !_ready(context)) return;
    setState(() {
      _data
        ..loading = true
        ..error = null;
    });
    try {
      final d = await _loadAssignment(
        context,
        widget.groupId,
        widget.assignmentId,
      );
      if (!mounted) return;
      setState(() {
        _missing = d == null || !d.group.isTeacher;
        _data.data = d;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _data.error = e);
    } finally {
      if (mounted) setState(() => _data.loading = false);
    }
  }

  @override
  void resetForAccount() {
    _data
      ..data = null
      ..error = null;
    _missing = false;
  }

  @override
  Future<void> reloadForAccount() => _load();

  @override
  Widget build(BuildContext context) => watchAccount(_page);

  Widget _page(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _data.data;
    final member = d?.members
        .where((m) => m.userId == widget.userId)
        .firstOrNull;
    final s = d?.submissions
        .where((s) => s.userId == widget.userId)
        .firstOrNull;
    return LgPage(
      title: member == null
          ? l.classesResults
          : memberLabel(context, widget.groupId, member),
      subtitle: d?.assignment.title,
      showProfile: false,
      children: [
        ClassesGate(
          child: _missing || (d != null && (s == null || d.key == null))
              ? LgStateView(kind: StateKind.empty, title: l.classesNotSubmitted)
              : _loadState(
                  context,
                  _data,
                  _load,
                  (d) => _questionsGate(d.assignment, (context, pack) {
                    final byId = _byId(context, pack);
                    final a = d.assignment;
                    final unanswered = s!.answers.where((x) => x < 0).length;
                    final ids = a.questionIdsOf(s);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ScoreHero(
                          title: l.classesStudentResultTitle,
                          correct: s.score,
                          total: s.total,
                          wrong: s.total - s.score - unanswered,
                          unanswered: unanswered,
                          caption: l.classesSubmittedAt(
                            formatWhen(s.submittedAt, context),
                          ),
                        ),
                        LgSectionTitle(l.examAnalysis),
                        for (var i = 0; i < ids.length; i++)
                          ExamReviewCard(
                            number: i + 1,
                            question: byId[ids[i]],
                            chosen: i < s.answers.length && s.answers[i] >= 0
                                ? [s.answers[i]]
                                : null,
                            // Kalit hovuz tartibida (variantli testda ham).
                            correct: [d.key![a.questionIds.indexOf(ids[i])]],
                            chosenLabel: l.classesStudentAnswer,
                          ),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }
}

/// Topshiriqni yechish (to'liq ekran, imtihon UI'si). Yakunlanganda
/// javoblar serverga yuboriladi; internet bo'lmasa qurilmada qoladi.
/// Ustozning “talaba ko'rinishida sinash” sahifasi: [ExamRunner] xuddi
/// talabadagidek, lekin yakunda faqat natija qaytariladi (yuborilmaydi).
class _AssignmentPreviewRun extends StatelessWidget {
  const _AssignmentPreviewRun({required this.session});

  final ExamSession session;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ExamRunner(
      key: const ValueKey('assignment-preview-run'),
      session: session,
      title:
          '${session.title ?? l.classesAssignments} · '
          '${l.classesPreviewAsStudent}',
      onFinish: ({required timedOut}) async {
        session.finish(context.services.exams.now(), timedOut: timedOut);
        Navigator.of(context).pop(session);
      },
    );
  }
}

class AssignmentRunScreen extends StatefulWidget {
  const AssignmentRunScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
  });

  final String groupId;
  final String assignmentId;

  @override
  State<AssignmentRunScreen> createState() => _AssignmentRunScreenState();
}

class _AssignmentRunScreenState extends State<AssignmentRunScreen> {
  bool _sending = false;

  Future<void> _finish(ExamSession s, {required bool timedOut}) async {
    final services = context.services;
    setState(() => _sending = true);
    await services.exams.finishAssignment(s, timedOut: timedOut);
    final outcome = await submitAssignmentSession(services, s);
    if (!mounted) return;
    _reportSubmit(context, outcome);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final services = context.services;
    return ListenableBuilder(
      listenable: services.exams,
      builder: (context, _) {
        if (_sending) {
          return ExamStatePage(
            title: l.classesAssignments,
            state: LgStateView(
              kind: StateKind.loading,
              title: l.classesSending,
            ),
          );
        }
        final s = services.exams.assignmentSession(
          widget.assignmentId,
          services.backend.userId,
        );
        if (s == null || s.finished) {
          return ExamStatePage(
            title: l.classesAssignments,
            state: LgStateView(
              kind: StateKind.empty,
              title: l.examNoActive,
              actionLabel: l.actionBack,
              onAction: () => context.pop(),
            ),
          );
        }
        return ExamRunner(
          session: s,
          title: s.title ?? l.classesAssignments,
          onFinish: ({required timedOut}) => _finish(s, timedOut: timedOut),
        );
      },
    );
  }
}
