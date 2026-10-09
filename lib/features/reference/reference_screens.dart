import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../tools/clinical_calc_screens.dart';
import 'reference_content.dart';

/// O'rganish tabidagi manzil.
const refBase = '/learn/reference';

String refRoute(String id) => '$refBase/$id';

/// Jadvallar ro'yxati.
class RefListScreen extends StatelessWidget {
  const RefListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return LgPage(
      title: l.refTitle,
      children: [
        Text(l.refIntro, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        for (final (i, t) in refTopics.indexed)
          LgRow(
            title: t.title.of(lang),
            subtitle: t.summary.of(lang),
            icon: t.icon,
            onTap: () => context.push(refRoute(t.id)),
            divider: i < refTopics.length - 1,
          ),
        const SizedBox(height: 8),
        LgNotice(l.refDraftNote),
      ],
    );
  }
}

/// Bitta jadval: bloklar kartalarda, har blok ostida manbalar.
class RefTopicScreen extends StatelessWidget {
  const RefTopicScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final topic = refTopic(topicId);
    if (topic == null) {
      return LgPage(
        title: l.refTitle,
        children: [LgNotice(l.refNotFound, kind: NoticeKind.error)],
      );
    }
    return LgPage(
      title: topic.title.of(lang),
      subtitle: l.refTitle,
      children: [
        Text(
          topic.summary.of(lang),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 4),
        for (final b in topic.blocks) _BlockCard(block: b, lang: lang),
        const SizedBox(height: 8),
        LgNotice(l.refDraftNote),
      ],
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.block, required this.lang});

  final RefBlock block;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(block.title.of(lang), style: text.titleLarge),
          ),
          if (block.tag case final tag?) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: LgTag(
                tag.of(lang),
                tone: block.warning ? LgTone.warning : LgTone.neutral,
                icon: block.warning
                    ? Icons.warning_amber_rounded
                    : Icons.history_rounded,
              ),
            ),
          ],
          for (final (i, f) in block.facts.indexed)
            MergeSemantics(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: i < block.facts.length - 1 || block.bullets.isNotEmpty
                      ? Border(
                          bottom: BorderSide(
                            color: p.line.withValues(alpha: 0.7),
                          ),
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.label.of(lang),
                      style: text.labelLarge!.copyWith(color: p.brand),
                    ),
                    const SizedBox(height: 2),
                    Text(f.value.of(lang), style: text.bodyLarge),
                  ],
                ),
              ),
            ),
          if (block.bullets.isNotEmpty) const SizedBox(height: 8),
          for (final x in block.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: text.bodyLarge),
                  Expanded(child: Text(x.of(lang), style: text.bodyLarge)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(l.diffSourcesTitle, style: text.labelLarge),
          ),
          for (final (i, r) in block.refs.indexed)
            CalcSourceTile(index: i + 1, ref: r),
        ],
      ),
    );
  }
}
