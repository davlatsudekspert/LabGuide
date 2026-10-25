// Marshrutlar va umumiy so'rov qayta ishlash (xatolar ichki ma'lumotsiz).

import * as admins from './admins';
import * as adminConsole from './adminconsole';
import * as auth from './auth';
import * as billing from './billing';
import * as guest from './guest';
import * as proGrants from './progrants';
import * as community from './community';
import * as complaints from './complaints';
import type { Ctx, Deps } from './context';
import { deriveKeys, hex, hmac } from './crypto';
import * as groups from './groups';
import * as social from './social';
import * as stepUp from './stepup';
import * as support from './support';
import * as tiers from './tiers';
import * as trial from './trial';
import {
  ApiError,
  billingEnabled,
  corsHeaders,
  type Env,
  errorResponse,
  json,
  withCors,
} from './http';

type Handler = (ctx: Ctx, ...params: string[]) => Promise<Response>;

interface Route {
  method: string;
  pattern: RegExp;
  handler: Handler;
}

const P = '([^/]+)';
const r = (method: string, path: string, handler: Handler): Route => ({
  method,
  pattern: new RegExp(`^${path.replace(/:[a-z]+/g, P)}$`),
  handler,
});

/**
 * Hali ko'chirilmagan funksiyalar: aniq `501 not_implemented` — hech narsa
 * ishlayotgandek ko'rsatilmaydi. Admin yo'llari avval vakolatni tekshiradi.
 */
const planned: Handler = async () => {
  throw new ApiError(501, 'not_implemented');
};
const plannedSignedIn: Handler = async (ctx) => {
  await auth.requireSession(ctx);
  return planned(ctx);
};
const plannedAdmin: Handler = async (ctx) => {
  await auth.requireAdmin(ctx);
  return planned(ctx);
};

