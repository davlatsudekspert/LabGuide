import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/auth/otp_auth.dart';
import 'backend_models.dart';
import 'partner_models.dart';

/// Build vaqtida beriladigan backend sozlamasi (repoda yo'q):
///
///   flutter build ipa --dart-define=LG_SUPABASE_URL=https://xxx.supabase.co \
///                     --dart-define=LG_SUPABASE_KEY=PUBLISHABLE_KEY
///
/// Publishable (anon) kalit ilova ichida bo'lishi uchun mo'ljallangan: u
/// sir emas, himoya serverdagi RLS va funksiyalarda. Service role kaliti
/// hech qachon ilovaga berilmaydi (faqat Edge Function ichida).
@immutable
class BackendConfig {
  const BackendConfig({required this.url, required this.publishableKey});

  static const fromEnvironment = BackendConfig(
    url: String.fromEnvironment('LG_SUPABASE_URL'),
    publishableKey: String.fromEnvironment('LG_SUPABASE_KEY'),
  );

  final String url;
  final String publishableKey;

  bool get isConfigured =>
      url.startsWith('https://') && publishableKey.isNotEmpty;
}

/// Ilova serveri: email OTP sessiyasi, vakolatlar, “Taklif va yordam”,
/// admin panel, guruhlar va hisobni o'chirish. Testlar va sozlanmagan
/// buildlar uchun boshqa implementatsiyalar bor.
abstract interface class LabBackend implements OtpAuthAdapter {
  bool get isConfigured;

  /// Sessiya bormi (token qurilmada, server tasdiqlagan).
  bool get hasSession;
  String? get sessionEmail;
  String? get userId;

  /// Ishga tushishda qurilmadagi sessiyani tiklaydi.
  Future<void> restoreSession();

  /// Server sessiyani bekor qildi (masalan, refresh token yaroqsiz).
  Stream<void> get sessionLost;

  Future<void> signOut();
  Future<void> deleteAccount();

  Future<AccessInfo> myAccess();
  Future<void> touchProfile({required String role, required String language});

  // --- admin 2FA
  Future<MfaStatus> mfaStatus();
  Future<TotpEnrollment> mfaEnroll();
  Future<void> mfaVerify({required String factorId, required String code});

