// Migratsiya 0018 (D-76): `pro_grants.tier` va `pro_trials.tier` CHECK
// cheklovi 'premium' ni qabul qiladi. 0014–0017 tahrirlanmagan; 0018 ular
// USTIGA qo'llanadi (test/setup.ts hamma migratsiyani tartib bilan qo'llaydi).
//
// Ma'lumot nusxasi alohida tekshiriladi: 0015/0016 dagi ESKI jadvallar
// `mig_` nomli nusxa sifatida quriladi (umumiy D1 dagi haqiqiy jadvallarga
// tegilmaydi), eski qatorlar yoziladi, so'ng 0018 SQL i aynan o'sha nom
// almashtirish bilan qo'llanadi.
import { env } from 'cloudflare:test';
import { describe, expect, it } from 'vitest';

const migrations = env.TEST_MIGRATIONS;
const byPrefix = (p: string) => {
  const m = migrations.find((x) => x.name.startsWith(p));
  if (!m) throw new Error(`migration ${p} not found`);
  return m;
};
/** Faqat `pro_grants` / `pro_trials` jadvali va indekslari, `mig_` nomi bilan. */
const scoped = (queries: string[]) =>
  queries
    .filter((q) => /\bpro_(grants|trials)/.test(q) && !/pro_trial_challenges/.test(q))
    .map((q) => q.replace(/\bpro_(grants|trials)/g, 'mig_pro_$1'));
const run = async (queries: string[]) => {
  for (const q of queries) await env.DB.prepare(q).run();
};
const insertGrant = (tier: string, id = crypto.randomUUID()) =>
  env.DB.prepare(
    `INSERT INTO mig_pro_grants (id, email_hmac, email_masked, tier, granted_by_hash, created_at, updated_at, starts_at, expires_at)
     VALUES (?1, ?2, 'a***@x.uz', ?3, 'h', 1, 2, 3, 4)`,
  )
    .bind(id, `hmac-${id}`, tier)
    .run();
const insertTrial = (tier: string, id = crypto.randomUUID()) =>
  env.DB.prepare(
    `INSERT INTO mig_pro_trials (id, user_id, tier, platform, email_key, device_key, started_at, expires_at, retain_until)
     VALUES (?1, ?2, ?3, 'android', ?4, ?5, 10, 20, 30)`,
  )
    .bind(id, `u-${id}`, tier, id.replace(/-/g, '').padEnd(64, 'a'), id.replace(/-/g, '').padEnd(64, 'b'))
    .run();

