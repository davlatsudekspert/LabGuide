import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/content_model.dart';
import 'library_catalog.dart';

/// Katalog tillari — o'z nomi bilan (til tanlagichdagi kabi).
const libraryLanguageNames = {
  'uz': 'O‘zbekcha',
  'ru': 'Русский',
  'en': 'English',
};

String libraryLanguageName(String code) =>
    libraryLanguageNames[code] ?? code.toUpperCase();

IconData openKindIcon(LibraryOpenKind k) => switch (k) {
  LibraryOpenKind.pending => Icons.hourglass_top_rounded,
  LibraryOpenKind.inApp => Icons.chrome_reader_mode_outlined,
  LibraryOpenKind.download => Icons.download_for_offline_outlined,
  LibraryOpenKind.link => Icons.public_rounded,
  LibraryOpenKind.record => Icons.inventory_2_outlined,
};

String openKindLabel(LibraryOpenKind k, AppLocalizations l) => switch (k) {
  LibraryOpenKind.pending => l.libOpenPending,
  LibraryOpenKind.inApp => l.libOpenInApp,
  LibraryOpenKind.download => l.libOpenDownload,
  LibraryOpenKind.link => l.libOpenLink,
  LibraryOpenKind.record => l.libAccessCatalog,
};

/// Filtrdagi qisqa nom.
String openKindShort(LibraryOpenKind k, AppLocalizations l) => switch (k) {
  LibraryOpenKind.pending => l.libOpenPending,
  LibraryOpenKind.inApp => l.libOpenInAppShort,
  LibraryOpenKind.download => l.libOpenDownloadShort,
  LibraryOpenKind.link => l.libOpenLinkShort,
  LibraryOpenKind.record => l.libOpenRecordShort,
};

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  return '${(kb / 1024).toStringAsFixed(1)} MB';
}

/// Sayt manzili (www. siz) — foydalanuvchi qaerga o'tishini biladi.
String linkHost(String url) {
  final host = Uri.tryParse(url)?.host ?? '';
  final clean = host.startsWith('www.') ? host.substring(4) : host;
  return clean.isEmpty ? url : clean;
}

/// “Bosganda nima bo'ladi” izohi.
String openKindHint(LibraryItem item, AppLocalizations l) =>
    switch (openKindOf(item)) {
      LibraryOpenKind.pending =>
        item.importState == ImportState.received
            ? l.libOpenReceivedHint
            : l.libOpenPendingHint,
      LibraryOpenKind.inApp => l.libOpenInAppHint,
      LibraryOpenKind.download => l.libOpenDownloadHint(
        formatFileSize(item.filePack!.size),
      ),
      LibraryOpenKind.link => l.libOpenLinkHint(linkHost(item.url!)),
      LibraryOpenKind.record => l.libOpenRecordHint,
    };

/// Sarlavha uchun qisqa nom: rasmiy hujjatlarning “— …” qismisiz, juda
/// uzun bo'lsa so'z chegarasida qisqartiriladi. To'liq nom sahifada alohida.
String libraryShortTitle(LibraryItem item, {int max = 110}) {
  var t = item.title.split(' — ').first.trim();
  if (t.length <= max) return t;
  t = t.substring(0, max);
  final space = t.lastIndexOf(' ');
  if (space > max * 0.6) t = t.substring(0, space);
  return '${t.trimRight()}…';
}

String importStateLabel(ImportState s, AppLocalizations l) => switch (s) {
  ImportState.notReceived => l.libStateNotReceived,
  ImportState.received => l.libStateReceived,
  ImportState.cataloged => l.libStateCataloged,
  ImportState.linked => l.libStateLinked,
  ImportState.reviewed => l.libStateReviewed,
};

/// Kutubxona qidiruv maydoni (Tahlillardagi qidiruv bilan bir xil ko'rinish,
/// tashqaridan fokus berish mumkin).
class LibrarySearchField extends StatelessWidget {
  const LibrarySearchField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    OutlineInputBorder border([BorderSide side = BorderSide.none]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(LgRadius.button),
          borderSide: side,
        );
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Semantics(
        label: label,
        textField: true,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintMaxLines: 2,
            prefixIcon: Icon(Icons.search_rounded, color: p.sub),
            suffixIcon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, _) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      tooltip: l.testsClearSearch,
                      icon: Icon(Icons.close_rounded, color: p.sub),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
            ),
            enabledBorder: border(),
            border: border(),
            focusedBorder: border(BorderSide(color: p.brand, width: 2)),
          ),
        ),
      ),
    );
  }
}

/// Ochilish turi belgisi: rangli ikonka + yorliq + izoh. Rangga tayanmaydi —
/// matn har doim bor.
class OpenKindLine extends StatelessWidget {
  const OpenKindLine({super.key, required this.item, this.large = false});

  final LibraryItem item;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final kind = openKindOf(item);
    final (Color bg, Color fg) = switch (kind) {
      LibraryOpenKind.pending => (p.amberBg, p.amber),
      LibraryOpenKind.inApp || LibraryOpenKind.download => (p.brand, p.onBrand),
      LibraryOpenKind.link => (p.soft, p.brand),
      LibraryOpenKind.record => (p.bg, p.sub),
    };
    final box = large ? 44.0 : 34.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Container(
            width: box,
            height: box,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(large ? 14 : 11),
            ),
            child: Icon(openKindIcon(kind), size: large ? 23 : 19, color: fg),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                openKindLabel(kind, l),
                style: (large ? text.titleMedium : text.titleSmall)!.copyWith(
                  color: kind == LibraryOpenKind.pending ? p.amber : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(openKindHint(item, l), style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
