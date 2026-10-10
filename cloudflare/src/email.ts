// Email OTP yuborish — Brevo transactional API (bepul: kuniga 300 xat).

import type { Env } from './http';

export type SendResult = 'sent' | 'not_configured' | 'failed';

export type CodeSender = (env: Env, to: string, code: string, lang: string) => Promise<SendResult>;

const SUBJECT: Record<string, string> = {
  uz: 'LabGuide kirish kodi',
  ru: 'Код входа в LabGuide',
  en: 'Your LabGuide sign-in code',
};

const TEXT: Record<string, (code: string) => string> = {
  uz: (c) => `Kodingiz: ${c}\nKod 10 daqiqa amal qiladi. Siz so'ramagan bo'lsangiz, xatni e'tiborsiz qoldiring.`,
  ru: (c) => `Ваш код: ${c}\nКод действует 10 минут. Если вы не запрашивали код, просто проигнорируйте письмо.`,
  en: (c) => `Your code: ${c}\nThe code is valid for 10 minutes. If you did not request it, ignore this email.`,
};

/** Brevo orqali yuboradi. API kaliti hech qachon logga yoki javobga chiqmaydi. */
export const brevoSender: CodeSender = async (env, to, code, lang) => {
  if (!env.BREVO_API_KEY || !env.LG_SENDER_EMAIL) return 'not_configured';
  const l = SUBJECT[lang] ? lang : 'uz';
  const text = TEXT[l](code);
  const html = `<p>${text.split('\n')[0].replace(code, `<strong style="font-size:20px">${code}</strong>`)}</p><p>${text.split('\n')[1]}</p>`;
  try {
    const res = await fetch('https://api.brevo.com/v3/smtp/email', {
      method: 'POST',
      headers: {
        'api-key': env.BREVO_API_KEY,
        'content-type': 'application/json',
        accept: 'application/json',
      },
      body: JSON.stringify({
        sender: { email: env.LG_SENDER_EMAIL, name: env.LG_SENDER_NAME || 'LabGuide' },
        to: [{ email: to }],
        subject: SUBJECT[l],
        textContent: text,
        htmlContent: html,
        // Kuzatuv (pixel/havola) kerak emas.
        headers: { 'X-Mailin-Track': '0' },
      }),
    });
    if (res.ok) return 'sent';
    // Faqat status; javob tanasi (email bo'lishi mumkin) logga yozilmaydi.
    console.warn(`brevo: status ${res.status}`);
    return 'failed';
  } catch {
    console.warn('brevo: network error');
    return 'failed';
  }
};
