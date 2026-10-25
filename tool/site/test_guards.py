"""Qorovul (guard) testlari: statik sayt va do'kon havolalari.

    python3 -m unittest discover -s tool/site -p 'test_*.py'

Egasi qarori: maxfiylik siyosati — https://labguide.nfcstore.uz/privacy/
(ilovadagi `lib/core/contact.dart` bilan bir xil); sayt sahifalari mavjud va
check_site.py dan o'tadi; do'kon yo'riqnomalarida eski manzil
(nfcstore.uz/labguide/) qolmaydi. Jadval: docs/GUARDS.md.
"""
from __future__ import annotations

import io
import re
import sys
import unittest
from contextlib import redirect_stdout
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE))

import check_site  # noqa: E402

SITE = ROOT / 'site'
PRIVACY_URL = 'https://labguide.nfcstore.uz/privacy/'
TERMS_URL = 'https://labguide.nfcstore.uz/terms/'
HOST = 'https://labguide.nfcstore.uz/'


class SiteGuards(unittest.TestCase):
    def test_pages_exist(self):
        for page in ('index.html', 'privacy/index.html', 'terms/index.html', 'delete-account/index.html',
                     'j/index.html'):
            self.assertTrue((SITE / page).is_file(), page)

    def test_check_site_passes(self):
        self.assertEqual(check_site.check_site(SITE), [])

    def test_check_site_self_test(self):
        with redirect_stdout(io.StringIO()):
            self.assertEqual(check_site.self_test(), 0)

    def test_privacy_url_matches_app(self):
        contact = (ROOT / 'lib/core/contact.dart').read_text(encoding='utf-8')
        self.assertIn(f"'{PRIVACY_URL}'", contact)

    def test_terms_url_matches_app(self):
        # Foydalanish shartlari manzili ilovadagi (to'lov oynasi) bilan bir xil.
        contact = (ROOT / 'lib/core/contact.dart').read_text(encoding='utf-8')
        self.assertIn(f"'{TERMS_URL}'", contact)
        billing = (ROOT / 'lib/core/entitlements/billing_catalog.dart').read_text(encoding='utf-8')
        self.assertIn('termsOfUse = Contact.termsOfUseUrl', billing)

    def test_terms_page_generated_and_complete(self):
        import build_site
        page = (SITE / 'terms/index.html').read_text(encoding='utf-8')
        self.assertEqual(page, build_site.build_terms())
        for lang in ('uz', 'ru', 'en'):
            self.assertIn(f'<section id="{lang}" lang="{lang}">', page)
        # Har uch tilda majburiy obuna shartlari bor (Apple 3.1.2 / Play): avtomatik
        # yangilanish, do'kon orqali bekor qilish, 7 kunlik sinov, nima yopilishi.
        src = (ROOT / 'docs/store/TERMS_OF_USE.md').read_text(encoding='utf-8')
        sections = re.split(r'^## ', src, flags=re.M)[1:]
        self.assertEqual(len(sections), 3)
        must = {
            'O‘zbekcha': ['avtomatik', '24 soat', 'bekor qil', '7 kunlik bepul sinov', 'faqat pullik imkoniyatlar yopiladi',
                          'Talaba Pro', 'Ustoz Pro', 'Mutaxassis Pro', 'Premium', 'Apple', 'Google Play',
                          'tashxis qo‘ymaydi', PRIVACY_URL],
            'Русский': ['автоматическ', '24 часа', 'отмен', 'на 7 дней', 'закрываются только платные функции',
                        'Студент Pro', 'Преподаватель Pro', 'Специалист Pro', 'Premium', 'Apple', 'Google Play',
                        'не ставит диагноз', PRIVACY_URL],
            'English': ['auto-renew', '24 hours', 'cancel', '7-day free trial', 'only the paid features close',
                        'Student Pro', 'Teacher Pro', 'Specialist Pro', 'Premium', 'Apple', 'Google Play',
                        'does not diagnose', PRIVACY_URL],
        }
        for sec in sections:
            name = sec.split('\n', 1)[0].strip()
            flat = ' '.join(sec.split())  # qator o'tkazishlarni tekislaymiz
            for needle in must[name]:
                self.assertIn(needle, flat, f'{name}: {needle}')

    def test_store_docs_use_same_host(self):
        # Do'kon maydonlariga yoziladigan manzillar ilovadagi bilan bir xil.
        old = re.compile(r'https://nfcstore\.uz/labguide/')
        files = [ROOT / 'site/README.md', *sorted((ROOT / 'docs/store').glob('*.md'))]
        for f in files:
            text = f.read_text(encoding='utf-8')
            self.assertIsNone(old.search(text), f'{f.relative_to(ROOT)}: eski manzil')
        app_store = (ROOT / 'docs/store/APP_STORE.md').read_text(encoding='utf-8')
        play = (ROOT / 'docs/store/PLAY_CONSOLE_UPLOAD.md').read_text(encoding='utf-8')
        self.assertIn(PRIVACY_URL, app_store)
        self.assertIn(PRIVACY_URL, play)
        self.assertIn(TERMS_URL, app_store)
        self.assertIn(TERMS_URL, play)
        self.assertIn(HOST + 'delete-account/', play)

    def test_join_page_opens_app(self):
        page = (SITE / 'j/index.html').read_text(encoding='utf-8')
        self.assertIn("'labguide://app/j?c='", page)

    def test_no_payment_words_on_site(self):
        # D-77 (D-58 o'rniga, faqat paid/pro-premium): to'lov/obuna so'zlari
        # faqat privacy/ sahifasida; narx literali va 7 dan boshqa sinov
        # muddati hech bir sahifada yo'q.
        names = {n for n, _ in check_site.BANNED}
        for n in ('Pro', 'obuna', 'subscription', 'payment', 'to‘lov', 'оплата/подписка',
                  'narx literali', 'sinov 7 kun emas'):
            self.assertIn(n, names)
        self.assertEqual(check_site.SUBSCRIPTION_TEXT_PAGES, {'privacy/index.html', 'terms/index.html'})
        self.assertTrue(check_site.SUBSCRIPTION_WORDS <= names)
        self.assertNotIn('narx literali', check_site.SUBSCRIPTION_WORDS)
        self.assertNotIn('sinov 7 kun emas', check_site.SUBSCRIPTION_WORDS)


if __name__ == '__main__':
    unittest.main()
