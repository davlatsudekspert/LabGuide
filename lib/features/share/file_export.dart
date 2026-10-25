import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Rect;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Eksport fayli (PDF / CSV) — xotirada yig'iladi, ulashish oynasiga beriladi.
@immutable
class ExportFile {
  const ExportFile({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });

  /// Fayl nomi (`labguide-qc-2026-10-25.pdf`) — faqat lotin, raqam, `-_.`.
  final String name;
  final String mimeType;
  final Uint8List bytes;

  static const pdf = 'application/pdf';
  static const csv = 'text/csv';
}

/// Fayl nomi uchun xavfsiz qism (bo'sh joy va maxsus belgilarsiz).
String safeFileStem(String raw) {
  final s = raw
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return s.isEmpty ? 'labguide' : (s.length > 40 ? s.substring(0, 40) : s);
}

/// Fayllarni tizim ulashish oynasi orqali berish (saqlash, Telegram, email).
/// Ilova hech qayerga o'zi yubormaydi.
abstract interface class FileSharer {
  /// Qaytaradi: oyna ochildi (`false` — imkoni bo'lmadi).
  Future<bool> shareFiles(List<ExportFile> files, {String? text, Rect? origin});
}

/// `share_plus` (BSD-3): fayl vaqtinchalik papkaga yoziladi — mavjud
/// natija ulashish mexanizmi bilan bir xil.
class SystemFileSharer implements FileSharer {
  const SystemFileSharer();

  @override
  Future<bool> shareFiles(
    List<ExportFile> files, {
    String? text,
    Rect? origin,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final out = <XFile>[];
      for (final f in files) {
        final file = File('${dir.path}/${f.name}');
        await file.writeAsBytes(f.bytes, flush: true);
        out.add(XFile(file.path, mimeType: f.mimeType, name: f.name));
      }
      await SharePlus.instance.share(
        ShareParams(files: out, text: text, sharePositionOrigin: origin),
      );
      return true;
    } on Object catch (e) {
      debugPrint('file share failed: $e');
      return false;
    }
  }
}
