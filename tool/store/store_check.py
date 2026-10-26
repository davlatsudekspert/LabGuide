#!/usr/bin/env python3
"""Do'konlar holatini FAQAT O'QISH (CI `store_check` rejimi): hech narsa yaratilmaydi, o'zgartirilmaydi, yuborilmaydi.

App Store Connect (API kalit) — ilova versiyalari va ko'rib chiqish holati, obuna guruhlari soni.
Google Play (service account) — treklar/relizlar holati, obuna mahsulotlari soni.
Soliq/bank/shartnoma holati ikkala API'da ham YO'Q — ularni konsolda ko'rish kerak (hisobotda yoziladi).
Kalitlar chiqarilmaydi; natija GITHUB_STEP_SUMMARY ga.
"""
import base64, json, os, sys, tempfile, time, urllib.request, urllib.error

out = []


def say(s=''):
    print(s)
    out.append(s)


def asc_token():
    import jwt
    key = base64.b64decode(os.environ['API_PRIVATE_KEY']).decode()
    now = int(time.time())
    return jwt.encode({'iss': os.environ['API_ISSUER_ID'], 'iat': now, 'exp': now + 600, 'aud': 'appstoreconnect-v1'},
                      key, algorithm='ES256', headers={'kid': os.environ['API_KEY_ID'], 'typ': 'JWT'})


def asc_get(tok, path):
    req = urllib.request.Request('https://api.appstoreconnect.apple.com' + path, headers={'Authorization': 'Bearer ' + tok})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return r.status, json.load(r)
    except urllib.error.HTTPError as e:
        try:
            body = json.load(e)
        except Exception:
            body = {}
        return e.code, body


def apple():
    say('## App Store Connect (faqat o‘qish)')
    if not all(os.environ.get(k) for k in ('API_KEY_ID', 'API_ISSUER_ID', 'API_PRIVATE_KEY')):
        say('- ASC kalitlari (GitHub secrets) yo‘q — tekshirib bo‘lmadi'); return
    tok = asc_token()
    app = os.environ['ASC_APP_ID']
    st, d = asc_get(tok, f'/v1/apps/{app}')
    say(f'- ilova: HTTP {st}' + (f", nom={d['data']['attributes'].get('name')}, bundle={d['data']['attributes'].get('bundleId')}" if st == 200 else ''))
    st, d = asc_get(tok, f'/v1/apps/{app}/appStoreVersions?limit=5')
    if st == 200:
        for v in d['data']:
            a = v['attributes']
            say(f"- versiya {a.get('versionString')} ({a.get('platform')}): **{a.get('appStoreState')}**")
    else:
        say(f'- versiyalar: HTTP {st}')
    st, d = asc_get(tok, f'/v1/apps/{app}/subscriptionGroups?limit=10')
    say(f"- obuna guruhlari: HTTP {st}" + (f", soni={len(d.get('data', []))}" if st == 200 else f" ({(d.get('errors') or [{}])[0].get('code')})"))
    say('- Paid Apps shartnomasi, bank, soliq holati API orqali KO‘RINMAYDI: App Store Connect → Business → Agreements.')


def google():
    say('## Google Play (faqat o‘qish)')
    raw = os.environ.get('PLAY_JSON')
    if not raw:
        say('- Play service account (GitHub secret) yo‘q — tekshirib bo‘lmadi'); return
    from google.oauth2 import service_account
    from googleapiclient.discovery import build
    pkg = os.environ.get('PLAY_PACKAGE', 'uz.labguide.app')
    cred = service_account.Credentials.from_service_account_info(json.loads(raw), scopes=['https://www.googleapis.com/auth/androidpublisher'])
    svc = build('androidpublisher', 'v3', credentials=cred, cache_discovery=False)
    try:
        edit = svc.edits().insert(packageName=pkg, body={}).execute()
        eid = edit['id']
        try:
            for t in svc.edits().tracks().list(packageName=pkg, editId=eid).execute().get('tracks', []):
                rel = [f"{r.get('status')} vc={r.get('versionCodes')}" for r in t.get('releases', [])]
                say(f"- trek {t['track']}: {rel or 'relizsiz'}")
        finally:
            svc.edits().delete(packageName=pkg, editId=eid).execute()
    except Exception as e:  # noqa: BLE001
        say(f'- treklar o‘qilmadi: {type(e).__name__}: {str(e)[:200]}')
    try:
        subs = svc.monetization().subscriptions().list(packageName=pkg).execute().get('subscriptions', [])
        say(f'- obuna mahsulotlari: {len(subs)} ta ' + str([s.get("productId") for s in subs]))
    except Exception as e:  # noqa: BLE001
        say(f'- obunalar o‘qilmadi: {type(e).__name__}: {str(e)[:200]}')
    say('- Merchant profili, bank va soliq holati API orqali KO‘RINMAYDI: Play Console → Settings → Payments profile.')


if __name__ == '__main__':
    apple()
    say()
    google()
    p = os.environ.get('GITHUB_STEP_SUMMARY')
    if p:
        open(p, 'a', encoding='utf-8').write('\n'.join(out) + '\n')