const routes: Route[] = [
  r('GET', '/v1/health', async () => json({ ok: true, api: 1 })),

  // Auth
  r('POST', '/v1/auth/otp/request', auth.requestCode),
  r('POST', '/v1/auth/otp/verify', auth.verifyCode),
  // Google / Apple bilan kirish (D-56): ID token serverda tekshiriladi.
  r('GET', '/v1/auth/providers', social.providers),
  r('POST', '/v1/auth/google', social.googleLogin),
  r('POST', '/v1/auth/apple', social.appleLogin),
  r('POST', '/v1/auth/apple/callback', social.appleCallback),
  r('POST', '/v1/auth/logout', auth.logout),
  r('POST', '/v1/auth/logout-all', auth.logoutAll),
  r('GET', '/v1/auth/mfa', auth.mfaStatus),
  r('POST', '/v1/auth/mfa/enroll', auth.mfaEnroll),
  r('POST', '/v1/auth/mfa/verify', auth.mfaVerify),
  // Admin step-up (xavfli amaldan oldin yangi tasdiq): stepup.ts.
  ...stepUp.ROUTES.map(([m, p, h]) => r(m, p, h)),

  // Hisob
  r('GET', '/v1/me', auth.me),
  r('PUT', '/v1/me/profile', auth.updateProfile),
  r('DELETE', '/v1/me', auth.deleteAccount),
  r('POST', '/v1/me/teacher', groups.registerTeacher),

  // Guruhlar
  r('GET', '/v1/groups', groups.listGroups),
  r('POST', '/v1/groups', groups.createGroup),
  r('POST', '/v1/groups/join', groups.joinGroup),
  r('DELETE', '/v1/groups/:g', groups.deleteGroup),
  r('POST', '/v1/groups/:g/leave', groups.leaveGroup),
  r('PUT', '/v1/groups/:g/alias', groups.setAlias),
  r('POST', '/v1/groups/:g/code', groups.rotateCode),
  r('GET', '/v1/groups/:g/members', groups.listMembers),
  r('DELETE', '/v1/groups/:g/members/:u', groups.removeMember),
  r('GET', '/v1/groups/:g/topics', groups.listTopics),
  r('PUT', '/v1/groups/:g/topics/:d', groups.openTopic),
  r('DELETE', '/v1/groups/:g/topics/:d', groups.closeTopic),
  r('POST', '/v1/groups/:g/topics/:d/stage', groups.markTopicStage),
  r('POST', '/v1/groups/:g/topics/:d/test', groups.startTopicTest),
  r('POST', '/v1/groups/:g/topics/:d/finish', groups.finishTopicTest),
  r('GET', '/v1/groups/:g/marks', groups.listMarks),
  r('PUT', '/v1/groups/:g/marks', groups.putMark),
  r('DELETE', '/v1/groups/:g/marks/:m', groups.deleteMark),
  r('GET', '/v1/groups/:g/assignments', groups.listAssignments),
  r('POST', '/v1/groups/:g/assignments', groups.createAssignment),
  r('GET', '/v1/groups/:g/submissions', groups.groupSubmissions),
  r('POST', '/v1/assignments/:a/open', (c, a) => groups.setAssignmentStatus(c, a, 'open')),
  r('POST', '/v1/assignments/:a/close', (c, a) => groups.setAssignmentStatus(c, a, 'closed')),
  r('POST', '/v1/assignments/:a/start', groups.startAssignment),
  r('POST', '/v1/assignments/:a/submit', groups.submitAssignment),
  r('GET', '/v1/assignments/:a/submissions', groups.listSubmissions),
  r('GET', '/v1/assignments/:a/key', groups.assignmentKey),
  r('GET', '/v1/assignments/:a/progress', groups.assignmentProgress),

  // Hamjamiyat (D-43)
  r('GET', '/v1/community/me', community.me),
  r('POST', '/v1/community/verify', community.verify),
  r('GET', '/v1/community/questions', community.listQuestions),
  r('POST', '/v1/community/questions', community.createQuestion),
  r('GET', '/v1/community/questions/:q', community.getQuestion),
  r('DELETE', '/v1/community/questions/:q', community.deleteQuestion),
  r('POST', '/v1/community/questions/:q/pin', community.pinQuestion),
  r('POST', '/v1/community/questions/:q/best', community.setBest),
  r('POST', '/v1/community/questions/:q/answers', community.createAnswer),
  r('DELETE', '/v1/community/answers/:a', community.deleteAnswer),
  r('POST', '/v1/community/answers/:a/vote', (c, a) => community.vote(c, a, true)),
  r('DELETE', '/v1/community/answers/:a/vote', (c, a) => community.vote(c, a, false)),
  r('POST', '/v1/community/reports', community.report),
  r('GET', '/v1/community/blocks', community.listBlocks),
  r('POST', '/v1/community/blocks', community.block),
  r('DELETE', '/v1/community/blocks', community.clearBlocks),
  r('POST', '/v1/community/translate', community.translate),
  r('GET', '/v1/admin/community/members', community.adminMembers),
  r('POST', '/v1/admin/community/members/:h/restore', community.adminRestore),
  r('POST', '/v1/admin/community/members/:h/revoke', community.adminRevoke),
  r('POST', '/v1/admin/community/members/:h/suspend', community.adminSuspend),
  r('POST', '/v1/admin/community/seed', community.adminSeed),
  r('POST', '/v1/admin/community/launch', community.adminCommunityLaunch),
  r('POST', '/v1/admin/seed-owner-verification', community.adminSeedOwnerVerification),

  // Adminlar boshqaruvi (D-44): ro'yxat — har admin, o'zgartirish — super admin.
  r('GET', '/v1/admin/admins', admins.listAdmins),
  r('POST', '/v1/admin/admins', admins.addAdmin),
  r('DELETE', '/v1/admin/admins/:id', admins.removeAdmin),

  // Taklif va yordam, shikoyatlar, egasi admin paneli (support.ts, complaints.ts, adminconsole.ts).
  ...[...support.ROUTES, ...complaints.ROUTES, ...adminConsole.ROUTES].map(([m, p, h]) => r(m, p, h)),

  // TODO(port): Supabase'dan ko'chiriladi — hozircha 501 (docs/BACKEND_CLOUDFLARE.md).
  r('*', '/v1/support(/.*)?', plannedSignedIn),
  r('*', '/v1/reviews(/.*)?', plannedSignedIn),
  r('*', '/v1/partners(/.*)?', planned),
  r('*', '/v1/admin(/.*)?', plannedAdmin),
];

/**
 * Pro obunalari (D-46…D-53, D-71). INERT: `LG_BILLING_ENABLED=true` bo'lmasa
 * bu yo'llar umuman yo'q (404) — bepul reliz bilan bir xil xatti-harakat.
 */