  // --- Taklif va yordam
  Future<List<SupportThread>> myThreads();
  Future<List<SupportMessage>> messages(String threadId);
  Future<String> createThread({
    required SupportKind kind,
    required String subject,
    required String body,
    SupportAttachment? attachment,
  });
  Future<void> postMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  });
  Future<void> markRead(String threadId);
  Future<Uint8List> attachment(String path);

  // --- admin
  Future<AdminStats> adminStats();
  Future<List<SupportThread>> adminThreads({SupportStatus? status});
  Future<void> adminReply(String threadId, String body);
  Future<void> adminSetStatus(String threadId, SupportStatus status);
  Future<void> adminMarkRead(String threadId);
  Future<AdminUserPage> adminUsers({
    String? query,
    String? role,
    String? language,
    int limit = 20,
    int offset = 0,
  });
  Future<String> adminRevealEmail(String userId);
  Future<void> adminSetReviewer(String userId, {required bool enabled});
  Future<List<AuditEntry>> adminAudit({int limit = 50});

  // --- kontent tekshiruvi (faqat admin bergan reviewer; server tekshiradi)
  Future<void> submitReview({
    required String kind,
    required String itemId,
    required String contentVersion,
    required ReviewDecision decision,
    String? comment,
  });

  /// Tekshiruvchi bo'lmasa — bo'sh ro'yxat (RLS).
  Future<List<ContentReview>> contentReviews();

  // --- guruhlar (ustoz — o'zini ro'yxatdan o'tkazgan va guruhni yaratgan
  // hisob; huquqlar serverda)

  /// O'zini ustoz sifatida ro'yxatdan o'tkazish (guruh ochish uchun).
  /// Admin vakolati bermaydi.
  Future<void> registerTeacher();
  Future<List<StudyGroup>> myGroups();

  /// [displayName] — ustozning guruhdagi ixtiyoriy nomi (odatda null).
  Future<StudyGroup> createGroup(String name, {String? displayName});

  /// Qo'shilgan guruh id si. [displayName] — ixtiyoriy taxallus (null —
  /// tartib raqami ko'rinadi); ism-familiya so'ralmaydi.
  Future<String> joinGroup(String code, {String? displayName});

  /// O'z taxallusini o'zgartirish (null — tartib raqami).
  Future<void> setMyAlias(String groupId, String? alias);
  Future<void> leaveGroup(String groupId);

  /// Guruh a'zolari (faqat a'zo ko'radi).
  Future<List<GroupMember>> groupMembers(String groupId);

  /// Ustoz talabani guruhdan chiqaradi (ustozni emas).
  Future<void> removeMember(String groupId, String userId);
  Future<List<GroupAssignment>> assignments(String groupId);
  Future<String> createAssignment({
    required String groupId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    DateTime? dueAt,
    int? timeLimitMinutes,
  });

  /// Talaba topshiriqni boshlaydi (qayta chaqirilsa — o'sha vaqt qaytadi).
  Future<AssignmentStart> startAssignment(String assignmentId);

  /// Javoblar (topshiriq tartibida, javobsiz — -1). Ball serverda.
  Future<GroupSubmission> submitAssignment(
    String assignmentId,
    List<int> answers,
  );

  /// Talaba — faqat o'zini, ustoz — guruhdagi hammani ko'radi.
  Future<List<GroupSubmission>> submissions(String assignmentId);
  Future<List<GroupSubmission>> groupSubmissions(String groupId);

  /// To'g'ri javoblar kaliti — faqat ustozga (talabaga `forbidden`).
  Future<List<int>> assignmentKey(String assignmentId);

  // --- o'quv dasturi mavzulari (faqat guruh egasi-ustoz o'zgartiradi)

  /// Guruhga ochilgan mavzular (a'zo ko'radi).
  Future<List<GroupTopic>> groupTopics(String groupId);
  Future<void> openTopic(String groupId, String topicId);
  Future<void> markTopicStage(String groupId, String topicId, TopicStage stage);

  /// “Testni boshlash”: mavzu testi talabalarda ochiladi. Topshiriq id si.
  Future<String> startTopicTest({
    required String groupId,
    required String topicId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    int? timeLimitMinutes,
  });

  /// Testni yakunlash (yangi urinish qabul qilinmaydi).
  Future<void> finishTopicTest(String groupId, String topicId);

  // --- Hamkorlar (reklama)

  /// E'lon qilingan va bugun faol hamkorlar (mehmon ham o'qiydi).
  Future<List<Partner>> partners();

  /// Ko'rsatilish/bog'lanish hisoblagichlari (≤ 20 ta bir chaqiruvda;
  /// faqat hisobli foydalanuvchi). Sanalganlar sonini qaytaradi.
  Future<int> trackPartnerEvents(List<PartnerEvent> events);
  Future<String> createPartnerRequest(PartnerRequestDraft draft);
  Future<List<PartnerRequest>> myPartnerRequests();
  Future<List<Partner>> adminPartners();

  /// [id] `null` — yangi hamkor (qoralama). Hamkor id sini qaytaradi.
  Future<String> adminSavePartner(PartnerDraft draft, {String? id});
  Future<void> adminSetPartnerStatus(String id, PartnerStatus status);

  /// Logoni ochiq `partner-logos` bucket'iga yuklaydi, URL qaytaradi.
  Future<String> adminUploadPartnerLogo(Uint8List bytes, String mimeType);
  Future<List<PartnerDayStat>> adminPartnerStats(String id);
  Future<List<PartnerRequest>> adminPartnerRequests({
    PartnerRequestStatus? status,
  });
  Future<void> adminUpdatePartnerRequest(
    String id, {
    required PartnerRequestStatus status,
    String? reply,
  });
}

/// Backend sozlanmagan build (masalan, hozirgi TestFlight): hamma amal
/// “ulanmagan” deb javob beradi, hech narsa ishlayotgandek ko'rsatilmaydi.
class UnconfiguredBackend implements LabBackend {
  const UnconfiguredBackend();

  Never _no() => throw const BackendException(BackendFailure.unavailable);

  @override
  bool get isConfigured => false;
  @override
  bool get isAvailable => false;
  @override
  bool get isDemo => false;
  @override
  bool get hasSession => false;
  @override
  String? get sessionEmail => null;
  @override
  String? get userId => null;
  @override
  Stream<void> get sessionLost => const Stream.empty();

  @override
  Future<OtpRequestResult> requestCode(String email) async =>
      const OtpRequestResult(OtpRequestStatus.unavailable);
  @override
  Future<OtpVerifyResult> verifyCode(String email, String code) async =>
      const OtpVerifyResult(OtpVerifyStatus.unavailable);

