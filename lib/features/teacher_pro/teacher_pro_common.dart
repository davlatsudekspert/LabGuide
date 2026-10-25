import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/backend/backend_models.dart';
import '../../core/backend/teacher_tests.dart';
import '../../core/entitlements/feature.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../learn/classes_screens.dart' show ClassesGate, classesErrorText;
import '../profile/pro_gate.dart' show purchaseRoute;

// Ustoz Pro (D-78) ekranlari uchun umumiy qism: server mavjudligi, xato
// matnlari, lokal kesh. Hammasi faqat `BuildFlags.proEnabled` buildda
// ko'rinadi (`AppServices.teacherTests`); bayroq o'chiq — yo'llar ham yo'q.

/// Ilova ichidagi manzillar.
abstract final class TtRoutes {
  static const tests = '/learn/classes/tests';
  static const newTest = '/learn/classes/tests/new';
  static const bank = '/learn/classes/tests/bank';
  static const invites = '/learn/classes/tests/invites';
  static String test(String id) => '/learn/classes/tests/t/$id';
  static String edit(String id) => '/learn/classes/tests/t/$id/edit';
  static String assign(String id) => '/learn/classes/tests/t/$id/assign';
  static String results(String aid) => '/learn/classes/tests/a/$aid';
  static const mine = '/learn/classes/my-tests';
  static String myTest(String aid) => '/learn/classes/my-tests/$aid';
  static String run(String aid) => '/learn/classes/my-tests/$aid/run';
  static String invite([String? token]) => Uri(
    path: '/learn/classes/invite',
    queryParameters: token == null ? null : {'t': token},
  ).toString();
}

/// Server xato kodi → foydalanuvchi matni (qolgani — guruhlar xatolari).
String ttErrorText(Object e, AppLocalizations l) => switch (e) {
  BackendException(code: 'plan_required' || 'tier_insufficient') => l.ttErrPlan,
  BackendException(code: 'teacher_role_required') => l.ttErrTeacherRole,
  BackendException(code: 'version_conflict') => l.ttVersionConflict,
  BackendException(code: 'not_published') => l.ttMustPublish,
  BackendException(code: 'no_questions') => l.ttErrNoQuestions,
  BackendException(code: 'invalid_title') => l.ttErrTitle,
  BackendException(code: 'invalid_time_limit') => l.ttErrTimeLimit,
  BackendException(code: 'invalid_pass_percent') => l.ttErrPassPercent,
  BackendException(code: 'invalid_due') => l.ttErrDue,
  BackendException(code: 'member_not_found') => l.ttErrMemberGone,
  BackendException(code: 'limit_tests') => l.ttErrLimitTests,
  BackendException(code: 'limit_invites') => l.ttErrLimitInvites,
  BackendException(code: 'limit_assignments') => l.ttErrLimitAssignments,
  BackendException(code: 'closed') => l.ttCantClosed,
  BackendException(code: 'past_due') => l.ttCantPastDue,
  BackendException(code: 'no_attempts_left') => l.ttCantNoAttempts,
  BackendException(code: 'time_over') => l.ttErrTimeOver,
  BackendException(code: 'already_submitted') => l.ttErrAlreadySubmitted,
  BackendException(code: 'invite_expired') => l.ttInviteExpired,
  BackendException(code: 'own_group') => l.ttInviteOwn,
  BackendException(code: 'consent_required') => l.ttInviteConsentBody,
  BackendException(code: 'abusive_language') => l.ttErrAbusive,
  BackendException(
    code: 'invalid_question' ||
        'invalid_question_text' ||
        'invalid_options' ||
        'duplicate_options' ||
        'invalid_correct' ||
        'invalid_explanation' ||
        'invalid_source' ||
        'invalid_questions',
  ) =>
    l.ttErrQuestionGeneric,
  _ => classesErrorText(e, l),
};

/// Tekshiruv kodi (TeacherTestInput / TtQuestion `validate`) → matn.
String ttValidationText(String code, AppLocalizations l) => switch (code) {
  'invalid_title' => l.ttErrTitle,
  'no_questions' => l.ttErrNoQuestions,
  'invalid_time_limit' => l.ttErrTimeLimit,
  'invalid_pass_percent' => l.ttErrPassPercent,
  'invalid_description' => l.ttErrDescription,
  'duplicate_options' => l.ttErrDuplicateOptions,
  'invalid_correct' => l.ttErrCorrect,
  'invalid_options' => l.ttErrOptions,
  'invalid_question_text' => l.ttErrQuestionText,
  _ => l.ttErrQuestionGeneric,
};

/// Server serverdagi reja yetmasligini aytdi (masalan, obuna boshqa
/// qurilmada tugagan, kesh eskirgan): standart to'lov oynasi ochiladi.
/// `true` — xato shu bilan "hal qilindi".
bool ttOfferIfPlanError(BuildContext context, Object e, Feature feature) {
  if (e is BackendException && e.planNeeded && context.mounted) {
    context.push(purchaseRoute(feature));
    return true;
  }
  return false;
}

/// Ustoz Pro serveri bormi + hisob (ClassesGate). Yo'q bo'lsa — halol holat.
class TeacherProGate extends StatelessWidget {
  const TeacherProGate({super.key, required this.builder});

  final Widget Function(BuildContext context, TeacherTestBackend api) builder;

  @override
  Widget build(BuildContext context) {
    final api = context.services.teacherTests;
    if (api == null) {
      final l = AppLocalizations.of(context);
      return LgStateView(
        kind: StateKind.unavailable,
        title: l.classesUnavailableTitle,
        message: l.classesUnavailableBody,
      );
    }
    // O'z tinglovchisi: hisob almashsa (chiqib, boshqasi bilan kirilsa)
    // [builder] har safar qayta chaqiriladi — oldingi hisob ma'lumoti
    // ko'rinib qolmaydi.
    return ClassesGate(
      child: ListenableBuilder(
        listenable: context.services.auth,
        builder: (context, _) => builder(context, api),
      ),
    );
  }
}

/// Server so'rovi holati.
class TtLoad<T> {
  T? data;
  Object? error;
  bool loading = false;

  /// Internetsiz — lokal keshdan ko'rsatilmoqda.
  bool fromCache = false;
}

/// Yuklanish / xato / ma'lumot.
Widget ttLoadState<T>(
  BuildContext context,
  TtLoad<T> s,
  VoidCallback retry,
  Widget Function(T data) builder,
) {
  final l = AppLocalizations.of(context);
  final data = s.data;
  if (data != null) return builder(data);
  if (s.error != null) {
    final offline =
        s.error is BackendException &&
        (s.error! as BackendException).failure == BackendFailure.network;
    return LgStateView(
      kind: offline ? StateKind.offline : StateKind.error,
      title: ttErrorText(s.error!, l),
      actionLabel: l.actionRetry,
      onAction: retry,
    );
  }
  return LgSkeleton(caption: l.classesLoading);
}

/// Daqiqa:soniya ko'rinishi (natijalar va taymer).
String ttDuration(AppLocalizations l, int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return l.ttMinSec(m, s);
}
