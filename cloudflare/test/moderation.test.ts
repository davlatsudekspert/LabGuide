import { describe, expect, it } from 'vitest';
import WORDS from '../data/abuse_words.json';
import { findAbuse, tokens } from '../src/moderation';
import { makeServer, uniqueEmail } from './helpers';

/** Tibbiy/laboratoriya matni — HECH QACHON rad etilmasligi kerak (noto'g'ri ijobiy). */
const MEDICAL = [
  'анализ', 'Анализ мочи', 'сукцинат', 'сукцинатдегидрогеназа', 'pH мочи 6,5', 'pH', 'kalsiy', 'Kalsiy miqdori',
  'siydik', 'Siydik tahlili', 'spermogramma', 'Spermogramma natijasi', 'спермограмма', 'анальный сфинктер',
  'анальгин', 'гиперплазия', 'бляшка', 'атеросклеротические бляшки', 'употребляя', 'корабля', 'оскорбляя',
  'застрахуйте', 'страхуй', 'хлеб', 'вебинар', 'небо', 'мудрый врач', 'сучок', 'педикулёз', 'себум', 'себорея',
  'sikl', 'siklik', 'sikloserin', 'siklofosfamid', 'harom', 'Halol va harom', 'amin', 'aminokislota',
  'cocktail', 'Dickens', 'Scunthorpe', 'shiitake', 'ebook', 'Ebola', 'assessment', 'class', 'bass',
  'retardation', 'psychomotor retardation', 'flame retardant', 'Hb 120 g/l', 'o‘tkir', 'g‘ovak', 'ko‘tarilgan',
  'qo‘shimcha', 'kotib', 'qon', 'ҳужайра', 'қон таҳлили', 'ўткир', 'ахборот', 'mudofaa', 'jalb qilish',
  'sukcinat', 'suktsinat',
];

const ABUSIVE = [
  'сука', 'Ты сука', 'СУКА', 'сууука', 'с.у.к.а', 'cyka', 'суkа', // lotin "k" bilan
  'блядь', 'бля', 'блять', 'хуй', 'нахуй', 'похуй', 'xyй', 'хуйня', 'пиздец', 'спиздил', 'заебал', 'уёбок',
  'ебать', 'ёбаный', 'мудак', 'пидор', 'залупа', 'ублюдок', 'долбоёб', 'дебил',
  'fuck', 'FUCK you', 'f u c k', 'fuuuck', 'motherfucker', 'bitch', 'bullshit', 'asshole', 'cunt',
  'jalab', 'jalablar', 'qanjiq', 'siktir', 'sikaman', 'dalbayob', 'itvachcha', "qo'taq", 'qo‘taq', 'haromi',
  'жалаб', 'қанжиқ', 'сиктир', 'итвачча', 'ҳароми', 'падарлаънат',
];

describe('moderatsiya: so‘z filtri (matcher)', () => {
  it('tibbiy so‘zlar o‘tadi (butun so‘z / o‘zak — so‘z ichidan qidirilmaydi)', () => {
    for (const t of MEDICAL) expect(findAbuse(t), t).toBeNull();
  });

  it('so‘kinish: uz (lotin, kirill), ru, en; katta-kichik harf, ё/е, o‘/o\', takror harf, aralash alifbo', () => {
    for (const t of ABUSIVE) expect(findAbuse(t), t).not.toBeNull();
  });

  it('normallashtirish: nuqta bilan bo‘lingan harflar birlashadi, apostroflar olib tashlanadi', () => {
    expect(tokens('с.у.к.а')).toContain('сука');
    expect(tokens('o‘g‘il')).toEqual(['ogil']);
    expect(tokens('Ёлка')).toEqual(['елка']);
  });

  it('ro‘yxat — ma’lumot fayli; xavfli qisqa o‘zaklar yo‘q', () => {
    const stems = [...WORDS.cyrillic.stems, ...WORDS.cyrillic.ru_prefixed_stems, ...WORDS.latin.stems];
    for (const bad of ['сук', 'анал', 'sik', 'бля', 'педик', 'ебу', 'cock', 'dick', 'ass', 'am']) {
      expect(stems, bad).not.toContain(bad);
    }
    for (const s of stems) expect([...s].length, s).toBeGreaterThanOrEqual(3);
  });
});

describe('moderatsiya: post yaratishda rad etish', () => {
  it('savol va javob: so‘kinish — 400 abusive_language (so‘z oshkor qilinmaydi); tibbiy matn — 201', async () => {
    const s = makeServer();
    const u = await s.signIn(uniqueEmail());
    const bad = await s.call('POST', '/v1/community/questions', {
      token: u.token,
      body: { title: 'Bu nima degani, jalab laborant?', body: 'Natija noto‘g‘ri chiqdi, nima qilay?' },
    });
    expect(bad.status).toBe(400);
    expect(bad.data).toEqual({ error: 'abusive_language' });
    const bad2 = await s.call('POST', '/v1/community/questions', {
      token: u.token,
      body: { title: 'Анализ мочи — что это значит?', body: 'Лаборант ответил: иди нахуй. Это нормально?' },
    });
    expect(bad2.status).toBe(400);
    expect(bad2.data.error).toBe('abusive_language');
    const ok = await s.call('POST', '/v1/community/questions', {
      token: u.token,
      body: { title: 'Siydik tahlili: pH 7,5 va kalsiy oksalat', body: 'Spermogramma va сукцинат haqida ham savol bor. Анализ normalmi?' },
    });
    expect(ok.status).toBe(201);
    const n = await s.env.DB.prepare('SELECT COUNT(*) AS n FROM community_questions WHERE author_hash IN (SELECT author_hash FROM community_questions WHERE id = ?1)')
      .bind(ok.data.id)
      .first<{ n: number }>();
    expect(n!.n).toBe(1);
  });
});
