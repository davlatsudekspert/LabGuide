// Soxta do'kon tekshiruvchisi (D-75) — FAQAT testlar. Production'da
// (src/index.ts) haqiqiy App Store Server API / Play Developer API
// tekshiruvchilari ishlaydi; kalitsiz ular 503 `store_verifier_not_configured`.
import type { Platform, Status, StoreVerifier, Verified } from '../src/billing';
import { ApiError } from '../src/http';

export interface FakePurchase {
  productId: string;
  status: Status;
  expiresAt: number | null;
  environment?: 'production' | 'sandbox';
  originalId?: string;
  accountHint?: string | null;
  eventAt?: number;
  needsAck?: boolean;
  periodType?: 'normal' | 'trial' | 'intro';
  autoRenew?: boolean | null;
  pendingProductId?: string | null;
  linkedToken?: string | null;
}

export class FakeStoreVerifier implements StoreVerifier {
  readonly purchases = new Map<string, FakePurchase>();
  readonly calls: string[] = [];
  readonly acks: string[] = [];
  isConfigured = true;
  /** Soat (Verified.eventAt uchun). */
  now = () => Date.now();

  constructor(readonly platform: Platform) {}

  configured(): boolean {
    return this.isConfigured;
  }

  set(token: string, p: FakePurchase): void {
    this.purchases.set(token, p);
  }

  update(token: string, patch: Partial<FakePurchase>): void {
    this.purchases.set(token, { ...this.purchases.get(token)!, ...patch });
  }

  async verify(_ctx: unknown, token: string, expectedProduct?: string): Promise<Verified> {
    this.calls.push(token);
    const p = this.purchases.get(token);
    if (!p) throw new ApiError(400, 'purchase_not_found');
    if (expectedProduct && expectedProduct !== p.productId) throw new ApiError(400, 'product_mismatch');
    return {
      platform: this.platform,
      originalId: p.originalId ?? token,
      productId: p.productId,
      status: p.status,
      startedAt: p.expiresAt == null ? null : p.expiresAt - 30 * 86400_000,
      expiresAt: p.expiresAt,
      ownership: 'purchased',
      environment: p.environment ?? 'production',
      eventAt: p.eventAt ?? this.now(),
      latestToken: token,
      accountHint: p.accountHint ?? null,
      needsAck: p.needsAck,
      periodType: p.periodType,
      autoRenew: p.autoRenew,
      pendingProductId: p.pendingProductId,
      linkedToken: p.linkedToken,
    };
  }

  async acknowledge(_ctx: unknown, v: Verified): Promise<void> {
    this.acks.push(v.latestToken);
  }
}
