// Pullik versiya matnlari izchilligi (D-77, 2026-10-25; matnlar agenti).
//
// Bir xil fikr — hamma joyda bir xil: ilova ARB (uz/ru/en), maxfiylik
// siyosati, Foydalanish shartlari, do'kon hujjatlari va sayt sahifalari.
//
// * Reja nomlari har tilda bir xil (uz: Talaba Pro / Ustoz Pro / Mutaxassis Pro /
//   Premium; ru: Студент Pro / Преподаватель Pro / Специалист Pro / Premium;
//   en: Student Pro / Teacher Pro / Specialist Pro / Premium); eski
//   “Ustoz” / “Премиум” / “Teacher plan” kabi nomlar qaytmaydi.
// * Bepul sinov — hamma matnda faqat 7 kun (30 / 14 emas), bir marta, karta yo'q.
// * Narx literali yo'q: ARB, sayt, huquqiy va do'kon matnlarida narx
//   yozilmaydi (narx do'kondan; yagona ma'lumot — ProPricing).
// * To'lov oynasidan Foydalanish shartlari va Maxfiylik siyosatiga havola bor
//   (matn kalitlari, Dart havolalari, sayt sahifalari, do'kon maydonlari).
// * Muddat tugagach “faqat pullik imkoniyatlar yopiladi; bepul va ma'lumotlar
//   qoladi” har tilda aytilgan; obuna ochiq-oydin sharti (avtomatik yangilanish,
//   24 soat, bekor qilish yo'li) bor.
// * 24 oylik sinov xeshi saqlash muddati ARB va siyosatda bir xil va siyosat
//   manbasida NEEDS_LAWYER_REVIEW belgisi turadi (saytga chiqmaydi).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/contact.dart';
import 'package:labguide/core/entitlements/billing_catalog.dart';

const _langs = ['uz', 'ru', 'en'];

/// Yakuniy reja nomlari (egasi qarori, 2026-10-25).
const _names = {
  'uz': ['Talaba Pro', 'Ustoz Pro', 'Mutaxassis Pro', 'Premium'],
  'ru': ['Студент Pro', 'Преподаватель Pro', 'Специалист Pro', 'Premium'],
  'en': ['Student Pro', 'Teacher Pro', 'Specialist Pro', 'Premium'],
};

/// ARB kalitlari: student, teacher, specialist, premium (tartib bilan).
const _tierKeys = [
  'proPayTierStudent',
  'proPayTierTeacher',
  'proPayTierSpecialist',
  'proPayTierPremium',
];
const _planKeys = [
  'proPlanStudent',
  'proPlanTeacher',
  'proPlanSpecialist',
  'proPlanPremium',
];

/// Eski / noto'g'ri reja nomlari (kolokatsiya bo'yicha; “Ustoz paneli”,
/// “ustoz” roli va h.k. to'g'ri so'zlar emas).
final _badNames = {
  'uz': RegExp(
    r'(Talaba|Ustoz|Mutaxassis) (rejasi|sinovi|obunasi|tarifi|yoki Premium|va Premium)|'
    r'Pro tarifi|«(Ustoz|Talaba|Mutaxassis)»',
  ),
  'ru': RegExp(
    r'Премиум|Pro для|«(Студент|Преподаватель|Специалист)(?! Pro)',
  ),
  'en': RegExp(
    r'(Student|Teacher|Specialist) (plan|trial|or Premium|and Premium)|'
    r'“(Student|Teacher|Specialist)”',
  ),
};

/// Sinov muddati: har tilda “N kunlik bepul sinov” va h.k.
final _trialDays = {
  'uz': RegExp(r'(\d+)\s*kunlik\s+(bepul\s+)?sinov'),
  'ru': RegExp(r'пробн\S*\s+период\S*\s+(на\s+)?(\d+)\s*дн'),
  'en': RegExp(r'(\d+)-day\s+(free\s+)?trial', caseSensitive: false),
};

