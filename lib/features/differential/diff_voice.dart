/// Leykoformula: ovoz bilan sanash (EKSPERIMENTAL).
///
/// Nutqni tanish — qurilmaning tizim xizmati (iOS: SFSpeechRecognizer,
/// Android: SpeechRecognizer), `speech_to_text` plagini orqali. Ilova ovozni
/// o'zi hech qayerga yubormaydi va saqlamaydi. iOS'da "faqat qurilmada"
/// rejimi talab qilinadi (qo'llanmasa — rejim ishlamaydi). Android'da
/// oflayn tanish faqat "afzal" deb so'raladi: tizim xizmati ovozni
/// serverga yuborishi mumkin — UI'da bu haqda ogohlantiriladi.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'diff_eyes_free_settings.dart';
import 'differential_content.dart';

// ───────────────────────── Buyruqlar parseri ─────────────────────────

/// Bitta ovozli buyruq: hujayra (+1) yoki bekor qilish.
@immutable
class VoiceCommand {
  const VoiceCommand.count(DiffCell this.cell);
  const VoiceCommand.undo() : cell = null;

  final DiffCell? cell;
  bool get isUndo => cell == null;

  @override
  bool operator ==(Object other) => other is VoiceCommand && other.cell == cell;

  @override
  int get hashCode => cell.hashCode;

  @override
  String toString() => isUndo ? 'undo' : cell!.name;
}

/// "Neytrofil" so'zi alohida ma'noga ega: tayoqcha/segment so'zidan keyin
/// kelsa — o'sha nomning davomi ("tayoqcha yadroli neytrofil").
enum _Kind { cell, neutrophil, undo }

class _Word {
  const _Word(this.stem, this.kind, {this.cell, this.exact = false});

  final String stem;
  final _Kind kind;
  final DiffCell? cell;

  /// Qisqa so'zlar faqat to'liq mos kelganda (masalan "eos", "mono").
  final bool exact;

  bool matches(String token) => exact ? token == stem : token.startsWith(stem);
}

const _seg = DiffCell.segmented;

/// Lug'at: o'zbek (lotin va kirill), rus, ingliz. Ildiz (prefiks) bo'yicha
/// mos keladi — kelishik qo'shimchalari ("лимфоцита") ham tushuniladi.
const _words = <_Word>[
  // Neytrofil (segment yadroli).
  _Word('neytrof', _Kind.neutrophil, cell: _seg),
  _Word('нейтроф', _Kind.neutrophil, cell: _seg),
  _Word('neutroph', _Kind.neutrophil, cell: _seg),
  _Word('neutrof', _Kind.neutrophil, cell: _seg),
  _Word('segment', _Kind.cell, cell: _seg),
  _Word('сегмент', _Kind.cell, cell: _seg),
  _Word('seg', _Kind.cell, cell: _seg, exact: true),
  _Word('segs', _Kind.cell, cell: _seg, exact: true),
  // Tayoqcha yadroli.
  _Word('tayoq', _Kind.cell, cell: DiffCell.band),
  _Word('таеқ', _Kind.cell, cell: DiffCell.band),
  _Word('таек', _Kind.cell, cell: DiffCell.band),
  _Word('палочк', _Kind.cell, cell: DiffCell.band),
  _Word('band', _Kind.cell, cell: DiffCell.band, exact: true),
  _Word('bands', _Kind.cell, cell: DiffCell.band, exact: true),
  // Limfotsit.
  _Word('limf', _Kind.cell, cell: DiffCell.lymphocyte),
  _Word('лимф', _Kind.cell, cell: DiffCell.lymphocyte),
  _Word('lymph', _Kind.cell, cell: DiffCell.lymphocyte),
  // Monotsit.
  _Word('monots', _Kind.cell, cell: DiffCell.monocyte),
  _Word('monos', _Kind.cell, cell: DiffCell.monocyte),
  _Word('monoc', _Kind.cell, cell: DiffCell.monocyte),
  _Word('моноц', _Kind.cell, cell: DiffCell.monocyte),
  _Word('mono', _Kind.cell, cell: DiffCell.monocyte, exact: true),
  _Word('моно', _Kind.cell, cell: DiffCell.monocyte, exact: true),
  // Eozinofil.
  _Word('eozin', _Kind.cell, cell: DiffCell.eosinophil),
  _Word('эозин', _Kind.cell, cell: DiffCell.eosinophil),
  _Word('eosin', _Kind.cell, cell: DiffCell.eosinophil),
  _Word('eos', _Kind.cell, cell: DiffCell.eosinophil, exact: true),
  // Bazofil.
  _Word('bazof', _Kind.cell, cell: DiffCell.basophil),
  _Word('базоф', _Kind.cell, cell: DiffCell.basophil),
  _Word('basoph', _Kind.cell, cell: DiffCell.basophil),
  _Word('baso', _Kind.cell, cell: DiffCell.basophil, exact: true),
  // Boshqa (atipik, blast).
  _Word('boshqa', _Kind.cell, cell: DiffCell.other),
  _Word('бошқа', _Kind.cell, cell: DiffCell.other),
  _Word('другие', _Kind.cell, cell: DiffCell.other, exact: true),
  _Word('другая', _Kind.cell, cell: DiffCell.other, exact: true),
  _Word('другой', _Kind.cell, cell: DiffCell.other, exact: true),
  _Word('other', _Kind.cell, cell: DiffCell.other, exact: true),
  _Word('blast', _Kind.cell, cell: DiffCell.other),
  _Word('бласт', _Kind.cell, cell: DiffCell.other),
  // Bekor qilish.
  _Word('bekor', _Kind.undo),
  _Word('бекор', _Kind.undo),
  _Word('отмен', _Kind.undo),
  _Word('назад', _Kind.undo, exact: true),
  _Word('undo', _Kind.undo, exact: true),
  _Word('cancel', _Kind.undo, exact: true),
];

