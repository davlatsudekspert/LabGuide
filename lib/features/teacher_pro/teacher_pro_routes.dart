import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'student_teacher_tests_screens.dart';
import 'teacher_assign_screens.dart';
import 'teacher_results_screens.dart';
import 'teacher_test_screens.dart';

/// Ustoz Pro yo'llari (`/learn/classes/` ostida). Router ularni faqat
/// `BuildFlags.proEnabled` buildda qo'shadi — bayroq o'chiq bo'lsa yo'llar
/// umuman yo'q (bepul reliz bilan bir xil). Statik yo'llar `g/:gid` dan oldin.
List<RouteBase> teacherProRoutes(GlobalKey<NavigatorState> rootKey) => [
  GoRoute(
    path: 'tests',
    builder: (context, state) => const TeacherTestsScreen(),
    routes: [
      GoRoute(
        path: 'new',
        builder: (context, state) => const TeacherTestEditScreen(),
      ),
      GoRoute(
        path: 'bank',
        builder: (context, state) => const TtBankPickerScreen(),
      ),
      GoRoute(
        path: 'invites',
        builder: (context, state) => const TtInvitesScreen(),
      ),
      GoRoute(
        path: 't/:tid',
        builder: (context, state) =>
            TeacherTestDetailScreen(testId: state.pathParameters['tid']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) =>
                TeacherTestEditScreen(testId: state.pathParameters['tid']!),
          ),
          GoRoute(
            path: 'assign',
            builder: (context, state) =>
                TtAssignScreen(testId: state.pathParameters['tid']!),
          ),
        ],
      ),
      GoRoute(
        path: 'a/:aid',
        builder: (context, state) =>
            TtResultsScreen(assignmentId: state.pathParameters['aid']!),
      ),
    ],
  ),
  GoRoute(
    path: 'my-tests',
    builder: (context, state) => const StudentTeacherTestsScreen(),
    routes: [
      GoRoute(
        path: ':aid',
        builder: (context, state) => StudentTeacherTestScreen(
          assignmentId: state.pathParameters['aid']!,
        ),
        routes: [
          // Yechish — to'liq ekran (tablar yashiringan).
          GoRoute(
            path: 'run',
            parentNavigatorKey: rootKey,
            builder: (context, state) => TtRunScreen(
              assignmentId: state.pathParameters['aid']!,
              args: state.extra is TtRunArgs ? state.extra! as TtRunArgs : null,
            ),
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: 'invite',
    builder: (context, state) =>
        TtInviteAcceptScreen(token: state.uri.queryParameters['t']),
  ),
];
