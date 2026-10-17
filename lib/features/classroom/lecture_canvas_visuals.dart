part of 'lecture_canvas.dart';

// Vizual shablonlar (raqam kartalari, chegaralar diagrammasi, bajarish
// tartibi, ikki ustun, tasnif daraxti, misol kartasi), yon rasm, sarlavha
// rasmi, bo'lim aksenti va slayd o'rni chizig'i. Mazmun — eksport
// (tool/slides/visuals.py) bergan maydonlardan: kanvas hech qanday son yoki
// matn qo'shmaydi, faqat chizadi. Har shablon tanasini o'lchab eng katta mos
// shriftni tanlaydi; baribir sig'masa — butunligicha kichraytiriladi
// (_Shrink), kesilmaydi.

// ---------------------------------------------------------- kategoriya ---

/// Bo'lim kategoriyasi: aksent rangi (kunduzgi / tungi) va Material ikon.
@immutable
class SlideCategory {
  const SlideCategory(this.light, this.night, this.icon);

  final Color light;
  final Color night;
  final IconData icon;

  Color color(bool dark) => dark ? night : light;

  // Ranglar kunduzgi fon (#F3F3EC) bilan >= 4.5:1, tungi (#0D1919) bilan
  // ham >= 4.5:1 (matn rangi sifatida ishlatiladi).
  static const _green = (Color(0xFF194C40), Color(0xFFC5E8A1));
  static const _blue = (Color(0xFF1F4E8C), Color(0xFF9CC3FF));
  static const _wine = (Color(0xFF8C2346), Color(0xFFFF9FBF));
  static const _rust = (Color(0xFF8A3A12), Color(0xFFFFB38A));
  static const _purple = (Color(0xFF5B3A9A), Color(0xFFCDB4FF));
  static const _teal = (Color(0xFF0E5E66), Color(0xFF7EDCE4));
  static const _ochre = (Color(0xFF6E5200), Color(0xFFF0D27A));

  static SlideCategory _c((Color, Color) hue, IconData icon) =>
      SlideCategory(hue.$1, hue.$2, icon);

  static final Map<String, SlideCategory> all = {
    'hematology': _c(_wine, Icons.bloodtype_outlined),
    'coagulation': _c(_wine, Icons.healing_outlined),
    'cardiac': _c(_wine, Icons.monitor_heart_outlined),
    'tumor-markers': _c(_wine, Icons.track_changes_rounded),
    'cells': _c(_wine, Icons.bubble_chart_outlined),
    'iron-vitamins': _c(_rust, Icons.medication_outlined),
    'liver': _c(_rust, Icons.science_outlined),
    'infection-serology': _c(_rust, Icons.coronavirus_outlined),
    'condition': _c(_rust, Icons.medical_information_outlined),
    'urine': _c(_ochre, Icons.water_drop_outlined),
    'carbohydrate': _c(_ochre, Icons.cookie_outlined),
    'stool-parasitology': _c(_ochre, Icons.pest_control_outlined),
    'example': _c(_ochre, Icons.calculate_outlined),
    'p_reading': _c(_ochre, Icons.calculate_outlined),
    'kidney': _c(_teal, Icons.filter_alt_outlined),
    'electrolytes': _c(_teal, Icons.bolt_outlined),
    'reference': _c(_teal, Icons.account_tree_outlined),
    'p_principle': _c(_teal, Icons.lightbulb_outline_rounded),
    'lipids': _c(_purple, Icons.opacity_rounded),
    'proteins': _c(_purple, Icons.hub_outlined),
    'endocrine': _c(_purple, Icons.device_hub_rounded),
    'cytology': _c(_purple, Icons.blur_on_rounded),
    'autoimmune': _c(_blue, Icons.shield_outlined),
    'body-fluids': _c(_blue, Icons.air_rounded),
    'qa': _c(_blue, Icons.quiz_outlined),
    'atlas': _c(_blue, Icons.photo_library_outlined),
    'p_atlas': _c(_blue, Icons.photo_library_outlined),
    'p_sampling': _c(_blue, Icons.colorize_outlined),
    'enzymes': _c(_green, Icons.biotech_outlined),
    'technique': _c(_green, Icons.handyman_outlined),
    'book': _c(_green, Icons.menu_book_outlined),
    'p_purpose': _c(_green, Icons.flag_outlined),
    'p_materials': _c(_green, Icons.inventory_2_outlined),
    'p_procedure': _c(_green, Icons.format_list_numbered_rounded),
    'p_qc': _c(_green, Icons.verified_outlined),
    'p_errors': _c(_rust, Icons.report_problem_outlined),
    'p_safety': _c(_rust, Icons.health_and_safety_outlined),
    'p_avoid': _c(_rust, Icons.block_rounded),
  };

