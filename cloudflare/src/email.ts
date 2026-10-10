// Email OTP yuborish. Standart provayder — Resend (alideveloper.uz domeni);
// `EMAIL_PROVIDER=brevo` bo'lsa Brevo transactional API.

import type { Env } from './http';

export type SendResult = 'sent' | 'not_configured' | 'failed';

export type CodeSender = (env: Env, to: string, code: string, lang: string) => Promise<SendResult>;

const DEFAULT_SENDER = 'labguide@alideveloper.uz';
const TIMEOUT_MS = 8000;

const SUBJECT: Record<string, string> = {
  uz: 'LabGuide: kirish kodi',
  ru: 'LabGuide: код входа',
  en: 'LabGuide: sign-in code',
};

const LINES: Record<string, (code: string) => [string, string, string]> = {
  uz: (c) => [`Kirish kodingiz: ${c}`, 'Kod 10 daqiqa amal qiladi.', "Agar siz so'ramagan bo'lsangiz, e'tibor bermang."],
  ru: (c) => [`Ваш код для входа: ${c}`, 'Код действует 10 минут.', 'Если вы не запрашивали код, проигнорируйте это письмо.'],
  en: (c) => [`Your sign-in code: ${c}`, 'The code is valid for 10 minutes.', 'If you did not request it, please ignore this email.'],
};

/** Matn va oddiy HTML. `lang` noma'lum bo'lsa — uz. */
export function composeMessage(code: string, lang: string): { subject: string; text: string; html: string } {
  const l = SUBJECT[lang] ? lang : 'uz';
  const [a, b, c] = LINES[l](code);
  const text = `${a}\n${b}\n${c}`;
  const html =
    `<p>${a.replace(code, `<strong style="font-size:20px;letter-spacing:2px">${code}</strong>`)}</p>` +
    `<p>${b}</p><p style="color:#666">${c}</p>`;
  return { subject: SUBJECT[l], text, html };
}

function senderEmail(env: Env): string {
  return env.LG_SENDER_EMAIL || DEFAULT_SENDER;
}
function senderName(env: Env): string {
  return env.LG_SENDER_NAME || 'LabGuide';
}

async function post(label: string, url: string, headers: Record<string, string>, body: unknown): Promise<SendResult> {
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: { ...headers, 'content-type': 'application/json', accept: 'application/json' },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });
    if (res.ok) return 'sent';
    // Faqat status (429 ham shu yerda); javob tanasi email/kod bo'lishi mumkin — logga yozilmaydi.
    console.warn(`${label}: status ${res.status}`);
    return 'failed';
  } catch {
    console.warn(`${label}: network error`);
    return 'failed';
  }
}

/** Resend orqali yuboradi. API kaliti, email va kod hech qachon logga chiqmaydi. */
export const resendSender: CodeSender = async (env, to, code, lang) => {
  if (!env.RESEND_API_KEY) return 'not_configured';
  const m = composeMessage(code, lang);
  return post(
    'resend',
    'https://api.resend.com/emails',
    { authorization: `Bearer ${env.RESEND_API_KEY}` },
    { from: `${senderName(env)} <${senderEmail(env)}>`, to: [to], subject: m.subject, text: m.text, html: m.html },
  );
};

/** Brevo orqali yuboradi (EMAIL_PROVIDER=brevo). */
export const brevoSender: CodeSender = async (env, to, code, lang) => {
  if (!env.BREVO_API_KEY || !env.LG_SENDER_EMAIL) return 'not_configured';
  const m = composeMessage(code, lang);
  return post(
    'brevo',
    'https://api.brevo.com/v3/smtp/email',
    { 'api-key': env.BREVO_API_KEY },
    {
      sender: { email: env.LG_SENDER_EMAIL, name: senderName(env) },
      to: [{ email: to }],
      subject: m.subject,
      textContent: m.text,
      htmlContent: m.html,
      // Kuzatuv (pixel/havola) kerak emas.
      headers: { 'X-Mailin-Track': '0' },
    },
  );
};

/** EMAIL_PROVIDER bo'yicha tanlaydi: "resend" (standart) | "brevo". */
export const emailSender: CodeSender = (env, to, code, lang) =>
  (env.EMAIL_PROVIDER || 'resend').trim().toLowerCase() === 'brevo'
    ? brevoSender(env, to, code, lang)
    : resendSender(env, to, code, lang);