const billingRoutes: Route[] = [
  r('GET', '/v1/billing/status', billing.status),
  r('GET', '/v1/billing/entitlements', billing.entitlements),
  r('GET', '/v1/entitlements', billing.entitlements),
  r('POST', '/v1/billing/verify', billing.verify),
  r('POST', '/v1/billing/apple/notifications', billing.appleNotification),
  r('POST', '/v1/billing/google/rtdn', billing.googleNotification),
  // Mehmon (hisobsiz) xarid / tiklash / hisobga bog'lash — Apple 5.1.1(v) (D-77 addendum).
  r('POST', '/v1/billing/guest/verify', guest.verify),
  r('POST', '/v1/billing/guest/entitlements', guest.entitlements),
  r('POST', '/v1/billing/guest/link', guest.link),
  // Admin grant (D-73): `/v1/admin(/.*)?` (plannedAdmin) dan OLDIN turadi.
  r('GET', '/v1/admin/pro-grants', proGrants.listGrants),
  r('POST', '/v1/admin/pro-grants', proGrants.createGrant),
  r('DELETE', '/v1/admin/pro-grants/:id', proGrants.revokeGrant),
  // Bepul sinov — bir telefonga bir marta (D-74); attestatsiya sozlanmagan — 503.
  r('POST', '/v1/billing/trial/challenge', trial.challenge),
  r('POST', '/v1/billing/trial/start', trial.start),
  r('GET', '/v1/billing/trial', trial.state),
  // Reja ↔ panel ajratish (D-74): serverdagi daraja va `requireTier` tekshiruvi.
  r('GET', '/v1/pro/access', tiers.access),
  r('GET', '/v1/pro/check/:capability', tiers.check),
];

export { billingEnabled };

const MIN_SECRET = 32;

export function createApp(deps: Deps) {
  return {
    async fetch(req: Request, env: Env): Promise<Response> {
      const cors = corsHeaders(req, env);
      if (req.method === 'OPTIONS') {
        // Preflight faqat ruxsat etilgan originga.
        return cors ? new Response(null, { status: 204, headers: cors }) : new Response(null, { status: 403 });
      }
      try {
        const url = new URL(req.url);
        let match: { route: Route; params: string[] } | null = null;
        let pathKnown = false;
        // Bayroq o'chiq: admin grant yo'llari umuman yo'q (plannedAdmin 403/501 bermaydi).
        if (!billingEnabled(env) && /^\/v1\/admin\/pro-grants(\/|$)/.test(url.pathname)) {
          throw new ApiError(404, 'not_found');
        }
        for (const route of billingEnabled(env) ? [...billingRoutes, ...routes] : routes) {
          const m = route.pattern.exec(url.pathname);
          if (!m) continue;
          pathKnown = true;
          if (route.method === '*' || route.method === req.method) {
            match = { route, params: m.slice(1).filter((x) => x !== undefined && !x.startsWith('/')) };
            break;
          }
        }
        if (!match) throw new ApiError(pathKnown ? 405 : 404, pathKnown ? 'method_not_allowed' : 'not_found');
        if (url.pathname === '/v1/health') return withCors(await match.route.handler({} as Ctx), cors);

        const secret = env.LG_SERVER_SECRET ?? '';
        if (secret.length < MIN_SECRET) throw new ApiError(503, 'not_configured');
        const keys = await deriveKeys(secret);
        const ip = req.headers.get('cf-connecting-ip') ?? 'unknown';
        const ctx: Ctx = {
          req,
          env,
          db: env.DB,
          keys,
          deps,
          now: deps.now(),
          ipTag: hex(await hmac(keys.ip, ip)).slice(0, 32),
        };
        return withCors(await match.route.handler(ctx, ...match.params), cors);
      } catch (e) {
        if (e instanceof ApiError) return withCors(errorResponse(e), cors);
        // Ichki tafsilot (SQL, stack) javobga chiqmaydi; logda faqat tur.
        console.error('internal error', e instanceof Error ? e.name : typeof e);
        return withCors(json({ error: 'internal' }, 500), cors);
      }
    },

    /** Kunlik tozalash: bitta batch (bepul tarif limitlarini tejaydi). */
    async scheduled(env: Env): Promise<void> {
      const now = deps.now();
      await env.DB.batch([
        env.DB.prepare('DELETE FROM otp_challenges WHERE expires_at < ?1').bind(now),
        env.DB.prepare('DELETE FROM sessions WHERE expires_at < ?1').bind(now),
        env.DB.prepare('DELETE FROM auth_replay WHERE expires_at < ?1').bind(now),
        env.DB.prepare('DELETE FROM step_up_challenges WHERE expires_at < ?1').bind(now),
        env.DB.prepare('DELETE FROM rate_limits WHERE window_start < ?1').bind(now - 86400_000),
        // Bepul sinov jadvallari faqat bayroq yoqilganda mavjud (0016 migratsiyasi).
        ...(billingEnabled(env) ? trial.trialCleanupStatements(env.DB, now) : []),
        // Do'kon bildirishnomalari jurnali (0017) — ham faqat bayroq bilan.
        ...(billingEnabled(env) ? billing.notificationCleanupStatements(env.DB, now) : []),
      ]);
    },
  };
}
