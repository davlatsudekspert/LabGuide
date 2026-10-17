/// Ilovaning ommaviy aloqa manzili — BITTA joyda.
///
/// Manzilni almashtirish uchun faqat [email] o'zgaradi (ekran, mailto va
/// testlar shundan o'qiydi). Bu manzil Cloudflare Email Routing orqali
/// egasiga yo'naltiriladi; maxfiylik siyosati (docs/store/PRIVACY_POLICY.md)
/// va do'kon “Support” maydonlari ham shu manzilni ko'rsatadi — o'zgarsa,
/// ularni ham yangilang.
abstract final class Contact {
  static const email = 'labguide@nfcstore.uz';

  static const subjectQuestion = 'LabGuide: savol/taklif';
  static const subjectAd = 'LabGuide: reklama';
  static const subjectReport = 'LabGuide: shikoyat';

  /// Maxfiylik siyosati (docs/store/PRIVACY_POLICY.md; App Store Connect'dagi
  /// havola bilan bir xil bo'lsin — docs/store/APP_STORE.md 14-bo'lim).
  static const privacyPolicyUrl =
      'https://labguide.nfcstore.uz/privacy/';

  /// `mailto:` havolasi. Mavzu va matn foiz bilan kodlanadi (bo'sh joy
  /// `%20`, qator `%0A`): ba'zi pochta ilovalari `+` ni bo'sh joy deb
  /// tushunmaydi, shuning uchun `Uri(queryParameters:)` ishlatilmaydi.
  static Uri mailto({required String subject, String? body}) {
    final query = [
      'subject=${Uri.encodeComponent(subject)}',
      if (body != null && body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&');
    return Uri.parse('mailto:$email?$query');
  }
}
