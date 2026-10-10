// D1 dagi qat'iy oynali hisoblagich (bitta atomar UPSERT so'rovi).

import { rateLimited } from './http';

/**
 * [bucket] uchun hisoblagichni oshiradi; [limit] dan oshsa 429 tashlaydi.
 * Bucket nomida faqat HMAC qilingan identifikator bo'ladi (email/IP emas).
 */
export async function hit(
  db: D1Database,
  bucket: string,
  limit: number,
  windowSec: number,
  now: number,
): Promise<void> {
  const windowMs = windowSec * 1000;
  const row = await db
    .prepare(
      `INSERT INTO rate_limits (bucket, window_start, count) VALUES (?1, ?2, 1)
       ON CONFLICT (bucket) DO UPDATE SET
         count = CASE WHEN rate_limits.window_start <= ?3 THEN 1 ELSE rate_limits.count + 1 END,
         window_start = CASE WHEN rate_limits.window_start <= ?3 THEN ?2 ELSE rate_limits.window_start END
       RETURNING count, window_start`,
    )
    .bind(bucket, now, now - windowMs)
    .first<{ count: number; window_start: number }>();
  if (row && row.count > limit) {
    throw rateLimited((row.window_start + windowMs - now) / 1000);
  }
}
