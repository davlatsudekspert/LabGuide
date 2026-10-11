import 'dart:typed_data';

import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/core/backend/community_backend.dart';

import 'fake_backend.dart';

class _Member {
  MemberStatus status = MemberStatus.none;
  MemberStatus? prev;
  VerifyMethod? method;
  SpecialistRole? role;
  String? country;
  DateTime? verifiedAt;
  bool owner = false;
  final Set<String> reporters = {};
}

class _Q {
  _Q(
    this.id,
    this.author,
    this.title,
    this.body,
    this.lang,
    this.topic,
    this.at,
  );
  final String id;
  final String author;
  final String title;
  final String body;
  final String lang;
  final String? topic;
  final DateTime at;
  bool pinned = false;
  String? best;
}

class _A {
  _A(this.id, this.qid, this.author, this.body, this.lang, this.at);
  final String id;
  final String qid;
  final String author;
  final String body;
  final String lang;
  final DateTime at;
  final Set<String> votes = {};
}

/// Widget testlar uchun xotiradagi hamjamiyat serveri: qoidalar
/// `cloudflare/src/community.ts` bilan bir xil (javob/ovoz — faqat
/// mutaxassis, eng yaxshi javob — muallif, admin — aal2, 3 shikoyat →
/// to'xtatish). Sessiya [lab] dan olinadi. AI yo'q: natija [verifyOutcome].
class FakeCommunityBackend implements CommunityBackend {
  FakeCommunityBackend(this.lab, {this.ownerName = 'LabGuide'});

  final FakeLabBackend lab;
  final String ownerName;

  /// Keyingi hujjat tekshiruvi natijasi.
  MemberStatus verifyOutcome = MemberStatus.verified;

  /// Yuklangan hujjatlar soni (baytlar saqlanmaydi).
  int uploads = 0;
  int translations = 0;

  final Map<String, _Member> _members = {};
  final List<_Q> _qs = [];
  final List<_A> _as = [];
  final Map<String, PostTranslation> _cache = {};
  int _seq = 0;
  DateTime _clock = DateTime.utc(2026, 10, 11, 9);

  DateTime _now() => _clock = _clock.add(const Duration(minutes: 1));

  String get _uid =>
      lab.userId ??
      (throw const CommunityException(
        BackendFailure.unauthorized,
        'unauthorized',
      ));
  _Member _m(String uid) => _members.putIfAbsent(uid, _Member.new);
  bool _visible(String author) =>
      _members[author]?.status != MemberStatus.suspended;

  Future<bool> _admin() async {
    final a = await lab.myAccess();
    return a.adminAccount && a.aal2;
  }

  Future<void> _requireAdmin() async {
    if (!await _admin()) {
      throw const CommunityException(BackendFailure.forbidden, 'forbidden');
    }
  }

  void _requireActive(String uid) {
    if (_members[uid]?.status == MemberStatus.suspended) {
      throw const CommunityException(BackendFailure.forbidden, 'suspended');
    }
  }

  // --- test yordamchilari (server tomondagi amallar)

  /// Egasi hisobi (qo'lda tekshirilgan) — `seed-owner-verification` kabi.
  void makeOwner(String uid) {
    _m(uid)
      ..status = MemberStatus.verified
      ..method = VerifyMethod.manual
      ..role = SpecialistRole.clinicalLabDiagnostics
      ..country = 'UZ'
      ..verifiedAt = _now()
      ..owner = true;
  }

  void makeSpecialist(
    String uid, {
    SpecialistRole role = SpecialistRole.laborant,
  }) {
    _m(uid)
      ..status = MemberStatus.verified
      ..method = VerifyMethod.aiAuto
      ..role = role
      ..country = 'UZ'
      ..verifiedAt = _now();
  }

  String seedQuestion({
    required String author,
    required String title,
    required String body,
    String lang = 'uz',
    String? topic,
    List<String> answers = const [],
    String? answerAuthor,
  }) {
    final q = _Q('q${++_seq}', author, title, body, lang, topic, _now());
    _qs.add(q);
    for (final a in answers) {
      _as.add(_A('a${++_seq}', q.id, answerAuthor ?? author, a, lang, _now()));
    }
    return q.id;
  }

  CommunityAuthor _author(String uid) {
    final m = _members[uid];
    final verified = m?.status == MemberStatus.verified;
    return CommunityAuthor(
      kind: m?.owner == true
          ? AuthorKind.owner
          : verified
          ? AuthorKind.specialist
          : AuthorKind.member,
      name: m?.owner == true ? ownerName : null,
      verified: verified,
      method: verified ? m?.method : null,
      role: verified ? m?.role : null,
      country: verified ? m?.country : null,
      isMe: lab.userId == uid,
    );
  }

