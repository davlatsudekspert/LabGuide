import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/admin/admin_screens.dart';
import '../features/auth/ui/auth_screens.dart';
import '../features/auth/ui/role_screen.dart';
import '../features/auth/ui/welcome_screen.dart';
import '../features/content/ui/analyte_screen.dart';
import '../features/content/ui/tests_screen.dart';
import '../features/home/home_screen.dart';
import '../features/instruments/calibration_screens.dart';
import '../features/instruments/instrument_screens.dart';
import '../features/lab/lab_screens.dart';
import '../features/learn/learn_screens.dart';
import '../features/microscopy/microscopy_quiz_screen.dart';
import '../features/microscopy/microscopy_screens.dart';
import '../features/library/library_screens.dart';
import '../features/profile/profile_screens.dart';
import '../features/qc/qc_screens.dart';
import '../features/settings/settings_controller.dart';
import '../features/support/support_screens.dart';
import '../features/tools/calc_info.dart';
import '../features/tools/clinical_calc_screens.dart';
import '../features/tools/tool_screens.dart';
import 'shell.dart';

/// Yo'llar xaritasi.
///
/// Onboarding: /welcome → /welcome/auth → /welcome/auth/otp → /welcome/role.
/// Tablar: /home, /tests, /lab, /library, /learn — har biri o'z stacki bilan.
/// Analit kartasi har bir tab ichida ochiladi (`<tab>/analyte/:id`), shunda
/// "orqaga" foydalanuvchini kelgan joyiga qaytaradi.
GoRouter buildRouter(
  SettingsController settings, {
  required Listenable refresh,
}) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final tabMemory = TabMemory();

  List<RouteBase> analyteRoutes() => [
    GoRoute(
      path: 'analyte/:id',
      builder: (context, state) =>
          AnalyteScreen(analyteId: state.pathParameters['id']!),
      routes: [
        GoRoute(
          path: 'units',
          builder: (context, state) =>
              UnitConverterScreen(analyteId: state.pathParameters['id']),
        ),
        GoRoute(
          path: 'quiz',
          builder: (context, state) =>
              QuizScreen(analyteId: state.pathParameters['id']),
        ),
      ],
    ),
  ];

  return GoRouter(
    navigatorKey: rootKey,
    // Holatni tiklash: tizim ilovani fonda yopsa, qaytganda tab steklari va
    // ochiq sahifalar tiklanadi.
    restorationScopeId: 'router',
    initialLocation: '/home',
    // Faqat onboarding holati o'zgarganda redirect qayta hisoblanadi. Til,
    // mavzu yoki rol o'zgarishi routerni yangilamaydi — aks holda kechikkan
    // yangilanish endigina yopilgan sahifani qaytarib qo'yishi mumkin.
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final inOnboarding = loc.startsWith('/welcome') || loc == '/terms';
      if (!settings.onboarded && !inOnboarding) return '/welcome';
      if (settings.onboarded && loc.startsWith('/welcome')) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'auth',
            builder: (context, state) => const EmailScreen(),
            routes: [
              GoRoute(
                path: 'otp',
                builder: (context, state) => const OtpScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'role',
            builder: (context, state) => const RoleScreen(onboarding: true),
          ),
        ],
      ),
      GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'role',
            builder: (context, state) => const RoleScreen(onboarding: false),
          ),
          GoRoute(
            path: 'purchase',
            builder: (context, state) => const PurchaseScreen(),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacyScreen(),
          ),
          GoRoute(
            path: 'support',
            builder: (context, state) => const SupportListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const NewSupportThreadScreen(),
              ),
              GoRoute(
                path: 'thread/:id',
                builder: (context, state) =>
                    SupportThreadScreen(threadId: state.pathParameters['id']!),
              ),
            ],
          ),
          // Har admin ekrani o'zini AdminGate bilan o'raydi (my_access + aal2);
          // yo'lni bilish hech narsa bermaydi — RPC'lar serverda tekshiradi.
          GoRoute(
            path: 'admin',
            builder: (context, state) => const AdminHomeScreen(),
            routes: [
              GoRoute(
                path: 'inbox',
                builder: (context, state) => const AdminInboxScreen(),
              ),
              GoRoute(
                path: 'thread/:id',
                builder: (context, state) =>
                    AdminThreadScreen(threadId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'users',
                builder: (context, state) => const AdminUsersScreen(),
              ),
              GoRoute(
                path: 'audit',
                builder: (context, state) => const AdminAuditScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'auth',
            builder: (context, state) => const EmailScreen(),
            routes: [
              GoRoute(
                path: 'otp',
                builder: (context, state) => const OtpScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'shell',
        builder: (context, state, shell) =>
            AppShell(shell: shell, memory: tabMemory, location: state.uri),
        branches: [
          StatefulShellBranch(
            restorationScopeId: 'tab-home',
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: analyteRoutes(),
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'tab-tests',
            routes: [
              GoRoute(
                path: '/tests',
                builder: (context, state) => const TestsScreen(),
                routes: analyteRoutes(),
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'tab-lab',
            routes: [
              GoRoute(
                path: '/lab',
                builder: (context, state) => const LabScreen(),
                routes: [
                  GoRoute(
                    path: 'calibration',
                    builder: (context, state) => CalibrationScreen(
                      modelId: state.uri.queryParameters['model'],
                      mineId: state.uri.queryParameters['mine'],
                      analyteId: state.uri.queryParameters['analyte'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'log',
                        builder: (context, state) =>
                            const CalibrationLogScreen(),
                        routes: [
                          GoRoute(
                            path: ':id',
                            builder: (context, state) =>
                                CalibrationRecordScreen(
                                  recordId: state.pathParameters['id']!,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'qc',
                    builder: (context, state) => const QcScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) => const QcNewSetScreen(),
                      ),
                      GoRoute(
                        path: 'set/:id',
                        builder: (context, state) =>
                            QcSetScreen(setId: state.pathParameters['id']!),
                        routes: [
                          GoRoute(
                            path: 'target/:level',
                            builder: (context, state) => QcTargetScreen(
                              setId: state.pathParameters['id']!,
                              levelId: state.pathParameters['level']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'preanalytics',
                    builder: (context, state) => const PreanalyticsScreen(),
                  ),
                  GoRoute(
                    path: 'instruments',
                    builder: (context, state) => const InstrumentsScreen(),
                    routes: [
                      GoRoute(
                        path: 'c/:category',
                        builder: (context, state) => InstrumentMakersScreen(
                          category: state.pathParameters['category']!,
                        ),
                        routes: [
                          GoRoute(
                            path: ':maker',
                            builder: (context, state) => InstrumentModelsScreen(
                              category: state.pathParameters['category']!,
                              makerId: state.pathParameters['maker']!,
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'm/:id',
                        builder: (context, state) => InstrumentCardScreen(
                          modelId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'microscopy',
                    builder: (context, state) => const MicroscopyScreen(),
                    routes: [
                      GoRoute(
                        path: 's/:section',
                        builder: (context, state) => MicroSectionScreen(
                          sectionId: state.pathParameters['section']!,
                        ),
                      ),
                      GoRoute(
                        path: 'i/:id',
                        builder: (context, state) => MicroImageScreen(
                          imageId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'quiz',
                        builder: (context, state) => MicroQuizScreen(
                          sectionId: state.uri.queryParameters['section'],
                        ),
                      ),
                      GoRoute(
                        path: 'credits',
                        builder: (context, state) => const MicroCreditsScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'calculators',
                    builder: (context, state) => const CalculatorsScreen(),
                    routes: [
                      GoRoute(
                        path: 'dilution',
                        builder: (context, state) => const DilutionScreen(),
                      ),
                      GoRoute(
                        path: 'units',
                        builder: (context, state) =>
                            const UnitConverterScreen(),
                      ),
                      for (final c in ClinicalCalc.values)
                        GoRoute(
                          path: calcRoute(c),
                          builder: (context, state) =>
                              ClinicalCalcScreen(calc: c),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'tab-library',
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'saved',
                    builder: (context, state) => const SavedScreen(),
                    routes: analyteRoutes(),
                  ),
                  GoRoute(
                    path: 'packs',
                    builder: (context, state) => const PacksScreen(),
                  ),
                  GoRoute(
                    path: 'books',
                    builder: (context, state) => const BooksScreen(),
                  ),
                  GoRoute(
                    path: 'sources',
                    builder: (context, state) => const SourcesScreen(),
                  ),
                  GoRoute(
                    path: 'research',
                    builder: (context, state) => const ResearchScreen(),
                  ),
                  GoRoute(
                    path: 'review',
                    builder: (context, state) => const ReviewQueueScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'tab-learn',
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: 'quiz',
                    builder: (context, state) => const QuizScreen(),
                  ),
                  GoRoute(
                    path: 'exam',
                    builder: (context, state) => const ExamScreen(),
                  ),
                  GoRoute(
                    path: 'classes',
                    builder: (context, state) => const ClassesScreen(),
                  ),
                  GoRoute(
                    path: 'lesson',
                    builder: (context, state) =>
                        const ResearchScreen(lessonPlan: true),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// [SettingsController] dan faqat `onboarded` o'zgarishini uzatadi.
class OnboardingChanges extends ChangeNotifier {
  OnboardingChanges(this._settings) : _last = _settings.onboarded {
    _settings.addListener(_onSettings);
  }

  final SettingsController _settings;
  bool _last;

  void _onSettings() {
    if (_settings.onboarded == _last) return;
    _last = _settings.onboarded;
    notifyListeners();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    super.dispose();
  }
}
