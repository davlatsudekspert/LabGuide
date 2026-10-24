import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:material_ui/material_ui.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../design/tokens.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../social_auth.dart';

/// Ikkala tugma bir xil balandlikda (Apple HIG: Apple tugmasi Google'nikidan
/// kam ko'zga tashlanmasin; eni ham bir xil).
const double kSocialButtonHeight = 52;

/// "yoki" ajratgichi va Google / Apple tugmalari. Faqat [providers] dagi
/// (platforma, build sozlamasi va server tasdiqlagan) tugmalar chiziladi;
/// ro'yxat bo'sh bo'lsa — hech narsa (o'lik tugma yo'q).
///
/// Tugma matni va belgisi brend talabiga ko'ra: Apple — plaginning rasmiy
/// `SignInWithAppleButton`'i, Google — rasmiy 4 rangli "G" belgisi bilan oq
/// (qorong'i mavzuda #131314) tugma. Apple birinchi.
class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({
    super.key,
    required this.providers,
    required this.onPressed,
    this.busy,
  });

  final List<SocialProvider> providers;
  final void Function(SocialProvider provider) onPressed;

  /// Hozir kirish jarayonidagi provayder (barcha tugmalar o'chiriladi).
  final SocialProvider? busy;

  @override
  Widget build(BuildContext context) {
    // Himoya qatlami: chaqiruvchi qanday ro'yxat bermasin, iOS'da Apple'siz
    // Google chizilmaydi (yagona qoida — [visibleSocialProviders]).
    final providers = visibleSocialProviders(
      platform: defaultTargetPlatform,
      appleAvailable: this.providers.contains(SocialProvider.apple),
      googleAvailable: this.providers.contains(SocialProvider.google),
    );
    if (providers.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final disabled = busy != null;

    final buttons = <Widget>[
      for (final provider in providers)
        switch (provider) {
          SocialProvider.apple => _AppleButton(
            label: l.authSignInApple,
            dark: dark,
            onPressed: disabled ? null : () => onPressed(provider),
          ),
          SocialProvider.google => _GoogleButton(
            label: l.authSignInGoogle,
            dark: dark,
            busy: busy == SocialProvider.google,
            onPressed: disabled ? null : () => onPressed(provider),
          ),
        },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Divider(color: p.line)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(l.authOr, style: text.bodySmall),
            ),
            Expanded(child: Divider(color: p.line)),
          ],
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          buttons[i],
        ],
      ],
    );
  }
}

class _AppleButton extends StatelessWidget {
  const _AppleButton({
    required this.label,
    required this.dark,
    required this.onPressed,
  });

  final String label;
  final bool dark;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Plagin matn o'lchamini balandlikdan oladi (HIG: 43%); tizim shrifti
    // masshtabi ustiga yana ko'paymasin, aks holda tor ekranda matn sig'maydi.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SignInWithAppleButton(
        text: label,
        height: kSocialButtonHeight,
        // Qorong'i mavzuda qora tugma fonda yo'qoladi — oq (HIG).
        style: dark
            ? SignInWithAppleButtonStyle.white
            : SignInWithAppleButtonStyle.black,
        onPressed: onPressed,
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.label,
    required this.dark,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool dark;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Google brend ranglari (Sign in with Google branding guidelines).
    final bg = dark ? const Color(0xFF131314) : const Color(0xFFFFFFFF);
    final fg = dark ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);
    final border = dark ? const Color(0xFF8E918F) : const Color(0xFF747775);
    final enabled = onPressed != null;
    return Semantics(
      key: const ValueKey('social-google'),
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled || busy ? 1 : 0.6,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kSocialButtonHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (busy)
                      SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: fg,
                        ),
                      )
                    else
                      const GoogleGLogo(size: 20),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        // Ilovaning o'z shrifti (Inter): Google yo'riqnomasi
                        // Roboto'ni tavsiya qiladi, majburlamaydi.
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: fg,
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

/// Google "G" belgisi (rasmiy 48×48 vektor, 4 rang) — rasm fayli kerak emas.
class GoogleGLogo extends StatelessWidget {
  const GoogleGLogo({super.key, this.size = 20});

  final double size;

  static const _paths = <(Color, String)>[
    (
      Color(0xFFEA4335),
      'M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 '
          '14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z',
    ),
    (
      Color(0xFF4285F4),
      'M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 '
          '5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z',
    ),
    (
      Color(0xFFFBBC05),
      'M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19'
          'C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z',
    ),
    (
      Color(0xFF34A853),
      'M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 '
          '2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _GPainter()),
      ),
    );
  }
}

class _GPainter extends CustomPainter {
  static final List<(Color, Path)> _parsed = [
    for (final (color, d) in GoogleGLogo._paths) (color, parseSvgPath(d)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);
    for (final (color, path) in _parsed) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..isAntiAlias = true,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GPainter oldDelegate) => false;
}

/// Eng sodda SVG yo'l o'qigichi: M m L l H h V v C c S s Z z (G belgisi uchun
/// yetarli). Ilovada SVG paketi yo'q — qo'shimcha bog'liqlik kerak emas.
Path parseSvgPath(String d) {
  final tokens = RegExp(r'[A-Za-z]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
      .allMatches(d)
      .map((m) => m[0]!)
      .toList();
  final path = Path();
  var i = 0;
  var cmd = '';
  double x = 0, y = 0, startX = 0, startY = 0;
  double? ctrlX, ctrlY;
  double n() => double.parse(tokens[i++]);
  bool isCmd(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);

  while (i < tokens.length) {
    if (isCmd(tokens[i])) {
      cmd = tokens[i++];
      if (cmd == 'Z' || cmd == 'z') {
        path.close();
        x = startX;
        y = startY;
        ctrlX = ctrlY = null;
        continue;
      }
    }
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        x = rel ? x + n() : n();
        y = rel ? y + n() : n();
        path.moveTo(x, y);
        startX = x;
        startY = y;
        ctrlX = ctrlY = null;
        // Keyingi juftliklar — chiziq.
        cmd = rel ? 'l' : 'L';
      case 'L':
        x = rel ? x + n() : n();
        y = rel ? y + n() : n();
        path.lineTo(x, y);
        ctrlX = ctrlY = null;
      case 'H':
        x = rel ? x + n() : n();
        path.lineTo(x, y);
        ctrlX = ctrlY = null;
      case 'V':
        y = rel ? y + n() : n();
        path.lineTo(x, y);
        ctrlX = ctrlY = null;
      case 'C':
        final x1 = rel ? x + n() : n();
        final y1 = rel ? y + n() : n();
        final x2 = rel ? x + n() : n();
        final y2 = rel ? y + n() : n();
        final nx = rel ? x + n() : n();
        final ny = rel ? y + n() : n();
        path.cubicTo(x1, y1, x2, y2, nx, ny);
        ctrlX = x2;
        ctrlY = y2;
        x = nx;
        y = ny;
      case 'S':
        final x1 = ctrlX == null ? x : 2 * x - ctrlX;
        final y1 = ctrlY == null ? y : 2 * y - ctrlY;
        final x2 = rel ? x + n() : n();
        final y2 = rel ? y + n() : n();
        final nx = rel ? x + n() : n();
        final ny = rel ? y + n() : n();
        path.cubicTo(x1, y1, x2, y2, nx, ny);
        ctrlX = x2;
        ctrlY = y2;
        x = nx;
        y = ny;
      default:
        throw FormatException('Unsupported SVG command: $cmd');
    }
  }
  return path;
}
