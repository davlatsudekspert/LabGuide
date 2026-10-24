-- Do'kon bildirishnomalari jurnali (D-75): App Store Server Notifications V2
-- (`notificationUUID`) va Google Play RTDN (Pub/Sub `messageId`) — takrorni
-- tashlash (idempotentlik) va audit uchun. FAQAT FAYL: production D1 ga
-- qo'llanmagan; yo'llar `LG_BILLING_ENABLED=true` bo'lmasa 404.
--
-- Saqlanadi: manba, tur/subtype, muhit, natija, vaqt. Tranzaksiya id,
-- purchaseToken, foydalanuvchi ma'lumoti YOZILMAYDI. Kunlik tozalash 90 kundan
-- eski qatorlarni o'chiradi (`NOTIFICATION_RETENTION_DAYS`).
CREATE TABLE IF NOT EXISTS billing_notifications (
  -- `app_store:<notificationUUID>` yoki `play_store:<messageId>`.
  id TEXT PRIMARY KEY,
  source TEXT NOT NULL CHECK (source IN ('app_store', 'play_store')),
  type TEXT NOT NULL,
  subtype TEXT,
  environment TEXT,
  outcome TEXT NOT NULL,
  received_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS billing_notifications_received ON billing_notifications (received_at);