  @override
  Future<void> restoreSession() async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<void> deleteAccount() async => _no();
  @override
  Future<AccessInfo> myAccess() async => AccessInfo.none;
  @override
  Future<void> touchProfile({
    required String role,
    required String language,
  }) async {}
  @override
  Future<MfaStatus> mfaStatus() async => _no();
  @override
  Future<TotpEnrollment> mfaEnroll() async => _no();
  @override
  Future<void> mfaVerify({
    required String factorId,
    required String code,
  }) async => _no();
  @override
  Future<List<SupportThread>> myThreads() async => _no();
  @override
  Future<List<SupportMessage>> messages(String threadId) async => _no();
  @override
  Future<String> createThread({
    required SupportKind kind,
    required String subject,
    required String body,
    SupportAttachment? attachment,
  }) async => _no();
  @override
  Future<void> postMessage(
    String threadId,
    String body, {
    SupportAttachment? attachment,
  }) async => _no();
  @override
  Future<void> markRead(String threadId) async => _no();
  @override
  Future<Uint8List> attachment(String path) async => _no();
  @override
  Future<AdminStats> adminStats() async => _no();
  @override
  Future<List<SupportThread>> adminThreads({SupportStatus? status}) async =>
      _no();
  @override
  Future<void> adminReply(String threadId, String body) async => _no();
  @override
  Future<void> adminSetStatus(String threadId, SupportStatus status) async =>
      _no();
  @override
  Future<void> adminMarkRead(String threadId) async => _no();
  @override
  Future<AdminUserPage> adminUsers({
    String? query,
    String? role,
    String? language,
    int limit = 20,
    int offset = 0,
  }) async => _no();
  @override
  Future<String> adminRevealEmail(String userId) async => _no();
  @override
  Future<void> adminSetReviewer(String userId, {required bool enabled}) async =>
      _no();
  @override
  Future<List<AuditEntry>> adminAudit({int limit = 50}) async => _no();
  @override
  Future<void> submitReview({
    required String kind,
    required String itemId,
    required String contentVersion,
    required ReviewDecision decision,
    String? comment,
  }) async => _no();
  @override
  Future<List<ContentReview>> contentReviews() async => _no();
  @override
  Future<void> registerTeacher() async => _no();
  @override
  Future<List<StudyGroup>> myGroups() async => _no();
  @override
  Future<StudyGroup> createGroup(String name, {String? displayName}) async =>
      _no();
  @override
  Future<String> joinGroup(String code, {String? displayName}) async => _no();
  @override
  Future<void> setMyAlias(String groupId, String? alias) async => _no();
  @override
  Future<void> leaveGroup(String groupId) async => _no();
  @override
  Future<List<GroupMember>> groupMembers(String groupId) async => _no();
  @override
  Future<void> removeMember(String groupId, String userId) async => _no();
  @override
  Future<List<GroupAssignment>> assignments(String groupId) async => _no();
  @override
  Future<String> createAssignment({
    required String groupId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    DateTime? dueAt,
    int? timeLimitMinutes,
  }) async => _no();
  @override
  Future<AssignmentStart> startAssignment(String assignmentId) async => _no();
  @override
  Future<GroupSubmission> submitAssignment(
    String assignmentId,
    List<int> answers,
  ) async => _no();
  @override
  Future<List<GroupSubmission>> submissions(String assignmentId) async => _no();
  @override
  Future<List<GroupSubmission>> groupSubmissions(String groupId) async => _no();
  @override
  Future<List<int>> assignmentKey(String assignmentId) async => _no();
  @override
  Future<List<GroupTopic>> groupTopics(String groupId) async => _no();
  @override
  Future<void> openTopic(String groupId, String topicId) async => _no();
  @override
  Future<void> markTopicStage(
    String groupId,
    String topicId,
    TopicStage stage,
  ) async => _no();
  @override
  Future<String> startTopicTest({
    required String groupId,
    required String topicId,
    required String title,
    required List<String> questionIds,
    required List<int> correctIndexes,
    int? timeLimitMinutes,
  }) async => _no();
  @override
  Future<void> finishTopicTest(String groupId, String topicId) async => _no();

  // --- Hamkorlar: server yo'q — reklama joylari umuman chiqmaydi.
  @override
  Future<List<Partner>> partners() async => const [];
  @override
  Future<int> trackPartnerEvents(List<PartnerEvent> events) async => 0;
  @override
  Future<String> createPartnerRequest(PartnerRequestDraft draft) async => _no();
  @override
  Future<List<PartnerRequest>> myPartnerRequests() async => _no();
  @override
  Future<List<Partner>> adminPartners() async => _no();
  @override
  Future<String> adminSavePartner(PartnerDraft draft, {String? id}) async =>
      _no();
  @override
  Future<void> adminSetPartnerStatus(String id, PartnerStatus status) async =>
      _no();
  @override
  Future<String> adminUploadPartnerLogo(
    Uint8List bytes,
    String mimeType,
  ) async => _no();
  @override
  Future<List<PartnerDayStat>> adminPartnerStats(String id) async => _no();
  @override
  Future<List<PartnerRequest>> adminPartnerRequests({
    PartnerRequestStatus? status,
  }) async => _no();
  @override
  Future<void> adminUpdatePartnerRequest(
    String id, {
    required PartnerRequestStatus status,
    String? reply,
  }) async => _no();
}
