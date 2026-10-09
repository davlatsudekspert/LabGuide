import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'diff_eyes_free.dart';
import 'diff_eyes_free_settings.dart';
import 'diff_voice.dart';
import 'differential_content.dart';
import 'differential_controller.dart';

const eyesFreeSettingsRoute = '/lab/differential/count/eyes-free';
const eyesFreeRunRoute = '/lab/differential/count/eyes-free/run';

String _langName(AppLocalizations l, String? lang) => switch (lang) {
  'uz' => l.diffVoiceLangUz,
  'ru' => l.diffVoiceLangRu,
  'en' => l.diffVoiceLangEn,
  _ => '',
};

String _pulseName(AppLocalizations l, Pulse p) => switch (p) {
  Pulse.light => l.diffEfPulseLight,
  Pulse.medium => l.diffEfPulseMedium,
  _ => l.diffEfPulseHeavy,
};

/// "2 × o'rtacha" — hujayra naqshi bitta kuchdagi zarbalardan iborat.
String patternText(AppLocalizations l, DiffCell c) {
  final p = cellPatterns[c]!;
  return l.diffEfPattern(p.length, _pulseName(l, p.first));
}

/// Ovoz rejimiga rozilik (ogohlantirish o'qilgach). `true` — yoqildi.
Future<bool> confirmVoiceConsent(BuildContext context) async {
  final diff = context.services.differential;
  if (diff.eyesFree.voiceConsent) return true;
  final l = AppLocalizations.of(context);
  final ios = Theme.of(context).platform == TargetPlatform.iOS;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.diffVoiceConsentTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ios ? l.diffVoicePrivacyIos : l.diffVoicePrivacyAndroid),
            const SizedBox(height: 10),
            Text(l.diffVoiceNoNames),
            const SizedBox(height: 10),
            Text(l.diffVoiceAccuracy),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.actionCancel),
        ),
        TextButton(
          key: const ValueKey('voice-consent'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.diffVoiceConsentAction),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  await diff.setEyesFree(diff.eyesFree.copyWith(voiceConsent: true));
  return true;
}

// ───────────────────────── Sozlamalar ─────────────────────────

class DiffEyesFreeSettingsScreen extends StatefulWidget {
  const DiffEyesFreeSettingsScreen({super.key});

  @override
  State<DiffEyesFreeSettingsScreen> createState() =>
      _DiffEyesFreeSettingsScreenState();
}

