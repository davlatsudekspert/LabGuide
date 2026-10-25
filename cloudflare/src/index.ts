import { createApp } from './app';
import { platformVerifier } from './attestation';
import { emailSender } from './email';
import { ApiError, type Env } from './http';

const app = createApp({
  sendCode: emailSender,
  now: () => Date.now(),
  // Haqiqiy qurilma attestatsiyasi (Play Integrity / DeviceCheck). Secretlarsiz
  // "sozlanmagan" → sinov 503 `trial_unavailable` (fail closed).
  attestation: platformVerifier(),
  runAi: async (env, model, input) => {
    if (!env.AI) throw new ApiError(503, 'ai_unavailable');
    return (env.AI as unknown as { run: (m: string, i: unknown) => Promise<unknown> }).run(model, input);
  },
});

export default {
  fetch: (req: Request, env: Env) => app.fetch(req, env),
  scheduled: async (_c: ScheduledController, env: Env, ctx: ExecutionContext) => {
    ctx.waitUntil(app.scheduled(env));
  },
} satisfies ExportedHandler<Env>;
