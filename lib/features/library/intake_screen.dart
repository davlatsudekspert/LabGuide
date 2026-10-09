import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

/// Domla/muharrir uchun materiallarni qabul qilish tartibi
/// (`docs/CONTENT_INTAKE.md` ning qisqa, ilovadagi ko'rinishi).
class IntakeGuideScreen extends StatelessWidget {
  const IntakeGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final content = context.services.content;
    return LgPage(
      title: l.intakeTitle,
      subtitle: l.intakeSubtitle,
      children: [
        // Haqiqiy son paketdan: domladan kelgan materiallar (hozircha 0).
        ListenableBuilder(
          listenable: content,
          builder: (context, _) {
            final pack = content.pack;
            if (pack == null) return const SizedBox.shrink();
            final fromTeachers = pack.library
                .where((i) => i.providedBy == 'teacher')
                .length;
            return LgNotice(
              l.intakeStatus(fromTeachers),
              kind: NoticeKind.info,
            );
          },
        ),
        LgSectionTitle(l.intakeWhatTitle),
        LgPanel(child: _Bullets([l.intakeWhat1, l.intakeWhat2, l.intakeWhat3])),
        LgSectionTitle(l.intakeRightsTitle),
        LgPanel(
          child: _Bullets([
            l.intakeRights1,
            l.intakeRights2,
            l.intakeRights3,
          ], icon: Icons.verified_user_outlined),
        ),
        LgSectionTitle(l.intakeReviewTitle),
        LgPanel(
          child: LgSteps([
            l.intakeStep1,
            l.intakeStep2,
            l.intakeStep3,
            l.intakeStep4,
            l.intakeStep5,
          ]),
        ),
        LgNotice(l.intakeConflict),
        LgSectionTitle(l.intakeNeverTitle),
        LgPanel(
          soft: true,
          child: _Bullets([
            l.intakeNever1,
            l.intakeNever2,
            l.intakeNever3,
          ], icon: Icons.do_not_disturb_on_outlined),
        ),
        LgSectionTitle(l.intakeContactTitle),
        Text(l.intakeContactBody, style: text.bodyMedium),
        const SizedBox(height: 12),
        LgButton.secondary(
          label: l.intakeContactAction,
          icon: Icons.mail_outline_rounded,
          onPressed: () => context.push('/profile/support/new'),
        ),
      ],
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items, {this.icon = Icons.check_circle_outline_rounded});

  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final (i, item) in items.indexed)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: ExcludeSemantics(
                    child: Icon(icon, size: 19, color: p.brand),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: text.bodyLarge)),
              ],
            ),
          ),
      ],
    );
  }
}
