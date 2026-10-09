// Yuklab olinadigan paketlar katalogini (`packs/index.json`) va sinov
// paketini quradi.
//
// Ishlatish (repo ildizida):
//   dart run tool/build_pack_catalog.dart
//
// Sinov paketi (`sample-test`) — yuklovchi zanjirini (katalog → manifest →
// yuklash → sha256 → atomar o'rnatish → yangilash) haqiqiy tarmoqda sinash
// uchun. Tarkibi asosiy paketdagi bitta draft kartaning aynan nusxasi:
// yangi klinik da'vo qo'shilmaydi. Katalogda `status: test` — ilova uni
// “Sinov paketi · klinik paket emas” deb ko'rsatadi.
//
// Fayllar GitHub'dagi public repodan statik xizmat qiladi:
//   https://raw.githubusercontent.com/davlatsudekspert/LabGuide/main/packs/index.json
// Paket o'zgarsa versiyani oshiring — eski versiya papkasi saqlanadi, shunda
// eski katalogni o'qigan ilova ham yuklashni tugata oladi.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _sampleId = 'sample-test';
const _sampleVersion = '2026.10.09-test.1';
const _sampleAnalyte = 'glucose-plasma-fasting';

void main() {
  final core =
      jsonDecode(File('assets/content/core/pack.json').readAsStringSync())
          as Map<String, dynamic>;
  final analytes = (core['analytes'] as List).cast<Map<String, dynamic>>();
  final card = Map<String, dynamic>.from(
    analytes.singleWhere((a) => a['id'] == _sampleAnalyte),
  );
  // Paket o'z-o'zidan to'liq bo'lishi uchun faqat bog'lanishlar
  // qisqartiriladi; kartaning matni va manbalari o'zgarmaydi.
  card['related'] = <String>[];
  final sourceIds = (card['source_ids'] as List).cast<String>().toSet();
  final sources = (core['sources'] as List)
      .cast<Map<String, dynamic>>()
      .where((s) => sourceIds.contains(s['id']))
      .toList();
  final group = (core['groups'] as List).cast<Map<String, dynamic>>().singleWhere(
    (g) => g['id'] == card['group'],
  );
  final pack = {
    'pack_id': _sampleId,
    'schema_version': core['schema_version'],
    'content_version': _sampleVersion,
    'groups': [group],
    'analytes': [card],
    'sources': sources,
  };
  final dir = Directory('packs/$_sampleId/$_sampleVersion')
    ..createSync(recursive: true);
  final packBytes = utf8.encode(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
  File('${dir.path}/pack.json').writeAsBytesSync(packBytes);
  final manifest = {
    'pack_id': _sampleId,
    'version': _sampleVersion,
    'min_schema': core['schema_version'],
    'languages': ['uz', 'ru', 'en'],
    'licence':
        'TEST PACK — a copy of one LabGuide draft card, for testing '
        'downloads only; not a clinical pack',
    'files': [
      {
        'path': 'pack.json',
        'size': packBytes.length,
        'sha256': sha256.convert(packBytes).toString(),
      },
    ],
  };
  File('${dir.path}/manifest.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
  );
  final index = {
    'catalog_version': 1,
    'packs': [
      {
        'pack_id': _sampleId,
        'status': 'test',
        'version': _sampleVersion,
        'manifest': '$_sampleId/$_sampleVersion/manifest.json',
        'size': packBytes.length,
        'languages': ['uz', 'ru', 'en'],
        'min_schema': core['schema_version'],
        'title': {
          'uz': 'Sinov paketi',
          'ru': 'Тестовый пакет',
          'en': 'Test pack',
        },
        'summary': {
          'uz':
              'Yuklab olish, tekshirish va yangilashni sinash uchun. Ichida '
              'asosiy paketdagi bitta draft kartaning nusxasi bor — klinik '
              'paket emas.',
          'ru':
              'Для проверки загрузки, контроля целостности и обновления. '
              'Внутри — копия одной черновой карточки из основного пакета; '
              'это не клинический пакет.',
          'en':
              'For testing download, integrity checks and updates. Contains '
              'a copy of one draft card from the core pack — not a clinical '
              'pack.',
        },
      },
    ],
  };
  File('packs/index.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(index)}\n',
  );
  stdout.writeln(
    'packs/index.json + $_sampleId $_sampleVersion: ${packBytes.length} bytes',
  );
}
