import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../app/widgets/lg_page.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/lg_widgets.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../settings/settings_controller.dart';

extension AppRoleText on AppRole {
  String title(AppLocalizations l) => switch (this) {
    AppRole.doctor => l.roleDoctor,
    AppRole.lab => l.roleLab,
    AppRole.student => l.roleStudent,
    AppRole.teacher => l.roleTeacher,
  };

  String description(AppLocalizations l) => switch (this) {
    AppRole.doctor => l.roleDoctorDesc,
    AppRole.lab => l.roleLabDesc,
    AppRole.student => l.roleStudentDesc,
    AppRole.teacher => l.roleTeacherDesc,
  };

  IconData get icon => switch (this) {
    AppRole.doctor => Icons.medical_services_outlined,
    AppRole.lab => Icons.biotech_outlined,
    AppRole.student => Icons.school_outlined,
    AppRole.teacher => Icons.co_present_outlined,
  };
}

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key, required this.onboarding});

  /// Onboardingda "Davom etish" bosh sahifaga olib boradi; profildan
  /// ochilganda tanlov saqlanib, oldingi ekranga qaytadi.
  final bool onboarding;

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  late AppRole _selected = context.services.settings.effectiveRole;

  bool _busy = false;

  /// Kirgan hisob “Ustoz”ni tanlasa — shu bosishda serverda ustoz sifatida
  /// ro'yxatdan o'tadi (D-42: o'z-o'zini ro'yxatdan o'tkazish, OTP sessiya
  /// shart; huquq — faqat o'z guruhlari). Avval bu guruh yaratishda alohida
  /// qadam edi. Xato bo'lsa — guruh yaratishdagi tugma qoladi.
  bool get _registersTeacher {
    final s = context.services;
    return _selected == AppRole.teacher &&
        s.backend.isConfigured &&
        s.auth.hasAccount &&
        !s.access.access.teacher;
  }

  Future<void> _continue() async {
    final services = context.services;
    final settings = services.settings;
    if (_registersTeacher) {
      setState(() => _busy = true);
      try {
        await services.backend.registerTeacher();
        await services.refreshAccess();
      } on Object {
        // Tarmoq: guruh yaratish sahifasida qayta taklif qilinadi.
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      if (!mounted) return;
    }
    await settings.setRole(_selected);
    if (widget.onboarding) {
      // Router redirect onboarding tugagach /home ga olib o'tadi.
      await settings.completeOnboarding();
    } else if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgPage(
      title: l.rolesTitle,
      subtitle: l.rolesSubtitle,
      showProfile: false,
      children: [
        for (final role in AppRole.values)
          RoleCard(
            role: role,
            selected: role == _selected,
            onTap: () => setState(() => _selected = role),
          ),
        if (_selected == AppRole.teacher &&
            context.services.backend.isConfigured)
          LgNotice(
            context.services.auth.hasAccount
                ? l.rolesTeacherRegisterNote
                : l.rolesTeacherSignInNote,
            key: const ValueKey('role-teacher-note'),
            kind: NoticeKind.info,
          ),
        LgNotice(l.rolesNote, kind: NoticeKind.info),
        const SizedBox(height: 8),
        LgButton(
          key: const ValueKey('role-continue'),
          label: l.actionContinue,
          busy: _busy,
          onPressed: _continue,
        ),
      ],
    );
  }
}

class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final AppRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? p.brand : Colors.transparent,
            width: 2,
          ),
        ),
        child: LgPressable(
          onTap: onTap,
          selected: selected,
          color: selected ? p.soft : p.paper,
          borderRadius: BorderRadius.circular(18),
          semanticLabel: '${role.title(l)}. ${role.description(l)}',
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: selected ? p.paper : p.soft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(role.icon, color: p.brand, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.title(l), style: text.titleMedium),
                        const SizedBox(height: 3),
                        Text(role.description(l), style: text.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? p.brand : p.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
