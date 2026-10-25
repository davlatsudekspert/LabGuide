// Apple JWS zanjiri tekshiruvi (src/x509.ts, D-75).
import { describe, expect, it } from 'vitest';
import { APPLE_ROOT_CA_G3_SHA256, JwsError, verifyAppleJws } from '../src/x509';
import { appleChain, expiredChain, tamper } from './apple_jws_fixture';

const at = Date.UTC(2026, 9, 24);

describe('x509: Apple JWS', () => {
  it('to‘g‘ri zanjir va imzo — yuklama qaytadi', async () => {
    const c = await appleChain();
    const p = await verifyAppleJws<{ a: number }>(await c.sign({ a: 1 }), { rootSha256: c.rootSha256, at });
    expect(p.a).toBe(1);
  });

  it('standart pin — Apple Root CA - G3; test root u bilan o‘tmaydi', async () => {
    expect(APPLE_ROOT_CA_G3_SHA256).toBe('63343abfb89a6a03ebb57e9b3f5fa7be7c4f5c756f3017b3a8c488c3653e9179');
    const c = await appleChain();
    await expect(verifyAppleJws(await c.sign({}), { at })).rejects.toBeInstanceOf(JwsError);
  });

  it('buzilgan yuklama, boshqa root, muddati o‘tgan zanjir, x5c siz — rad', async () => {
    const c = await appleChain();
    const opts = { rootSha256: c.rootSha256, at };
    await expect(verifyAppleJws(tamper(await c.sign({ a: 1 })), opts)).rejects.toThrow('signature');
    await expect(verifyAppleJws(await c.signForeign({}), opts)).rejects.toThrow('root');
    const old = await expiredChain();
    await expect(verifyAppleJws(await old.sign({}), { rootSha256: old.rootSha256, at })).rejects.toThrow('expired');
    await expect(verifyAppleJws('e30.e30.c2ln', opts)).rejects.toBeInstanceOf(JwsError);
    await expect(verifyAppleJws(42, opts)).rejects.toBeInstanceOf(JwsError);
  });
});
