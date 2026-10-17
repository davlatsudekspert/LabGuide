import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../design/tokens.dart';
import '../design/widgets/collapse_hysteresis.dart';
import '../l10n/gen/app_localizations.dart';

/// Har bir tabning oxirgi manzili va “faol tab qayta bosildi” hodisasi.
///
/// Boshqa tabga havola ([openInTab]) shu tab allaqachon o'sha bo'limning
/// ichida (masalan, ochiq QC to'plami yoki imtihon) bo'lsa, stekni
/// tashlab yubormaydi.
class TabMemory extends ChangeNotifier {
  final Map<int, Uri> _last = {};

  /// Qayta bosilgan tab indeksi (har bosishda [notifyListeners]).
  int? reselectedIndex;

  void record(int index, Uri location) => _last[index] = location;

  /// Oxirgi manzili [location] bo'limining ichida turgan tab (bo'lsa).
  /// So'rovli manzil (`?maker=…`) faqat aynan mos kelsa hisoblanadi.
  ///
  /// [exact] — faqat aynan shu sahifada turgan tab (ichkaridagi sahifa,
  /// masalan ochiq hujayra kartasi, hisobga olinmaydi).
  int? branchUnder(String location, {bool exact = false}) {
    final target = Uri.parse(location);
    for (final MapEntry(key: index, value: last) in _last.entries) {
      final inside = target.hasQuery
          ? last == target
          : last.path == target.path ||
                (!exact && last.path.startsWith('${target.path}/'));
      if (inside) return index;
    }
    return null;
  }

  void reselect(int index) {
    reselectedIndex = index;
    notifyListeners();
  }
}

class TabMemoryScope extends InheritedWidget {
  const TabMemoryScope({super.key, required this.memory, required super.child});

  final TabMemory memory;

  static TabMemory? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TabMemoryScope>()?.memory;

  @override
  bool updateShouldNotify(TabMemoryScope oldWidget) =>
      memory != oldWidget.memory;
}

/// Boshqa tabdagi bo'limni ochish: o'sha tab allaqachon shu bo'lim ichida
/// bo'lsa — tabning o'ziga o'tiladi, aks holda bo'lim ochiladi.
///
/// `go(oxirgi manzil)` yetmaydi: u stekni URL'dan qayta quradi va push
/// qilingan sahifalar (masalan, ro'yxatdan ochilgan QC to'plami) yangidan
/// yaratilib, kiritilgan, hali saqlanmagan qiymat yo'qolardi. `goBranch`
/// tab stekini o'zgarishsiz tiklaydi.
///
/// [exact]: yorliq aynan bo'lim sahifasini va'da qilsa (masalan, O'rganishdagi
/// "Leykoformula" qatori) — tab o'sha bo'limning ichkarisida (hujayra
/// kartasi, rasm, tarix) qolgan bo'lsa ham, bo'lim sahifasining o'zi
/// ochiladi. Bo'lim holati (sanash, saqlangan natijalar) controllerda
/// turadi — yo'qolmaydi.
void openInTab(BuildContext context, String location, {bool exact = false}) {
  // Tab ildizi (`/tests`, `/learn`) so'ralsa — aynan ildiz ochiladi: aks
  // holda “Tahlillar” tugmasi shu tabda oxirgi ochiq qolgan sahifani
  // (masalan, Kaliy kartasini) ko'rsatardi.
  final target = Uri.parse(location);
  if (!target.hasQuery && target.pathSegments.length <= 1) {
    context.go(location);
    return;
  }
  final index = TabMemoryScope.maybeOf(context)
      ?.branchUnder(location, exact: exact);
  final shell = StatefulNavigationShell.maybeOf(context);
  if (index != null && shell != null) {
    shell.goBranch(index);
  } else {
    context.go(location);
  }
}

