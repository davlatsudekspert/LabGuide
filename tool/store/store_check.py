#!/usr/bin/env python3
"""Do'konlar holatini FAQAT O'QISH (CI `store_check` rejimi): hech narsa yaratilmaydi, o'zgartirilmaydi, yuborilmaydi.

App Store Connect (API kalit) — ilova versiyalari va ko'rib chiqish holati, obuna guruhlari soni.
Google Play (service account) — treklar/relizlar holati, obuna mahsulotlari soni.
Soliq/bank/shartnoma holati ikkala API'da ham YO'Q — ularni konsolda ko'rish kerak (hisobotda yoziladi).
Kalitlar chiqarilmaydi; natija GITHUB_STEP_SUMMARY ga.

D-80 (egasi qarori 2026-10-31): pullik rejalarning bepul sinovi = 30 kun. Do'kon tomoni:
Apple — har bir obuna uchun Introductory Offer = FREE_TRIAL, ONE_MONTH (kalendar oy; server sinovi aniq 30 kun);
Google Play — free-trial offer 30 kun / 1 oy. Bu skript FAQAT o'qiydi va kutilganidan farqni hisobotga
yozadi (hech narsa yaratmaydi/o'zgartirmaydi). Apple va Play maydon nomlari bu muhitda haqiqiy API bilan
TEKSHIRILMAGAN (skript ishga tushirilmagan — NOT RUN).
"""
import base64, json, os, sys, tempfile, time, urllib.request, urllib.error

out = []

# D-80: kutilgan do'kon sinov (introductory / free-trial) davri.
EXPECTED_APPLE_TRIAL = ('FREE_TRIAL', 'ONE_MONTH')   # ASC subscriptionOfferDuration
EXPECTED_PLAY_TRIAL_DURATIONS = ('P1M', 'P30D')      # ISO 8601; Play Console variantlari bo'yicha egasi tekshiradi


def apple_trial_verdict(offers):
    """offers — [(offerMode, duration)] yoki 'HTTP ...' satri. D-80 kutilgan holatga nisbatan hukm."""
    if isinstance(offers, str):
        return 'NOT CHECKED (' + offers + ')'
    if not offers:
        return 'D-80 MISMATCH: intro offer YO‘Q (kutilgan: FREE_TRIAL ONE_MONTH)'
    if EXPECTED_APPLE_TRIAL in [tuple(o) for o in offers]:
        return 'D-80 ok: FREE_TRIAL ONE_MONTH'
    return 'D-80 MISMATCH: intro=' + str(offers) + ' (kutilgan: FREE_TRIAL ONE_MONTH)'


def play_trial_verdict(durations):
    """durations — bepul (free) fazalar davomiyliklari ro'yxati."""
    if not durations:
        return 'D-80 MISMATCH: free-trial offer YO‘Q (kutilgan: 30 kun / 1 oy)'
    if any(d in EXPECTED_PLAY_TRIAL_DURATIONS for d in durations):
        return 'D-80 ok: free trial ' + ','.join(durations)
    return 'D-80 MISMATCH: free trial=' + ','.join(durations) + ' (kutilgan: P1M yoki P30D)'


def say(s=''):
    print(s)
    out.append(s)


def asc_token():
    import jwt
    raw = os.environ['API_PRIVATE_KEY']
    if 'BEGIN PRIVATE KEY' in raw:
        key = raw
    else:
        body = ''.join(raw.split())
        try:
            dec = base64.b64decode(body).decode()
        except Exception:  # noqa: BLE001
            dec = ''
        if 'BEGIN PRIVATE KEY' in dec:
            key = dec
        else:  # xom base64 tanasi (PEM sarlavhasiz)
            key = '-----BEGIN PRIVATE KEY-----\n' + '\n'.join(body[i:i + 64] for i in range(0, len(body), 64)) + '\n-----END PRIVATE KEY-----\n'
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
    if st == 200:
        for g in d.get('data', []):
            s2, ds = asc_get(tok, f"/v1/subscriptionGroups/{g['id']}/subscriptions?limit=50")
            for sub in (ds.get('data', []) if s2 == 200 else []):
                a = sub['attributes']
                sp, dp = asc_get(tok, f"/v1/subscriptions/{sub['id']}/prices?filter[territory]=USA&include=subscriptionPricePoint&limit=5")
                usd = [i['attributes'].get('customerPrice') for i in dp.get('included', []) if i.get('type') == 'subscriptionPricePoints'] if sp == 200 else f'HTTP {sp}'
                so, do = asc_get(tok, f"/v1/subscriptions/{sub['id']}/introductoryOffers?limit=5")
                offers = [(o['attributes'].get('offerMode'), o['attributes'].get('duration')) for o in do.get('data', [])] if so == 200 else f'HTTP {so}'
                say(f"  - {a.get('productId')}: {a.get('state')}, USD={usd}, intro={offers}")
                say(f"    {apple_trial_verdict(offers)}")
                if a.get('productId') == 'uz.labguide.student.monthly':
                    pts, nxt = set(), f"/v1/subscriptions/{sub['id']}/pricePoints?filter[territory]=USA&limit=200"
                    for _ in range(10):
                        sc, dc = asc_get(tok, nxt)
                        if sc != 200:
                            break
                        pts |= {x['attributes'].get('customerPrice') for x in dc.get('data', [])}
                        link = (dc.get('links') or {}).get('next')
                        if not link:
                            break
                        nxt = link.replace('https://api.appstoreconnect.apple.com', '')
                    say(f"  - Apple USD narx nuqtalari soni={len(pts)}; 1.49:{'1.49' in pts} 2.49:{'2.49' in pts} 3.49:{'3.49' in pts} 24.99:{'24.99' in pts} 34.99:{'34.99' in pts}")
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
        say(f'- obuna mahsulotlari: {len(subs)} ta')
        for sb in subs:
            for bp in sb.get('basePlans', []):
                us = [rc for rc in bp.get('regionalConfigs', []) if rc.get('regionCode') == 'US']
                pr = us[0].get('price') if us else None
                usd = f"{pr.get('units', '0')}.{int(pr.get('nanos', 0)) // 10_000_000:02d}" if pr else None
                say(f"  - {sb.get('productId')} / {bp.get('basePlanId')}: {bp.get('state')}, US=${usd}")
                try:
                    offers = svc.monetization().subscriptions().basePlans().offers().list(
                        packageName=pkg, productId=sb.get('productId'), basePlanId=bp.get('basePlanId')).execute().get('subscriptionOffers', [])
                    free = [ph.get('duration') for of in offers for ph in of.get('phases', [])
                            if any('free' in rc for rc in ph.get('regionalConfigs', []))]
                    say(f"    {play_trial_verdict(free)}")
                except Exception as e:  # noqa: BLE001
                    say(f"    D-80 NOT CHECKED (offerlar o‘qilmadi: {type(e).__name__}: {str(e)[:120]})")
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
