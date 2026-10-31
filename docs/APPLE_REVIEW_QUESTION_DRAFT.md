# Draft: question to Apple App Review / Developer Support (NOT SENT)

> Status: draft only (D-75). Nothing has been sent. The owner sends it from App Store Connect
> (Resolution Center on a submitted build, or Contact Us → App Review / Developer Support) and keeps the
> written reply. Until a written "acceptable" answer exists, the server keeps `TRIAL_PLATFORMS=android`,
> so the free trial is not offered on iOS.

---

**Subject:** Guideline 3.1.1 / 3.1.2 — developer-granted, payment-free 30-day trial and administrator-granted
access alongside auto-renewable subscriptions (LabGuide, bundle ID `uz.labguide.app`)

Hello App Review team,

We are preparing optional paid plans for LabGuide, an educational and reference app for clinical laboratory
staff, students and teachers. Most of the app is free and will stay free. We would like to confirm, before
we ship, that the two access mechanisms below are acceptable on iOS alongside our In-App Purchase
subscriptions.

**Our planned in-app purchases.** One subscription group ("LabGuide Pro") with six auto-renewable
subscriptions: Student, Teacher and Specialist plans, each monthly and yearly. Prices are set in App Store
Connect and shown from StoreKit in the app. The subscription screen shows the billed amount, the period,
auto-renewal terms, Restore Purchases, a link to manage or cancel the subscription
(`showManageSubscriptions`), and links to our Terms of Use and Privacy Policy. The app does not link to or
mention any other payment method. We do not plan to configure an introductory free-trial offer.

**Question 1 — payment-free 30-day trial granted by our server.**
A signed-in user (verified email) could start a one-time 30-day trial of one plan from inside the app.
- No payment method is requested and nothing is charged. The trial never converts to a paid subscription;
  it simply ends. To continue, the user would separately choose to buy a subscription through In-App
  Purchase.
- Before starting, the app shows: the plan name, "free until <date>", "no payment method, nothing is
  charged", and "after it ends, all free features continue".
- One trial per account, per email address and per device. On iOS we would use DeviceCheck (the two
  per-device bits) only to record that a device has already used the promotional trial. We do not
  fingerprint devices.
- The trial is recorded on our server and unlocks the same features as the paid plan for 30 days.

Is this server-granted, payment-free trial acceptable under Guideline 3.1.1 for an app that also sells
auto-renewable subscriptions, or must any free trial on iOS be configured as an App Store introductory offer?

**Question 2 — access granted by an administrator.**
Our administrators can grant a plan to a specific account (for example, teachers at a partner institution,
or staff we work with), for a fixed period or until revoked. No payment happens inside or outside the app
for these grants, and there is no code, key or other unlock mechanism that users can enter. The account
simply has access on our server, on any platform. Is this acceptable on iOS?

**Question 3 — cross-platform access.** A subscription bought through Google Play on Android would also
give access in the iOS app for the same account, and the same plans are sold as In-App Purchases in the
iOS app (Guideline 3.1.3(b)). Please confirm this is acceptable.

If either mechanism is not acceptable, we will not offer it on iOS and will rely only on In-App Purchase
subscriptions there. We are happy to provide a build and a demo account showing the exact flow.

Thank you,
LabGuide team

---

## Ichki eslatma (o'zbekcha)
- Javob “mumkin” bo'lsa: egasi test serverda `TRIAL_PLATFORMS=android,ios` qiladi, DeviceCheck tekshiruvchisi
  yoziladi va ulanadi, keyin production — egasining alohida qarori.
- Javob “mumkin emas” bo'lsa: variant A — iOS'da vaqtli sinov yo'q (bepul daraja + IAP); variant B — 1 oylik
  App Store kirish taklifi (avtomatik pullikka o'tadi — egasining (b) qoidasiga zid, alohida rozilik kerak).
- Admin grantlar hisobga bog'langan (platformaga emas), shuning uchun alohida `ADMIN_GRANTS_PLATFORMS`
  sozlamasi qo'shilmadi; Apple 2-savolga “yo'q” desa, iOS ilovada admin grantni ko'rsatmaslik/qo'llamaslik
  uchun alohida ish kerak bo'ladi (D-75 ochiq qaror).
