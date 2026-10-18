import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';

import '../tokens.dart';

/// Javobdan keyin paydo bo'ladigan izoh (to'g'ri/xato) ekrandan pastda
/// qolsa — ro'yxatni shu izoh boshigacha suradi.
///
/// Audit 2026-10-18 (tablar): kichik telefonda (360×640, ×1.3) javob
/// variantini bosgach "To'g'ri / xato" izohi va "Keyingi" tugmasi
/// ko'rinmasdi — har savolda qo'lda surish kerak edi. Izoh allaqachon
/// ko'rinib turgan bo'lsa (katta ekran) — hech narsa qilinmaydi;
/// ro'yxat hech qachon yuqoriga (orqaga) surilmaydi.
class RevealOnMount extends StatefulWidget {
  const RevealOnMount({super.key, required this.child});

  final Widget child;

  /// Pastdagi suzuvchi menyu va xavfsiz hudud uchun zaxira (px).
  static const bottomReserve = 112.0;

  /// Izoh boshi viewportning shu ulushida turadi (yuqoridan).
  static const anchor = 0.35;

  @override
  State<RevealOnMount> createState() => _RevealOnMountState();
}

class _RevealOnMountState extends State<RevealOnMount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  void _reveal() {
    if (!mounted) return;
    final scrollable = Scrollable.maybeOf(context);
    final box = context.findRenderObject();
    if (scrollable == null || box is! RenderBox || !box.hasSize) return;
    final position = scrollable.position;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null || !position.hasContentDimensions) return;
    final viewportBox = scrollable.context.findRenderObject();
    if (viewportBox is! RenderBox) return;
    final top = box.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
    final visibleBottom =
        viewportBox.size.height -
        MediaQuery.paddingOf(context).bottom -
        RevealOnMount.bottomReserve;
    // Izohning kamida 48 px qismi ko'rinib tursa — foydalanuvchi uni ko'radi.
    if (top + 48 <= visibleBottom) return;
    final target =
        (position.pixels + top - viewportBox.size.height * RevealOnMount.anchor)
            .clamp(position.pixels, position.maxScrollExtent);
    if (target <= position.pixels) return;
    final d = LgMotion.of(context, const Duration(milliseconds: 280));
    if (d == Duration.zero) {
      position.jumpTo(target);
    } else {
      unawaited(position.animateTo(target, duration: d, curve: Curves.easeOut));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
