import { createApp } from './app';
import { brevoSender } from './email';
import type { Env } from './http';

const app = createApp({ sendCode: brevoSender, now: () => Date.now() });

export default {
  fetch: (req: Request, env: Env) => app.fetch(req, env),
  scheduled: async (_c: ScheduledController, env: Env, ctx: ExecutionContext) => {
    ctx.waitUntil(app.scheduled(env));
  },
} satisfies ExportedHandler<Env>;
