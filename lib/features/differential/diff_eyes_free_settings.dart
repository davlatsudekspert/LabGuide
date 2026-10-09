/// Leykoformula: "ko'rmasdan sanash" rejimi sozlamalari va zonalar
/// joylashuvi (sof mantiq — platformaga bog'liq emas).
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'differential_content.dart';

/// Buyruqlar tili (ovozli sanash).
enum VoiceLanguage { auto, uz, ru, en }

/// Rejim sozlamalari (faqat qurilmada).
@immutable
class EyesFreeSettings {
  const EyesFreeSettings({
    this.order = defaultOrder,
    this.includeOther = true,
    this.leftHanded = false,
    this.undoZone = true,
    this.sound = true,
    this.haptics = true,
    this.keepAwake = false,
    this.voice = false,
    this.voiceLanguage = VoiceLanguage.auto,
    this.voiceConsent = false,
  });

  factory EyesFreeSettings.fromJson(Map<String, Object?> json) {
    final names = DiffCell.values.asNameMap();
    final order = <DiffCell>[
      for (final n in (json['order'] as List? ?? const []).cast<String>())
        ?names[n],
    ];
    return EyesFreeSettings(
      order: _normalizeOrder(order),
      includeOther: json['other'] as bool? ?? true,
      leftHanded: json['left'] as bool? ?? false,
      undoZone: json['undoZone'] as bool? ?? true,
      sound: json['sound'] as bool? ?? true,
      haptics: json['haptics'] as bool? ?? true,
      keepAwake: json['awake'] as bool? ?? false,
      voice: json['voice'] as bool? ?? false,
      voiceLanguage:
          VoiceLanguage.values.asNameMap()[json['voiceLang']] ??
          VoiceLanguage.auto,
      voiceConsent: json['voiceConsent'] as bool? ?? false,
    );
  }

  /// Birinchi zona — bosh barmoqqa eng yaqin (eng ko'p uchraydigan turlar).
  static const defaultOrder = [
    DiffCell.segmented,
    DiffCell.lymphocyte,
    DiffCell.monocyte,
    DiffCell.eosinophil,
    DiffCell.band,
    DiffCell.basophil,
    DiffCell.other,
  ];

  final List<DiffCell> order;

  /// "Boshqa (blast…)" zonasi (7 zona); o'chirilsa 6 zona.
  final bool includeOther;

  /// Chap qo'l: zonalar ko'zgudagidek joylashadi.
  final bool leftHanded;

  /// Tepada katta "Bekor" zonasi (ikki barmoq bilan bosish doim ishlaydi).
  final bool undoZone;
  final bool sound;
  final bool haptics;

  /// Sanash paytida ekran o'chmasin.
  final bool keepAwake;

  /// Ovozli buyruqlar (eksperimental) yoqilgan.
  final bool voice;
  final VoiceLanguage voiceLanguage;

  /// Foydalanuvchi ovoz qayerda qayta ishlanishi haqidagi ogohlantirishni
  /// o'qib, rozilik bergan.
  final bool voiceConsent;

  /// Ekranda ko'rinadigan zonalar tartibi.
  List<DiffCell> get zones => [
    for (final c in order)
      if (c != DiffCell.other || includeOther) c,
  ];

  EyesFreeSettings copyWith({
    List<DiffCell>? order,
    bool? includeOther,
    bool? leftHanded,
    bool? undoZone,
    bool? sound,
    bool? haptics,
    bool? keepAwake,
    bool? voice,
    VoiceLanguage? voiceLanguage,
    bool? voiceConsent,
  }) => EyesFreeSettings(
    order: order == null ? this.order : _normalizeOrder(order),
    includeOther: includeOther ?? this.includeOther,
    leftHanded: leftHanded ?? this.leftHanded,
    undoZone: undoZone ?? this.undoZone,
    sound: sound ?? this.sound,
    haptics: haptics ?? this.haptics,
    keepAwake: keepAwake ?? this.keepAwake,
    voice: voice ?? this.voice,
    voiceLanguage: voiceLanguage ?? this.voiceLanguage,
    voiceConsent: voiceConsent ?? this.voiceConsent,
  );

  Map<String, Object?> toJson() => {
    'order': [for (final c in order) c.name],
    'other': includeOther,
    'left': leftHanded,
    'undoZone': undoZone,
    'sound': sound,
    'haptics': haptics,
    'awake': keepAwake,
    'voice': voice,
    'voiceLang': voiceLanguage.name,
    'voiceConsent': voiceConsent,
  };

  /// Takrorlarni olib tashlaydi va yetishmagan turlarni oxiriga qo'shadi.
  static List<DiffCell> _normalizeOrder(List<DiffCell> order) {
    final out = <DiffCell>[];
    for (final c in [...order, ...defaultOrder]) {
      if (!out.contains(c)) out.add(c);
    }
    return List.unmodifiable(out);
  }
}

EyesFreeSettings decodeEyesFree(String? raw) {
  if (raw == null) return const EyesFreeSettings();
  try {
    return EyesFreeSettings.fromJson(
      (jsonDecode(raw) as Map).cast<String, Object?>(),
    );
  } on Object {
    return const EyesFreeSettings();
  }
}

String encodeEyesFree(EyesFreeSettings s) => jsonEncode(s.toJson());

// ───────────────────────── Zonalar joylashuvi ─────────────────────────

/// Bitta zona: katakdagi o'rni (ustun/qator) va egallagan ustunlar soni.
@immutable
class ZoneSlot {
  const ZoneSlot(this.cell, this.row, this.col, {this.span = 1});

  final DiffCell cell;

  /// 0 — eng yuqori qator.
  final int row;
  final int col;
  final int span;

  @override
  String toString() => 'ZoneSlot(${cell.name}, r$row c$col x$span)';
}

/// Zonalar to'ri: [columns] ustun (portret — 2, landshaft — 4). Tartibdagi
/// birinchi zona bosh barmoqqa eng yaqin — pastki qatorda, o'ng qo'lda
/// o'ngda (chap qo'lda chapda). Yuqori qator to'lmasa, oxirgi zona qolgan
/// ustunlarni egallaydi (bo'sh joy qolmaydi).
List<ZoneSlot> layoutZones(
  List<DiffCell> zones, {
  required bool leftHanded,
  int columns = 2,
}) {
  final n = zones.length;
  final rows = zoneRows(n, columns);
  return [
    for (var i = 0; i < n; i++) _slot(zones[i], i, n, rows, columns, leftHanded),
  ];
}

ZoneSlot _slot(DiffCell c, int i, int n, int rows, int columns, bool left) {
  final r = i ~/ columns;
  final pos = i % columns;
  final inRow = math.min(columns, n - r * columns);
  final span = pos == inRow - 1 ? columns - pos : 1;
  final col = left ? pos : columns - pos - span;
  return ZoneSlot(c, rows - 1 - r, col, span: span);
}

int zoneRows(int count, [int columns = 2]) =>
    (count + columns - 1) ~/ columns;
