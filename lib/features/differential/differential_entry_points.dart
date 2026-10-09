/// Leykoformula: keyinchalik "entitlement" (Pro) qatlami bilan bog'lanadigan
/// kirish nuqtalari. Egasining qarori: hisoblagich, foiz va mutlaq sonlar
/// doim BEPUL; boshlangan sanash hech qachon to'lov oynasi bilan
/// to'xtatilmaydi; tarix qurilmada to'liq saqlanadi va yashirincha
/// o'chirilmaydi. Cheklov (bo'lsa) faqat KO'RSATISHGA qo'yiladi.
///
/// Hozir hamma narsa ochiq. To'lov UI yo'q.
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'differential_controller.dart';

abstract final class DiffEntryPoints {
  /// Tarix ro'yxatida ko'rsatiladigan yozuvlar soni (`null` — cheksiz).
  /// Ma'lumot baribir to'liq saqlanadi; bu faqat ro'yxatni chizish chegarasi.
  static int? historyVisibleLimit(BuildContext context) => null;

  /// Kengaytirilgan mashq ("belgi → hujayra" savollari bilan).
  static const extendedQuizLocation = '/lab/differential/quiz?mode=extended';

  static void openExtendedQuiz(BuildContext context) =>
      context.push(extendedQuizLocation);

  /// PDF eksport hali amalga oshirilmagan: ilovada PDF yaratuvchi kutubxona
  /// yo'q (pdfrx — faqat o'quvchi). Shuning uchun UI'da tugma yo'q va
  /// funksiya `false` qaytaradi — ishlayotgandek ko'rsatilmaydi.
  static bool get pdfExportAvailable => false;

  /// Natijani PDF ga eksport qilish uchun kirish nuqtasi. Amalga oshirilganda
  /// shu yerda yoziladi va [pdfExportAvailable] `true` bo'ladi.
  static Future<bool> exportPdf(
    BuildContext context,
    DiffRecord record,
  ) async => false;
}