describe('migratsiya 0018: premium darajasi', () => {
  it('0018 — oxirgi raqamdan keyingi (0017 dan keyin), 0014–0017 o‘z joyida', () => {
    const names = migrations.map((m) => m.name);
    for (const p of ['0014_', '0015_', '0016_', '0017_']) expect(names.some((n) => n.startsWith(p)), p).toBe(true);
    const i17 = names.findIndex((n) => n.startsWith('0017_'));
    expect(names[i17 + 1]).toBe('0018_premium_tier.sql');
  });

  it('qo‘llangan sxema: pro_grants va pro_trials premium ni qabul qiladi, noma’lum darajani rad etadi', async () => {
    const id = crypto.randomUUID();
    await env.DB.prepare(
      `INSERT INTO pro_grants (id, email_hmac, email_masked, tier, granted_by_hash, created_at, updated_at)
       VALUES (?1, ?2, 'p***@x.uz', 'premium', 'h', 1, 1)`,
    )
      .bind(id, `hmac-mig-${id}`)
      .run();
    await expect(
      env.DB.prepare(
        `INSERT INTO pro_grants (id, email_hmac, email_masked, tier, granted_by_hash, created_at, updated_at)
         VALUES (?1, ?2, 'g***@x.uz', 'gold', 'h', 1, 1)`,
      )
        .bind(crypto.randomUUID(), `hmac-mig-gold-${id}`)
        .run(),
    ).rejects.toThrow(/CHECK/);
    const tid = crypto.randomUUID();
    const key = (c: string) => tid.replace(/-/g, '').padEnd(64, c);
    await env.DB.prepare(
      `INSERT INTO pro_trials (id, user_id, tier, platform, email_key, device_key, started_at, expires_at, retain_until)
       VALUES (?1, NULL, 'premium', 'android', ?2, ?3, 1, 2, 3)`,
    )
      .bind(tid, key('c'), key('d'))
      .run();
    await expect(
      env.DB.prepare(
        `INSERT INTO pro_trials (id, user_id, tier, platform, email_key, device_key, started_at, expires_at, retain_until)
         VALUES (?1, NULL, 'gold', 'android', ?2, ?3, 1, 2, 3)`,
      )
        .bind(crypto.randomUUID(), key('e'), key('f'))
        .run(),
    ).rejects.toThrow(/CHECK/);
    const idx = (
      await env.DB.prepare(`SELECT name FROM sqlite_master WHERE type = 'index' AND tbl_name IN ('pro_grants', 'pro_trials')`).all<{
        name: string;
      }>()
    ).results.map((r) => r.name);
    expect(idx).toEqual(
      expect.arrayContaining([
        'pro_grants_active_email',
        'pro_grants_email',
        'pro_trials_user',
        'pro_trials_email',
        'pro_trials_device',
        'pro_trials_retain',
      ]),
    );
  });

  it('eski (0015/0016) jadval ustiga: qatorlar saqlanadi, premium ochiladi, unikal indekslar ishlaydi', async () => {
    await run(['DROP TABLE IF EXISTS mig_pro_grants', 'DROP TABLE IF EXISTS mig_pro_trials']);
    await run([...scoped(byPrefix('0015_').queries), ...scoped(byPrefix('0016_').queries)]);
    // Eski cheklov: premium YO'Q.
    await insertGrant('teacher', 'g-old-1');
    await insertGrant('specialist', 'g-old-2');
    await insertTrial('student', 't-old-1');
    await expect(insertGrant('premium')).rejects.toThrow(/CHECK/);
    await expect(insertTrial('premium')).rejects.toThrow(/CHECK/);

    const q18 = scoped(byPrefix('0018_').queries);
    expect(q18.length).toBeGreaterThanOrEqual(10);
    await run(q18);

    const grants = (await env.DB.prepare('SELECT id, tier, email_masked, starts_at, expires_at FROM mig_pro_grants ORDER BY id').all()).results;
    expect(grants).toEqual([
      { id: 'g-old-1', tier: 'teacher', email_masked: 'a***@x.uz', starts_at: 3, expires_at: 4 },
      { id: 'g-old-2', tier: 'specialist', email_masked: 'a***@x.uz', starts_at: 3, expires_at: 4 },
    ]);
    const trials = (await env.DB.prepare('SELECT id, tier, started_at, expires_at, retain_until FROM mig_pro_trials').all()).results;
    expect(trials).toEqual([{ id: 't-old-1', tier: 'student', started_at: 10, expires_at: 20, retain_until: 30 }]);

    await insertGrant('premium', 'g-new');
    await insertTrial('premium', 't-new');
    await expect(insertGrant('gold')).rejects.toThrow(/CHECK/);
    // Unikal indeks qayta qurilgan: bir emailga ikkinchi faol grant — rad.
    await expect(
      env.DB.prepare(
        `INSERT INTO mig_pro_grants (id, email_hmac, email_masked, tier, granted_by_hash, created_at, updated_at)
         VALUES ('dup', 'hmac-g-new', 'x', 'student', 'h', 1, 1)`,
      ).run(),
    ).rejects.toThrow(/UNIQUE/);
    // Vaqtinchalik `_v2` jadvali qolmagan.
    const left = await env.DB.prepare(`SELECT name FROM sqlite_master WHERE name LIKE 'mig_pro_%_v2'`).all();
    expect(left.results).toEqual([]);
    await run(['DROP TABLE mig_pro_grants', 'DROP TABLE mig_pro_trials']);
  });
});