  QuestionSummary _summary(_Q q, {bool full = false}) => QuestionSummary(
    id: q.id,
    title: q.title,
    text: full || q.body.length <= 200
        ? q.body
        : '${q.body.substring(0, 200)}…',
    lang: q.lang,
    topic: q.topic,
    pinned: q.pinned,
    answerCount: _as.where((a) => a.qid == q.id).length,
    bestAnswerId: q.best,
    createdAt: q.at,
    author: _author(q.author),
  );

  _Q _q(String id) => _qs.firstWhere(
    (q) => q.id == id && _visible(q.author),
    orElse: () =>
        throw const CommunityException(BackendFailure.notFound, 'not_found'),
  );

  @override
  bool get hasSession => lab.hasSession;

  @override
  Future<CommunityMe> communityMe() async {
    final m = _members[_uid];
    final status = m?.status ?? MemberStatus.none;
    return CommunityMe(
      status: status,
      method: m?.method,
      role: m?.role,
      country: m?.country,
      verifiedAt: m?.verifiedAt,
      institution: m?.owner == true
          ? 'Andijon davlat tibbiyot instituti'
          : null,
      specialtyCode: m?.owner == true
          ? '3.03.01 Klinik laborator diagnostika'
          : null,
      credential: m?.owner == true ? 'birlamchi ixtisoslik kursi' : null,
      year: m?.owner == true ? 2026 : null,
      isOwner: m?.owner ?? false,
      canAsk: status != MemberStatus.suspended,
      canAnswer: status == MemberStatus.verified,
      admin: await _admin(),
    );
  }

