import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Apple "required reason API" qoidasi (developer.apple.com/news/upcoming-requirements,
/// 2024-05-01 dan): ilova ham, kutubxonalar ham sabab kodini e'lon qilishi kerak.
/// Runner'da PrivacyInfo.xcprivacy bo'lishi, Xcode loyihasiga ulangani va
/// ilovaning o'z Swift kodi (AppDelegate/SceneDelegate) manifestda e'lon
/// qilinmagan API'dan foydalanmayotgani shu testda tekshiriladi.
void main() {
  final manifest = File('ios/Runner/PrivacyInfo.xcprivacy');

  test("Runner/PrivacyInfo.xcprivacy bor va kuzatish yo'q", () {
    expect(manifest.existsSync(), isTrue);
    final xml = manifest.readAsStringSync();
    expect(RegExp(r'NSPrivacyTracking</key>\s*<false/>').hasMatch(xml), isTrue);
    expect(xml, contains('NSPrivacyAccessedAPITypes'));
    expect(xml, contains('NSPrivacyCollectedDataTypes'));
    expect(xml, contains('NSPrivacyTrackingDomains'));
  });

  test('manifest Xcode loyihasida Runner resurslariga ulangan', () {
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    // PBXBuildFile yozuvi + Runner "Resources" bosqichidagi qator.
    expect(
      RegExp(r'PrivacyInfo\.xcprivacy in Resources').allMatches(pbx).length,
      2,
    );
    expect(pbx, contains('path = PrivacyInfo.xcprivacy'));
  });

  test("e'lon qilingan ma'lumot turlari App Store jadvaliga mos", () {
    final xml = manifest.readAsStringSync();
    final types = RegExp(r'<string>(NSPrivacyCollectedDataType\w+)</string>')
        .allMatches(xml)
        .map((m) => m.group(1)!)
        .where((t) => !t.contains('Purpose'))
        .toSet();
    expect(types, {
      'NSPrivacyCollectedDataTypeEmailAddress',
      'NSPrivacyCollectedDataTypeUserID',
      'NSPrivacyCollectedDataTypeOtherUserContent',
      'NSPrivacyCollectedDataTypeProductInteraction',
    });
    // Har bir tur: bog'langan, kuzatish uchun emas.
    expect(
      RegExp(r'NSPrivacyCollectedDataTypeLinked</key>\s*<true/>')
          .allMatches(xml)
          .length,
      4,
    );
    expect(
      RegExp(r'NSPrivacyCollectedDataTypeTracking</key>\s*<false/>')
          .allMatches(xml)
          .length,
      4,
    );
  });

  test("Runner o'z kodida required-reason API yo'q (manifest bo'sh)", () {
    final xml = manifest.readAsStringSync();
    final empty = RegExp(r'NSPrivacyAccessedAPITypes</key>\s*<array/>')
        .hasMatch(xml);
    // Manifest bo'sh bo'lsa, o'z Swift kodi quyidagilarni ishlatmasligi shart.
    final risky = RegExp(
      r'UserDefaults|systemUptime|mach_absolute_time|creationDate|'
      r'modificationDate|fileModificationDate|volumeAvailableCapacity|'
      r'systemFreeSize|activeInputModes|\bstat\(|\bfstat\(',
    );
    final sources = Directory('ios/Runner')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.swift') || f.path.endsWith('.m'));
    expect(sources, isNotEmpty);
    if (empty) {
      for (final f in sources) {
        expect(
          risky.hasMatch(f.readAsStringSync()),
          isFalse,
          reason:
              '${f.path}: required-reason API ishlatilgan — '
              'PrivacyInfo.xcprivacy ga sabab kodini yozing',
        );
      }
    }
  });
}
