import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/build_flags.dart';
import '../../core/entitlements/feature.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../profile/pro_gate.dart';
import '../share/file_export.dart';

/// Bepul ekrandagi YANGI Pro kirish nuqtasi (D-78): faqat Pro bayrog'i
/// yoqilgan buildda ko'rinadi (bayroq o'chiq — ekran `main` bilan bir xil).
/// Bosilganda tekshiruv faqat boshlashdan oldin ([requireFeature]) — obuna
/// yo'q bo'lsa to'lov oynasi; bepul qism hech qachon yopilmaydi.
class ProEntryRow extends StatelessWidget {
  const ProEntryRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.divider = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    if (!BuildFlags.proEnabled) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return LgRow(
      title: title,
      subtitle: subtitle,
      icon: icon,
      trailing: LgTag(l.proPayTierPro),
      divider: divider,
      onTap: onTap,
    );
  }
}

/// Pro ekran qopqog'i: ochiq bo'lsa [child]; yopiq bo'lsa (masalan, to'g'ridan-
/// to'g'ri havola bilan kelinganda) — izoh va "Rejalarni ko'rish". Bir marta
/// ochilgan ekran obuna o'rtada tugasa ham YOPILMAYDI (boshlangan amal
/// to'xtatilmaydi). Hech qanday ma'lumot o'chirilmaydi.
class ProFeatureGate extends StatefulWidget {
  const ProFeatureGate({super.key, required this.feature, required this.child});

  final Feature feature;
  final Widget child;

  @override
  State<ProFeatureGate> createState() => _ProFeatureGateState();
}

class _ProFeatureGateState extends State<ProFeatureGate> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    final ent = context.services.entitlements;
    return ListenableBuilder(
      listenable: ent,
      builder: (context, _) {
        if (_opened || ent.can(widget.feature)) {
          _opened = true;
          return widget.child;
        }
        final l = AppLocalizations.of(context);
        return LgStateView(
          key: const ValueKey('pro-gate-closed'),
          kind: StateKind.empty,
          title: l.proGateClosedTitle,
          message: l.proGateClosedBody,
          actionLabel: l.proGateOpenPlans,
          onAction: () => context.push(purchaseRoute(widget.feature)),
        );
      },
    );
  }
}

/// Eksport natijasi (fayllar tayyorlash).
typedef ExportBuilder = Future<List<ExportFile>> Function();

/// Eksport oqimi: avval [feature] tekshiriladi (boshlashdan oldin), so'ng
/// PDF / CSV tanlanadi, fayl(lar) yig'iladi va tizim ulashish oynasi
/// ochiladi. Fayl qurilmada yaratiladi — ilova hech qayerga yubormaydi.
Future<void> runExport(
  BuildContext context, {
  required Feature feature,
  required ExportBuilder pdf,
  required ExportBuilder csv,
}) async {
  if (!await requireFeature(context, feature)) return;
  if (!context.mounted) return;
  final l = AppLocalizations.of(context);
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    // Tor ekran / katta shriftda ham sig'adi (aylantiriladi).
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LgSectionTitle(l.proExportTitle),
            LgRow(
              key: const ValueKey('export-pdf'),
              title: l.proExportPdf,
              subtitle: l.proExportPdfSub,
              icon: Icons.picture_as_pdf_outlined,
              onTap: () => Navigator.of(sheet).pop('pdf'),
            ),
            LgRow(
              key: const ValueKey('export-csv'),
              title: l.proExportCsv,
              subtitle: l.proExportCsvSub,
              icon: Icons.table_view_outlined,
              divider: false,
              onTap: () => Navigator.of(sheet).pop('csv'),
            ),
          ],
        ),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  final services = context.services;
  final messenger = ScaffoldMessenger.of(context);
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null || !box.hasSize
      ? null
      : box.localToGlobal(Offset.zero) & box.size;
  void snack(String m) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));
  snack(l.proExportBusy);
  bool ok;
  try {
    final files = await (choice == 'pdf' ? pdf() : csv());
    ok = await services.fileSharer.shareFiles(files, origin: origin);
  } on Object catch (e) {
    debugPrint('export: $e');
    ok = false;
  }
  snack(ok ? l.proExportShared : l.proExportFailed);
}

/// Hisobot sanasi: `2026-10-25` (fayl nomi uchun).
String fileDate(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

/// Eksport tugmasi (Pro ekranlarida va bepul ekrandagi Pro qatorida).
class ExportButton extends StatelessWidget {
  const ExportButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgButton.secondary(
      key: const ValueKey('export-button'),
      label: l.proExportAction,
      icon: Icons.ios_share_rounded,
      onPressed: onPressed,
    );
  }
}
