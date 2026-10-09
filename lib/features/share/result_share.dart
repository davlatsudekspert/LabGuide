import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_scope.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

/// Do'kon havolasi. TODO(egasi): App Store / Google Play havolasi berilgach
/// shu yerga yoziladi — hozircha ulashish matnida faqat "LabGuide".
const String? kStoreLink = null;

/// Qaysi natija ulashilmoqda.
enum ShareKind {
  /// Kunlik 5 ta savol.
  daily,

  /// Mashq imtihoni (kontent paketi savollari).
  exam,

  /// Toifa testi mashqi — rasmiy natija emas.
  toifa;

  String label(AppLocalizations l) => switch (this) {
    ShareKind.daily => l.shareKindDaily,
    ShareKind.exam => l.shareKindExam,
    ShareKind.toifa => l.shareKindToifa,
  };
}

/// Rasmga chiqadigan natija: shaxsiy ma'lumot (ism, email, guruh) yo'q.
@immutable
class ShareData {
  const ShareData({
    required this.kind,
    required this.correct,
    required this.total,
    required this.date,
    this.topic,
    this.streak,
  });

  final ShareKind kind;
  final int correct;
  final int total;
  final DateTime date;

  /// Mavzu nomi (masalan, "Gematologiya") — bo'lmasa null.
  final String? topic;

  /// Kunlik savolda — ketma-ket kunlar.
  final int? streak;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  /// Ulashish oynasidagi matn.
  String text(AppLocalizations l) {
    final b = StringBuffer(l.shareText(kind.label(l), correct, total, percent));
    if (kind == ShareKind.toifa) b.write('\n${l.shareToifaNote}');
    if (kStoreLink case final link?) b.write('\n$link');
    return b.toString();
  }
}

/// Tizim ulashish oynasi (Telegram va boshqalar shu yerda).
abstract interface class ResultSharer {
  /// PNG va matnni ulashadi. Qaytaradi: oyna ochildi (false — imkoni yo'q).
  Future<bool> share({
    required Uint8List png,
    required String text,
    Rect? origin,
  });
}

/// `share_plus` (BSD-3): rasm vaqtinchalik papkaga yoziladi.
class SystemResultSharer implements ResultSharer {
  const SystemResultSharer();

  @override
  Future<bool> share({
    required Uint8List png,
    required String text,
    Rect? origin,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/labguide-result.png');
      await file.writeAsBytes(png, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: text,
          // iPad'da oyna shu nuqtaga bog'lanadi (aks holda xato).
          sharePositionOrigin: origin,
        ),
      );
      return true;
    } on Object catch (e) {
      debugPrint('share failed: $e');
      return false;
    }
  }
}

/// Kartochka o'lchami (logik px); rasm 3x — 1080×1350.
const kShareCardSize = Size(360, 450);

/// Ulashish kartochkasi: logo, "LabGuide", natija, sana. Ilova mavzusi va
/// shrift o'lchamidan qat'i nazar bir xil ko'rinadi.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.data});

  final ShareData data;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const p = LgPalette.light;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMMd(locale).format(data.date);
    final ink = p.ink;
    TextStyle style(double size, FontWeight w, {Color? color}) => TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: w,
      color: color ?? ink,
      height: 1.2,
      decoration: TextDecoration.none,
    );
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox.fromSize(
        size: kShareCardSize,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8EEDB), Color(0xFFFFFEF9)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/images/logo_mark.png'),
                      width: 40,
                      height: 40,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'LabGuide',
                      style: style(
                        22,
                        FontWeight.w700,
                      ).copyWith(letterSpacing: -0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  data.kind.label(l).toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: style(
                    12,
                    FontWeight.w700,
                    color: p.brand,
                  ).copyWith(letterSpacing: 1.2),
                ),
                if (data.topic case final topic?) ...[
                  const SizedBox(height: 6),
                  Text(
                    topic,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style(16, FontWeight.w600, color: p.sub),
                  ),
                ],
                const Spacer(),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${data.correct}/${data.total}',
                        style: style(
                          76,
                          FontWeight.w700,
                          color: p.brand,
                        ).copyWith(letterSpacing: -3, height: 1),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '${data.percent}%',
                        style: style(30, FontWeight.w600, color: p.sub),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l.shareCorrectCaption,
                  style: style(15, FontWeight.w500, color: p.sub),
                ),
                if (data.streak case final streak? when streak > 0) ...[
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.brand,
                      borderRadius: BorderRadius.circular(LgRadius.tag),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 18,
                            color: Color(0xFFF7FAEE),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l.dailyStreakDays(streak),
                            style: style(14, FontWeight.w600, color: p.onBrand),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Container(height: 1, color: p.line),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        data.kind == ShareKind.toifa
                            ? l.shareToifaNote
                            : l.shareFooter,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: style(
                          12,
                          FontWeight.w500,
                          color: data.kind == ShareKind.toifa ? p.amber : p.sub,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(date, style: style(12, FontWeight.w600, color: p.sub)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Natijani ulashish tugmasi: avval kartochka ko'rinishi, so'ng tizim oynasi.
class ShareResultButton extends StatelessWidget {
  const ShareResultButton({
    super.key,
    required this.data,
    this.primary = false,
  });

  final ShareData data;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    void open() => showShareSheet(context, data);
    return primary
        ? LgButton(
            label: l.shareResult,
            icon: Icons.ios_share_rounded,
            onPressed: open,
          )
        : LgButton.secondary(
            label: l.shareResult,
            icon: Icons.ios_share_rounded,
            onPressed: open,
          );
  }
}

Future<void> showShareSheet(BuildContext context, ShareData data) {
  // Oldingi xabar (masalan, "eslatma yoqildi") tugmani yopib turmasin.
  ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // Tab paneli ham xiralashsin (oyna butun ekran ustida).
    useRootNavigator: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _ShareSheet(data: data),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.data});

  final ShareData data;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _card = GlobalKey();
  final _button = GlobalKey();
  bool _busy = false;
  bool _failed = false;

  Future<Uint8List?> _capture() async {
    final boundary =
        _card.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _share() async {
    final l = AppLocalizations.of(context);
    final sharer = context.services.sharer;
    final box = _button.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() {
      _busy = true;
      _failed = false;
    });
    var ok = false;
    try {
      final png = await _capture();
      if (png != null) {
        ok = await sharer.share(
          png: png,
          text: widget.data.text(l),
          origin: origin,
        );
      }
    } on Object catch (e) {
      debugPrint('share capture failed: $e');
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failed = !ok;
    });
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(l.shareSheetTitle, style: text.titleLarge),
          ),
          const SizedBox(height: 4),
          Text(l.shareSheetBody, style: text.bodySmall),
          const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(LgRadius.card),
                child: FittedBox(
                  child: RepaintBoundary(
                    key: _card,
                    child: Semantics(
                      label: widget.data.text(l),
                      child: ExcludeSemantics(
                        child: ShareCard(data: widget.data),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_failed) ...[
            LgNotice(l.shareFailed, kind: NoticeKind.warning),
            const SizedBox(height: 8),
          ],
          KeyedSubtree(
            key: _button,
            child: LgButton(
              label: l.shareResult,
              icon: Icons.ios_share_rounded,
              onPressed: _busy ? null : _share,
            ),
          ),
        ],
      ),
    );
  }
}
