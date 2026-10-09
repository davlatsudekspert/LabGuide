// Foydalanuvchi o'z hisobini o'chiradi (App Store 5.1.1(v)).
//
// Chaqiruvchi o'z JWT si bilan keladi; funksiya foydalanuvchini aniqlab,
// service role bilan uning murojaat fayllarini (Storage API orqali) va auth
// yozuvini o'chiradi. Profil, murojaatlar, guruh a'zoligi va natijalar
// `on delete cascade` bilan ketadi. Service role kaliti faqat shu yerda —
// ilovada yoki repoda yo'q (Supabase uni funksiyaga o'zi beradi).
import { createClient } from "jsr:@supabase/supabase-js@2";

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !anon || !service) return json({ error: "not configured" }, 500);

  const authorization = req.headers.get("Authorization") ?? "";
  const asUser = createClient(url, anon, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false },
  });
  const { data, error } = await asUser.auth.getUser();
  if (error || !data.user) return json({ error: "unauthorized" }, 401);
  const userId = data.user.id;

  const admin = createClient(url, service, { auth: { persistSession: false } });
  const bucket = admin.storage.from("support-attachments");
  for (;;) {
    const { data: files, error: listError } = await bucket.list(userId, { limit: 100 });
    if (listError) return json({ error: "storage list failed" }, 500);
    if (!files || files.length === 0) break;
    const { error: removeError } = await bucket.remove(
      files.map((f) => `${userId}/${f.name}`),
    );
    if (removeError) return json({ error: "storage remove failed" }, 500);
  }
  const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
  if (deleteError) return json({ error: "delete failed" }, 500);
  return json({ deleted: true });
});
