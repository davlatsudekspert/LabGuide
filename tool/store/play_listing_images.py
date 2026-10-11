#!/usr/bin/env python3
"""Google Play do'kon sahifasiga LabGuide grafikalarini yuklaydi (faqat rasmlar).

Matnlarga tegmaydi. Mavjud tillar (edits.listings.list) bo'yicha ishlaydi:
har til uchun ikonka, feature graphic va telefon skrinshotlari almashtiriladi.
Til → papka: ru* → ru, uz* → uz, qolganlari → en.

Kerak: GOOGLE_PLAY_SERVICE_ACCOUNT_JSON (env), service account'da LabGuide uchun
"Ilova sahifasini boshqarish" (store listing) ruxsati. Production'ga tegmaydi —
faqat do'kon sahifasining rasmlari.
"""
import glob
import json
import os
import sys

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

PACKAGE = 'uz.labguide.app'
ROOT = os.path.join(os.path.dirname(__file__), '..', '..', 'docs', 'store')


def folder_for(lang: str) -> str:
    l = lang.lower()
    if l.startswith('ru'):
        return 'ru'
    if l.startswith('uz'):
        return 'uz'
    return 'en'


def main() -> int:
    raw = os.environ.get('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON', '')
    if not raw:
        print('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON yo\'q', file=sys.stderr)
        return 2
    creds = service_account.Credentials.from_service_account_info(
        json.loads(raw), scopes=['https://www.googleapis.com/auth/androidpublisher'])
    api = build('androidpublisher', 'v3', credentials=creds, cache_discovery=False)
    edits = api.edits()
    edit_id = edits.insert(packageName=PACKAGE, body={}).execute()['id']
    langs = [l['language'] for l in
             edits.listings().list(packageName=PACKAGE, editId=edit_id).execute().get('listings', [])]
    if not langs:
        print('Do\'kon sahifasida til yo\'q — avval Play Console\'da sahifani yarating.', file=sys.stderr)
        return 3
    icon = os.path.join(ROOT, 'google_play_icon_512.png')
    feature = os.path.join(ROOT, 'google_play_feature_graphic.png')
    for lang in langs:
        shots = sorted(glob.glob(os.path.join(ROOT, 'screenshots_play', folder_for(lang), '*.png')))[:8]
        plan = [('icon', [icon]), ('featureGraphic', [feature]), ('phoneScreenshots', shots)]
        for kind, files in plan:
            edits.images().deleteall(packageName=PACKAGE, editId=edit_id,
                                     language=lang, imageType=kind).execute()
            for f in files:
                edits.images().upload(packageName=PACKAGE, editId=edit_id, language=lang,
                                      imageType=kind,
                                      media_body=MediaFileUpload(f, mimetype='image/png')).execute()
        print(f'{lang}: ikonka, feature graphic, {len(shots)} ta skrinshot ({folder_for(lang)})')
    edits.commit(packageName=PACKAGE, editId=edit_id).execute()
    print('Saqlandi (commit).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
