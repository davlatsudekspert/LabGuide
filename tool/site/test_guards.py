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
HOST = 'https://labguide.nfcstore.uz/'


class SiteGuards(unittest.TestCase):
    def test_pages_exist(self):
        for page in ('index.html', 'privacy/index.html', 'delete-account/index.html', 'j/index.html'):
            self.assertTrue((SITE / page).is_file(), page)

    def test_check_site_passes(self):
        self.assertEqual(check_site.check_site(SITE), [])

    def test_check_site_self_test(self):
        with redirect_stdout(io.StringIO()):
            self.assertEqual(check_site.self_test(), 0)

    def test_privacy_url_matches_app(self):
        contact = (ROOT / 'lib/core/contact.dart').read_text(encoding='utf-8')
        self.assertIn(f"'{PRIVACY_URL}'", contact)

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
        self.assertEqual(check_site.SUBSCRIPTION_TEXT_PAGES, {'privacy/index.html'})
        self.assertTrue(check_site.SUBSCRIPTION_WORDS <= names)
        self.assertNotIn('narx literali', check_site.SUBSCRIPTION_WORDS)
        self.assertNotIn('sinov 7 kun emas', check_site.SUBSCRIPTION_WORDS)


if __name__ == '__main__':
    unittest.main()
