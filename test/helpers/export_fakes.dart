import 'dart:convert';

import 'package:flutter/painting.dart' show Rect;
import 'package:labguide/features/share/file_export.dart';

/// Ulashish oynasi o'rnida: berilgan fayllar xotirada qoladi (testlar
/// mazmunini tekshiradi).
class FakeFileSharer implements FileSharer {
  final shared = <List<ExportFile>>[];
  bool available = true;

  @override
  Future<bool> shareFiles(
    List<ExportFile> files, {
    String? text,
    Rect? origin,
  }) async {
    if (!available) return false;
    shared.add(files);
    return true;
  }

  /// Oxirgi ulashilgan [mimeType] fayl.
  ExportFile? last(String mimeType) => [
    for (final batch in shared.reversed)
      for (final f in batch)
        if (f.mimeType == mimeType) f,
  ].firstOrNull;

  /// Oxirgi CSV (BOM siz matn).
  String? lastCsv() {
    final f = last(ExportFile.csv);
    if (f == null) return null;
    final bytes = f.bytes;
    final body = bytes.length >= 3 && bytes[0] == 0xEF ? bytes.sublist(3) : bytes;
    return utf8.decode(body);
  }
}
