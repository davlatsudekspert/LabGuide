#!/usr/bin/env node
// Ustoz–talaba oqimi: MAHALLIY Worker'ga qarshi haqiqiy HTTP orqali to'liq
// e2e sinov (docs/E2E_CLASSROOM_2026-10-18.md).
//
//   cd cloudflare
//   npx wrangler d1 migrations apply labguide-local --local -c dev/wrangler.local.toml
//   npx wrangler dev --local --port 8799 -c dev/wrangler.local.toml
//   node ../tool/e2e/classroom_e2e.mjs            # boshqa terminalda
//
// Kirish kodi: dev/local.ts xat yubormaydi, kodni GET /__outbox beradi
// (bu yo'l faqat mahalliy entry'da; ishlab chiqarish src/index.ts da yo'q —
// cloudflare/test/security.test.ts buni tekshiradi). D1 tekshiruvlari
// `wrangler d1 execute --local` orqali.
//
// Faqat 127.0.0.1/localhost ga ruxsat — masofaviy serverga hech qachon.

import { execFileSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const BASE = process.env.LG_LOCAL_API ?? 'http://127.0.0.1:8799';
if (!/^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?$/.test(BASE)) {
  throw new Error(`Faqat mahalliy Worker: ${BASE}`);
}
const CF_DIR = resolve(dirname(fileURLToPath(import.meta.url)), '../../cloudflare');
const STAMP = Date.now().toString(36);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

let passed = 0;
const failures = [];
function check(cond, what) {
  if (cond) {
    passed++;
    console.log(`  ok  ${what}`);
  } else {
    failures.push(what);
    console.log(`  XATO ${what}`);
  }
}
function step(t) {
  console.log(`\n== ${t}`);
}

async function call(method, path, { token, body, ip } = {}) {
  const headers = { accept: 'application/json' };
  if (token) headers.authorization = `Bearer ${token}`;
  if (body !== undefined) headers['content-type'] = 'application/json';
  if (ip) headers['cf-connecting-ip'] = ip;
  const res = await fetch(BASE + path, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await res.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = text;
  }
  return { status: res.status, data };
}

function sql(command) {
  const out = execFileSync(
    'npx',
    ['wrangler', 'd1', 'execute', 'labguide-local', '--local', '-c', 'dev/wrangler.local.toml', '--json', '--command', command],
    { cwd: CF_DIR, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] },
  );
  return JSON.parse(out)[0].results;
}

async function login(name) {
  const email = `${name}.${STAMP}@example.test`;
  const r = await call('POST', '/v1/auth/otp/request', { body: { email, language: 'uz' } });
  if (r.status !== 200) throw new Error(`otp request ${name}: ${r.status} ${JSON.stringify(r.data)}`);
  const box = (await call('GET', '/__outbox')).data;
  const code = box.filter((m) => m.to === email).at(-1).code;
  const v = await call('POST', '/v1/auth/otp/verify', { body: { email, code } });
  if (v.status !== 200) throw new Error(`otp verify ${name}: ${v.status}`);
  return { name, email, token: v.data.token, id: v.data.user_id };
}

const iso = (ms) => new Date(ms).toISOString();