class _DiffEyesFreeSettingsScreenState
    extends State<DiffEyesFreeSettingsScreen> {
  EyesFreeFeedback? _feedback;

  EyesFreeFeedback get _fb => _feedback ??= EyesFreeFeedback();

  @override
  void dispose() {
    unawaited(_feedback?.dispose());
    super.dispose();
  }

  Future<void> _set(EyesFreeSettings s) =>
      context.services.differential.setEyesFree(s);

  Future<void> _move(List<DiffCell> zones, int i, int delta) async {
    final s = context.services.differential.eyesFree;
    final j = i + delta;
    if (j < 0 || j >= zones.length) return;
    final next = [...zones];
    final c = next.removeAt(i);
    next.insert(j, c);
    await _set(s.copyWith(order: next));
  }

  Future<void> _toggleVoice(bool on) async {
    final diff = context.services.differential;
    if (on && !await confirmVoiceConsent(context)) return;
    await diff.setEyesFree(diff.eyesFree.copyWith(voice: on));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final diff = context.services.differential;
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    return ListenableBuilder(
      listenable: diff,
      builder: (context, _) {
        final s = diff.eyesFree;
        final zones = s.zones;
        final words = voiceWords[lang] ?? voiceWords['en']!;
        return LgPage(
          title: l.diffEfSettingsTitle,
          subtitle: l.diffEfSettingsSub,
          children: [
            LgPanel(
              soft: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.diffEfHowTitle, style: text.titleMedium),
                  const SizedBox(height: 6),
                  Text(l.diffEfHowBody, style: text.bodyMedium),
                  const SizedBox(height: 14),
                  LgButton(
                    key: const ValueKey('eyes-free-start'),
                    label: l.diffEfStart,
                    icon: Icons.touch_app_rounded,
                    onPressed: () => context.push(eyesFreeRunRoute),
                  ),
                ],
              ),
            ),
            LgSectionTitle(l.diffEfZonesTitle),
            Text(l.diffEfHandLabel, style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LgChoiceChip(
                  label: l.diffEfHandRight,
                  selected: !s.leftHanded,
                  onTap: () => _set(s.copyWith(leftHanded: false)),
                ),
                LgChoiceChip(
                  label: l.diffEfHandLeft,
                  selected: s.leftHanded,
                  onTap: () => _set(s.copyWith(leftHanded: true)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l.diffEfHandHint,
              style: text.bodySmall!.copyWith(color: p.sub),
            ),
            const SizedBox(height: 10),
            _ZonePreview(settings: s, lang: lang),
            _SwitchRow(
              title: l.diffEfOtherZone,
              subtitle: l.diffEfOtherZoneSub,
              value: s.includeOther,
              onChanged: (v) => _set(s.copyWith(includeOther: v)),
            ),
            _SwitchRow(
              title: l.diffEfUndoSwitch,
              subtitle: l.diffEfUndoSwitchSub,
              value: s.undoZone,
              onChanged: (v) => _set(s.copyWith(undoZone: v)),
            ),
            LgSectionTitle(l.diffEfOrderTitle),
            Text(
              l.diffEfOrderHint,
              style: text.bodySmall!.copyWith(color: p.sub),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < zones.length; i++)
              _OrderRow(
                index: i,
                name: diffCellButton[zones[i]]!.of(lang),
                onUp: i == 0 ? null : () => _move(zones, i, -1),
                onDown: i == zones.length - 1
                    ? null
                    : () => _move(zones, i, 1),
                upLabel: l.diffEfMoveUp(diffCellNames[zones[i]]!.of(lang)),
                downLabel: l.diffEfMoveDown(diffCellNames[zones[i]]!.of(lang)),
              ),
            LgSectionTitle(l.diffEfSignalsTitle),
            _SwitchRow(
              title: l.diffEfSound,
              subtitle: l.diffEfSoundSub,
              value: s.sound,
              onChanged: (v) => _set(s.copyWith(sound: v)),
            ),
            _SwitchRow(
              title: l.diffEfHaptics,
              subtitle: l.diffEfHapticsSub,
              value: s.haptics,
              onChanged: (v) => _set(s.copyWith(haptics: v)),
            ),
            const SizedBox(height: 8),
            Text(l.diffEfPatternsTitle, style: text.titleSmall),
            Text(
              l.diffEfPatternsHint,
              style: text.bodySmall!.copyWith(color: p.sub),
            ),
            const SizedBox(height: 4),
            for (final c in zones)
              _PatternRow(
                title: diffCellButton[c]!.of(lang),
                pattern: patternText(l, c),
                onTap: () {
                  _fb
                    ..sound = s.sound
                    ..haptics = true;
                  unawaited(_fb.preview(c));
                },
              ),
            _PatternRow(
              title: l.diffEfPatternTen,
              pattern: l.diffEfPatternTenDesc,
            ),
            _PatternRow(
              title: l.diffEfPatternDone,
              pattern: l.diffEfPatternDoneDesc,
            ),
            _PatternRow(
              title: l.diffEfUndoZone,
              pattern: l.diffEfPatternUndoDesc,
            ),
            LgSectionTitle(l.diffEfScreenTitle),
            _SwitchRow(
              title: l.diffEfAwake,
              subtitle: l.diffEfAwakeSub,
              value: s.keepAwake,
              onChanged: (v) => _set(s.copyWith(keepAwake: v)),
            ),
            LgSectionTitle(
              l.diffVoiceTitle,
              trailing: LgTag(l.diffVoiceExperimental, tone: LgTone.warning),
            ),
            _SwitchRow(
              key: const ValueKey('voice-switch'),
              title: l.diffVoiceSwitch,
              subtitle: l.diffVoiceSwitchSub,
              value: s.voice,
              onChanged: _toggleVoice,
            ),
            const SizedBox(height: 4),
            Text(l.diffVoiceLangLabel, style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in VoiceLanguage.values)
                  LgChoiceChip(
                    label: switch (v) {
                      VoiceLanguage.auto => l.diffVoiceLangAuto,
                      VoiceLanguage.uz => l.diffVoiceLangUz,
                      VoiceLanguage.ru => l.diffVoiceLangRu,
                      VoiceLanguage.en => l.diffVoiceLangEn,
                    },
                    selected: s.voiceLanguage == v,
                    onTap: () => _set(s.copyWith(voiceLanguage: v)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l.diffVoiceLangHint,
              style: text.bodySmall!.copyWith(color: p.sub),
            ),
            const SizedBox(height: 12),
            Text(l.diffVoiceWordsTitle, style: text.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in [...zones, null])
                  LgTag('${words[c]}'),
              ],
            ),
            LgNotice(
              ios ? l.diffVoicePrivacyIos : l.diffVoicePrivacyAndroid,
              title: l.diffVoicePrivacyTitle,
            ),
            Text(l.diffVoiceNoNames, style: text.bodySmall),
            const SizedBox(height: 6),
            Text(
              l.diffVoiceAccuracy,
              style: text.bodySmall!.copyWith(color: p.sub),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: Text(subtitle),
    value: value,
    onChanged: onChanged,
  );
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({
    required this.index,
    required this.name,
    required this.onUp,
    required this.onDown,
    required this.upLabel,
    required this.downLabel,
  });

  final int index;
  final String name;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final String upLabel;
  final String downLabel;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.soft, shape: BoxShape.circle),
              child: Text(
                '${index + 1}',
                style: text.labelMedium!.copyWith(color: p.brand),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: text.bodyLarge)),
          IconButton(
            tooltip: upLabel,
            onPressed: onUp,
            icon: const Icon(Icons.arrow_upward_rounded),
          ),
          IconButton(
            tooltip: downLabel,
            onPressed: onDown,
            icon: const Icon(Icons.arrow_downward_rounded),
          ),
        ],
      ),
    );
  }
}