  static SlideCategory? of(String? key) => key == null ? null : all[key];
}

// ------------------------------------------------- slayd o'rni chizig'i ---

/// Kanvas pastidagi ingichka chiziq: slayd taqdimotning qayerida.
class _Progress extends StatelessWidget {
  const _Progress({
    required this.number,
    required this.total,
    required this.color,
    required this.track,
  });

  final int number;
  final int total;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final f = total <= 0 ? 0.0 : (number / total).clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: SizedBox(
        height: SlideCanvasMetrics.progressH,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: SlideCanvasMetrics.width * f,
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

double _spanWidth(InlineSpan span) {
  final tp = TextPainter(
    text: span,
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout();
  final w = tp.width;
  tp.dispose();
  return w;
}

// ------------------------------------------------------------ rasmlar ---

Widget _assetImage(String asset, Color fallback) => Image.asset(
  asset,
  fit: BoxFit.contain,
  filterQuality: FilterQuality.medium,
  excludeFromSemantics: true,
  errorBuilder: (context, _, _) =>
      Center(child: Icon(Icons.image_not_supported_outlined, color: fallback)),
);

/// Sarlavha slaydi rasmi (o'ngda, oq ramkada) va krediti.
class _TitleImage extends StatelessWidget {
  const _TitleImage({required this.asset, this.credit, required this.base});

  static const w = 420.0;

  final String asset;
  final String? credit;
  final TextStyle base;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEF9),
            borderRadius: BorderRadius.circular(22),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _assetImage(asset, SlideColors.pale),
          ),
        ),
      ),
      if (credit case final c?) ...[
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 48),
          child: _Shrink(
            width: w,
            child: Text(
              c,
              style: base.copyWith(
                fontSize: 16,
                height: 1.3,
                color: SlideColors.pale,
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

/// Bandli slayddagi yon rasm (o'ngda) va krediti (sxema / foto muallifi).
class _SideImage extends StatelessWidget {
  const _SideImage({
    required this.asset,
    required this.credit,
    required this.colors,
    required this.base,
    required this.height,
  });

  final String asset;
  final String? credit;
  final SlideColors colors;
  final TextStyle base;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final creditStyle = base.copyWith(fontSize: 16, height: 1.3, color: c.sub);
    final ch = credit == null
        ? 0.0
        : _spanHeight(
                TextSpan(text: credit, style: creditStyle),
                SlideCanvasMetrics.sideW,
              ) +
              10;
    final imgH = (height - ch).clamp(80.0, SlideCanvasMetrics.sideW * 0.9);
    return SizedBox(
      width: SlideCanvasMetrics.sideW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: SlideCanvasMetrics.sideW,
            height: imgH,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.paper,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.line, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _assetImage(asset, c.sub),
            ),
          ),
          if (credit case final t?) ...[
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height - imgH - 10),
              child: _Shrink(
                width: SlideCanvasMetrics.sideW,
                child: Text(t, style: creditStyle),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------ raqam kartalari ---

class _StatsBody extends StatelessWidget {
  const _StatsBody({
    required this.slide,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final stats = slide.stats;
    const gap = 20.0;
    final n = stats.length;
    final cardW = n == 0 ? width : (width - gap * (n - 1)) / n;
    Widget card(SlideStat st) => Container(
      width: cardW,
      height: SlideCanvasMetrics.statRowH,
      decoration: BoxDecoration(
        color: c.paper,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: c.p.shadow.withValues(alpha: c.dark ? 0.35 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 6, color: c.accent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 58,
                    width: cardW - 40,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        st.value,
                        maxLines: 1,
                        style: base.copyWith(
                          fontSize: 48,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: c.accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: _Shrink(
                      width: cardW - 40,
                      child: Text(
                        st.label,
                        style: base.copyWith(
                          fontSize: 21,
                          height: 1.25,
                          color: c.sub,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    final rest =
        maxHeight - SlideCanvasMetrics.statRowH - SlideCanvasMetrics.statGap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kartalar — bandlardagi matnning o'zi (ekran o'quvchi bandlarni o'qiydi).
        ExcludeSemantics(
          child: Row(
            children: [
              for (final (i, st) in stats.indexed) ...[
                if (i > 0) const SizedBox(width: gap),
                card(st),
              ],
            ],
          ),
        ),
        const SizedBox(height: SlideCanvasMetrics.statGap),
        _Bullets(
          slide: slide,
          colors: c,
          base: base,
          width: width,
          maxHeight: rest < 80 ? 80 : rest,
        ),
      ],
    );
  }
}

// ------------------------------------------------- chegaralar diagrammasi ---

class _RangeBody extends StatelessWidget {
  const _RangeBody({
    required this.range,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
  });

  final SlideRange range;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;

  static const _labelW = 380.0;
  static const _gap = 28.0;
  static const _axisH = 56.0;
  static const _bar = 22.0;

  /// Qiymat yozuvi: kartadagi son va taqqoslash belgisi (deck_content._range_str
  /// bilan bir xil: past ochiq — ">", yopiq — "≥"; yuqori ochiq — "<").
  static String valueText(SlideRangeRow r) {
    final lo = r.lowText;
    final hi = r.highText;
    if (lo != null && hi != null && !r.lowExclusive && !r.highExclusive) {
      return '$lo–$hi';
    }
    return [
      if (lo != null) '${r.lowExclusive ? '>' : '≥'} $lo',
      if (hi != null) '${r.highExclusive ? '<' : '≤'} $hi',
    ].join('; ');
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final rows = range.rows;
    final vals = [
      for (final r in rows) ...[?r.low, ?r.high],
    ];
    var vmin = vals.reduce((a, b) => a < b ? a : b);
    var vmax = vals.reduce((a, b) => a > b ? a : b);
    // O'q chetlari: ochiq tomon uchun joy (son emas — faqat chizma maydoni).
    final span = vmax - vmin;
    final pad = span > 0
        ? span * 0.22
        : (vmax.abs() > 0 ? vmax.abs() * 0.6 : 1);
    vmin -= pad;
    vmax += pad;
    final gw = width - _labelW - _gap;
    double x(double v) => (v - vmin) / (vmax - vmin) * gw;
    final head = range.caption != null || range.unit.isNotEmpty;
    final headH = head ? 52.0 : 0.0;
    final rowH = ((maxHeight - headH - _axisH) / rows.length).clamp(64.0, 96.0);
    final labelStyle = base.copyWith(
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: c.ink,
    );
    final subStyle = base.copyWith(fontSize: 18, height: 1.25, color: c.sub);
    final valStyle = base.copyWith(
      fontSize: 22,
      height: 1.1,
      fontWeight: FontWeight.w700,
      color: c.ink,
    );
    Color barColor(SlideRangeRow r) {
      if (r.low == null) {
        return c.dark ? const Color(0xFF9CC3FF) : const Color(0xFF2F64A8);
      }
      if (r.high == null) {
        return c.dark ? const Color(0xFFFF9FBF) : const Color(0xFFB0325A);
      }
      return c.accent;
    }

    Widget row(SlideRangeRow r) {
      final from = r.low == null ? 0.0 : x(r.low!);
      final to = r.high == null ? gw : x(r.high!);
      final col = barColor(r);
      final text = valueText(r);
      final tw = _spanWidth(TextSpan(text: text, style: valStyle));
      // Yozuv bar ustida, o'rtasida; chetdan chiqmasin.
      final mid = (from + to) / 2;
      final left = (mid - tw / 2).clamp(0.0, gw - tw < 0 ? 0.0 : gw - tw);
      return Semantics(
        label:
            '${r.label}${r.sub == null ? '' : ' (${r.sub})'}: $text '
            '${range.unit}',
        child: ExcludeSemantics(
          child: SizedBox(
            height: rowH,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: _labelW,
                  height: rowH - 8,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _Shrink(
                      width: _labelW,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(r.label, style: labelStyle),
                          if (r.sub case final s?)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(s, style: subStyle),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: _gap),
                SizedBox(
                  width: gw,
                  height: rowH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // trek
                      Positioned(
                        left: 0,
                        right: 0,
                        top: rowH / 2 + 4,
                        height: _bar,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: c.line.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(_bar / 2),
                          ),
                        ),
                      ),
                      // chegaralangan oraliq
                      Positioned(
                        left: from,
                        width: (to - from).clamp(6.0, gw),
                        top: rowH / 2 + 4,
                        height: _bar,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                if (r.low == null) col.withValues(alpha: 0.25),
                                col,
                                col,
                                if (r.high == null) col.withValues(alpha: 0.25),
                              ],
                            ),
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(
                                r.low == null ? 0 : _bar / 2,
                              ),
                              right: Radius.circular(
                                r.high == null ? 0 : _bar / 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (r.low == null)
                        Positioned(
                          left: -30,
                          top: rowH / 2 + 4 + _bar / 2 - 15,
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 30,
                            color: col,
                          ),
                        ),
                      if (r.high == null)
                        Positioned(
                          right: -30,
                          top: rowH / 2 + 4 + _bar / 2 - 15,
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 30,
                            color: col,
                          ),
                        ),
                      // chegara nuqtalari
                      for (final v in [?r.low, ?r.high])
                        Positioned(
                          left: x(v) - 3,
                          top: rowH / 2 - 2,
                          width: 6,
                          height: _bar + 12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.ink,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      Positioned(
                        left: left,
                        top: rowH / 2 - 30,
                        child: Text(text, style: valStyle.copyWith(color: col)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // O'q: faqat kartadagi qiymatlar (bir-biriga juda yaqinlari tushiriladi).
    final ticks = <(double, String)>[];
    for (final r in rows) {
      if (r.low != null && r.lowText != null) ticks.add((r.low!, r.lowText!));
      if (r.high != null && r.highText != null) {
        ticks.add((r.high!, r.highText!));
      }
    }
    ticks.sort((a, b) => a.$1.compareTo(b.$1));
    final shown = <(double, String)>[];
    for (final t in ticks) {
      if (shown.isNotEmpty && shown.last.$1 == t.$1) continue;
      if (shown.isNotEmpty && x(t.$1) - x(shown.last.$1) < 64) continue;
      shown.add(t);
    }
    final tickStyle = base.copyWith(fontSize: 18, height: 1.1, color: c.sub);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (head)
          SizedBox(
            height: headH,
            child: Row(
              children: [
                if (range.caption case final cap?)
                  Expanded(
                    child: _Shrink(
                      width: width - 200,
                      child: Text(
                        cap,
                        style: base.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: c.accent,
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (range.unit.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: c.accentSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 22,
                          color: c.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          range.unit,
                          style: base.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: c.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        for (final r in rows) row(r),
        ExcludeSemantics(
          child: SizedBox(
            height: _axisH,
            child: Row(
              children: [
                const SizedBox(width: _labelW + _gap),
                SizedBox(
                  width: gw,
                  height: _axisH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 6,
                        height: 2,
                        child: ColoredBox(color: c.sub.withValues(alpha: 0.5)),
                      ),
                      for (final t in shown) ...[
                        Positioned(
                          left: x(t.$1) - 1,
                          top: 0,
                          width: 2,
                          height: 14,
                          child: ColoredBox(color: c.sub),
                        ),
                        Positioned(
                          left: x(t.$1) - 40,
                          width: 80,
                          top: 18,
                          child: Text(
                            t.$2,
                            textAlign: TextAlign.center,
                            style: tickStyle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------- bajarish tartibi ---

final _stepNum = RegExp(r'^(\d{1,2})\.\s+(.+)$', dotAll: true);

class _StepsBody extends StatelessWidget {
  const _StepsBody({
    required this.slide,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;

  static const _padX = 20.0;
  static const _padY = 14.0;
  static const _gap = 16.0;
  static const _arrow = 56.0;

  List<(String, String)> get _steps => [
    for (final b in slide.bullets)
      if (_stepNum.firstMatch(b) case final m?)
        (m.group(1)!, m.group(2)!)
      else
        ('', b),
  ];

  TextStyle _st(double s) =>
      base.copyWith(fontSize: s, height: 1.3, color: colors.ink);

  /// Kam va qisqa qadamlar — gorizontal oqim, aks holda vertikal.
  bool get _horizontal {
    final st = _steps;
    return st.length >= 2 &&
        st.length <= 4 &&
        st.every((s) => s.$2.length <= 110);
  }

  double _measureV(double s) {
    var h = 0.0;
    final tw = width - SlideCanvasMetrics.stepCol - 2 * _padX;
    for (final (i, st) in _steps.indexed) {
      final t =
          _spanHeight(_richItem(st.$2, _st(s), colors.accent), tw) + 2 * _padY;
      h += t < SlideCanvasMetrics.stepNode ? SlideCanvasMetrics.stepNode : t;
      if (i > 0) h += _gap;
    }
    return h;
  }

  double _cardW(int n) => (width - (n - 1) * _arrow) / n;

  double _measureH(double s) {
    final st = _steps;
    final tw = _cardW(st.length) - 2 * _padX;
    var m = 0.0;
    for (final x in st) {
      final t = _spanHeight(_richItem(x.$2, _st(s), colors.accent), tw);
      if (t > m) m = t;
    }
    return m + SlideCanvasMetrics.stepNode + 16 + 2 * 18;
  }

  Widget _node(String n) => Container(
    width: SlideCanvasMetrics.stepNode,
    height: SlideCanvasMetrics.stepNode,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
    child: Text(
      n,
      style: base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colors.onAccent,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final st = _steps;
    const sizes = [32.0, 30.0, 28.0, 26.0, 24.0, 22.0];
    if (_horizontal) {
      final s = _pick(sizes, (s) => _measureH(s) <= maxHeight);
      final cw = _cardW(st.length);
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, x) in st.indexed) ...[
              if (i > 0)
                SizedBox(
                  width: _arrow,
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 40,
                      color: c.accent,
                    ),
                  ),
                ),
              Container(
                width: cw,
                padding: const EdgeInsets.symmetric(
                  horizontal: _padX,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: c.paper,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.line, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (x.$1.isNotEmpty) _node(x.$1),
                    const SizedBox(height: 16),
                    Text.rich(_richItem(x.$2, _st(s), c.accent)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }
    final s = _pick(sizes, (s) => _measureV(s) <= maxHeight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, x) in st.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: SlideCanvasMetrics.stepNode,
                  child: Column(
                    children: [
                      if (x.$1.isNotEmpty)
                        _node(x.$1)
                      else
                        const SizedBox(height: SlideCanvasMetrics.stepNode),
                      if (i < st.length - 1)
                        Expanded(
                          child: ExcludeSemantics(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 4,
                                    color: c.accent.withValues(alpha: 0.45),
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 26,
                                  color: c.accent,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  width:
                      SlideCanvasMetrics.stepCol - SlideCanvasMetrics.stepNode,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < st.length - 1 ? _gap : 0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _padX,
                        vertical: _padY,
                      ),
                      constraints: const BoxConstraints(
                        minHeight: SlideCanvasMetrics.stepNode,
                      ),
                      decoration: BoxDecoration(
                        color: c.paper,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.line, width: 1.5),
                      ),
                      child: Text.rich(_richItem(x.$2, _st(s), c.accent)),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------------- ikki ustun ---

class _SplitBody extends StatelessWidget {
  const _SplitBody({
    required this.slide,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;

  static const _gap = 32.0;
  static const _pad = 20.0;
  static const _head = 64.0;
  static const _indent = 30.0;

  double get _colW => (width - _gap) / 2;

  TextStyle _st(double s) =>
      base.copyWith(fontSize: s, height: 1.35, color: colors.ink);

  double _items(List<String> xs, double s, double w) {
    var h = 0.0;
    for (final (i, x) in xs.indexed) {
      h += _spanHeight(TextSpan(text: x, style: _st(s)), w);
      if (i > 0) h += s * 0.5;
    }
    return h;
  }

  double _measure(double s) {
    final cols = slide.columns;
    final w = _colW - 2 * _pad - _indent;
    var m = 0.0;
    for (final c in cols) {
      final h = _items(c.items, s, w);
      if (h > m) m = h;
    }
    var h = _head + 16 + m + 2 * _pad;
    if (slide.bullets.isNotEmpty) {
      h += 20 + _items(slide.bullets, s, width - _indent);
    }
    return h;
  }

  (IconData, Color) _kind(String k) {
    final dark = colors.dark;
    return switch (k) {
      'up' => (
        Icons.arrow_upward_rounded,
        dark ? const Color(0xFFFF9FBF) : const Color(0xFFB0325A),
      ),
      'down' => (
        Icons.arrow_downward_rounded,
        dark ? const Color(0xFF9CC3FF) : const Color(0xFF2F64A8),
      ),
      'pos' => (
        Icons.add_rounded,
        dark ? const Color(0xFFFFB38A) : const Color(0xFF8A3A12),
      ),
      _ => (
        Icons.remove_rounded,
        dark ? const Color(0xFF7EDCE4) : const Color(0xFF0E5E66),
      ),
    };
  }

  Widget _list(List<String> xs, double s, Color marker) {
    final lineH = s * 1.35;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, x) in xs.indexed)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : s * 0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 18, top: (lineH - 12) / 2),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: marker,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Expanded(child: Text(x, style: _st(s))),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final s = _pick(const [
      30.0,
      28.0,
      26.0,
      24.0,
      22.0,
      20.0,
    ], (s) => _measure(s) <= maxHeight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, col) in slide.columns.indexed) ...[
                if (i > 0) const SizedBox(width: _gap),
                Builder(
                  builder: (context) {
                    final (icon, hue) = _kind(col.kind);
                    return Container(
                      width: _colW,
                      padding: const EdgeInsets.all(_pad),
                      decoration: BoxDecoration(
                        color: c.paper,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hue.withValues(alpha: 0.55),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: _head,
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: hue.withValues(
                                      alpha: c.dark ? 0.22 : 0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, size: 34, color: hue),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Semantics(
                                    header: true,
                                    child: Text(
                                      col.head,
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                      style: base.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: hue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _list(col.items, s, hue),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (slide.bullets.isNotEmpty) ...[
          const SizedBox(height: 20),
          _list(slide.bullets, s, c.accent),
        ],
      ],
    );
  }
}

// ------------------------------------------------------- tasnif daraxti ---

class _TreeBody extends StatelessWidget {
  const _TreeBody({
    required this.slide,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;

  static const _rootW = 300.0;
  static const _link = 64.0;
  static const _padX = 18.0;
  static const _padY = 12.0;
  static const _gap = 12.0;

  double get _childW => width - _rootW - _link;

  List<(String, String)> get _items => [
    for (final b in slide.bullets)
      if (_label.firstMatch(b) case final m?)
        (m.group(1)!, m.group(2)!)
      else
        ('', b),
  ];

  TextStyle _lab(double s) => base.copyWith(
    fontSize: s,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: colors.accent,
  );

  TextStyle _val(double s) =>
      base.copyWith(fontSize: s, height: 1.3, color: colors.ink);

  List<double> _heights(double s) {
    final w = _childW - 2 * _padX;
    return [
      for (final (l, v) in _items)
        (l.isEmpty ? 0 : _spanHeight(TextSpan(text: l, style: _lab(s)), w)) +
            _spanHeight(TextSpan(text: v, style: _val(s)), w) +
            2 * _padY +
            2,
    ];
  }

  double _total(List<double> hs) =>
      hs.fold<double>(0, (a, b) => a + b) + (hs.length - 1) * _gap;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final s = _pick(const [
      30.0,
      28.0,
      26.0,
      24.0,
      22.0,
      20.0,
    ], (s) => _total(_heights(s)) <= maxHeight);
    final hs = _heights(s);
    final total = _total(hs);
    final centers = <double>[];
    var y = 0.0;
    for (final h in hs) {
      centers.add(y + h / 2);
      y += h + _gap;
    }
    final rootStyle = base.copyWith(
      fontSize: 26,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: c.onAccent,
    );
    return SizedBox(
      width: width,
      height: total,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                painter: _TreeLinks(
                  from: Offset(_rootW, total / 2),
                  toX: _rootW + _link,
                  ys: centers,
                  color: c.accent.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            width: _rootW,
            top: 0,
            bottom: 0,
            child: Center(
              child: ExcludeSemantics(
                child: Container(
                  width: _rootW,
                  constraints: BoxConstraints(
                    maxHeight: total < 120 ? 120 : total,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _Shrink(
                    width: _rootW - 44,
                    child: Row(
                      children: [
                        Icon(
                          c.icon ?? Icons.account_tree_outlined,
                          color: c.onAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(slide.title, style: rootStyle)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: _rootW + _link,
            width: _childW,
            top: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, (l, v)) in _items.indexed)
                  Container(
                    width: _childW,
                    height: hs[i],
                    margin: EdgeInsets.only(top: i == 0 ? 0 : _gap),
                    padding: const EdgeInsets.symmetric(
                      horizontal: _padX,
                      vertical: _padY,
                    ),
                    decoration: BoxDecoration(
                      color: c.paper,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.line),
                    ),
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        stops: [0, 6 / _childW, 6 / _childW, 1],
                        colors: [
                          c.accent,
                          c.accent,
                          c.accent.withValues(alpha: 0),
                          c.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: _Shrink(
                      width: _childW - 2 * _padX - 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (l.isNotEmpty) Text(l, style: _lab(s)),
                          Text(v, style: _val(s)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeLinks extends CustomPainter {
  _TreeLinks({
    required this.from,
    required this.toX,
    required this.ys,
    required this.color,
  });

  final Offset from;
  final double toX;
  final List<double> ys;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final midX = (from.dx + toX) / 2;
    for (final y in ys) {
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..lineTo(midX, from.dy)
        ..lineTo(midX, y)
        ..lineTo(toX, y);
      canvas.drawPath(path, p);
    }
    canvas.drawCircle(from, 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TreeLinks old) =>
      old.from != from || old.toX != toX || old.ys != ys || old.color != color;
}

// ---------------------------------------------------------- misol kartasi ---

class _ExampleBody extends StatelessWidget {
  const _ExampleBody({
    required this.slide,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;

  static const _pad = 28.0;

  /// Misol matni: "berilgan → natija" (oxirgi strelka bo'yicha; matn
  /// so'zma-so'z, faqat ajratib ko'rsatiladi).
  (String, String?) get _parts {
    final t = slide.example ?? '';
    final i = t.lastIndexOf('→');
    if (i < 0) return (t, null);
    return (t.substring(0, i).trimRight(), t.substring(i + 1).trim());
  }

  TextStyle _st(double s) =>
      base.copyWith(fontSize: s, height: 1.35, color: colors.ink);

  double _measure(double s) {
    var h = 0.0;
    for (final (i, b) in slide.bullets.indexed) {
      h += _spanHeight(_richItem(b, _st(s), colors.accent), width - 2 * 24);
      if (i > 0) h += s * 0.4;
    }
    if (slide.bullets.isNotEmpty) h += 2 * 18 + 24;
    final (given, result) = _parts;
    final cw = width - 2 * _pad;
    h += 44 + 16;
    h += _spanHeight(TextSpan(text: given, style: _st(s)), cw);
    if (result != null) {
      h +=
          16 +
          _spanHeight(
            TextSpan(
              text: '→ $result',
              style: _st(s * 1.35).copyWith(fontWeight: FontWeight.w700),
            ),
            cw,
          );
    }
    return h + 2 * _pad;
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final s = _pick(const [
      30.0,
      28.0,
      26.0,
      24.0,
      22.0,
    ], (s) => _measure(s) <= maxHeight);
    final (given, result) = _parts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (slide.bullets.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: c.accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, b) in slide.bullets.indexed)
                  Padding(
                    padding: EdgeInsets.only(top: i == 0 ? 0 : s * 0.4),
                    child: Text.rich(_richItem(b, _st(s), c.accent)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        Container(
          padding: const EdgeInsets.all(_pad),
          decoration: BoxDecoration(
            color: c.paper,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.accent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: c.p.shadow.withValues(alpha: c.dark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    Icon(Icons.calculate_outlined, size: 34, color: c.accent),
                    const SizedBox(width: 12),
                    Text(
                      slide.eyebrow ?? '',
                      style: base.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: c.accent,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(given, style: _st(s)),
              if (result != null) ...[
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '→ ',
                        style: _st(s * 1.35).copyWith(color: c.accent),
                      ),
                      TextSpan(
                        text: result,
                        style: _st(s * 1.35).copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
