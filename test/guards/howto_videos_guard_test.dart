// Qorovul: “Qanday foydalaniladi?” videolari tasodifan e’lon qilinmasin.
//
// assets/howto/videos.json ilova bilan birga do‘konga ketadi. Unda manzil
// paydo bo‘lishi — egasi qarori (hosting, maxfiylik siyosati, do‘kon
// izohlari; docs/video/DELIVERY_PLAN.md). Shuning uchun:
//  * ro‘yxat bo‘sh bo‘lsa — faylda hech qanday manzil (http) yo‘q;
//  * yozuv bo‘lsa — `owner_approval` docs/DECISIONS.md dagi mavjud qarorga
//    (`## D-NN.`) ishora qiladi va o‘sha qaror videolar haqida;
//  * maxfiylik siyosatida video hostingi tilga olingan;
//  * og‘ir video pleyer bog‘liqligi qo‘shilmagan (video tashqi ilovada).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/howto/howto_videos.dart';

void main() {
  final raw = File(kHowToVideosAsset).readAsStringSync();
  final json = jsonDecode(raw) as Map<String, Object?>;
  final videos = json['videos']! as List;

  test('videos.json pubspec assets ro‘yxatida', () {
    expect(File('pubspec.yaml').readAsStringSync(), contains('- assets/howto/'));
  });

  test('videos.json sxemaga mos (ilova tekshiruvchisi qabul qiladi)', () {
    expect(() => HowToVideoCatalog.parse(raw), returnsNormally);
  });

  test('egasi qarorisiz manzil yo‘q', () {
    if (videos.isEmpty) {
      expect(json['owner_approval'], isNull);
      expect(raw.toLowerCase(), isNot(contains('http')));
      return;
    }
    final id = json['owner_approval'] as String?;
    expect(id, isNotNull, reason: 'videolar bor — owner_approval kerak');
    final decisions = File('docs/DECISIONS.md').readAsStringSync();
    final heading = RegExp(
      '^## ${RegExp.escape(id!)}\\. (.*)\$',
      multiLine: true,
    ).firstMatch(decisions);
    expect(heading, isNotNull, reason: '$id docs/DECISIONS.md da yo‘q');
    expect(
      heading!.group(1)!.toLowerCase(),
      contains('video'),
      reason: '$id videolar haqidagi qaror emas',
    );
  });

  test('videolar e’lon qilinsa — maxfiylik siyosatida hosting tilga olingan', () {
    if (videos.isEmpty) return;
    final policy = File('docs/store/PRIVACY_POLICY.md').readAsStringSync();
    final hosts = {
      for (final v in videos) Uri.parse((v as Map)['url'] as String).host,
    };
    for (final h in hosts) {
      expect(policy, contains(h), reason: 'PRIVACY_POLICY.md da $h yo‘q');
    }
  });

  test('video pleyer bog‘liqligi yo‘q (video tizim ilovasida ochiladi)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final dep in [
      'video_player',
      'chewie',
      'better_player',
      'media_kit',
      'youtube_player',
      'flick_video_player',
    ]) {
      expect(
        RegExp('^\\s+$dep[a-z_]*:', multiLine: true).hasMatch(pubspec),
        isFalse,
        reason: dep,
      );
    }
  });

  test('MP4 fayllar repoga / ilovaga qo‘shilmagan', () {
    final offenders = [
      for (final dir in ['assets', 'docs'])
        for (final f in Directory(dir).listSync(recursive: true))
          if (f is File && RegExp(r'\.(mp4|m4v|mov|webm)$').hasMatch(f.path))
            f.path,
    ];
    expect(offenders, isEmpty);
  });
}
