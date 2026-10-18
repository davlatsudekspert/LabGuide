import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Lab bo'limidan analit kartasini ochish — Lab tabi ichida
/// (`/lab/analyte/<id>`), shunda "orqaga" foydalanuvchini bo'limga
/// qaytaradi (D-03). Avval karta Tahlillar tabida ochilib, "orqaga"
/// Tahlillar ro'yxatiga tushirardi (Lab auditi, 2026-10-18).
void openLabAnalyte(BuildContext context, String analyteId) =>
    context.push('/lab/analyte/$analyteId');
