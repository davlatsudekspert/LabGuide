// Ilova siyosati (src/policy.ts): majburiy / taklif qilinadigan yangilash, fail open.

import { describe, expect, it } from 'vitest';
import { compareVersions, parseVersion } from '../src/policy';
import { makeServer } from './helpers';

describe('app policy', () => {
  it('parses and compares versions, ignores the build suffix', () => {
    expect(parseVersion('0.1.1+7')).toEqual([0, 1, 1]);
    expect(parseVersion('1.2')).toBeNull();
    expect(parseVersion('abc')).toBeNull();
    expect(parseVersion('')).toBeNull();
    expect(compareVersions([0, 1, 0], [0, 1, 1])).toBeLessThan(0);
    expect(compareVersions([0, 2, 0], [0, 1, 9])).toBeGreaterThan(0);
    expect(compareVersions([1, 0, 0], [1, 0, 0])).toBe(0);
  });

  it('is public and forces nobody when nothing is configured', async () => {
    const s = makeServer();
    const r = await s.call('GET', '/v1/app-policy?platform=android&version=0.0.1');
    expect(r.status).toBe(200);
    expect(r.data).toEqual({
      api: 1,
      min_version: null,
      latest_version: null,
      update_url: null,
      update_required: false,
      update_available: false,
    });
  });

  it('marks older versions as required / available and returns the platform URL', async () => {
    const s = makeServer({
      LG_MIN_APP_VERSION: '0.2.0',
      LG_LATEST_APP_VERSION: '0.3.0',
      LG_UPDATE_URL_ANDROID: 'https://example.org/android',
      LG_UPDATE_URL_IOS: 'https://example.org/ios',
    });
    const old = (await s.call('GET', '/v1/app-policy?platform=android&version=0.1.1+4')).data as Record<string, unknown>;
    expect(old.update_required).toBe(true);
    expect(old.update_available).toBe(true);
    expect(old.update_url).toBe('https://example.org/android');
    const mid = (await s.call('GET', '/v1/app-policy?platform=ios&version=0.2.5')).data as Record<string, unknown>;
    expect(mid.update_required).toBe(false);
    expect(mid.update_available).toBe(true);
    expect(mid.update_url).toBe('https://example.org/ios');
    const cur = (await s.call('GET', '/v1/app-policy?platform=ios&version=0.3.0')).data as Record<string, unknown>;
    expect(cur.update_required).toBe(false);
    expect(cur.update_available).toBe(false);
  });

  it('fails open on a misconfigured value (never locks users out)', async () => {
    const s = makeServer({
      LG_MIN_APP_VERSION: 'oops',
      LG_LATEST_APP_VERSION: '0.3',
      LG_UPDATE_URL_ANDROID: 'http://insecure.example.org',
    });
    const r = (await s.call('GET', '/v1/app-policy?platform=android&version=0.0.1')).data as Record<string, unknown>;
    expect(r.update_required).toBe(false);
    expect(r.update_available).toBe(false);
    expect(r.min_version).toBeNull();
    expect(r.update_url).toBeNull();
  });
});
