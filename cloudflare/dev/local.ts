// FAQAT mahalliy sinov (wrangler dev --local): xat yuborilmaydi, kodlar xotirada
// ushlanadi va `GET /__outbox` orqali o'qiladi. Ishlab chiqarish Workeri
// (src/index.ts) bilan aloqasi yo'q va deploy qilinmaydi.
import { createApp } from '../src/app';
import type { CodeSender } from '../src/email';
import type { Env } from '../src/http';

const outbox: { to: string; code: string; lang: string }[] = [];
const sendCode: CodeSender = async (_env, to, code, lang) => {
  outbox.push({ to, code, lang });
  return 'sent';
};
const app = createApp({ sendCode, now: () => Date.now() });

export default {
  fetch: (req: Request, env: Env) => {
    const url = new URL(req.url);
    if (url.pathname === '/__outbox') return Response.json(outbox);
    return app.fetch(req, env);
  },
} satisfies ExportedHandler<Env>;
