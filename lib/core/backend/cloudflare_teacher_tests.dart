import 'teacher_tests.dart';

/// HTTP chaqiruv: JSON javob (`data`); xato statusda [BackendException]
/// (server `error` kodi bilan) tashlaydi.
typedef TtCall = Future<Object?> Function(
  String method,
  String path, {
  Object? body,
  Map<String, String>? query,
});

/// Cloudflare Worker (`cloudflare/src/teachertests.ts`) mijozi.
class CloudflareTeacherTests implements TeacherTestBackend {
  CloudflareTeacherTests(this._call);

  final TtCall _call;

  static String _seg(String s) => Uri.encodeComponent(s);

  static Map<String, Object?> _map(Object? d) =>
      (d is Map) ? d.cast<String, Object?>() : const {};

  static List<Map<String, Object?>> _rows(Object? d) => [
    for (final r in (d as List? ?? const []))
      (r as Map).cast<String, Object?>(),
  ];

  @override
  Future<List<TeacherTest>> teacherTests() async => [
    for (final r in _rows(await _call('GET', '/v1/teacher/tests')))
      TeacherTest.fromJson(r),
  ];

  @override
  Future<TeacherTest> teacherTest(String id) async => TeacherTest.fromJson(
    _map(await _call('GET', '/v1/teacher/tests/${_seg(id)}')),
  );

  @override
  Future<TeacherTest> createTeacherTest(TeacherTestInput input) async =>
      TeacherTest.fromJson(
        _map(await _call('POST', '/v1/teacher/tests', body: input.toJson())),
      );

  @override
  Future<TeacherTest> updateTeacherTest(
    String id,
    TeacherTestInput input,
  ) async => TeacherTest.fromJson(
    _map(
      await _call('PUT', '/v1/teacher/tests/${_seg(id)}', body: input.toJson()),
    ),
  );

  @override
  Future<void> deleteTeacherTest(String id) =>
      _call('DELETE', '/v1/teacher/tests/${_seg(id)}');

  @override
  Future<TtAssignment> assignTeacherTest(
    String testId, {
    required String groupId,
    required DateTime dueAt,
    String? userId,
    int maxAttempts = 1,
    bool acceptLate = false,
  }) async => TtAssignment.fromJson(
    _map(
      await _call(
        'POST',
        '/v1/teacher/tests/${_seg(testId)}/assignments',
        body: {
          'group_id': groupId,
          'user_id': ?userId,
          'due_at': dueAt.toUtc().toIso8601String(),
          'max_attempts': maxAttempts,
          'late_policy': acceptLate ? 'accept' : 'reject',
        },
      ),
    ),
  );

  @override
  Future<List<TtAssignment>> teacherAssignments({String? testId}) async => [
    for (final r in _rows(
      await _call(
        'GET',
        '/v1/teacher/assignments',
        query: testId == null ? null : {'test_id': testId},
      ),
    ))
      TtAssignment.fromJson(r),
  ];

  @override
  Future<void> closeTeacherAssignment(String id) =>
      _call('POST', '/v1/teacher/assignments/${_seg(id)}/close');

  @override
  Future<void> deleteTeacherAssignment(String id) =>
      _call('DELETE', '/v1/teacher/assignments/${_seg(id)}');

  @override
  Future<List<TtInvite>> groupInvites(String groupId) async => [
    for (final r in _rows(
      await _call('GET', '/v1/teacher/groups/${_seg(groupId)}/invites'),
    ))
      TtInvite.fromJson(r),
  ];

  @override
  Future<TtInvite> createInvite(
    String groupId, {
    int maxUses = 50,
    int days = 7,
  }) async => TtInvite.fromJson(
    _map(
      await _call(
        'POST',
        '/v1/teacher/groups/${_seg(groupId)}/invites',
        body: {'max_uses': maxUses, 'days': days},
      ),
    ),
  );

  @override
  Future<void> revokeInvite(String id) =>
      _call('DELETE', '/v1/teacher/invites/${_seg(id)}');

  @override
  Future<TtResults> teacherResults(String assignmentId) async =>
      TtResults.fromJson(
        _map(
          await _call(
            'GET',
            '/v1/teacher/assignments/${_seg(assignmentId)}/results',
          ),
        ),
      );

  @override
  Future<TtExport> exportTeacherResults(String assignmentId) async =>
      TtExport.fromJson(
        _map(
          await _call(
            'GET',
            '/v1/teacher/assignments/${_seg(assignmentId)}/export',
          ),
        ),
      );

  @override
  Future<TtInvitePreview> previewInvite(String token) async =>
      TtInvitePreview.fromJson(
        _map(await _call('GET', '/v1/teacher-invites/${_seg(token)}')),
      );

  @override
  Future<String> acceptInvite(String token, {String? displayName}) async =>
      _map(
            await _call(
              'POST',
              '/v1/teacher-invites/${_seg(token)}/accept',
              body: {
                'consent': true,
                if (displayName != null && displayName.trim().isNotEmpty)
                  'display_name': displayName.trim(),
              },
            ),
          )['group_id']!
          as String;

  @override
  Future<List<StudentTeacherTest>> myTeacherTests() async => [
    for (final r in _rows(await _call('GET', '/v1/me/teacher-tests')))
      StudentTeacherTest.fromJson(r),
  ];

  @override
  Future<StudentTeacherTest> myTeacherTest(String id) async =>
      StudentTeacherTest.fromJson(
        _map(await _call('GET', '/v1/me/teacher-tests/${_seg(id)}')),
      );

  @override
  Future<TtRun> startTeacherTest(String id) async => TtRun.fromJson(
    _map(await _call('POST', '/v1/me/teacher-tests/${_seg(id)}/start')),
  );

  @override
  Future<TtAttempt> submitTeacherTest(
    String id, {
    required String attemptId,
    required List<int> answers,
  }) async => TtAttempt.fromJson(
    _map(
      await _call(
        'POST',
        '/v1/me/teacher-tests/${_seg(id)}/submit',
        body: {'attempt_id': attemptId, 'answers': answers},
      ),
    ),
  );
}
