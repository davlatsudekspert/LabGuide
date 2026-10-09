import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../content/content_model.dart';

/// Katalogdagi paket holati. Faqat [reviewed] — mustaqil mutaxassis
/// tasdiqlagan paket; [test] yuklovchini sinash uchun, klinik paket emas.
enum PackStatus { test, draft, reviewed }

PackStatus _status(Object? raw) => switch (raw) {
  'test' => PackStatus.test,
  'draft' => PackStatus.draft,
  'reviewed' => PackStatus.reviewed,
  _ => throw FormatException('unknown pack status: $raw'),
};

/// `packs/index.json` dagi bitta yozuv.
@immutable
class PackCatalogEntry {
  const PackCatalogEntry({
    required this.packId,
    required this.status,
    required this.version,
    required this.manifestUri,
    required this.size,
    required this.languages,
    required this.minSchema,
    required this.title,
    required this.summary,
  });

  final String packId;
  final PackStatus status;
  final String version;

  /// Manifest manzili (katalog manziliga nisbatan hal qilingan).
  final Uri manifestUri;

  /// Yuklanadigan fayllarning umumiy hajmi (baytda) — yuklashdan oldin
  /// ko'rsatiladi; manifest bilan solishtiriladi.
  final int size;
  final List<String> languages;
  final int minSchema;
  final LocalizedText title;
  final LocalizedText summary;
}

/// Yuklab olinadigan paketlar katalogi. Har qanday nomuvofiqlikda
/// [FormatException] — buzuq katalog yarim-yarti ko'rsatilmaydi.
@immutable
class PackCatalog {
  const PackCatalog(this.entries);

  final List<PackCatalogEntry> entries;

  /// Katalogning o'zi kichik — bundan katta javob rad etiladi.
  static const maxBytes = 256 * 1024;

  static PackCatalog parse(Uint8List bytes, Uri indexUri) {
    if (bytes.length > maxBytes) {
      throw const FormatException('catalog too large');
    }
    final json = jsonDecode(utf8.decode(bytes));
    if (json is! Map || json['catalog_version'] != 1) {
      throw const FormatException('unsupported catalog');
    }
    final seen = <String>{};
    final entries = <PackCatalogEntry>[];
    for (final raw in json['packs'] as List) {
      final e = (raw as Map).cast<String, Object?>();
      final id = e['pack_id']! as String;
      if (!seen.add(id)) throw FormatException('duplicate pack $id');
      if (id == 'core') {
        // Asosiy paket ilova bilan keladi; katalog uni almashtira olmaydi.
        throw const FormatException('catalog must not list the core pack');
      }
      final manifest = indexUri.resolve(e['manifest']! as String);
      if (manifest.scheme != 'https' && manifest.scheme != 'file') {
        throw FormatException('insecure manifest url $manifest');
      }
      final size = e['size']! as int;
      if (size <= 0) throw FormatException('$id: bad size');
      entries.add(
        PackCatalogEntry(
          packId: id,
          status: _status(e['status']),
          version: e['version']! as String,
          manifestUri: manifest,
          size: size,
          languages: [for (final l in e['languages']! as List) l as String],
          minSchema: e['min_schema']! as int,
          title: LocalizedText.fromJson(e['title']),
          summary: LocalizedText.fromJson(e['summary']),
        ),
      );
    }
    return PackCatalog(List.unmodifiable(entries));
  }
}