class _PatternRow extends StatelessWidget {
  const _PatternRow({required this.title, required this.pattern, this.onTap});

  final String title;
  final String pattern;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            onTap == null ? Icons.vibration_rounded : Icons.play_circle_outline,
            color: p.brand,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: text.bodyMedium)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              pattern,
              textAlign: TextAlign.end,
              style: text.bodyMedium!.copyWith(color: p.sub),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return MergeSemantics(child: row);
    return MergeSemantics(
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

/// Zonalar joylashuvining kichik sxemasi (raqam = tartib).
class _ZonePreview extends StatelessWidget {
  const _ZonePreview({required this.settings, required this.lang});

  final EyesFreeSettings settings;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final zones = settings.zones;
    final slots = layoutZones(zones, leftHanded: settings.leftHanded);
    final rows = zoneRows(zones.length);
    return ExcludeSemantics(
      child: Center(
        child: Container(
          width: 168,
          height: 260,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: p.paper,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: p.line, width: 2),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              const gap = 4.0;
              final undoH = settings.undoZone ? 26.0 : 0.0;
              final rowH = (c.maxHeight - undoH - gap * rows) / rows;
              final colW = (c.maxWidth - gap) / 2;
              return Stack(
                children: [
                  if (settings.undoZone)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: undoH,
                      child: _box(
                        p.amberBg,
                        Icon(Icons.undo_rounded, size: 16, color: p.amber),
                      ),
                    ),
                  for (final s in slots)
                    Positioned(
                      left: s.col * (colW + gap),
                      width: s.span == 2 ? c.maxWidth : colW,
                      top: undoH + gap + s.row * (rowH + gap),
                      height: rowH,
                      child: _box(
                        s.cell == zones.first ? p.brand : p.soft,
                        Text(
                          '${zones.indexOf(s.cell) + 1}',
                          textScaler: TextScaler.noScaling,
                          style: text.titleSmall!.copyWith(
                            color: s.cell == zones.first ? p.onBrand : p.brand,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _box(Color color, Widget child) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(child: child),
  );
}

// ───────────────────────── Sanash ekrani ─────────────────────────

/// To'liq ekranli zonalar: pastki tablarsiz, tasodifiy navigatsiyasiz.
class DiffEyesFreeScreen extends StatefulWidget {
  const DiffEyesFreeScreen({super.key});

  @override
  State<DiffEyesFreeScreen> createState() => _DiffEyesFreeScreenState();
}

class _DiffEyesFreeScreenState extends State<DiffEyesFreeScreen> {
  late final DifferentialController _diff;
  late final EyesFreeFeedback _feedback;
  VoiceCounter? _voice;
  bool _awake = false;
  bool _voiceStarted = false;

  /// Bosilgan zona qisqa vaqt ajralib turadi (ko'rib turganlar uchun).
  DiffCell? _flash;
  bool _flashUndo = false;
  Timer? _flashTimer;

  // Ko'p barmoqli bosishni kuzatish.
  final _pointers = <int, Offset>{};
  int _maxPointers = 0;
  bool _moved = false;
  Offset? _first;
  Size _area = Size.zero;

  @override
  void initState() {
    super.initState();
    _diff = context.services.differential;
    _feedback = EyesFreeFeedback();
    _applySettings();
    if (_diff.eyesFree.keepAwake) {
      _awake = true;
      unawaited(DiffDevice.screenAwake.set(on: true));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = _diff.eyesFree;
    if (!_voiceStarted && s.voice && s.voiceConsent) {
      _voiceStarted = true;
      unawaited(_startVoice());
    }
  }

  void _applySettings() {
    final s = _diff.eyesFree;
    _feedback
      ..sound = s.sound
      ..haptics = s.haptics;
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    if (_awake) unawaited(DiffDevice.screenAwake.set(on: false));
    _voice?.dispose();
    unawaited(_feedback.dispose());
    super.dispose();
  }

  String get _lang => Localizations.localeOf(context).languageCode;

  void _announce(String msg) {
    if (!mounted) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        msg,
        Directionality.of(context),
      ),
    );
  }

  bool get _screenReader => MediaQuery.accessibleNavigationOf(context);

  void _count(DiffCell c) {
    final l = AppLocalizations.of(context);
    final outcome = _diff.tap(c);
    unawaited(_feedback.counted(c, outcome, _diff.total));
    if (outcome != TapOutcome.blocked) _showFlash(c);
    switch (outcome) {
      case TapOutcome.completed:
        _announce(l.diffDoneTitle(_diff.target));
      case TapOutcome.blocked:
        if (_screenReader) _announce(l.diffBlocked);
      case TapOutcome.added:
        if (_screenReader) {
          _announce(
            l.diffEfAnnounce(
              diffCellButton[c]!.of(_lang),
              _diff.count(c),
              _diff.total,
            ),
          );
        }
    }
  }

  void _undo() {
    final l = AppLocalizations.of(context);
    final c = _diff.undo();
    if (c == null) {
      unawaited(_feedback.blocked());
      if (_screenReader) _announce(l.diffEfNothingToUndo);
      return;
    }
    unawaited(_feedback.undone());
    _showFlash(null, undo: true);
    if (_screenReader) {
      _announce(l.diffEfUndone(diffCellButton[c]!.of(_lang), _diff.total));
    }
  }

  void _showFlash(DiffCell? c, {bool undo = false}) {
    _flashTimer?.cancel();
    setState(() {
      _flash = c;
      _flashUndo = undo;
    });
    _flashTimer = Timer(const Duration(milliseconds: 160), () {
      if (mounted) {
        setState(() {
          _flash = null;
          _flashUndo = false;
        });
      }
    });
  }

  // ── Bosishni aniqlash: bitta barmoq — zona, ikki barmoq — bekor ──

  void _onDown(PointerDownEvent e) {
    if (_pointers.isEmpty) {
      _maxPointers = 0;
      _moved = false;
      _first = e.localPosition;
    }
    _pointers[e.pointer] = e.localPosition;
    _maxPointers = math.max(_maxPointers, _pointers.length);
  }

  void _onMove(PointerMoveEvent e) {
    final start = _pointers[e.pointer];
    if (start != null && (e.localPosition - start).distance > 48) {
      _moved = true;
    }
  }

  void _onUp(PointerUpEvent e) {
    _pointers.remove(e.pointer);
    if (_pointers.isNotEmpty) return;
    if (_maxPointers >= 2) {
      _undo();
    } else if (!_moved && _first != null) {
      _hit(_first!);
    }
    _first = null;
  }

  void _onCancel(PointerCancelEvent e) {
    _pointers.remove(e.pointer);
    if (_pointers.isEmpty) _first = null;
  }

  void _hit(Offset pos) {
    final g = _ZoneGeometry(_area, _diff.eyesFree);
    final target = g.hit(pos);
    if (target == null) return;
    if (target.undo) {
      _undo();
    } else {
      _count(target.cell!);
    }
  }

  // ── Ovoz ──

  Future<void> _startVoice() async {
    final s = _diff.eyesFree;
    final v = _voice ??= VoiceCounter()..addListener(_onVoiceChanged);
    await v.start(
      pref: s.voiceLanguage,
      appLang: _lang,
      onCommand: (cmd) {
        if (!mounted) return;
        if (cmd.isUndo) {
          _undo();
        } else {
          _count(cmd.cell!);
        }
      },
    );
  }

  void _onVoiceChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggleVoice() async {
    final v = _voice;
    if (v != null && (v.active || v.state == VoiceState.starting)) {
      await v.stop();
      return;
    }
    if (!await confirmVoiceConsent(context)) return;
    if (!_diff.eyesFree.voice) {
      await _diff.setEyesFree(_diff.eyesFree.copyWith(voice: true));
    }
    await _startVoice();
  }

  void _exit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(eyesFreeSettingsRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    return ListenableBuilder(
      listenable: _diff,
      builder: (context, _) {
        _applySettings();
        final s = _diff.eyesFree;
        return Scaffold(
          backgroundColor: p.bg,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(
                  total: _diff.total,
                  target: _diff.target,
                  done: _diff.isComplete,
                  showMic: s.voice,
                  micOn:
                      _voice?.active == true ||
                      _voice?.state == VoiceState.starting,
                  onExit: _exit,
                  onMic: _toggleVoice,
                ),
                if (_voice != null && _voice!.state != VoiceState.off)
                  _VoiceStrip(
                    voice: _voice!,
                    appLang: _lang,
                    auto: s.voiceLanguage == VoiceLanguage.auto,
                    onRetry: _startVoice,
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Stack(
                      children: [
                        Positioned.fill(child: _zones(context, l, s)),
                        if (_diff.isComplete)
                          Center(
                            child: _DonePanel(
                              title: l.diffDoneTitle(_diff.target),
                              action: l.diffEfShowResult,
                              onAction: () => context.go(
                                '/lab/differential/count',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _zones(
    BuildContext context,
    AppLocalizations l,
    EyesFreeSettings s,
  ) => LayoutBuilder(
    builder: (context, c) {
      _area = Size(c.maxWidth, c.maxHeight);
      final g = _ZoneGeometry(_area, s);
      final lang = _lang;
      final zones = s.zones;
      return Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onDown,
        onPointerMove: _onMove,
        onPointerUp: _onUp,
        onPointerCancel: _onCancel,
        child: Stack(
          children: [
            if (s.undoZone)
              Positioned.fromRect(
                rect: g.undoRect,
                child: Semantics(
                  button: true,
                  label: '${l.diffEfUndoZone}. ${l.diffEfUndoHint}',
                  onTap: _undo,
                  child: ExcludeSemantics(
                    child: _UndoZone(
                      key: const ValueKey('ef-undo'),
                      flash: _flashUndo,
                      label: l.diffEfUndoZone,
                      hint: l.diffEfUndoHint,
                      enabled: _diff.canUndo,
                    ),
                  ),
                ),
              ),
            for (final slot in g.slots)
              Positioned.fromRect(
                rect: g.rectOf(slot),
                child: Semantics(
                  button: true,
                  label: l.diffEfZoneSemantics(
                    diffCellNames[slot.cell]!.of(lang),
                    _diff.count(slot.cell),
                    _diff.total,
                    _diff.target,
                  ),
                  onTap: () => _count(slot.cell),
                  customSemanticsActions: {
                    CustomSemanticsAction(label: l.diffEfUndoZone): _undo,
                  },
                  child: ExcludeSemantics(
                    child: _Zone(
                      key: ValueKey('ef-zone-${slot.cell.name}'),
                      number: zones.indexOf(slot.cell) + 1,
                      label: diffCellButton[slot.cell]!.of(lang),
                      count: _diff.count(slot.cell),
                      flash: _flash == slot.cell,
                      primary: zones.indexOf(slot.cell) < 2,
                      dimmed: _diff.isComplete,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

/// Zonalar geometriyasi — chizish va bosishni aniqlash uchun bir xil.
class _ZoneGeometry {
  factory _ZoneGeometry(Size size, EyesFreeSettings s) {
    // Landshaftda (keng ekran) — 4 ustun, zonalar past bo'lib qolmasin.
    final columns = size.width > size.height * 1.2 ? 4 : 2;
    return _ZoneGeometry._(
      size,
      s.undoZone,
      layoutZones(s.zones, leftHanded: s.leftHanded, columns: columns),
      zoneRows(s.zones.length, columns),
      columns,
    );
  }

  _ZoneGeometry._(this.size, this.undo, this.slots, this.rows, this.columns);

  static const gap = 8.0;

  final Size size;
  final bool undo;
  final List<ZoneSlot> slots;
  final int rows;
  final int columns;

  double get undoH =>
      undo ? math.min(math.max(56.0, size.height * 0.11), 96.0) : 0;
  double get top => undo ? undoH + gap : 0;
  double get rowH => (size.height - top - gap * (rows - 1)) / rows;
  double get colW => (size.width - gap * (columns - 1)) / columns;

  Rect get undoRect => Rect.fromLTWH(0, 0, size.width, undoH);

  Rect rectOf(ZoneSlot s) => Rect.fromLTWH(
    s.col * (colW + gap),
    top + s.row * (rowH + gap),
    colW * s.span + gap * (s.span - 1),
    rowH,
  );

  /// Nuqta qaysi zonaga tegishli (oraliqlar eng yaqin zonaga).
  ({bool undo, DiffCell? cell})? hit(Offset pos) {
    if (size.isEmpty) return null;
    if (undo && pos.dy < undoH + gap / 2) return (undo: true, cell: null);
    final row = ((pos.dy - top + gap / 2) / (rowH + gap)).floor().clamp(
      0,
      rows - 1,
    );
    final col = (pos.dx / (size.width / columns)).floor().clamp(
      0,
      columns - 1,
    );
    for (final s in slots) {
      if (s.row == row && col >= s.col && col < s.col + s.span) {
        return (undo: false, cell: s.cell);
      }
    }
    return null;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.total,
    required this.target,
    required this.done,
    required this.showMic,
    required this.micOn,
    required this.onExit,
    required this.onMic,
  });

  final int total;
  final int target;
  final bool done;
  final bool showMic;
  final bool micOn;
  final VoidCallback onExit;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('ef-exit'),
            tooltip: l.diffEfExit,
            onPressed: onExit,
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              label: '$total / $target',
              child: ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$total',
                          style: text.headlineMedium!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: done ? p.brand : p.ink,
                          ),
                        ),
                        TextSpan(
                          text: ' / $target',
                          style: text.titleMedium!.copyWith(color: p.sub),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showMic)
            IconButton(
              key: const ValueKey('ef-mic'),
              tooltip: micOn ? l.diffEfVoiceOff : l.diffEfVoiceOn,
              onPressed: onMic,
              isSelected: micOn,
              icon: Icon(
                micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                color: micOn ? p.brand : p.sub,
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _VoiceStrip extends StatelessWidget {
  const _VoiceStrip({
    required this.voice,
    required this.appLang,
    required this.auto,
    required this.onRetry,
  });

  final VoiceCounter voice;
  final String appLang;
  final bool auto;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final langName = _langName(l, voice.lang);
    final (String msg, bool error) = switch (voice.state) {
      VoiceState.starting => (l.diffVoiceStarting, false),
      VoiceState.listening || VoiceState.off => (
        voice.lastHeard.isEmpty
            ? l.diffVoiceListening(langName)
            : voice.lastMatched == 0
            ? l.diffVoiceNotUnderstood(voice.lastHeard)
            : l.diffVoiceHeard(voice.lastHeard),
        false,
      ),
      VoiceState.permissionDenied => (l.diffVoicePermissionDenied, true),
      VoiceState.unavailable => (l.diffVoiceUnavailable, true),
      VoiceState.languageUnavailable => (l.diffVoiceLanguageUnavailable, true),
      VoiceState.onDeviceUnavailable => (l.diffVoiceOnDeviceUnavailable, true),
      VoiceState.failed => (l.diffVoiceFailed, true),
    };
    final fallback =
        auto &&
        voice.state == VoiceState.listening &&
        voice.lang != null &&
        voice.lang != appLang;
    // Zonalarga joy qolsin: matn qisqa (2 qator); xato bo'lsa bosib
    // to'liq matnni o'qish mumkin.
    final strip = Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: error ? p.amberBg : p.soft,
        borderRadius: BorderRadius.circular(LgRadius.chip),
      ),
      child: Row(
        children: [
          Icon(
            error ? Icons.mic_off_rounded : Icons.graphic_eq_rounded,
            size: 20,
            color: error ? p.danger : p.brand,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fallback ? '$msg\n${l.diffVoiceFallback(langName)}' : msg,
              style: text.bodySmall!.copyWith(color: p.ink),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (error) Icon(Icons.info_outline_rounded, size: 20, color: p.sub),
          if (voice.state == VoiceState.failed)
            TextButton(onPressed: onRetry, child: Text(l.diffVoiceRetry)),
        ],
      ),
    );
    final full = fallback ? '$msg ${l.diffVoiceFallback(langName)}' : msg;
    return Semantics(
      liveRegion: true,
      container: true,
      label: full,
      child: ExcludeSemantics(
        child: error || fallback
            ? GestureDetector(
                key: const ValueKey('ef-voice-strip'),
                behavior: HitTestBehavior.opaque,
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l.diffVoiceTitle),
                    content: SingleChildScrollView(child: Text(full)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          MaterialLocalizations.of(context).okButtonLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                child: strip,
              )
            : strip,
      ),
    );
  }
}

class _Zone extends StatelessWidget {
  const _Zone({
    super.key,
    required this.number,
    required this.label,
    required this.count,
    required this.flash,
    required this.primary,
    required this.dimmed,
  });

  final int number;
  final String label;
  final int count;
  final bool flash;
  final bool primary;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final bg = flash ? p.brand : (primary ? p.soft : p.paper);
    final fg = flash ? p.onBrand : p.ink;
    return AnimatedOpacity(
      opacity: dimmed ? 0.45 : 1,
      duration: const Duration(milliseconds: 150),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(LgRadius.card),
          border: Border.all(color: p.line),
        ),
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '$number',
                textScaler: TextScaler.noScaling,
                style: text.labelMedium!.copyWith(
                  color: flash ? p.onBrand : p.sub,
                ),
              ),
            ),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: text.displaySmall!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: flash ? p.onBrand : p.brand,
                      ),
                    ),
                    Text(
                      label,
                      style: text.titleMedium!.copyWith(color: fg),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UndoZone extends StatelessWidget {
  const _UndoZone({
    super.key,
    required this.flash,
    required this.label,
    required this.hint,
    required this.enabled,
  });

  final bool flash;
  final String label;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: flash ? p.amber : p.amberBg,
        borderRadius: BorderRadius.circular(LgRadius.card),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.undo_rounded,
                color: flash ? p.onBrand : p.amber,
                size: 28,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: text.titleMedium!.copyWith(
                      color: flash ? p.onBrand : p.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    hint,
                    style: text.bodySmall!.copyWith(
                      color: flash ? p.onBrand : p.sub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonePanel extends StatelessWidget {
  const _DonePanel({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        color: p.paper,
        borderRadius: BorderRadius.circular(LgRadius.hero),
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24)],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: p.brand, size: 40),
            const SizedBox(height: 8),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            LgButton(
              key: const ValueKey('ef-show-result'),
              label: action,
              icon: Icons.table_chart_outlined,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }
}