/// Besh tabli qobiq. Har bir tab o'z navigation stackini va scroll
/// holatini saqlaydi (StatefulShellRoute.indexedStack).
///
/// Pastki menyu — Instagram/iOS uslubidagi yarim shaffof (frosted glass)
/// suzuvchi panel: kontent uning ostida ko'rinib scroll bo'ladi
/// (`extendBody`). Pastga scroll qilinganda panel ixcham, faqat ikonali
/// kapsulaga aylanadi, yuqoriga scroll qilinganda (yoki tepada) qayta
/// kengayadi — qaror [CollapseHysteresis] orqali (titroq yo'q).
///
/// Kontent panel ostida qolmasligi uchun [Scaffold] panelning KENGAYGAN
/// balandligini (suzuvchi Lab tugmasi va xavfsiz hudud bilan) body'ning
/// `MediaQuery.padding.bottom` qiymatiga qo'shadi; [LgPage] ro'yxat
/// oxirida shuncha bo'sh joy qoldiradi. Bu qiymat ixchamlashganda
/// o'zgarmaydi — scroll uzunligi panel holatiga bog'liq bo'lib qolmaydi.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.shell,
    required this.memory,
    required this.location,
  });

  final StatefulNavigationShell shell;
  final TabMemory memory;

  /// Joriy manzil (shu tabning oxirgi manzili sifatida eslab qolinadi).
  final Uri location;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _hysteresis = CollapseHysteresis();
  ScrollDirection _userDirection = ScrollDirection.idle;
  bool _compact = false;

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Boshqa tabga o'tilganda (havola, orqaga) panel kengaytirilgan.
    if (oldWidget.shell.currentIndex != widget.shell.currentIndex) {
      _hysteresis.reset();
      _compact = false;
    }
  }

  void _expand() {
    final changed = _hysteresis.reset();
    if (changed || _compact) setState(() => _compact = false);
  }

  void _select(int index) {
    // Faol tab qayta bosilsa — shu tab ildiziga qaytadi; ildizda bo'lsa,
    // ro'yxat tepaga suriladi (LgPage hodisani tinglaydi).
    if (index == widget.shell.currentIndex) widget.memory.reselect(index);
    widget.shell.goBranch(
      index,
      initialLocation: index == widget.shell.currentIndex,
    );
    _expand();
  }

  /// Sahifaning asosiy (chuqurligi 0) vertikal ro'yxati scroll qilinganda
  /// panelni ixchamlashtiradi/kengaytiradi. LgPage'dagi sarlavha mantig'i
  /// bilan bir xil [CollapseHysteresis] (14 px).
  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification) {
      _userDirection = n.direction;
      return false;
    }
    if (n is ScrollUpdateNotification) {
      final userDriven =
          n.dragDetails != null || _userDirection != ScrollDirection.idle;
      final metrics = n.metrics;
      if (userDriven) {
        _hysteresis.onScroll(
          pixels: metrics.pixels,
          delta: n.scrollDelta ?? 0,
          maxScrollExtent: metrics.maxScrollExtent,
          // Panel ro'yxat viewportini o'zgartirmaydi.
          collapsibleExtent: 0,
        );
      } else if (metrics.pixels <= _hysteresis.topSnap) {
        // Dasturiy scroll (masalan, tepaga qaytish) — faqat kengaytirish.
        _hysteresis.reset();
      }
      if (_hysteresis.collapsed != _compact) {
        setState(() => _compact = _hysteresis.collapsed);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.shell;
    widget.memory.record(shell.currentIndex, widget.location);
    final l = AppLocalizations.of(context);
    final tabs = [
      _Tab(Icons.home_outlined, Icons.home_rounded, l.navHome),
      _Tab(Icons.biotech_outlined, Icons.biotech_rounded, l.navTests),
      _Tab(Icons.science_outlined, Icons.science_rounded, l.navLab),
      _Tab(
        Icons.local_library_outlined,
        Icons.local_library_rounded,
        l.navLibrary,
      ),
      _Tab(Icons.school_outlined, Icons.school_rounded, l.navLearn),
    ];
    // Android "orqaga": tab ildizida bo'lsa va bu Bosh tab bo'lmasa —
    // avval Bosh tabga qaytadi, keyin ilovadan chiqadi.
    final atBranchRoot = !GoRouter.of(context).canPop();
    return TabMemoryScope(
      memory: widget.memory,
      child: PopScope(
        canPop: shell.currentIndex == 0 || !atBranchRoot,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && shell.currentIndex != 0) shell.goBranch(0);
        },
        child: Scaffold(
          extendBody: true,
          body: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: shell,
          ),
          bottomNavigationBar: _GlassTabBar(
            tabs: tabs,
            currentIndex: shell.currentIndex,
            compact: _compact,
            onSelect: _select,
          ),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Panel o'lchamlari (logik px).
abstract final class _Nav {
  /// Kengaygan panel balandligi (matn masshtabi katta bo'lsa o'sadi).
  static const barHeight = 64.0;
  static const compactBarHeight = 48.0;

  /// Lab tugmasi panel ustidan qancha chiqib turadi.
  static const raise = 16.0;
  static const compactRaise = 8.0;

  /// Lab tugmasi diametri.
  static const lab = 56.0;
  static const compactLab = 50.0;

  /// Lab tugmasi egallaydigan gorizontal joy: diametr + [slotExtra]
  /// (tor ekranda ≤ 360 px — kamroq: boshqa tab nomlariga joy kerak).
  static const slotExtra = 8.0;
  static const narrowSlotExtra = 0.0;

  static const maxWidth = 560.0;
  static const compactWidth = 280.0;

  /// Shu balandlikdan past ekranda (landshaft telefon) panel doim ixcham.
  static const shortScreen = 480.0;

  static const animation = Duration(milliseconds: 220);
}

class _GlassTabBar extends StatelessWidget {
  const _GlassTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.compact,
    required this.onSelect,
  });

  final List<_Tab> tabs;
  final int currentIndex;
  final bool compact;
  final ValueChanged<int> onSelect;

  /// Lab — o'rtadagi (3-)tab.
  static const labIndex = 2;

  @override
  Widget build(BuildContext context) {
    // Klaviatura ochiq: panel klaviatura ostida qoladi va joy egallamaydi
    // (Scaffold body'ni klaviatura ustiga o'zi sig'diradi).
    if (MediaQuery.viewInsetsOf(context).bottom > 0) {
      return const SizedBox.shrink();
    }
    // Tab nomlari iOS/Android tab bar kabi cheklangan masshtabda: juda katta
    // shrift sozlamasida ham nomlar bir qatorga sig'ishi uchun (≤ 1.2).
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: Builder(builder: _build),
    );
  }

  Widget _build(BuildContext context) {
    final p = LgPalette.of(context);
    final media = MediaQuery.of(context);
    final text = Theme.of(context).textTheme;
    final short = media.size.height < _Nav.shortScreen;
    final target = compact || short ? 1.0 : 0.0;

    final width = media.size.width;
    final narrow = width <= 360;
    final margin = narrow ? 4.0 : 12.0;
    final fullWidth = math.min(width - 2 * margin, _Nav.maxWidth);
    final compactWidth = math.min(fullWidth, _Nav.compactWidth);
    // Home indikatori ustida suzadi: xavfsiz hududning yarmi (kamida 8).
    final gap = math.max(8.0, media.padding.bottom / 2);

    // Nomning bir qatorli balandligi: masshtab katta bo'lsa panel o'sadi.
    final labelStyle = tabLabelStyle(text, selected: true);
    final probe = TextPainter(
      text: TextSpan(text: 'Ag', style: labelStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final lineHeight = probe.height;
    probe.dispose();

    final fullBar = short
        ? _Nav.compactBarHeight
        : math.max(_Nav.barHeight, 46 + lineHeight);
    final fullRaise = short ? _Nav.compactRaise : _Nav.raise;
    final fullLab = short ? _Nav.compactLab : _Nav.lab;
    // Ajratilgan balandlik kengaygan holat uchun — ixchamlashganda
    // o'zgarmaydi (panel pastga tiralib turadi, tepasi shaffof va
    // teginishlarni pastdagi kontentga o'tkazadi).
    final reserved = fullRaise + fullBar + gap;

    final solid = MediaQuery.highContrastOf(context);
    final brightness = Theme.of(context).brightness;
    final duration = LgMotion.of(context, _Nav.animation);

    // Kengliklar kengaygan holat bo'yicha bir marta o'lchanadi.
    final pad = narrow ? 2.0 : 4.0;
    final slotExtra = narrow ? _Nav.narrowSlotExtra : _Nav.slotExtra;
    final fullSlot = fullLab + slotExtra;
    final layout = _TabLayout.compute(
      context,
      labels: [
        for (var i = 0; i < tabs.length; i++)
          if (i != labIndex) tabs[i].label,
      ],
      groupWidth: (fullWidth - 2 * pad - fullSlot) / 2,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: SizedBox(
        height: reserved,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: target),
              duration: duration,
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                double mix(double a, double b) => lerpDouble(a, b, t)!;
                final barH = mix(fullBar, _Nav.compactBarHeight);
                final raise = mix(fullRaise, _Nav.compactRaise);
                final lab = mix(fullLab, _Nav.compactLab);
                final slot = lab + slotExtra;
                final barWidth = mix(fullWidth, compactWidth);
                final radius = BorderRadius.circular(mix(26, 24));
                final flex = [
                  for (final f in layout.flex)
                    (mix(f.toDouble(), layout.meanFlex) * 100).round(),
                ];
                Widget item(int tab, int flexIndex) => Expanded(
                  flex: flex[flexIndex],
                  child: _NavItem(
                    index: tab,
                    tab: tabs[tab],
                    selected: tab == currentIndex,
                    t: t,
                    highlightHeight: barH - 12,
                    labelScaler: layout.scaler,
                    onTap: () => onSelect(tab),
                  ),
                );
                return SizedBox(
                  width: barWidth,
                  height: raise + barH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: barH,
                        child: _GlassSurface(
                          key: const ValueKey('nav-pill'),
                          palette: p,
                          brightness: brightness,
                          radius: radius,
                          solid: solid,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: pad),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [item(0, 0), item(1, 1)],
                                    ),
                                  ),
                                  SizedBox(width: slot),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [item(3, 2), item(4, 3)],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: slot,
                            child: _LabButton(
                              tab: tabs[labIndex],
                              index: labIndex,
                              selected: labIndex == currentIndex,
                              t: t,
                              diameter: lab,
                              labelScaler: layout.scaler,
                              onTap: () => onSelect(labIndex),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Yarim shaffof panel yuzasi: orqasi xiralashtiriladi, yupqa chegara va
/// yumshoq soya (soya panel ICHIGA tushmaydi — aks holda shisha loyqa
/// kulrang ko'rinardi).
class _GlassSurface extends StatelessWidget {
  const _GlassSurface({
    super.key,
    required this.palette,
    required this.brightness,
    required this.radius,
    required this.solid,
    required this.child,
  });

  final LgPalette palette;
  final Brightness brightness;
  final BorderRadius radius;

  /// Shaffoflik o'chirilgan (OS "kontrastni oshirish").
  final bool solid;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = brightness == Brightness.dark;
    return CustomPaint(
      painter: _GlassShadowPainter(
        radius: radius,
        color: palette.shadow.withValues(alpha: dark ? 0.5 : 0.16),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          enabled: !solid,
          filter: ImageFilter.blur(
            sigmaX: LgGlass.blurSigma,
            sigmaY: LgGlass.blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: LgGlass.surface(palette, brightness, solid: solid),
              borderRadius: radius,
              border: Border.all(color: LgGlass.border(palette, solid: solid)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlassShadowPainter extends CustomPainter {
  const _GlassShadowPainter({required this.radius, required this.color});

  final BorderRadius radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);
    // Faqat panel tashqarisiga: ichki qismi qirqib tashlanadi.
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect.inflate(80)),
      Path()..addRRect(rrect),
    );
    canvas
      ..save()
      ..clipPath(outside)
      ..drawRRect(
        rrect.shift(const Offset(0, 8)),
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlassShadowPainter old) =>
      old.radius != radius || old.color != color;
}

TextStyle tabLabelStyle(
  TextTheme text, {
  required bool selected,
  Color? color,
}) => text.labelSmall!.copyWith(
  color: color,
  letterSpacing: -0.1,
  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
);

/// Tanlanmagan tab rangi: `ink` — shisha ostidagi har qanday kontent ustida
/// ham ≥ 4,5:1 (LgGlass shaffofligi shunga mos). Tanlanganlik rangga
/// qo'shimcha ravishda to'ldirilgan ikonka, qalin nom va yumshoq fon bilan
/// ham bildiriladi (faqat rangga tayanmaydi).
Color _tabColor(LgPalette p, bool selected) => selected ? p.brand : p.ink;

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.tab,
    required this.selected,
    required this.t,
    required this.highlightHeight,
    required this.labelScaler,
    required this.onTap,
  });

  final int index;
  final _Tab tab;
  final bool selected;

  /// 0 — kengaygan, 1 — ixcham (nomlar yashirin).
  final double t;
  final double highlightHeight;
  final TextScaler labelScaler;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final color = _tabColor(p, selected);
    final duration = LgMotion.of(context, const Duration(milliseconds: 180));
    // excludeSemantics ichki InkWell'ning tap amalini ham olib tashlaydi —
    // shuning uchun onTap shu yerda qayta beriladi (aks holda TalkBack'da
    // ikki marta bosish hech narsa qilmaydi). Nom ixcham holatda ham
    // ekran o'quvchiga aytiladi.
    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('nav-tab-$index'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          // Balandlik panel animatsiyasi bilan bir kadrda o'zgaradi (implicit
          // animatsiya ortda qolib, ichidagi ustunni toshirib yuborardi);
          // faqat rang silliq almashadi.
          child: SizedBox(
            height: highlightHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: duration,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? p.soft : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? tab.activeIcon : tab.icon,
                      size: 24,
                      color: color,
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 1 - t,
                        child: Opacity(
                          opacity: 1 - t,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              tab.label,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              textAlign: TextAlign.center,
                              textScaler: labelScaler,
                              style: tabLabelStyle(
                                text,
                                selected: selected,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// O'rtadagi Lab tabi: panel ustidan chiqib turgan dumaloq brend tugma.
/// Oddiy tab sifatida ishlaydi (tanlangan/tanlanmagan holati, qayta bosish).
class _LabButton extends StatelessWidget {
  const _LabButton({
    required this.tab,
    required this.index,
    required this.selected,
    required this.t,
    required this.diameter,
    required this.labelScaler,
    required this.onTap,
  });

  final _Tab tab;
  final int index;
  final bool selected;
  final double t;
  final double diameter;
  final TextScaler labelScaler;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final duration = LgMotion.of(context, const Duration(milliseconds: 180));
    final labelColor = _tabColor(p, selected);
    return Semantics(
      selected: selected,
      button: true,
      label: tab.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              // Tanlanmaganda: brend doira + kontur ikonka + tinch halqa.
              // Tanlanganda: to'ldirilgan ikonka + brend halo + kuchliroq soya.
              SizedBox(
                key: const ValueKey('nav-lab-circle'),
                width: diameter,
                height: diameter,
                child: AnimatedContainer(
                  duration: duration,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.brand,
                    border: Border.all(
                      width: selected ? 4 : 3,
                      color: selected
                          ? p.brand.withValues(alpha: dark ? 0.45 : 0.32)
                          : p.paper.withValues(alpha: 0.9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: p.brand.withValues(alpha: selected ? 0.4 : 0.22),
                        blurRadius: selected ? 18 : 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    selected ? tab.activeIcon : tab.icon,
                    size: diameter * 0.46,
                    color: p.onBrand,
                  ),
                ),
              ),
              Expanded(
                child: ClipRect(
                  child: Center(
                    child: Opacity(
                      opacity: 1 - t,
                      child: Text(
                        tab.label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.center,
                        textScaler: labelScaler,
                        style: tabLabelStyle(
                          text,
                          selected: selected,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkResponse(
                key: ValueKey('nav-tab-$index'),
                onTap: onTap,
                containedInkWell: false,
                customBorder: const CircleBorder(),
                radius: diameter / 2 + 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab kengliklari va nom masshtabi (Lab dan tashqari 4 tab, chap/o'ng
/// juftlik simmetrik: Lab doim panel markazida).
///
/// * Joy yetsa — teng kenglik, nomlar 1.2 gacha kattalashadi.
/// * Biror nom teng ulushga sig'masa (masalan, 320 px da "Библиотека") —
///   kengliklar nom uzunligiga mutanosib taqsimlanadi, har tab ≥ 44 px.
/// * Shunda ham sig'masa — masshtab 1.0 (11 px) ga qaytadi. Matn hech
///   qachon 11 px dan kichraymaydi.
class _TabLayout {
  const _TabLayout(this.flex, this.scaler);

  final List<int> flex;
  final TextScaler scaler;

  double get meanFlex => flex.fold(0, (a, b) => a + b) / flex.length;

  static const _itemPadding = 2.0; // element chetidagi 1 + 1 px bo‘shliq
  static const _minItem = kMinTap + 4;

  /// [labels] — Lab'dan boshqa 4 tab nomi (chapdan o'ngga), [groupWidth] —
  /// chap (yoki o'ng) juftlik kengligi.
  static _TabLayout compute(
    BuildContext context, {
    required List<String> labels,
    required double groupWidth,
  }) {
    final text = Theme.of(context).textTheme;
    final style = tabLabelStyle(text, selected: true);
    final direction = Directionality.of(context);
    List<double> measure(TextScaler scaler) {
      final widths = <double>[];
      for (final l in labels) {
        final painter = TextPainter(
          text: TextSpan(text: l, style: style),
          textDirection: direction,
          textScaler: scaler,
          maxLines: 1,
        )..layout();
        widths.add(painter.width + _itemPadding);
        painter.dispose();
      }
      return widths;
    }

    final share = groupWidth / 2;
    for (final scaler in [
      MediaQuery.textScalerOf(context),
      TextScaler.noScaling,
    ]) {
      final widths = measure(scaler);
      if (widths.every((w) => w <= share)) {
        return _TabLayout(List.filled(labels.length, 1), scaler);
      }
      final needed = [for (final w in widths) w < _minItem ? _minItem : w];
      final fits =
          needed[0] + needed[1] <= groupWidth &&
          needed[2] + needed[3] <= groupWidth;
      if (fits) {
        return _TabLayout([for (final w in needed) (w * 10).round()], scaler);
      }
    }
    return _TabLayout(List.filled(labels.length, 1), TextScaler.noScaling);
  }
}