/// Ekranda ko'rsatiladigan asosiy so'zlar (til bo'yicha).
const voiceWords = <String, Map<DiffCell?, String>>{
  'uz': {
    DiffCell.segmented: 'neytrofil',
    DiffCell.band: 'tayoqcha',
    DiffCell.lymphocyte: 'limfotsit',
    DiffCell.monocyte: 'monotsit',
    DiffCell.eosinophil: 'eozinofil',
    DiffCell.basophil: 'bazofil',
    DiffCell.other: 'boshqa',
    null: 'bekor',
  },
  'ru': {
    DiffCell.segmented: 'нейтрофил',
    DiffCell.band: 'палочка',
    DiffCell.lymphocyte: 'лимфоцит',
    DiffCell.monocyte: 'моноцит',
    DiffCell.eosinophil: 'эозинофил',
    DiffCell.basophil: 'базофил',
    DiffCell.other: 'другие',
    null: 'отмена',
  },
  'en': {
    DiffCell.segmented: 'neutrophil',
    DiffCell.band: 'band',
    DiffCell.lymphocyte: 'lymphocyte',
    DiffCell.monocyte: 'monocyte',
    DiffCell.eosinophil: 'eosinophil',
    DiffCell.basophil: 'basophil',
    DiffCell.other: 'other',
    null: 'undo',
  },
};

final _apostrophes = RegExp('[\'’‘ʻʼ`]');
final _nonLetters = RegExp(r'[^a-zа-яўқғҳ]+');

/// Tanilgan matnni buyruqlar ketma-ketligiga aylantiradi. Bir gapda bir
/// nechta so'z bo'lishi mumkin ("limfotsit limfotsit neytrofil").
List<VoiceCommand> parseVoiceCommands(String text) {
  final norm = text
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(_apostrophes, '')
      .replaceAll(_nonLetters, ' ')
      .trim();
  if (norm.isEmpty) return const [];
  final out = <VoiceCommand>[];
  // Oxirgi buyruq tayoqcha/segment bo'lsa, keyingi "neytrofil" uning
  // davomi hisoblanadi (orada boshqa buyruq bo'lmasa).
  var lastNeutrophilName = false;
  for (final token in norm.split(' ')) {
    final w = _words.where((w) => w.matches(token)).firstOrNull;
    if (w == null) continue;
    switch (w.kind) {
      case _Kind.undo:
        out.add(const VoiceCommand.undo());
        lastNeutrophilName = false;
      case _Kind.neutrophil:
        if (lastNeutrophilName) {
          lastNeutrophilName = false;
          continue;
        }
        out.add(VoiceCommand.count(w.cell!));
      case _Kind.cell:
        out.add(VoiceCommand.count(w.cell!));
        lastNeutrophilName = w.cell == DiffCell.band || w.cell == _seg;
    }
  }
  return out;
}

