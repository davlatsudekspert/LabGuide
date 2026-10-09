-- Pro huquqlari (obuna). Qarang: docs/PRO_BILLING_PLAN.md.
--
-- * Qatorni FAQAT server yozadi: `verify-purchase` Edge Function (service
--   role) do'kon (App Store Server API / Google Play Developer API) javobini
--   tekshirgandan keyin `entitlement_apply` ni chaqiradi. Ilova (anon yoki
--   authenticated) hech narsa yoza olmaydi — o'zini Pro qila olmaydi.
-- * Foydalanuvchi faqat o'z qatorlarini o'qiydi (RLS).
-- * Bitta do'kon xaridi (platform + original_transaction_id) faqat bitta
--   hisobga bog'lanadi; boshqa hisob uni "tiklay" olmaydi (owned_by_other).
-- * Do'kon xabarlari tartibsiz kelishi mumkin: eskiroq hodisa (event_at)
--   yangisining ustidan yozilmaydi.
-- * Muddati o'tgan / qaytarilgan (refund) qatorlar O'CHIRILMAYDI — ilova
--   ular orqali "Pro davrida saqlangan natijalar"ni ko'rsatishda davrlarni
--   biladi (qaytarilgan xarid davr hisoblanmaydi).

create table public.entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  product_id text not null check (product_id ~ '^[A-Za-z0-9._-]{1,100}$'),
  platform text not null check (platform in ('app_store', 'play_store')),
  -- active        — to'langan, amalda;
  -- grace_period  — to'lov muvaffaqiyatsiz, do'kon imtiyoz davri (huquq bor);
  -- billing_retry — imtiyoz tugagan, do'kon qayta urinmoqda (huquq yo'q);
  -- paused        — Google Play pauza (huquq yo'q);
  -- expired       — muddati tugagan yoki bekor qilingan va tugagan;
  -- revoked       — qaytarilgan (refund) yoki oilaviy ulashish to'xtatilgan.
  status text not null check (status in
    ('active', 'grace_period', 'billing_retry', 'paused', 'expired', 'revoked')),
  started_at timestamptz,
  expires_at timestamptz,
  original_transaction_id text not null
    check (char_length(original_transaction_id) between 1 and 200),
  -- purchased — o'zi sotib olgan; family_shared — Apple Family Sharing.
  ownership text not null default 'purchased'
    check (ownership in ('purchased', 'family_shared')),
  environment text not null default 'production'
    check (environment in ('production', 'sandbox')),
  -- Do'kon hodisasining vaqti (signedDate / eventTimeMillis): tartib uchun.
  event_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (platform, original_transaction_id),
  check (expires_at is null or started_at is null or expires_at >= started_at)
);
create index entitlements_user_idx on public.entitlements (user_id);

alter table public.entitlements enable row level security;

create policy entitlements_select_own on public.entitlements
  for select to authenticated
  using (user_id = auth.uid());
-- insert/update/delete siyosati YO'Q: RLS ostida mijoz yoza olmaydi.

revoke all on public.entitlements from anon, authenticated;
grant select on public.entitlements to authenticated;
grant select, insert, update, delete on public.entitlements to service_role;

-- -------------------------------------------------------------- o'qish
-- Ilova uchun: o'z qatorlari + server vaqti (qurilma soati orqaga
-- surilganini aniqlash va kesh muddatini server vaqtidan hisoblash uchun).
create function public.my_entitlements() returns jsonb
language sql stable security invoker set search_path = '' as $$
  select jsonb_build_object(
    'server_time', now(),
    'items', coalesce((
      select jsonb_agg(jsonb_build_object(
        'product_id', e.product_id,
        'platform', e.platform,
        'status', e.status,
        'started_at', e.started_at,
        'expires_at', e.expires_at,
        'ownership', e.ownership,
        'environment', e.environment,
        'updated_at', e.updated_at) order by e.expires_at desc nulls last)
      from public.entitlements e
      where e.user_id = auth.uid()), '[]'::jsonb));
$$;
revoke all on function public.my_entitlements() from public, anon;
grant execute on function public.my_entitlements() to authenticated;

-- Server tomoni uchun (kelajakdagi Pro Edge Function'lar): hozir amaldagi
-- huquq bormi. Faqat service role.
create function public.entitlement_active(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.entitlements e
    where e.user_id = p_user
      and e.status in ('active', 'grace_period')
      and (e.expires_at is null or e.expires_at > now()));
$$;
revoke all on function public.entitlement_active(uuid) from public, anon, authenticated;
grant execute on function public.entitlement_active(uuid) to service_role;

-- -------------------------------------------------------------- yozish
-- Faqat service role (verify-purchase va do'kon bildirishnomalari).
-- Natija: 'inserted' | 'updated' | 'stale' (eskiroq hodisa e'tiborsiz) |
-- 'owned_by_other' (xarid boshqa hisobga bog'langan — ko'chirilmaydi).
create function public.entitlement_apply(
  p_user uuid,
  p_platform text,
  p_product_id text,
  p_original_transaction_id text,
  p_status text,
  p_started_at timestamptz,
  p_expires_at timestamptz,
  p_event_at timestamptz,
  p_ownership text default 'purchased',
  p_environment text default 'production'
) returns text
language plpgsql security definer set search_path = '' as $$
declare
  cur public.entitlements;
begin
  if p_user is null or p_event_at is null then
    raise exception 'user and event time required' using errcode = '22023';
  end if;
  select * into cur from public.entitlements
   where platform = p_platform and original_transaction_id = p_original_transaction_id
   for update;
  if not found then
    insert into public.entitlements (user_id, product_id, platform, status, started_at,
      expires_at, original_transaction_id, ownership, environment, event_at)
    values (p_user, p_product_id, p_platform, p_status, p_started_at, p_expires_at,
      p_original_transaction_id, p_ownership, p_environment, p_event_at);
    return 'inserted';
  end if;
  if cur.user_id <> p_user then
    return 'owned_by_other';
  end if;
  if p_event_at < cur.event_at then
    return 'stale';
  end if;
  update public.entitlements set
    product_id = p_product_id,
    status = p_status,
    started_at = coalesce(cur.started_at, p_started_at),
    expires_at = p_expires_at,
    ownership = p_ownership,
    environment = p_environment,
    event_at = p_event_at,
    updated_at = now()
  where id = cur.id;
  return 'updated';
end $$;
revoke all on function public.entitlement_apply(uuid, text, text, text, text,
  timestamptz, timestamptz, timestamptz, text, text) from public, anon, authenticated;
grant execute on function public.entitlement_apply(uuid, text, text, text, text,
  timestamptz, timestamptz, timestamptz, text, text) to service_role;
