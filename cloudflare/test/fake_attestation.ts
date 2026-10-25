// Soxta qurilma attestatsiyasi (D-74) — FAQAT testlar uchun. Production'da
// (src/index.ts) hech qanday tekshiruvchi ulanmagan: haqiqiy Apple App Attest /
// DeviceCheck va Google Play Integrity egasi kalitlarini talab qiladi.
//
// Token formati: `fake:<qurilma>:<nonce>`. Nonce mos kelmasa yoki token
// `fake:fail...` bo'lsa — rad etiladi. `markUsed` platforma bayrog'ini
// (DeviceCheck bitlari / Play device recall) taqlid qiladi.
import type { AttestationInput, AttestationResult, DeviceAttestationVerifier } from '../src/trial';

export class FakeDeviceAttestationVerifier implements DeviceAttestationVerifier {
  readonly seen: AttestationInput[] = [];
  /** Platforma bayrog'i "ishlatilgan" qilingan qurilmalar (xom — faqat testda). */
  readonly flagged = new Set<string>();
  /** true — platforma bayrog'ini ham tekshiradi (DeviceCheck kabi). */
  constructor(readonly usePlatformFlag = false) {}

  configured(): boolean {
    return true;
  }

  async verify(_ctx: unknown, input: AttestationInput): Promise<AttestationResult> {
    this.seen.push(input);
    const [kind, device, nonce] = input.token.split(':');
    if (kind !== 'fake' || !device || device === 'fail') return { ok: false, reason: 'invalid_token' };
    if (nonce !== input.nonce) return { ok: false, reason: 'nonce_mismatch' };
    return {
      ok: true,
      subject: device,
      alreadyUsed: this.usePlatformFlag && this.flagged.has(`${input.platform}:${device}`),
    };
  }

  async markUsed(_ctx: unknown, input: AttestationInput): Promise<void> {
    const device = input.token.split(':')[1];
    this.flagged.add(`${input.platform}:${device}`);
  }
}

/** `configured` = true, lekin har doim rad etadi. */
export const RejectingVerifier: DeviceAttestationVerifier = {
  configured: () => true,
  verify: async () => ({ ok: false, reason: 'integrity_failed' }),
};