  @override
  Future<CommunityMe> verifySpecialist({
    required SpecialistRole role,
    required String country,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final uid = _uid;
    _requireActive(uid);
    if (bytes.length > 5 * 1024 * 1024) {
      throw const CommunityException(BackendFailure.invalid, 'too_large');
    }
    uploads++;
    final ok = verifyOutcome == MemberStatus.verified;
    _m(uid)
      ..status = ok ? MemberStatus.verified : MemberStatus.rejected
      ..method = VerifyMethod.aiAuto
      ..role = role
      ..country = country
      ..verifiedAt = ok ? _now() : null;
    return communityMe();
  }

  @override
  Future<QuestionPage> questions({
    String? topic,
    bool mine = false,
    int limit = 20,
    int offset = 0,
  }) async {
    final uid = mine ? _uid : null;
    final all =
        _qs
            .where(
              (q) =>
                  _visible(q.author) &&
                  (topic == null || q.topic == topic) &&
                  (uid == null || q.author == uid),
            )
            .toList()
          ..sort((a, b) {
            if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
            return b.at.compareTo(a.at);
          });
    final items = all.skip(offset).take(limit).toList();
    final next = offset + items.length;
    return QuestionPage(
      items: [for (final q in items) _summary(q)],
      total: all.length,
      nextOffset: next < all.length ? next : null,
    );
  }

  @override
  Future<String> askQuestion({
    required String title,
    required String body,
    String? topic,
    required String lang,
  }) async {
    final uid = _uid;
    _requireActive(uid);
    if (title.trim().length < 10 || body.trim().length < 10) {
      throw const CommunityException(BackendFailure.invalid, 'invalid_title');
    }
    if (RegExp(r'[^\s@]+@[^\s@]+\.[a-z]{2,}').hasMatch(body)) {
      throw const CommunityException(BackendFailure.invalid, 'contact_data');
    }
    final q = _Q(
      'q${++_seq}',
      uid,
      title.trim(),
      body.trim(),
      lang,
      topic,
      _now(),
    );
    _qs.add(q);
    return q.id;
  }

  @override
  Future<QuestionThread> question(String id) async {
    final q = _q(id);
    final me = lab.userId;
    final verified =
        me != null && _members[me]?.status == MemberStatus.verified;
    final answers = _as.where((a) => a.qid == id && _visible(a.author)).toList()
      ..sort((a, b) {
        if ((a.id == q.best) != (b.id == q.best)) {
          return a.id == q.best ? -1 : 1;
        }
        if (a.votes.length != b.votes.length) {
          return b.votes.length - a.votes.length;
        }
        return a.at.compareTo(b.at);
      });
    return QuestionThread(
      question: _summary(q, full: true),
      answers: [
        for (final a in answers)
          CommunityAnswer(
            id: a.id,
            body: a.body,
            lang: a.lang,
            upvotes: a.votes.length,
            voted: me != null && a.votes.contains(me),
            isBest: a.id == q.best,
            createdAt: a.at,
            author: _author(a.author),
          ),
      ],
      canAnswer: verified,
      canVote: verified,
      isAuthor: me == q.author,
      admin: await _admin(),
    );
  }

  @override
  Future<String> answer(
    String questionId,
    String body, {
    required String lang,
  }) async {
    final uid = _uid;
    _requireActive(uid);
    if (_members[uid]?.status != MemberStatus.verified) {
      throw const CommunityException(BackendFailure.forbidden, 'not_verified');
    }
    _q(questionId);
    final a = _A('a${++_seq}', questionId, uid, body.trim(), lang, _now());
    _as.add(a);
    return a.id;
  }

  _A _a(String id) => _as.firstWhere(
    (a) => a.id == id,
    orElse: () =>
        throw const CommunityException(BackendFailure.notFound, 'not_found'),
  );

  @override
  Future<int> vote(String answerId, {required bool up}) async {
    final uid = _uid;
    if (_members[uid]?.status != MemberStatus.verified) {
      throw const CommunityException(BackendFailure.forbidden, 'not_verified');
    }
    final a = _a(answerId);
    if (a.author == uid) {
      throw const CommunityException(BackendFailure.forbidden, 'own_answer');
    }
    up ? a.votes.add(uid) : a.votes.remove(uid);
    return a.votes.length;
  }

  @override
  Future<void> setBestAnswer(String questionId, String? answerId) async {
    final q = _q(questionId);
    if (q.author != _uid) {
      throw const CommunityException(BackendFailure.forbidden, 'not_author');
    }
    q.best = answerId;
  }

  @override
  Future<void> report({
    required PostKind kind,
    required String id,
    required ReportReason reason,
  }) async {
    final uid = _uid;
    final author = kind == PostKind.question ? _q(id).author : _a(id).author;
    if (author == uid) {
      throw const CommunityException(BackendFailure.invalid, 'own_post');
    }
    final m = _m(author)..reporters.add(uid);
    if (!m.owner &&
        m.reporters.length >= 3 &&
        m.status != MemberStatus.suspended) {
      m
        ..prev = m.status
        ..status = MemberStatus.suspended;
    }
  }

  @override
  Future<PostTranslation> translate({
    required PostKind kind,
    required String id,
    required String lang,
  }) async {
    final key = '${kind.name}:$id:$lang';
    final cached = _cache[key];
    if (cached != null) return cached;
    translations++;
    final (title, body, src) = kind == PostKind.question
        ? (_q(id).title, _q(id).body, _q(id).lang)
        : (null, _a(id).body, _a(id).lang);
    if (src == lang) {
      throw const CommunityException(BackendFailure.invalid, 'same_language');
    }
    return _cache[key] = PostTranslation(
      title: title == null ? null : '[$lang] $title',
      body: '[$lang] $body',
      lang: lang,
      sourceLang: src,
    );
  }

  @override
  Future<void> pinQuestion(String id, {required bool pinned}) async {
    await _requireAdmin();
    _q(id).pinned = pinned;
  }

  @override
  Future<void> deleteQuestion(String id) async {
    await _requireAdmin();
    _qs.removeWhere((q) => q.id == id);
    _as.removeWhere((a) => a.qid == id);
  }

  @override
  Future<void> deleteAnswer(String id) async {
    await _requireAdmin();
    _as.removeWhere((a) => a.id == id);
  }

  @override
  Future<List<CommunityMemberAdmin>> adminMembers({
    MemberStatus status = MemberStatus.suspended,
  }) async {
    await _requireAdmin();
    return [
      for (final e in _members.entries)
        if (e.value.status == status)
          CommunityMemberAdmin(
            userHash: e.key.padRight(64, '0'),
            status: e.value.status,
            prevStatus: e.value.prev,
            role: e.value.role,
            country: e.value.country,
            method: e.value.method,
            reporters: e.value.reporters.length,
            reports: [
              for (final q in _qs.where((q) => q.author == e.key))
                CommunityReport(
                  kind: PostKind.question,
                  reason: ReportReason.wrong,
                  excerpt: q.title,
                  createdAt: q.at,
                ),
            ],
            isOwner: e.value.owner,
          ),
    ];
  }

  String _byHash(String hash) =>
      _members.keys.firstWhere((k) => k.padRight(64, '0') == hash);

  @override
  Future<void> adminRestore(String userHash) async {
    await _requireAdmin();
    final m = _members[_byHash(userHash)]!;
    m
      ..status = m.prev ?? MemberStatus.none
      ..prev = null
      ..reporters.clear();
  }

  @override
  Future<void> adminRevoke(String userHash) async {
    await _requireAdmin();
    _members[_byHash(userHash)]!
      ..status = MemberStatus.rejected
      ..verifiedAt = null;
  }
}
