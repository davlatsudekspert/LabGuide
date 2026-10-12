import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

const spermBase = '/lab/spermogram';
const spermCardImage = 'assets/spermogram/card.png';

/// Spermogramma bo'limi — hozircha "tayyorlanmoqda" sahifasi (me'yorlar
/// JSST 2021 qo'llanmasi bilan tekshirilgach qo'shiladi; raqam to'qilmaydi).
class SpermogramScreen extends StatelessWidget {
  const SpermogramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPage(
      title: l.spermTitle,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(spermCardImage, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        LgNotice(l.spermSoonBody, title: l.spermSoonTitle),
        LgSectionTitle(l.spermPlannedTitle),
        for (final line in l.spermPlanned.split('\n'))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExcludeSemantics(child: Text('•  ')),
                Expanded(child: Text(line, style: text.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
