// Variantli test (D-66): har talabaga hovuzdan deterministik to'plam.
//
// Algoritm ilovadagi `lib/core/backend/variant_draw.dart` bilan AYNAN bir xil
// (umumiy test vektorlari: test/variant_vectors.json):
//  1. seed = "<assignmentId>:<userId>".
//  2. Har savol uchun h = hex(SHA-256(seed + ":" + savolId)).
//  3. Savollar mavzu (pool_topics[i]; yo'q — "") bo'yicha qatlamlarga
//     ajratiladi; qatlam ichida h (teng bo'lsa — id) bo'yicha o'sish tartibida.
//  4. Qatlamlar tartibi: hex(SHA-256(seed + "#" + mavzu)) bo'yicha (teng —
//     mavzu nomi) — qaysi mavzu "ortiqcha" savol berishi talabadan talabaga
//     almashadi.
//  5. Navbatma-navbat (round-robin): har qatlamdan 1-savol, keyin 2-savol, …
//     to `count` ta bo'lguncha. Natija — shu tanlash tartibi.
// Satrlar UTF-16 kod birliklari bo'yicha taqqoslanadi (JS `<` va Dart
// `compareTo` bir xil); SHA-256 kirishi — UTF-8.

const enc = new TextEncoder();

export async function sha256hex(s: string): Promise<string> {
  const d = await crypto.subtle.digest('SHA-256', enc.encode(s));
  return [...new Uint8Array(d)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

const cmp = (a: string, b: string) => (a < b ? -1 : a > b ? 1 : 0);

export async function drawVariant(
  assignmentId: string,
  userId: string,
  pool: readonly string[],
  topics: readonly (string | null)[] | null,
  count: number,
): Promise<string[]> {
  const seed = `${assignmentId}:${userId}`;
  const strata = new Map<string, { id: string; h: string }[]>();
  for (let i = 0; i < pool.length; i++) {
    const t = topics?.[i] ?? '';
    const h = await sha256hex(`${seed}:${pool[i]}`);
    let s = strata.get(t);
    if (!s) strata.set(t, (s = []));
    s.push({ id: pool[i], h });
  }
  const keyHash = new Map<string, string>();
  for (const k of strata.keys()) keyHash.set(k, await sha256hex(`${seed}#${k}`));
  const keys = [...strata.keys()].sort((a, b) => cmp(keyHash.get(a)!, keyHash.get(b)!) || cmp(a, b));
  const lists = keys.map((k) => strata.get(k)!.sort((x, y) => cmp(x.h, y.h) || cmp(x.id, y.id)));
  const n = Math.max(0, Math.min(count, pool.length));
  const out: string[] = [];
  for (let round = 0; out.length < n; round++) {
    for (const l of lists) {
      if (round < l.length && out.length < n) out.push(l[round].id);
    }
  }
  return out;
}