/// 7 dan boshqa sinov muddati (har qanday til; yaqin so'z bilan).
final _otherTrial = RegExp(
  r'(?<!\d)(?!7(?!\d))\d+[\s -]*(kunlik|kun|days?|day|дн\w*)[\s-]*(bepul\s+|free\s+|бесплатн\w*\s+)?(sinov|trial|пробн)|'
  r'(sinov|trial|пробн\w*\s+период\w*)\s+(na\s+|of\s+|на\s+)?(?!7(?!\d))\d+[\s -]*(kun|days?|дн)',
  caseSensitive: false,
);

/// Narx literali (valyuta bilan) va egasi bergan D-76 / eski taklif summalari.
final _price = RegExp(
  r"[$€£]\s?\d|\d\s?(usd|uzs|so['‘ʼ’]m)\b|\d\s?сум(?![а-яё])|\b(usd|uzs)\s?\d|"
  r'\d+[.,]\d{2}\s?(\$|usd)|'
  r'(?<![\d.,])(1\.49|9\.99|2\.49|24\.99|3\.49|34\.99|4\.99|49\.99|3\.99|5\.99|6\.99)(?!\d)',
  caseSensitive: false,
);

String _read(String path) => File(path).readAsStringSync();

Map<String, String> _arb(String lang) => {
  for (final e in (jsonDecode(_read('lib/l10n/app_$lang.arb')) as Map)
      .cast<String, Object?>()
      .entries)
    if (!e.key.startsWith('@') && e.value is String) e.key: e.value! as String,
};

/// pro* kalitlari (`profile*` emas).
Map<String, String> _proArb(String lang) => {
  for (final e in _arb(lang).entries)
    if (RegExp(r'^pro(?!file)').hasMatch(e.key)) e.key: e.value,
};

/// Markdown'ni til bo'limlariga ajratadi (## O‘zbekcha / Русский / English).
Map<String, String> _sections(String md) {
  const heads = {'O‘zbekcha': 'uz', 'Русский': 'ru', 'English': 'en'};
  final out = <String, String>{};
  final parts = md.split(RegExp(r'^## ', multiLine: true)).skip(1);
  for (final p in parts) {
    final nl = p.indexOf('\n');
    final head = p.substring(0, nl).trim();
    final lang = heads[head];
    if (lang != null) out[lang] = p.substring(nl + 1);
  }
  return out;
}

String _flat(String s) => s.split(RegExp(r'\s+')).join(' ');

/// Siyosatning 16-bo'limi (obuna/sinov/to'lov) — til bo'limi ichidan.
String _privacy16(String langSection) {
  final a = langSection.indexOf('### 16.');
  final b = langSection.indexOf('### 17.');
  expect(a, greaterThanOrEqualTo(0), reason: '16-bo‘lim yo‘q');
  expect(b, greaterThan(a), reason: '17-bo‘lim yo‘q');
  return langSection.substring(a, b);
}

/// Matn (hujjat) ichidagi sinov muddati 7 ekanini tekshiradi.
void _expectTrial7(String lang, String text, String where) {
  for (final m in _trialDays[lang]!.allMatches(text)) {
    final n = lang == 'ru' ? m[2] : m[1];
    expect(n, '7', reason: '$where: ${m[0]}');
  }
  final bad = _otherTrial.firstMatch(text);
  expect(bad, isNull, reason: '$where: 7 dan boshqa sinov muddati: ${bad?[0]}');
}

