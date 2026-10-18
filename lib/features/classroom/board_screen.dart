// “Katta ekran” (proyektor / televizor): ustoz telefonini ekranga uzatadi —
// gorizontal, to'liq ekran, katta shrift. Jonli reyting (har 5 s): har
// talaba bitta qator (o'rin, taxallus, holat: kutilmoqda / yechmoqda /
// topshirdi, ball, sarflangan vaqt), qatorlar silliq qayta tartiblanadi.
// Yon panelda — qo'shilish QR va kodi (kechikkanlar uchun).
//
// Maxfiylik: faqat taxallus yoki “Talaba NN” (ustozning shaxsiy eslatmasi —
// lokal ism — EKRANGA CHIQMAYDI), email yo'q. “Muddat tugagach” testida
// ekranda faqat ball; savollar bo'yicha natija (eng qiyin savollar) — ustoz
// testni yakunlagach.
import 'dart:async';
import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../app/app_scope.dart';
import '../../core/backend/backend_models.dart';
import '../../design/tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../learn/classes_screens.dart' show classesErrorText;
import 'invite_link.dart';
import 'lecture_present.dart';
import 'qr_code_view.dart';
import 'topic_questions.dart';

/// Jadval holati.
enum BoardStatus { submitted, solving, waiting }

/// Bitta talaba qatori.
@immutable
class BoardRow {
  const BoardRow({
    required this.userId,
    required this.name,
    required this.status,
    this.score,
    this.total,
    this.took,
    this.submittedAt,
    this.startedAt,
  });

  final String userId;
  final String name;
  final BoardStatus status;
  final int? score;
  final int? total;
  final Duration? took;
  final DateTime? submittedAt;
  final DateTime? startedAt;

  int get percent =>
      (total ?? 0) == 0 ? 0 : ((score ?? 0) * 100 / total!).round();
}

/// Ekrandagi ism: faqat taxallus yoki tartib raqami (lokal ism emas).
String boardName(AppLocalizations l, GroupMember m) =>
    m.alias ?? l.classesSeat((m.seatNo ?? 0).toString().padLeft(2, '0'));

/// Reyting tartibi: topshirganlar (foiz ↓, tezroq ↑), yechayotganlar
/// (boshlagan vaqt ↑), kutilayotganlar (ism ↑).
List<BoardRow> boardRows({
  required AppLocalizations l,
  required List<GroupMember> members,
  required List<GroupSubmission> submissions,
  required List<AssignmentAttempt> attempts,
  required String assignmentId,
}) {
  final subs = {
    for (final s in submissions)
      if (s.assignmentId == assignmentId) s.userId: s,
  };
  final started = {for (final a in attempts) a.userId: a.startedAt};
  final rows = [
    for (final m in members)
      if (!m.isTeacher)
        () {
          final s = subs[m.userId];
          final st = started[m.userId];
          if (s != null) {
            return BoardRow(
              userId: m.userId,
              name: boardName(l, m),
              status: BoardStatus.submitted,
              score: s.score,
              total: s.total,
              submittedAt: s.submittedAt,
              startedAt: st,
              took: st == null ? null : s.submittedAt.difference(st),
            );
          }
          return BoardRow(
            userId: m.userId,
            name: boardName(l, m),
            status: st == null ? BoardStatus.waiting : BoardStatus.solving,
            startedAt: st,
          );
        }(),
  ];
  int cmp(BoardRow a, BoardRow b) {
    if (a.status != b.status) return a.status.index.compareTo(b.status.index);
    switch (a.status) {
      case BoardStatus.submitted:
        final p = b.percent.compareTo(a.percent);
        if (p != 0) return p;
        final ta = a.took ?? const Duration(days: 999);
        final tb = b.took ?? const Duration(days: 999);
        final t = ta.compareTo(tb);
        if (t != 0) return t;
        return a.submittedAt!.compareTo(b.submittedAt!);
      case BoardStatus.solving:
        return a.startedAt!.compareTo(b.startedAt!);
      case BoardStatus.waiting:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }
  }

  return rows..sort(cmp);
}

