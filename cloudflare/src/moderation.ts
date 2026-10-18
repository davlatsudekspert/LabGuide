// Hamjamiyat so'z filtri (D-62, App Store 1.2 "a method for filtering
// objectionable material"): savol va javob yaratilganda so'kinish va
// haqoratni rad etadi (`400 abusive_language`; ilova tilida tushunarli xabar).
//
// Ro'yxat — cloudflare/data/abuse_words.json (kod emas, ma'lumot).
//
// Normallashtirish (matn va ro'yxat bir xil yo'ldan o'tadi):
// * NFKC, kichik harf, ё → е; apostroflar (o‘, g‘, ʼ, ’, `) olib tashlanadi;
// * kirill skeleti: lotin "o'xshash" harflar (a c e o p x y k m t h b) →
//   kirill; o'zbek ў қ ғ ҳ → у к г х; ъ, ь olib tashlanadi;
// * lotin skeleti: kirill o'xshash harflar → lotin; 0 → o, @ → a, $ → s;
// * takror harflar bittaga ("сууука" → "сука"); nuqta/bo'shliq bilan
//   bo'lingan harflar ("с.у.к.а") qayta qo'shiladi.
//
// Noto'g'ri ijobiy natijaga qarshi: moslik faqat BUTUN SO'Z ("words") yoki
// SO'Z BOSHI ("stems", aniq va yetarlicha uzun o'zak) bo'yicha — so'z
// ichidan qidirilmaydi. Shuning uchun "анализ", "сукцинат", "kalsiy",
// "siydik", "spermogramma", "корабля", "застрахуйте" o'tadi.

import WORDS from '../data/abuse_words.json';
import { badRequest } from './http';

const TO_CYR: Record<string, string> = {
  a: 'а', b: 'в', c: 'с', e: 'е', h: 'н', k: 'к', m: 'м', o: 'о', p: 'р', t: 'т', x: 'х', y: 'у',
  '0': 'о', '@': 'а',
};
const TO_LAT: Record<string, string> = {
  а: 'a', в: 'b', с: 'c', е: 'e', н: 'h', к: 'k', м: 'm', о: 'o', р: 'p', т: 't', х: 'x', у: 'y', і: 'i',
  '0': 'o', '@': 'a', $: 's',
};
const UZ_CYR: Record<string, string> = { ў: 'у', қ: 'к', ғ: 'г', ҳ: 'х' };

const CYR_RE = /[Ѐ-ӿ]/;
const LAT_RE = /[a-z]/;
const APOS_RE = /['‘’ʻʼ`´]/g;

function base(s: string): string {
  return s.normalize('NFKC').toLowerCase().replace(/ё/g, 'е').replace(APOS_RE, '');
}

const collapse = (s: string) => s.replace(/(.)\1+/gu, '$1');

export function cyrSkeleton(token: string): string {
  let out = '';
  for (const ch of token) {
    const c = TO_CYR[ch] ?? UZ_CYR[ch] ?? ch;
    if (c === 'ъ' || c === 'ь') continue;
    out += c;
  }
  return collapse(out);
}

export function latSkeleton(token: string): string {
  let out = '';
  for (const ch of token) out += TO_LAT[ch] ?? ch;
  return collapse(out);
}

/** Matndan so'zlar (normallashtirilgan, lekin skeletsiz). */
export function tokens(text: string): string[] {
  const raw = base(text).match(/[\p{L}\p{M}0@$]+/gu) ?? [];
  const out = [...raw];
  // "с.у.к.а", "f u c k": ketma-ket 3+ ta bir harfli bo'lak — bitta so'z.
  let run: string[] = [];
  const flush = () => {
    if (run.length >= 3) out.push(run.join(''));
    run = [];
  };
  for (const t of raw) {
    if ([...t].length === 1) run.push(t);
    else flush();
  }
  flush();
  return out;
}

interface Lists {
  words: Set<string>;
  stems: string[];
}

function build(): { cyr: Lists; lat: Lists } {
  const c = WORDS.cyrillic;
  const l = WORDS.latin;
  const cyrStems = new Set<string>(c.stems.map((s) => cyrSkeleton(base(s))));
  for (const p of c.ru_prefixes) {
    for (const s of c.ru_prefixed_stems) cyrStems.add(cyrSkeleton(base(p + s)));
  }
  return {
    cyr: { words: new Set(c.words.map((w) => cyrSkeleton(base(w)))), stems: [...cyrStems] },
    lat: {
      words: new Set(l.words.map((w) => latSkeleton(base(w)))),
      stems: l.stems.map((s) => latSkeleton(base(s))),
    },
  };
}

let lists: ReturnType<typeof build> | null = null;

function match(skel: string, list: Lists): boolean {
  if (list.words.has(skel)) return true;
  for (const s of list.stems) if (skel.startsWith(s)) return true;
  return false;
}

/** Topilgan birinchi so'z (normallashtirilgan skelet) yoki `null`. */
export function findAbuse(text: string): string | null {
  lists ??= build();
  for (const t of tokens(text)) {
    const hasCyr = CYR_RE.test(t);
    const hasLat = LAT_RE.test(t);
    if (hasCyr) {
      const s = cyrSkeleton(t);
      if (match(s, lists.cyr)) return s;
    }
    if (hasLat || !hasCyr) {
      const s = latSkeleton(t);
      if (match(s, lists.lat)) return s;
    }
  }
  return null;
}

/** Post yaratishda: so'kinish bo'lsa — `400 abusive_language` (so'z oshkor qilinmaydi). */
export function guardAbuse(...texts: string[]): void {
  for (const t of texts) {
    if (findAbuse(t) !== null) throw badRequest('abusive_language');
  }
}