// ───────────────────────── Nutqni tanish dvigateli ─────────────────────────

enum VoiceInit { ready, permissionDenied, unavailable }

/// Tanish xatosi: [code] — plagin kodi (foydalanuvchiga ko'rsatilmaydi).
typedef VoiceErrorCallback = void Function(String code, bool permanent);

abstract class SpeechEngine {
  Future<VoiceInit> init({
    required VoiceErrorCallback onError,
    required void Function(String status) onStatus,
  });

  /// Qurilmada mavjud tillar (masalan `ru-RU`, `en_US`).
  Future<List<String>> localeIds();

  /// Bitta tinglash seansi. Xato bo'lsa [PlatformException] tashlanishi
  /// mumkin (masalan, `onDeviceError`).
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
  });

  Future<void> stop();

  /// Ovoz qurilmadan chiqmasligi kafolatlanganmi (iOS — ha, Android — yo'q).
  bool get onDeviceGuaranteed;
}

/// `speech_to_text` orqali haqiqiy dvigatel.
class PluginSpeechEngine implements SpeechEngine {
  final _stt = SpeechToText();

  @override
  bool get onDeviceGuaranteed => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<VoiceInit> init({
    required VoiceErrorCallback onError,
    required void Function(String status) onStatus,
  }) async {
    try {
      final ok = await _stt.initialize(
        onError: (e) => onError(e.errorMsg, e.permanent),
        onStatus: onStatus,
      );
      if (ok) return VoiceInit.ready;
      return await _stt.hasPermission
          ? VoiceInit.unavailable
          : VoiceInit.permissionDenied;
    } on PlatformException catch (e) {
      return e.code.contains('ermission')
          ? VoiceInit.permissionDenied
          : VoiceInit.unavailable;
    } on Object {
      return VoiceInit.unavailable;
    }
  }

  @override
  Future<List<String>> localeIds() async {
    try {
      return [for (final l in await _stt.locales()) l.localeId];
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
  }) => _stt.listen(
    onResult: (r) => onResult(r.recognizedWords, r.finalResult),
    listenOptions: SpeechListenOptions(
      // Faqat yakuniy natija — oraliq gipotezalar ikki marta sanalmasin.
      partialResults: false,
      onDevice: true,
      listenMode: ListenMode.confirmation,
      cancelOnError: false,
      localeId: localeId,
      pauseFor: const Duration(seconds: 2),
      listenFor: const Duration(seconds: 50),
    ),
  );

  @override
  Future<void> stop() async {
    try {
      await _stt.stop();
    } on Object {
      // e'tiborsiz
    }
  }
}

// ───────────────────────── Seans ─────────────────────────

enum VoiceState {
  off,
  starting,
  listening,
  permissionDenied,
  unavailable,
  languageUnavailable,
  onDeviceUnavailable,
  failed,
}

/// Ilova tilidan va tanlovdan qurilmadagi tanish tilini tanlash.
/// `null` — mos til yo'q.
({String localeId, String lang})? pickVoiceLocale(
  List<String> available,
  VoiceLanguage pref,
  String appLang,
) {
  final order = switch (pref) {
    VoiceLanguage.auto => [appLang, 'ru', 'en'],
    VoiceLanguage.uz => ['uz'],
    VoiceLanguage.ru => ['ru'],
    VoiceLanguage.en => ['en'],
  };
  for (final lang in order) {
    // Avval mintaqaviy asosiy variant (uz-UZ, ru-RU, en-US), keyin istalgan.
    final main = {'uz': 'uz_uz', 'ru': 'ru_ru', 'en': 'en_us'}[lang];
    String? found;
    for (final id in available) {
      final n = id.toLowerCase().replaceAll('-', '_');
      if (n == main) {
        found = id;
        break;
      }
      if (found == null && (n == lang || n.startsWith('${lang}_'))) found = id;
    }
    if (found != null) return (localeId: found, lang: lang);
  }
  return null;
}

/// Uzluksiz tinglash: har yakuniy natijadan keyin qayta boshlanadi.
class VoiceCounter extends ChangeNotifier {
  VoiceCounter({SpeechEngine? engine, this.restartDelay = _restartDelay})
    : engine = engine ?? DiffVoiceDevice.engine();