String _clock(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

class _BoardData {
  const _BoardData({
    required this.group,
    required this.assignment,
    required this.members,
    required this.submissions,
    required this.attempts,
    required this.key,
  });

  final StudyGroup group;
  final GroupAssignment assignment;
  final List<GroupMember> members;
  final List<GroupSubmission> submissions;
  final List<AssignmentAttempt> attempts;
  final List<int>? key;
}

class AssignmentBoardScreen extends StatefulWidget {
  const AssignmentBoardScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
    this.askRotate = true,
  });

  final String groupId;
  final String assignmentId;

  /// Tik ekranda gorizontalga o'tishni so'rash (testda o'chiriladi).
  final bool askRotate;

  /// Jonli yangilanish oralig'i.
  static const refreshEvery = Duration(seconds: 5);

  @override
  State<AssignmentBoardScreen> createState() => _AssignmentBoardScreenState();
}

class _AssignmentBoardScreenState extends State<AssignmentBoardScreen> {
  _BoardData? _data;
  Object? _error;
  Timer? _timer;
  bool _immersive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Jadval va ekran holati savoli parallel (dialog ortida jadval tayyor).
      unawaited(_load());
      await _enter();
      if (!mounted) return;
      _timer = Timer.periodic(
        AssignmentBoardScreen.refreshEvery,
        (_) => _load(),
      );
    });
  }

  Future<void> _enter() async {
    if (!mounted) return;
    unawaited(_wakelock(true));
    final size = MediaQuery.sizeOf(context);
    var landscape = false;
    if (widget.askRotate && size.height > size.width) {
      final store = context.services.store;
      switch (LecturePresentation.read(store)) {
        case LectureOrientation.landscape:
          landscape = true;
        case LectureOrientation.keep:
          landscape = false;
        case LectureOrientation.ask:
          final r = await askLandscape(context, cast: true);
          if (!mounted) return;
          landscape = r?.landscape ?? false;
          if (r != null && r.remember) {
            await LecturePresentation.write(
              store,
              r.landscape
                  ? LectureOrientation.landscape
                  : LectureOrientation.keep,
            );
          }
      }
    }
    _immersive = true;
    await LecturePresentation.enter(landscape: landscape);
  }

  static Future<void> _wakelock(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } on Object {
      // Plagin yo'q (test/veb) — ekran baribir ishlaydi.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_wakelock(false));
    if (_immersive) unawaited(LecturePresentation.exit());
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final b = context.services.backend;
    try {
      final group = (await b.myGroups())
          .where((g) => g.id == widget.groupId && g.isTeacher)
          .firstOrNull;
      final a = group == null
          ? null
          : (await b.assignments(widget.groupId))
                .where((x) => x.id == widget.assignmentId)
                .firstOrNull;
      if (group == null || a == null) {
        throw const BackendException(BackendFailure.notFound);
      }
      final r = await Future.wait<Object>([
        b.groupMembers(widget.groupId),
        b.submissions(widget.assignmentId),
        b.assignmentProgress(widget.assignmentId),
      ]);
      final key = a.closed ? await b.assignmentKey(widget.assignmentId) : null;
      if (!mounted) return;
      setState(() {
        _error = null;
        _data = _BoardData(
          group: group,
          assignment: a,
          members: r[0] as List<GroupMember>,
          submissions: r[1] as List<GroupSubmission>,
          attempts: r[2] as List<AssignmentAttempt>,
          key: key,
        );
      });
    } on Object catch (e) {
      // Jonli yangilanishda tarmoq uzilsa — oxirgi jadval qoladi.
      if (mounted && _data == null) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final d = _data;
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: d == null
            ? Center(
                child: _error == null
                    ? const CircularProgressIndicator()
                    : Text(classesErrorText(_error!, l)),
              )
            : _Board(data: d, onExit: () => context.pop()),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.data, required this.onExit});

  final _BoardData data;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final a = data.assignment;
    final rows = boardRows(
      l: l,
      members: data.members,
      submissions: data.submissions,
      attempts: data.attempts,
      assignmentId: a.id,
    );
    final joined = rows.length;
    final solving = rows.where((r) => r.status == BoardStatus.solving).length;
    final submitted = rows
        .where((r) => r.status == BoardStatus.submitted)
        .length;
    return LayoutBuilder(
      builder: (context, c) {
        // Proyektor: shrift ekran balandligiga qarab (720p ~ 1, 1080p ~ 1.5).
        final k = math
            .min(c.maxHeight / 560, c.maxWidth / 1000)
            .clamp(0.7, 2.2);
        final title = TextStyle(
          fontSize: 30 * k,
          fontWeight: FontWeight.w700,
          color: p.ink,
          height: 1.15,
        );
        final side = math.min(c.maxWidth * 0.28, c.maxHeight * 0.62);
        return Padding(
          padding: EdgeInsets.fromLTRB(24 * k, 14 * k, 24 * k, 14 * k),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: title,
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('board-exit'),
                    tooltip: l.boardClose,
                    iconSize: 26 * k,
                    onPressed: onExit,
                    icon: Icon(Icons.close_rounded, color: p.sub),
                  ),
                ],
              ),
              SizedBox(height: 8 * k),
              Wrap(
                spacing: 10 * k,
                runSpacing: 6 * k,
                children: [
                  _Counter(k: k, label: l.quizQuestionCount(a.questionCount)),
                  if (a.isVariant)
                    _Counter(
                      key: const ValueKey('board-variant'),
                      k: k,
                      label: l.variantLabel,
                    ),
                  _Counter(k: k, label: '${l.boardJoined}: $joined'),
                  _Counter(
                    k: k,
                    label: '${l.boardStarted}: $solving',
                    tone: p.amber,
                  ),
                  _Counter(
                    k: k,
                    key: const ValueKey('board-submitted'),
                    label: '${l.boardSubmitted}: $submitted / $joined',
                    tone: p.brand,
                  ),
                  if (a.closed)
                    _Counter(k: k, label: l.classroomStatusTestDone),
                ],
              ),
              SizedBox(height: 12 * k),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: rows.isEmpty
                          ? Center(
                              child: Text(
                                l.boardEmpty,
                                style: TextStyle(
                                  fontSize: 22 * k,
                                  color: p.sub,
                                ),
                              ),
                            )
                          : _Leaderboard(rows: rows, k: k),
                    ),
                    SizedBox(width: 20 * k),
                    SizedBox(
                      width: side,
                      child: _SidePanel(data: data, k: k, qr: side * 0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({super.key, required this.k, required this.label, this.tone});

  final double k;
  final String label;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * k, vertical: 5 * k),
      decoration: BoxDecoration(
        color: (tone ?? p.sub).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16 * k,
          fontWeight: FontWeight.w600,
          color: tone ?? p.sub,
        ),
      ),
    );
  }
}

