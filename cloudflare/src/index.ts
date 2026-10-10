import { createApp } from './app';
import { emailSender } from './email';
import type { Env } from './http';

const app = createApp({ sendCode: emailSender, now: () => Date.now() });

export default {
  fetch: (req: Request, env: Env) => app.fetch(req, env),
  scheduled: async (_c: ScheduledController, env: Env, ctx: ExecutionContext) => {
    ctx.waitUntil(app.scheduled(env));
  },
} satisfies ExportedHandler<Env>;