void main() {
  final arb = {for (final l in _langs) l: _arb(l)};
  final pro = {for (final l in _langs) l: _proArb(l)};
  final terms = _sections(_read('docs/store/TERMS_OF_USE.md'));
  final privacy = _sections(_read('docs/store/PRIVACY_POLICY.md'));
  final appStoreAll = _read('docs/store/APP_STORE.md');
  final playAll = _read('docs/store/PLAY_CONSOLE_UPLOAD.md');
  final appStore = appStoreAll.substring(appStoreAll.indexOf('## 16. Pullik versiya'));
  final play = playAll.substring(playAll.indexOf('## 7. Pullik versiya'));

  group('reja nomlari: har tilda bir xil (ARB, hujjatlar, sayt)', () {
    test('ARB: proPayTier* va proPlan* yakuniy nomlarga teng', () {
      for (final l in _langs) {
        for (var i = 0; i < 4; i++) {
          expect(arb[l]![_tierKeys[i]], _names[l]![i], reason: '$l ${_tierKeys[i]}');
          expect(arb[l]![_planKeys[i]], _names[l]![i], reason: '$l ${_planKeys[i]}');
        }
      }
    });

    test('ARB pro*: eski / noto‘g‘ri reja nomlari yo‘q', () {
      for (final l in _langs) {
        for (final e in pro[l]!.entries) {
          final m = _badNames[l]!.firstMatch(e.value);
          expect(m, isNull, reason: '$l ${e.key}: ${m?[0]}');
        }
      }
    });

    test('ARB: reja tavsifi va imkoniyat ro‘yxatida to‘rtala nom ham ishlatilgan', () {
      for (final l in _langs) {
        final all = pro[l]!.values.join('\n');
        for (final n in _names[l]!) {
          expect(all, contains(n), reason: '$l: $n');
        }
        // Premium = hammasi birga: tavsifida uchala Pro nomi bor.
        final premiumSub = arb[l]!['proPayTierPremiumSub']!;
        for (final n in _names[l]!.take(3)) {
          expect(premiumSub, contains(n), reason: '$l proPayTierPremiumSub: $n');
        }
      }
    });

    test('Foydalanish shartlari va siyosatning 16-bo‘limi: to‘rtala nom, eski nom yo‘q', () {
      expect(terms.keys.toSet(), _langs.toSet());
      expect(privacy.keys.toSet(), _langs.toSet());
      for (final l in _langs) {
        final t = _flat(terms[l]!);
        final p = _flat(_privacy16(privacy[l]!));
        for (final n in _names[l]!) {
          expect(t, contains(n), reason: '$l TERMS_OF_USE: $n');
          expect(p, contains(n), reason: '$l PRIVACY 16: $n');
        }
        expect(_badNames[l]!.firstMatch(t), isNull, reason: '$l TERMS_OF_USE');
        expect(_badNames[l]!.firstMatch(p), isNull, reason: '$l PRIVACY 16');
      }
    });

    test('do‘kon hujjatlari (pullik bo‘limlar): har tilda to‘rtala nom', () {
      for (final l in _langs) {
        for (final n in _names[l]!) {
          expect(appStore, contains(n), reason: 'APP_STORE 16 [$l]: $n');
          expect(play, contains(n), reason: 'PLAY 7 [$l]: $n');
        }
        expect(_badNames[l]!.firstMatch(_flat(appStore)), isNull, reason: 'APP_STORE 16 [$l]');
        expect(_badNames[l]!.firstMatch(_flat(play)), isNull, reason: 'PLAY 7 [$l]');
      }
    });

    test('sayt: /terms/ va /privacy/ sahifalarida nomlar bor (tilga qarab)', () {
      for (final page in ['site/terms/index.html', 'site/privacy/index.html']) {
        final html = _read(page);
        for (final l in _langs) {
          final sec = RegExp('<section id="$l" lang="$l">(.*?)</section>', dotAll: true)
              .firstMatch(html)!
              .group(1)!;
          final flat = _flat(sec.replaceAll(RegExp(r'<[^>]+>'), ' '));
          for (final n in _names[l]!) {
            expect(flat, contains(n), reason: '$page [$l]: $n');
          }
        }
      }
    });
  });

  group('bepul sinov: hamma matnda faqat 7 kun', () {
    test('ARB: sinov matnida 7; 7 dan boshqa muddat yo‘q', () {
      for (final l in _langs) {
        for (final e in arb[l]!.entries) {
          _expectTrial7(l, e.value, '$l ${e.key}');
        }
        expect(_trialDays[l]!.hasMatch(arb[l]!['proPrivacyTrialNote']!), isTrue,
            reason: '$l proPrivacyTrialNote sinov muddatini aytmaydi');
      }
    });

    test('ARB: sinov bir marta va kartasiz (uch tilda)', () {
      final once = {'uz': 'bir marta', 'ru': 'один раз', 'en': 'once'};
      final noCard = {
        'uz': RegExp(r'karta yoki to‘lov usuli kerak emas|to‘lov usuli yo‘q'),
        'ru': RegExp(r'карта или способ оплаты не нужны|без способа оплаты'),
        'en': RegExp(r'no card or payment method|no payment method'),
      };
      for (final l in _langs) {
        expect(noCard[l]!.hasMatch(arb[l]!['proSubTrialBody']!), isTrue, reason: l);
        expect(noCard[l]!.hasMatch(arb[l]!['proSubTrialConfirmBody']!), isTrue, reason: l);
        expect(arb[l]!['proSubTrialBody']!.toLowerCase(), contains(once[l]), reason: l);
        expect(arb[l]!['proSubTrialOncePerPhone'], isNotEmpty);
      }
    });

    test('shartlar, siyosat, do‘kon hujjatlari va sayt sahifalari: 7 kun', () {
      for (final l in _langs) {
        _expectTrial7(l, _flat(terms[l]!), '$l TERMS_OF_USE');
        expect(_trialDays[l]!.hasMatch(_flat(terms[l]!)), isTrue, reason: '$l TERMS_OF_USE sinov muddatini aytmaydi');
        final p16 = _flat(_privacy16(privacy[l]!));
        _expectTrial7(l, p16, '$l PRIVACY 16');
        expect(_trialDays[l]!.hasMatch(p16), isTrue, reason: '$l PRIVACY 16 sinov muddatini aytmaydi');
      }
      for (final e in {'APP_STORE 16': appStore, 'PLAY 7': play}.entries) {
        for (final l in _langs) {
          _expectTrial7(l, _flat(e.value), '${e.key} [$l]');
        }
      }
      for (final page in ['site/terms/index.html', 'site/privacy/index.html']) {
        final html = _flat(_read(page).replaceAll(RegExp(r'<[^>]+>'), ' '));
        for (final l in _langs) {
          _expectTrial7(l, html, '$page [$l]');
        }
      }
    });
  });

  group('narx literali yo‘q (narx do‘kondan)', () {
    test('ARB (hamma kalit), sayt sahifalari, huquqiy va do‘kon matnlari', () {
      for (final l in _langs) {
        for (final e in arb[l]!.entries) {
          expect(_price.hasMatch(e.value), isFalse, reason: '$l ${e.key}');
        }
      }
      final sources = {
        'TERMS_OF_USE.md': _read('docs/store/TERMS_OF_USE.md'),
        'PRIVACY_POLICY.md': _read('docs/store/PRIVACY_POLICY.md'),
        'APP_STORE.md §16': appStore,
        'PLAY_CONSOLE_UPLOAD.md §7': play,
        'site/terms': _read('site/terms/index.html'),
        'site/privacy': _read('site/privacy/index.html'),
        'site/index': _read('site/index.html'),
      };
      for (final e in sources.entries) {
        final m = _price.firstMatch(e.value);
        expect(m, isNull, reason: '${e.key}: ${m?[0]}');
      }
    });
  });

  group('Foydalanish shartlari + Maxfiylik havolalari to‘lov oynasida', () {
    test('ARB: havola yorliqlari va rozilik matni (uch tilda)', () {
      final terms = {'uz': 'Foydalanish shartlari', 'ru': 'Условия использования', 'en': 'Terms of Use'};
      final priv = {'uz': 'Maxfiylik siyosati', 'ru': 'Политика конфиденциальности', 'en': 'Privacy Policy'};
      // Rozilik jumlasida rus tilida kelishik o'zgaradi (“Политику …”): o'zak bilan.
      final privStem = {'uz': 'Maxfiylik siyosati', 'ru': 'конфиденциальности', 'en': 'Privacy Policy'};
      for (final l in _langs) {
        expect(arb[l]!['proPayTerms'], contains(terms[l]!), reason: l);
        expect(arb[l]!['proPayPrivacy'], contains(priv[l]!), reason: l);
        final agree = arb[l]!['proPayAgreeNote']!;
        expect(agree, contains(terms[l]!), reason: '$l proPayAgreeNote');
        expect(agree, contains(privStem[l]!), reason: '$l proPayAgreeNote');
      }
    });

    test('Dart: ikkala ekran ham ikkala havolani ochadi; manzillar saytniki', () {
      expect(Contact.termsOfUseUrl, 'https://labguide.nfcstore.uz/terms/');
      expect(Contact.privacyPolicyUrl, 'https://labguide.nfcstore.uz/privacy/');
      expect(BillingLinks.termsOfUse, Contact.termsOfUseUrl);
      expect(BillingLinks.privacyPolicy, Contact.privacyPolicyUrl);
      for (final f in [
        'lib/features/profile/purchase_screen.dart',
        'lib/features/profile/subscription_screen.dart',
      ]) {
        final src = _read(f);
        for (final needle in [
          'l.proPayTerms',
          'l.proPayPrivacy',
          'BillingLinks.termsOfUse',
          'BillingLinks.privacyPolicy',
        ]) {
          expect(src, contains(needle), reason: '$f: $needle');
        }
      }
    });

    test('sayt sahifalari mavjud; do‘kon hujjatlarida ikkala manzil bor', () {
      expect(File('site/terms/index.html').existsSync(), isTrue);
      expect(File('site/privacy/index.html').existsSync(), isTrue);
      for (final e in {'APP_STORE.md': appStore, 'PLAY_CONSOLE_UPLOAD.md': play}.entries) {
        expect(e.value, contains(Contact.termsOfUseUrl), reason: e.key);
        expect(e.value, contains(Contact.privacyPolicyUrl), reason: e.key);
      }
      for (final l in _langs) {
        expect(terms[l]!, contains(Contact.privacyPolicyUrl), reason: 'TERMS [$l]');
        expect(_privacy16(privacy[l]!), contains(Contact.termsOfUseUrl), reason: 'PRIVACY 16 [$l]');
      }
    });
  });

  group('obuna ochiq-oydin sharti va muddat tugash matni', () {
    test('proPayDisclosure: {store}, 24 soat, avtomatik yangilanish, do‘kon oynasi', () {
      final auto = {'uz': 'avtomatik yangilanadi', 'ru': 'продлевается автоматически', 'en': 'renew automatically'};
      final cancel = {'uz': 'bekor qil', 'ru': 'отмен', 'en': 'cancel'};
      final h24 = {'uz': '24 soat', 'ru': '24 часа', 'en': '24 hours'};
      for (final l in _langs) {
        final d = arb[l]!['proPayDisclosure']!;
        expect(d, contains('{store}'), reason: l);
        expect(d, contains(auto[l]!), reason: l);
        expect(d, contains(cancel[l]!), reason: l);
        expect(d, contains(h24[l]!), reason: l);
        // do'kon bepul sinov/boshlang'ich taklif ko'rsatsa — narx va shartlar do'konnikidek
        final store = arb[l]!['proPayStoreTrialNote']!;
        expect(store, contains('{store}'), reason: l);
        final trial = arb[l]!['proPayTrial']!;
        expect(trial, contains('{trial}'), reason: l);
        expect(trial, contains('{price}'), reason: l);
      }
    });

    test('bekor qilish yo‘li (Apple / Google) — ARB, shartlar va siyosat', () {
      final apple = {'uz': 'Sozlamalar', 'ru': 'Настройки', 'en': 'Settings'};
      final google = {'uz': 'Google Play', 'ru': 'Google Play', 'en': 'Google Play'};
      for (final l in _langs) {
        expect(arb[l]!['proPayCancelPathApple'], contains(apple[l]!), reason: l);
        expect(arb[l]!['proPayCancelPathGoogle'], contains(google[l]!), reason: l);
        final t = _flat(terms[l]!);
        final p = _flat(_privacy16(privacy[l]!));
        for (final text in [t, p]) {
          expect(text, contains(apple[l]!));
          expect(text, contains(google[l]!));
        }
      }
    });

    test('tugagach faqat pullik imkoniyatlar yopiladi; bepul va ma’lumot qoladi', () {
      final closes = {
        'uz': RegExp(r'faqat pullik', caseSensitive: false),
        'ru': RegExp(r'только платные', caseSensitive: false),
        'en': RegExp(r'only the paid', caseSensitive: false),
      };
      final stays = {
        'uz': RegExp(r'bepul imkoniyatlar', caseSensitive: false),
        'ru': RegExp(r'бесплатные функции', caseSensitive: false),
        'en': RegExp(r'free features', caseSensitive: false),
      };
      final data = {'uz': 'ma’lumotlaringiz', 'ru': 'данные', 'en': 'data'};
      for (final l in _langs) {
        for (final k in ['proPayFree', 'proSubTrialBody', 'proSubTrialConfirmBody', 'proSubEnded']) {
          final v = arb[l]![k]!;
          expect(closes[l]!.hasMatch(v), isTrue, reason: '$l $k');
          expect(stays[l]!.hasMatch(v), isTrue, reason: '$l $k');
        }
        for (final k in ['proSubTrialBody', 'proSubTrialConfirmBody', 'proSubEnded']) {
          expect(arb[l]![k]!.toLowerCase(), contains(data[l]), reason: '$l $k');
        }
        for (final text in [_flat(terms[l]!), _flat(_privacy16(privacy[l]!))]) {
          expect(closes[l]!.hasMatch(text), isTrue, reason: l);
          expect(stays[l]!.hasMatch(text), isTrue, reason: l);
        }
      }
    });

    test('mehmon, oflayn, qaytarish va xato holatlari uchun matnlar bor (3 til)', () {
      const keys = [
        'proPayGuestNote',
        'proPaySignInRequired',
        'proSubTrialGuest',
        'proPayOfflineNote',
        'proPayOfflineAction',
        'proStatusOffline',
        'proPayRefundNote',
        'proPayRefundedStatus',
        'proPayCancelledUntil',
        'proPayGraceNote',
        'proPayFailed',
        'proPayUnavailable',
        'proPayPending',
        'proPayNothingFound',
        'proPayOwnedByOther',
        'proPayRestored',
        'proPayDeleteAccountNote',
      ];
      for (final l in _langs) {
        for (final k in keys) {
          expect(arb[l]![k], isNotNull, reason: '$l $k yo‘q');
          expect(arb[l]![k]!.trim(), isNotEmpty, reason: '$l $k');
        }
        // Qaytarish matni do'konga yo'naltiradi.
        expect(arb[l]!['proPayRefundNote'], contains('{store}'), reason: l);
      }
    });
  });

  group('24 oylik sinov yozuvi: ARB va siyosat bir xil, yurist belgisi manbada', () {
    test('ARB va siyosat 16-bo‘limi 24 oyni aytadi', () {
      final months = {'uz': '24 oy', 'ru': '24 месяца', 'en': '24 months'};
      for (final l in _langs) {
        expect(arb[l]!['proPrivacyTrialNote'], contains(months[l]!), reason: 'ARB $l');
        expect(_flat(_privacy16(privacy[l]!)), contains(months[l]!), reason: 'PRIVACY $l');
      }
    });

    test('NEEDS_LAWYER_REVIEW izohi manbada bor, saytga chiqmaydi', () {
      final src = _read('docs/store/PRIVACY_POLICY.md');
      expect(RegExp(r'<!--[^>]*NEEDS_LAWYER_REVIEW[^>]*24', dotAll: true).hasMatch(src), isTrue);
      expect('NEEDS_LAWYER_REVIEW'.allMatches(src).length, greaterThanOrEqualTo(3)); // uz, ru, en
      for (final page in ['site/privacy/index.html', 'site/terms/index.html']) {
        final html = _read(page);
        expect(html, isNot(contains('NEEDS_')), reason: page);
        expect(html, isNot(contains('<!-- NEEDS')), reason: page);
      }
    });
  });
}