  static const _restartDelay = Duration(milliseconds: 250);

  final SpeechEngine engine;
  final Duration restartDelay;

  VoiceState _state = VoiceState.off;
  VoiceState get state => _state;

  /// Tanlangan tanish tili ('uz' | 'ru' | 'en') va qurilmadagi id.
  String? lang;
  String? localeId;

  /// Oxirgi eshitilgan matn va undan topilgan buyruqlar soni.
  String lastHeard = '';
  int lastMatched = 0;

  /// Texnik xato kodi (faqat "failed" holatida, diagnostika uchun).
  String? errorCode;

  bool _active = false;
  bool _initDone = false;
  int _hardErrors = 0;
  void Function(VoiceCommand)? _onCommand;

  bool get active => _active;

  Future<void> start({
    required VoiceLanguage pref,
    required String appLang,
    required void Function(VoiceCommand) onCommand,
  }) async {
    if (_active) return;
    _active = true;
    _onCommand = onCommand;
    _hardErrors = 0;
    errorCode = null;
    _set(VoiceState.starting);
    if (!_initDone) {
      final init = await engine.init(onError: _onError, onStatus: _onStatus);
      if (!_active) return;
      if (init != VoiceInit.ready) {
        return _fail(
          init == VoiceInit.permissionDenied
              ? VoiceState.permissionDenied
              : VoiceState.unavailable,
        );
      }
      _initDone = true;
    }
    final picked = pickVoiceLocale(await engine.localeIds(), pref, appLang);
    if (!_active) return;
    if (picked == null) return _fail(VoiceState.languageUnavailable);
    lang = picked.lang;
    localeId = picked.localeId;
    await _listen();
  }

  Future<void> stop() async {
    _active = false;
    await engine.stop();
    _set(VoiceState.off);
  }

  Future<void> _listen() async {
    if (!_active) return;
    try {
      await engine.listen(localeId: localeId!, onResult: _onResult);
      if (_active) _set(VoiceState.listening);
    } on PlatformException catch (e) {
      if (e.code == 'onDeviceError') {
        return _fail(VoiceState.onDeviceUnavailable);
      }
      errorCode = e.code;
      _hardError();
    } on Object catch (e) {
      errorCode = '$e';
      _hardError();
    }
  }

  void _onResult(String words, bool isFinal) {
    if (!isFinal || !_active) return;
    final cmds = parseVoiceCommands(words);
    lastHeard = words;
    lastMatched = cmds.length;
    if (cmds.isNotEmpty) _hardErrors = 0;
    notifyListeners();
    for (final c in cmds) {
      _onCommand?.call(c);
    }
  }

  void _onStatus(String status) {
    if (!_active) return;
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _restart();
    }
  }

  void _onError(String code, bool permanent) {
    if (!_active) return;
    switch (code) {
      case 'error_permission':
      case 'error_insufficient_permissions':
        _fail(VoiceState.permissionDenied);
      case 'error_language_not_supported':
      case 'error_language_unavailable':
        _fail(VoiceState.languageUnavailable);
      // Jimlik yoki tanilmagan so'z — oddiy hol, qayta tinglaymiz.
      case 'error_no_match':
      case 'error_speech_timeout':
      case 'error_retry':
      case 'error_busy':
        _restart();
      default:
        errorCode = code;
        if (permanent) _hardError();
    }
  }

  bool _restarting = false;

  void _restart() {
    if (!_active || _restarting) return;
    _restarting = true;
    Timer(restartDelay, () {
      _restarting = false;
      unawaited(_listen());
    });
  }

  void _hardError() {
    _hardErrors++;
    if (_hardErrors >= 3) {
      _fail(VoiceState.failed);
    } else {
      _restart();
    }
  }

  void _fail(VoiceState s) {
    _active = false;
    unawaited(engine.stop());
    _set(s);
  }

  void _set(VoiceState s) {
    _state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_active) {
      _active = false;
      unawaited(engine.stop());
    }
    super.dispose();
  }
}

/// Testlarda almashtiriladi.
abstract final class DiffVoiceDevice {
  static SpeechEngine Function() engine = PluginSpeechEngine.new;
}