/// Qatorlar [AnimatedPositioned] bilan: yangi natija kelganda talaba o'z
/// o'rniga silliq suriladi.
class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.rows, required this.k});

  final List<BoardRow> rows;
  final double k;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = (c.maxHeight / rows.length).clamp(40.0 * k, 64.0 * k);
        final total = h * rows.length;
        var rank = 0;
        final ranks = <String, int>{};
        for (final r in rows) {
          if (r.status == BoardStatus.submitted) ranks[r.userId] = ++rank;
        }
        // Barqaror tartib: Stack bolalari id bo'yicha (faqat joy o'zgaradi).
        final byId = [...rows]..sort((a, b) => a.userId.compareTo(b.userId));
        return SingleChildScrollView(
          child: SizedBox(
            height: total,
            child: Stack(
              children: [
                for (final r in byId)
                  AnimatedPositioned(
                    key: ValueKey('board-row-${r.userId}'),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    top: rows.indexOf(r) * h,
                    left: 0,
                    right: 0,
                    height: h,
                    child: _RowView(row: r, rank: ranks[r.userId], k: k),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RowView extends StatelessWidget {
  const _RowView({required this.row, required this.rank, required this.k});

  final BoardRow row;
  final int? rank;
  final double k;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final big = TextStyle(
      fontSize: 22 * k,
      fontWeight: FontWeight.w600,
      color: p.ink,
    );
    final small = TextStyle(fontSize: 17 * k, color: p.sub);
    final r = row;
    final Widget status = switch (r.status) {
      BoardStatus.submitted => Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: r.percent / 100,
                minHeight: 10 * k,
                color: p.brand,
                backgroundColor: p.sub.withValues(alpha: 0.12),
              ),
            ),
          ),
          SizedBox(width: 12 * k),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Text(
                    '${r.score}/${r.total} · ${r.percent}%',
                    style: big.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (r.took != null) ...[
                    SizedBox(width: 12 * k),
                    Text(
                      _clock(r.took!),
                      style: small.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      BoardStatus.solving => Text(
        l.boardStatusSolving,
        style: small.copyWith(color: p.amber, fontWeight: FontWeight.w600),
      ),
      BoardStatus.waiting => Text(l.boardStatusWaiting, style: small),
    };
    return Container(
      margin: EdgeInsets.only(bottom: 4 * k),
      padding: EdgeInsets.symmetric(horizontal: 14 * k),
      decoration: BoxDecoration(
        color: r.status == BoardStatus.submitted
            ? p.paper
            : p.paper.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12 * k),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46 * k,
            child: Text(
              rank == null ? '–' : '$rank',
              style: big.copyWith(
                color: rank != null && rank! <= 3 ? p.brand : p.sub,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              r.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: big,
            ),
          ),
          SizedBox(width: 12 * k),
          Expanded(flex: 6, child: status),
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.data, required this.k, required this.qr});

  final _BoardData data;
  final double k;
  final double qr;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final code = data.group.joinCode ?? '';
    final a = data.assignment;
    final children = <Widget>[];
    if (!a.closed && code.length == 8) {
      children.addAll([
        Text(
          l.boardScan,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18 * k, color: p.sub),
        ),
        SizedBox(height: 8 * k),
        Center(
          child: QrCodeView(
            key: const ValueKey('board-qr'),
            data: inviteUrl(code, assignmentId: a.id),
            size: qr,
            semanticLabel: l.classesQrLabel(code.split('').join(' ')),
          ),
        ),
        SizedBox(height: 8 * k),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${code.substring(0, 4)} ${code.substring(4)}',
            style: TextStyle(
              fontSize: 34 * k,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: p.brand,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        SizedBox(height: 10 * k),
      ]);
    }
    if (a.closed) {
      children.addAll(_hardest(context));
    } else if (a.revealAfterDue) {
      children.add(
        Text(
          l.boardAnswersAfterClose,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15 * k, color: p.sub),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  /// Yakunlangan test: eng ko'p xato qilingan savollar (3 tagacha).
  List<Widget> _hardest(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final a = data.assignment;
    final students = {
      for (final m in data.members)
        if (!m.isTeacher) m.userId,
    };
    final subs = [
      for (final s in data.submissions)
        if (students.contains(s.userId)) s,
    ];
    if (subs.isEmpty) return const [];
    // Har savol — faqat u tushgan talabalar orasida (variantli test, D-66).
    final wrong = hardestTallies(tallyQuestions(a, subs, data.key));
    final pack = context.services.content.pack;
    final byId = pack == null
        ? const <String, Never>{}
        : classQuestionIndex(pack, context.services.toifa.bank);
    return [
      Text(
        l.topicTestHardest,
        style: TextStyle(
          fontSize: 22 * k,
          fontWeight: FontWeight.w700,
          color: p.ink,
        ),
      ),
      SizedBox(height: 8 * k),
      for (final t in wrong.take(3))
        Padding(
          key: ValueKey('board-hardest-${t.index}'),
          padding: EdgeInsets.only(bottom: 10 * k),
          child: Container(
            padding: EdgeInsets.all(10 * k),
            decoration: BoxDecoration(
              color: p.paper,
              borderRadius: BorderRadius.circular(10 * k),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    l.examQuestionN(t.index + 1),
                    l.classesWrongOf(t.wrong, t.received),
                    if (a.isVariant) l.variantReceived(t.received),
                  ].join(' · '),
                  style: TextStyle(
                    fontSize: 15 * k,
                    fontWeight: FontWeight.w700,
                    color: p.amber,
                  ),
                ),
                SizedBox(height: 4 * k),
                Text(
                  byId[t.questionId]?.prompt(lang) ?? l.examQuestionMissing,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16 * k, color: p.ink),
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
