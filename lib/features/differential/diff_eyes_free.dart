/// Leykoformula: "ko'rmasdan sanash" (mikroskop) rejimi — tebranish
/// naqshlari, tovush signallari, ekranni yoqiq ushlash.
///
/// Rejim hisoblagichning o'zi kabi BEPUL; sanash [DifferentialController]
/// orqali o'tadi (bir xil qoralama, bir xil 100/200 chegarasi).
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'differential_content.dart';
import 'differential_controller.dart';

// ───────────────────────── Tebranish naqshlari ─────────────────────────

/// Bitta tebranish zarbasi.
enum Pulse { light, medium, heavy, selection, long }

/// Hujayra turiga xos naqsh: zarba turi (kuchi) va soni farqlanadi —
/// ko'z bilan qaramasdan qaysi zona bosilganini sezish uchun.
const cellPatterns = <DiffCell, List<Pulse>>{
  DiffCell.segmented: [Pulse.light],
  DiffCell.lymphocyte: [Pulse.medium],
  DiffCell.monocyte: [Pulse.heavy],
  DiffCell.eosinophil: [Pulse.light, Pulse.light],
  DiffCell.band: [Pulse.medium, Pulse.medium],
  DiffCell.basophil: [Pulse.heavy, Pulse.heavy],
  DiffCell.other: [Pulse.light, Pulse.light, Pulse.light],
};

/// Har 10-hujayradan keyin qo'shimcha (pauzadan so'ng) — uzun tebranish.
const tenPattern = [Pulse.long];

/// Maqsadga yetildi.
const donePattern = [Pulse.heavy, Pulse.heavy, Pulse.long];
const undoPattern = [Pulse.heavy, Pulse.selection];
const blockedPattern = [Pulse.long, Pulse.long];

/// Naqsh ichidagi zarbalar orasidagi pauza va qo'shimcha signal oldidan
/// pauza.
const pulseGap = Duration(milliseconds: 110);
const milestoneGap = Duration(milliseconds: 260);

Future<void> _playPulse(Pulse p) => switch (p) {
  Pulse.light => HapticFeedback.lightImpact(),
  Pulse.medium => HapticFeedback.mediumImpact(),
  Pulse.heavy => HapticFeedback.heavyImpact(),
  Pulse.selection => HapticFeedback.selectionClick(),
  Pulse.long => HapticFeedback.vibrate(),
};

// ───────────────────────── Tovush va qurilma ─────────────────────────

/// Signal tovushlari (`assets/differential/sounds/*.wav`, o'zimiz sintez
/// qilganmiz: tool/sounds/gen_diff_sounds.py).
enum Cue { tap, ten, done, undo, blocked }

abstract class CuePlayer {
  Future<void> play(Cue cue);
  Future<void> dispose();
}

/// audioplayers orqali: har signal uchun kichik pul (tez ketma-ket bosish).
/// Xato bo'lsa jim qoladi — sanash hech qachon to'xtamaydi.
class AssetCuePlayer implements CuePlayer {
  final Map<Cue, Future<AudioPool?>> _pools = {};

  Future<AudioPool?> _pool(Cue cue) => _pools[cue] ??= () async {
    try {
      return await AudioPool.create(
        source: AssetSource('differential/sounds/${cue.name}.wav'),
        maxPlayers: cue == Cue.tap ? 4 : 2,
        audioContext: AudioContextConfig(
          focus: AudioContextConfigFocus.mixWithOthers,
        ).build(),
      );
    } on Object {
      return null;
    }
  }();

  @override
  Future<void> play(Cue cue) async {
    try {
      await (await _pool(cue))?.start();
    } on Object {
      // Tovush ishlamasa — tebranish va ekran baribir ishlaydi.
    }
  }

  @override
  Future<void> dispose() async {
    for (final f in _pools.values) {
      try {
        await (await f)?.dispose();
      } on Object {
        // e'tiborsiz
      }
    }
    _pools.clear();
  }
}

class SilentCuePlayer implements CuePlayer {
  @override
  Future<void> play(Cue cue) async {}

  @override
  Future<void> dispose() async {}
}

/// Ekranni yoqiq ushlash.
abstract class ScreenAwake {
  Future<void> set({required bool on});
}

class WakelockScreenAwake implements ScreenAwake {
  const WakelockScreenAwake();

  @override
  Future<void> set({required bool on}) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } on Object {
      // Qo'llanmasa — e'tiborsiz (ekran tizim sozlamasiga ko'ra o'chadi).
    }
  }
}

/// Qurilma bilan bog'liq qismlar — testlarda almashtiriladi.
abstract final class DiffDevice {
  static CuePlayer Function() cuePlayer = AssetCuePlayer.new;
  static ScreenAwake screenAwake = const WakelockScreenAwake();

  /// Zarbalar orasidagi kutish (testda — darhol).
  static Future<void> Function(Duration) wait = Future<void>.delayed;
}

/// Bosish natijasiga ko'ra tovush + tebranish.
class EyesFreeFeedback {
  EyesFreeFeedback({CuePlayer? player})
    : _player = player ?? DiffDevice.cuePlayer();

  final CuePlayer _player;
  bool sound = true;
  bool haptics = true;

  /// Navbatdagi naqsh oldingisi tugagach boshlanadi (aralashib ketmasin).
  Future<void> _queue = Future.value();

  Future<void> _pattern(List<Pulse> pulses, {List<Pulse>? then}) {
    if (!haptics) return Future.value();
    final next = _queue.then((_) async {
      for (var i = 0; i < pulses.length; i++) {
        if (i > 0) await DiffDevice.wait(pulseGap);
        await _playPulse(pulses[i]);
      }
      if (then != null) {
        await DiffDevice.wait(milestoneGap);
        for (var i = 0; i < then.length; i++) {
          if (i > 0) await DiffDevice.wait(pulseGap);
          await _playPulse(then[i]);
        }
      }
    });
    _queue = next.catchError((Object _) {});
    return next;
  }

  Future<void> _cue(Cue c) => sound ? _player.play(c) : Future.value();

  /// Sanash bosilgandan keyin ([total] — bosishdan keyingi jami).
  Future<void> counted(DiffCell cell, TapOutcome outcome, int total) {
    switch (outcome) {
      case TapOutcome.blocked:
        return blocked();
      case TapOutcome.completed:
        return Future.wait([
          _cue(Cue.done),
          _pattern(cellPatterns[cell]!, then: donePattern),
        ]);
      case TapOutcome.added:
        final ten = total > 0 && total % 10 == 0;
        return Future.wait([
          _cue(ten ? Cue.ten : Cue.tap),
          _pattern(cellPatterns[cell]!, then: ten ? tenPattern : null),
        ]);
    }
  }

  Future<void> undone() => Future.wait([_cue(Cue.undo), _pattern(undoPattern)]);

  Future<void> blocked() =>
      Future.wait([_cue(Cue.blocked), _pattern(blockedPattern)]);

  /// Sozlamalarda naqshni sinab ko'rish.
  Future<void> preview(DiffCell cell) =>
      Future.wait([_cue(Cue.tap), _pattern(cellPatterns[cell]!)]);

  Future<void> dispose() => _player.dispose();
}
