import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/entitlements/feature.dart';

/// To'lov oynasi manzili; [feature] berilsa — qaysi imkoniyat uchun ochilgani.
String purchaseRoute([Feature? feature]) => feature == null
    ? '/profile/purchase'
    : '/profile/purchase?feature=${feature.name}';

/// Pullik imkoniyatni BOSHLASHDAN OLDIN tekshirish (D-53): ochiq bo'lsa
/// `true`. Yopiq bo'lsa to'lov oynasi ochiladi va qaytgach yana tekshiriladi.
///
/// Faqat amal boshlanishidan oldin chaqiriladi — boshlangan test yoki
/// sanash hech qachon to'xtatilmaydi. To'lov yoqilmagan buildda
/// `EntitlementService.can` doim `true`, shuning uchun hech narsa ochilmaydi.
Future<bool> requireFeature(BuildContext context, Feature feature) async {
  final ent = context.services.entitlements;
  if (ent.can(feature)) return true;
  await context.push(purchaseRoute(feature));
  return context.mounted && ent.can(feature);
}

/// [requireFeature] dan keyin [path] ga o'tish (ro'yxat qatorlari uchun).
Future<void> pushGated(
  BuildContext context,
  Feature feature,
  String path,
) async {
  if (await requireFeature(context, feature) && context.mounted) {
    await context.push(path);
  }
}

/// Sinxron tekshiruv — sanash tugmasi kabi darhol bajariladigan amallar
/// uchun (D-76). Ochiq bo'lsa `true` va amal shu zahoti bajariladi (to'lov
/// yoqilmagan buildda doim shunday). Yopiq bo'lsa to'lov oynasi ochiladi va
/// `false` — bosish bajarilmaydi.
///
/// [inProgress] — boshlangan sessiya (masalan, sanash o'rtasida): hech
/// qachon tekshirilmaydi va to'xtatilmaydi (obuna o'rtada tugasa ham).
bool allowOrOffer(
  BuildContext context,
  Feature feature, {
  bool inProgress = false,
}) {
  if (inProgress || context.services.entitlements.can(feature)) return true;
  unawaited(context.push(purchaseRoute(feature)));
  return false;
}