async function main() {
  const health = await call('GET', '/__outbox').catch(() => null);
  if (!health || health.status !== 200) throw new Error(`Mahalliy Worker ishlamayapti: ${BASE}`);

  // ------------------------------------------------------------------ 1
  step('1. Kirish (email kodi) va ustoz roli');
  const T = await login('ustoz');
  const A = await login('talaba-a');
  const B = await login('talaba-b');
  const C = await login('talaba-c'); // kechikkan talaba
  const X = await login('begona'); // guruhga a'zo emas
  check(T.token && A.token && B.token, 'besh hisob kod bilan kirdi');
  const wrongCode = await call('POST', '/v1/auth/otp/verify', {
    body: { email: `nobody.${STAMP}@example.test`, code: '123456' },
  });
  check(wrongCode.status === 400, `kodsiz email bilan kirish rad etildi (${wrongCode.status})`);

  let r = await call('POST', '/v1/groups', { token: A.token, body: { name: 'Talaba guruhi' } });
  check(r.status === 403 && r.data?.error === 'teacher_role_required', `ustoz bo'lmagan guruh ocholmaydi (${r.status})`);
  r = await call('PUT', '/v1/me/profile', { token: T.token, body: { role: 'teacher', language: 'uz' } });
  check(r.status === 200 && r.data.role === 'teacher', 'profil roli: teacher');
  r = await call('POST', '/v1/me/teacher', { token: T.token });
  check(r.status === 200 && r.data.teacher === true, 'ustoz hisobi ro\'yxatdan o\'tdi');

  // ------------------------------------------------------------------ 2
  step('2. Guruh yaratish va talabalar qo\'shilishi');
  r = await call('POST', '/v1/groups', { token: T.token, body: { name: `Klinik lab 1-kurs ${STAMP}` } });
  check(r.status === 201 && /^[A-HJ-NP-Z2-9]{8}$/.test(r.data.join_code), `guruh yaratildi, kod ${r.data?.join_code}`);
  const G = r.data.id;
  const CODE = r.data.join_code;

  r = await call('POST', '/v1/groups/join', { token: A.token, body: { code: 'ZZZZZZZZ' } });
  check(r.status === 404, `noto'g'ri kod — 404 (${r.status})`);
  r = await call('POST', '/v1/groups/join', { token: A.token, body: { code: CODE, display_name: 'a@b.uz' } });
  check(r.status === 400 && r.data?.error === 'invalid_nickname', `email taxallus rad etildi (${r.status})`);
  r = await call('POST', '/v1/groups/join', { token: A.token, body: { code: CODE, display_name: 'Lola' } });
  check(r.status === 201 && r.data.group_id === G, 'A qo\'shildi (taxallus Lola)');
  // Kod kichik harf va chiziqcha bilan ham qabul qilinadi.
  const dashed = `${CODE.slice(0, 4)}-${CODE.slice(4)}`.toLowerCase();
  r = await call('POST', '/v1/groups/join', { token: B.token, body: { code: dashed } });
  check(r.status === 201, `B qo'shildi (kod "${dashed}")`);
  r = await call('POST', '/v1/groups/join', { token: B.token, body: { code: CODE } });
  check(r.status === 200 && r.data.group_id === G, 'qayta qo\'shilish — 200, o\'zgarishsiz');
  r = await call('POST', '/v1/groups/join', { token: C.token, body: { code: CODE } });
  check(r.status === 201, 'C qo\'shildi');

  r = await call('GET', '/v1/groups', { token: A.token });
  check(r.data[0].join_code === null && r.data[0].is_teacher === false, 'talaba taklif kodini ko\'rmaydi');
  check(r.data[0].my_display_name === 'Lola', 'talaba o\'z nomini ko\'radi');
  r = await call('GET', `/v1/groups/${G}/members`, { token: T.token });
  check(r.data.length === 4, `ustoz 4 a'zoni ko'radi (${r.data.length})`);
  check(
    r.data.some((m) => m.label === 'Talaba 02') && r.data.some((m) => m.label === 'Lola'),
    'taxallussiz talaba "Talaba NN" sifatida',
  );
  r = await call('GET', `/v1/groups/${G}/members`, { token: B.token });
  check(
    r.data.length === 2 && r.data.every((m) => m.member_role === 'teacher' || m.user_id === B.id),
    'talaba boshqa talabalarni ko\'rmaydi (faqat ustoz va o\'zi)',
  );
  r = await call('GET', `/v1/groups/${G}/members`, { token: X.token });
  check(r.status === 404, `begona guruh a'zolarini ko'rolmaydi (${r.status})`);

  // ------------------------------------------------------------------ 3
  step('3. "Guruhga topshirish": mavzu testi (deck) + oddiy topshiriq');
  const Q = ['bio.q1', 'bio.q2', 'bio.q3', 'bio.q4', 'bio.q5'];
  const KEY = [0, 1, 2, 3, 1];
  const now = Date.now();
  const topicBody = {
    title: 'Mavzu testi: Qon umumiy tahlili',
    question_ids: Q,
    correct_indexes: KEY,
    due_at: iso(now + 86400_000),
    day_id: 'd001-L',
    deck_id: 'hem-cbc',
    reveal: 'after_due',
    start: true,
  };
  r = await call('POST', `/v1/groups/${G}/assignments`, { token: A.token, body: topicBody });
  check(r.status === 403, `talaba topshiriq bera olmaydi (${r.status})`);
  r = await call('POST', `/v1/groups/${G}/assignments`, { token: X.token, body: topicBody });
  check(r.status === 404, `begona ustoz/foydalanuvchi — 404 (${r.status})`);
  r = await call('POST', `/v1/groups/${G}/assignments`, {
    token: T.token,
    body: { ...topicBody, due_at: null },
  });
  check(r.status === 400 && r.data?.error === 'invalid_reveal', '"muddat tugagach" muddatsiz — 400');
  r = await call('POST', `/v1/groups/${G}/assignments`, {
    token: T.token,
    body: { ...topicBody, due_at: iso(now - 60_000) },
  });
  check(r.status === 400 && r.data?.error === 'invalid_due', 'o\'tgan muddat — 400');
  r = await call('POST', `/v1/groups/${G}/assignments`, { token: T.token, body: topicBody });
  check(r.status === 201 && r.data.status === 'open', 'mavzu testi topshirildi (reveal=after_due)');
  const TOPIC = r.data.id;

  r = await call('POST', `/v1/groups/${G}/assignments`, {
    token: T.token,
    body: { title: 'Uy vazifasi: siydik tahlili', question_ids: ['u.1', 'u.2'], correct_indexes: [1, 0], time_limit_minutes: 10 },
  });
  check(r.status === 201, 'oddiy topshiriq (10 daqiqa, darhol natija)');
  const PLAIN = r.data.id;

  // Qisqa muddatli test — kechikib topshirishni tekshirish uchun.
  const shortDue = Date.now() + 12_000;
  r = await call('POST', `/v1/groups/${G}/assignments`, {
    token: T.token,
    body: {
      title: 'Qisqa test (muddat 12 s)',
      question_ids: ['s.1', 's.2'],
      correct_indexes: [0, 0],
      due_at: iso(shortDue),
      deck_id: 'hem-cbc',
      day_id: 'd001-L',
      reveal: 'after_due',
    },
  });
  check(r.status === 201, 'qisqa muddatli test topshirildi');
  const SHORT = r.data.id;

  // ------------------------------------------------------------------ 4
  step('4. Talabalar topshiriqlarni oladi, javob beradi, yuboradi');
  r = await call('GET', `/v1/groups/${G}/assignments`, { token: A.token });
  const seen = r.data.find((a) => a.id === TOPIC);
  check(
    r.data.length === 3 && seen.deck_id === 'hem-cbc' && seen.reveal === 'after_due' && seen.topic_id === 'd001-L',
    'talaba 3 topshiriqni ko\'radi (deck_id, reveal, topic_id bilan)',
  );
  check(!('correct_indexes' in seen), 'topshiriq ro\'yxatida javob kaliti yo\'q');
  r = await call('GET', `/v1/assignments/${TOPIC}/key`, { token: A.token });
  check(r.status === 403, `talaba javob kalitini ololmaydi (${r.status})`);

  r = await call('POST', `/v1/assignments/${PLAIN}/submit`, { token: A.token, body: { answers: [1, 0] } });
  check(r.status === 409 && r.data?.error === 'time_over', 'vaqt chegarali testni boshlamasdan yuborib bo\'lmaydi');

  for (const s of [A, B]) {
    r = await call('POST', `/v1/assignments/${TOPIC}/start`, { token: s.token });
    check(r.status === 200 && r.data.status === 'open', `${s.name} testni boshladi`);
  }
  r = await call('POST', `/v1/assignments/${TOPIC}/submit`, { token: A.token, body: { answers: [0, 1] } });
  check(r.status === 400 && r.data?.error === 'invalid_answers', 'javoblar soni noto\'g\'ri — 400');
  r = await call('POST', `/v1/assignments/${TOPIC}/submit`, { token: A.token, body: { answers: KEY } });
  check(r.status === 201 && r.data.score === 5 && r.data.total === 5, 'A: 5/5');
  check(r.data.correct === null, 'A: ball ko\'rinadi, har savol natijasi (correct) — null');
  r = await call('POST', `/v1/assignments/${TOPIC}/submit`, { token: B.token, body: { answers: [0, 0, -1, 3, 2] } });
  check(r.status === 201 && r.data.score === 2 && r.data.correct === null, 'B: 2/5, correct=null');
  r = await call('POST', `/v1/assignments/${TOPIC}/submit`, { token: A.token, body: { answers: KEY } });
  check(r.status === 409 && r.data?.error === 'already_submitted', 'ikkinchi marta yuborish — 409');

  r = await call('POST', `/v1/assignments/${PLAIN}/start`, { token: B.token });
  r = await call('POST', `/v1/assignments/${PLAIN}/submit`, { token: B.token, body: { answers: [1, 1] } });
  check(r.status === 201 && JSON.stringify(r.data.correct) === '[true,false]', 'oddiy topshiriq: natija darhol ([true,false])');

  // ------------------------------------------------------------------ 5
  step('5. Maxfiylik: talaba boshqalarning javoblarini ko\'rmaydi');
  r = await call('GET', `/v1/assignments/${TOPIC}/submissions`, { token: B.token });
  check(r.data.length === 1 && r.data[0].user_id === B.id, 'B faqat o\'z javobini ko\'radi');
  check(r.data[0].correct === null && r.data[0].score === 2, 'B: muddatgacha correct=null, ball bor');
  r = await call('GET', `/v1/groups/${G}/submissions`, { token: B.token });
  check(r.data.every((s) => s.user_id === B.id), 'guruh natijalarida ham faqat o\'zi');
  check(r.data.find((s) => s.assignment_id === TOPIC).correct === null, 'guruh natijalarida ham correct=null');
  r = await call('GET', `/v1/assignments/${TOPIC}/submissions`, { token: X.token });
  check(r.status === 404, `begona — 404 (${r.status})`);
  r = await call('GET', `/v1/groups/${G}/marks`, { token: B.token });
  check(r.status === 200 && r.data.length === 0, 'belgilar: faqat o\'ziniki');
  r = await call('DELETE', `/v1/groups/${G}/members/${A.id}`, { token: B.token });
  check(r.status === 403, `talaba boshqa talabani chiqara olmaydi (${r.status})`);
  r = await call('POST', `/v1/assignments/${TOPIC}/close`, { token: B.token });
  check(r.status === 403, `talaba testni yakunlay olmaydi (${r.status})`);

  // ------------------------------------------------------------------ 6
  step('6. Ustoz natijalari: hamma, taqsimot, eng qiyin savollar');
  r = await call('GET', `/v1/assignments/${TOPIC}/submissions`, { token: T.token });
  check(r.data.length === 2 && r.data.every((s) => Array.isArray(s.correct)), 'ustoz 2 natijani to\'liq ko\'radi');
  const subs = r.data;
  const pct = subs.map((s) => Math.round((s.score * 100) / s.total)).sort((a, b) => a - b);
  check(JSON.stringify(pct) === '[40,100]', `taqsimot: ${pct.join('%, ')}%`);
  const wrongBy = Q.map((_, i) => subs.filter((s) => !s.correct[i]).length);
  const hardest = wrongBy.map((n, i) => [i + 1, n]).filter(([, n]) => n > 0);
  check(JSON.stringify(hardest) === '[[2,1],[3,1],[5,1]]', `eng qiyin savollar: ${JSON.stringify(hardest)}`);
  r = await call('GET', `/v1/assignments/${TOPIC}/key`, { token: T.token });
  check(JSON.stringify(r.data.correct_indexes) === JSON.stringify(KEY), 'ustoz javob kalitini ko\'radi');

  // ------------------------------------------------------------------ 7
  step('7. Ustoz testni yakunlaydi → javoblar ochiladi');
  r = await call('POST', `/v1/assignments/${TOPIC}/close`, { token: T.token });
  check(r.status === 200 && r.data.status === 'closed', 'test yakunlandi');
  r = await call('GET', `/v1/assignments/${TOPIC}/submissions`, { token: B.token });
  check(JSON.stringify(r.data[0].correct) === '[true,false,false,true,false]', 'B endi har savol natijasini ko\'radi');
  r = await call('POST', `/v1/assignments/${TOPIC}/start`, { token: C.token });
  check(r.status === 409 && r.data?.error === 'not_open', `yakunlangan testni boshlab bo'lmaydi (${r.status})`);
  r = await call('POST', `/v1/assignments/${TOPIC}/submit`, { token: C.token, body: { answers: KEY } });
  check(r.status === 409 && r.data?.error === 'closed', `yakunlangan testga yuborib bo'lmaydi (${r.status})`);

  // ------------------------------------------------------------------ 8
  step('8. Muddat o\'tgach: kech boshlash/yuborish, javoblar ochiladi');
  r = await call('POST', `/v1/assignments/${SHORT}/start`, { token: A.token });
  check(r.status === 200, 'A qisqa testni muddatdan oldin boshladi');
  r = await call('POST', `/v1/assignments/${SHORT}/submit`, { token: A.token, body: { answers: [0, 1] } });
  check(r.status === 201 && r.data.correct === null, 'A muddatgacha yubordi — correct=null');
  const wait = shortDue - Date.now() + 1500;
  if (wait > 0) await sleep(wait);
  r = await call('POST', `/v1/assignments/${SHORT}/start`, { token: C.token });
  check(r.status === 409 && r.data?.error === 'past_due', `muddatdan keyin boshlab bo'lmaydi (${r.status})`);
  r = await call('POST', `/v1/assignments/${SHORT}/submit`, { token: C.token, body: { answers: [0, 0] } });
  check(r.status === 409 && r.data?.error === 'past_due', `muddatdan keyin yuborib bo'lmaydi (${r.status})`);
  r = await call('GET', `/v1/assignments/${SHORT}/submissions`, { token: A.token });
  check(JSON.stringify(r.data[0].correct) === '[true,false]', 'muddat o\'tgach A natijani ko\'radi (ustoz yakunlamasa ham)');

  // ------------------------------------------------------------------ 9
  step('9. Limitlar (rate limit)');
  const D = await login('taxminchi');
  const codes = [];
  for (let i = 0; i < 11; i++) {
    const g = await call('POST', '/v1/groups/join', { token: D.token, body: { code: `ABCDEFG${'23456789'[i % 8]}` } });
    codes.push(g.status);
  }
  check(codes.slice(0, 10).every((s) => s === 404) && codes[10] === 429, `kod taxmini: 10×404 so'ng 429 (${codes.join(',')})`);
  // Kod tasdiqlangach challenge o'chadi — yangi email bilan ketma-ket ikki so'rov.
  const fresh = `qayta.${STAMP}@example.test`;
  await call('POST', '/v1/auth/otp/request', { body: { email: fresh } });
  r = await call('POST', '/v1/auth/otp/request', { body: { email: fresh } });
  check(r.status === 429 && r.data?.retry_after > 0, `kodni 60 s ichida qayta so'rash — 429 (retry_after ${r.data?.retry_after})`);

  // ----------------------------------------------------------------- 10
  step('10. Chiqarish, chiqish, hisobni o\'chirish, tozalash');
  r = await call('DELETE', `/v1/groups/${G}/members/${B.id}`, { token: T.token });
  check(r.status === 204, 'ustoz B ni chiqardi');
  r = await call('GET', '/v1/groups', { token: B.token });
  check(r.data.length === 0, 'B guruhni endi ko\'rmaydi');
  r = await call('GET', `/v1/groups/${G}/assignments`, { token: B.token });
  check(r.status === 404, `B topshiriqlarni ko'rmaydi (${r.status})`);
  r = await call('GET', `/v1/assignments/${TOPIC}/submissions`, { token: B.token });
  check(r.status === 404, `B o'z eski natijasini ham bu yo'l bilan ko'rmaydi (${r.status})`);
  r = await call('DELETE', `/v1/groups/${G}/members/${B.id}`, { token: T.token });
  check(r.status === 404 && r.data?.error === 'member_not_found', 'qayta chiqarish — member_not_found');

  r = await call('POST', `/v1/groups/${G}/leave`, { token: T.token });
  check(r.status === 400 && r.data?.error === 'teacher_cannot_leave', 'ustoz o\'z guruhidan chiqolmaydi');
  r = await call('POST', `/v1/groups/${G}/leave`, { token: C.token });
  check(r.status === 204, 'C guruhdan chiqdi');
  check(sql(`SELECT COUNT(*) AS n FROM submissions WHERE user_id = '${B.id}'`)[0].n === 2,
    'maxfiylik siyosati: chiqarilgan talaba natijalari guruh/hisob o\'chguncha qoladi');

  r = await call('DELETE', '/v1/me', { token: A.token });
  check(r.status === 204 || r.status === 200, `A hisobini o'chirdi (${r.status})`);
  const leftA = sql(
    `SELECT (SELECT COUNT(*) FROM submissions WHERE user_id='${A.id}') +
            (SELECT COUNT(*) FROM assignment_attempts WHERE user_id='${A.id}') +
            (SELECT COUNT(*) FROM group_members WHERE user_id='${A.id}') +
            (SELECT COUNT(*) FROM sessions WHERE user_id='${A.id}') +
            (SELECT COUNT(*) FROM users WHERE id='${A.id}') AS n`,
  )[0].n;
  check(leftA === 0, 'A ning natija, urinish, a\'zolik, sessiya va profili o\'chdi');
  r = await call('GET', '/v1/groups', { token: A.token });
  check(r.status === 401, `o'chirilgan hisob tokeni ishlamaydi (${r.status})`);
  r = await call('GET', `/v1/assignments/${TOPIC}/submissions`, { token: T.token });
  check(r.data.length === 1 && r.data[0].user_id === B.id, 'ustoz ro\'yxatida A natijasi qolmadi');

  r = await call('DELETE', '/v1/me', { token: T.token });
  check(r.status === 204 || r.status === 200, 'ustoz hisobini o\'chirdi');
  const leftG = sql(
    `SELECT (SELECT COUNT(*) FROM study_groups WHERE id='${G}') +
            (SELECT COUNT(*) FROM group_members WHERE group_id='${G}') +
            (SELECT COUNT(*) FROM assignments WHERE group_id='${G}') +
            (SELECT COUNT(*) FROM assignment_keys WHERE assignment_id IN ('${TOPIC}','${PLAIN}','${SHORT}')) +
            (SELECT COUNT(*) FROM submissions WHERE assignment_id IN ('${TOPIC}','${PLAIN}','${SHORT}')) +
            (SELECT COUNT(*) FROM assignment_attempts WHERE assignment_id IN ('${TOPIC}','${PLAIN}','${SHORT}')) AS n`,
  )[0].n;
  check(leftG === 0, 'ustoz o\'chganda guruh, topshiriqlar, kalitlar va barcha talabalar natijalari o\'chdi');
  r = await call('GET', '/v1/groups', { token: B.token });
  check(r.status === 200 && r.data.length === 0, 'B hisobi ishlaydi, guruh yo\'q');

  for (const u of [B, C, X, D]) await call('DELETE', '/v1/me', { token: u.token });

  console.log(`\n${passed} ta tekshiruv o'tdi, ${failures.length} ta xato.`);
  if (failures.length) {
    for (const f of failures) console.log(`  - ${f}`);
    process.exit(1);
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
