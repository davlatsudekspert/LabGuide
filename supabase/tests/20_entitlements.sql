-- Qabul testlari: Pro huquqlari (10_acceptance.sql dan keyin: t.login,
-- t.vars, Alice a1 va Bob b1 hisoblari bor).
--
--   * foydalanuvchi faqat o'z huquqini o'qiydi, mehmon hech narsa;
--   * mijoz (authenticated/anon) yoza olmaydi — o'zini Pro qila olmaydi;
--   * entitlement_apply faqat service role uchun;
--   * eskiroq do'kon hodisasi yangisining ustidan yozilmaydi;
--   * bir xarid boshqa hisobga ko'chirilmaydi;
--   * qaytarish (refund) qatorni o'chirmaydi, holatni 'revoked' qiladi.

-- ===================================== service role: Alice Pro sotib oldi
set role service_role;
do $$ begin
  assert public.entitlement_apply(
    '00000000-0000-0000-0000-0000000000a1', 'app_store', 'labguide.pro.monthly',
    'otx-alice-1', 'active', now() - interval '3 days', now() + interval '27 days',
    now() - interval '1 minute') = 'inserted', 'insert';
  -- Do'kon eski hodisani kechikib yubordi: e'tiborsiz.
  assert public.entitlement_apply(
    '00000000-0000-0000-0000-0000000000a1', 'app_store', 'labguide.pro.monthly',
    'otx-alice-1', 'expired', now() - interval '3 days', now() - interval '1 day',
    now() - interval '2 days') = 'stale', 'stale event ignored';
  assert (select status from public.entitlements where original_transaction_id = 'otx-alice-1')
    = 'active', 'stale event must not overwrite';
  -- Bob Alice'ning xaridini o'ziga "tiklay" olmaydi.
  assert public.entitlement_apply(
    '00000000-0000-0000-0000-0000000000b1', 'app_store', 'labguide.pro.monthly',
    'otx-alice-1', 'active', now(), now() + interval '30 days', now()) = 'owned_by_other',
    'purchase moved to another account';
  assert (select user_id from public.entitlements where original_transaction_id = 'otx-alice-1')
    = '00000000-0000-0000-0000-0000000000a1', 'owner unchanged';
  assert public.entitlement_active('00000000-0000-0000-0000-0000000000a1'), 'alice active';
  assert not public.entitlement_active('00000000-0000-0000-0000-0000000000b1'), 'bob not active';
end $$;
-- Noto'g'ri holat/platforma qabul qilinmaydi.
do $$ begin
  perform public.entitlement_apply(
    '00000000-0000-0000-0000-0000000000b1', 'web', 'labguide.pro.monthly',
    'otx-x', 'active', now(), now() + interval '1 day', now());
  raise exception 'unknown platform accepted';
exception when check_violation then null;
end $$;
do $$ begin
  perform public.entitlement_apply(
    '00000000-0000-0000-0000-0000000000b1', 'play_store', 'labguide.pro.monthly',
    'otx-y', 'lifetime', now(), now() + interval '1 day', now());
  raise exception 'unknown status accepted';
exception when check_violation then null;
end $$;
reset role;

-- ===================================== mijoz: o'qish faqat o'ziniki
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$
declare r jsonb := public.my_entitlements();
begin
  assert (select count(*) from public.entitlements) = 1, 'alice sees her row';
  assert jsonb_array_length(r -> 'items') = 1, 'rpc returns her row';
  assert r -> 'items' -> 0 ->> 'status' = 'active', 'status';
  assert r ? 'server_time', 'server time for the offline cache';
  assert not (r -> 'items' -> 0) ? 'user_id', 'no user id echoed';
end $$;

select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  assert (select count(*) from public.entitlements) = 0, 'bob must not see alice';
  assert jsonb_array_length(public.my_entitlements() -> 'items') = 0, 'bob rpc empty';
end $$;

-- Bob o'zini Pro qila olmaydi: na jadvalga, na RPC orqali.
do $$ begin
  insert into public.entitlements (user_id, product_id, platform, status, expires_at,
    original_transaction_id)
  values ('00000000-0000-0000-0000-0000000000b1', 'labguide.pro.monthly', 'app_store',
    'active', now() + interval '1 year', 'fake');
  raise exception 'client inserted an entitlement';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  update public.entitlements set expires_at = now() + interval '10 years';
  raise exception 'client updated an entitlement';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  delete from public.entitlements;
  raise exception 'client deleted an entitlement';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.entitlement_apply(
    '00000000-0000-0000-0000-0000000000b1', 'app_store', 'labguide.pro.monthly',
    'otx-bob-fake', 'active', now(), now() + interval '1 year', now());
  raise exception 'client called entitlement_apply';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.entitlement_active('00000000-0000-0000-0000-0000000000b1');
  raise exception 'client called entitlement_active';
exception when insufficient_privilege then null;
end $$;

-- Alice ham o'z qatorini uzaytira olmaydi.
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$ begin
  update public.entitlements set expires_at = now() + interval '10 years';
  raise exception 'owner updated her entitlement';
exception when insufficient_privilege then null;
end $$;
reset role;

-- Mehmon (anon) hech narsa o'qimaydi.
set role anon;
do $$ begin
  perform 1 from public.entitlements;
  raise exception 'anon read entitlements';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.my_entitlements();
  raise exception 'anon called my_entitlements';
exception when insufficient_privilege then null;
end $$;
reset role;

-- ===================================== qaytarish (refund): qator qoladi
set role service_role;
do $$ begin
  assert public.entitlement_apply(
    '00000000-0000-0000-0000-0000000000a1', 'app_store', 'labguide.pro.monthly',
    'otx-alice-1', 'revoked', now() - interval '3 days', now(), now()) = 'updated', 'refund';
  assert not public.entitlement_active('00000000-0000-0000-0000-0000000000a1'), 'refund revokes';
  assert (select count(*) from public.entitlements) = 1, 'row kept after refund';
  assert (select started_at from public.entitlements where original_transaction_id = 'otx-alice-1')
    is not null, 'start kept';
end $$;
reset role;

select 'entitlements: all checks passed' as result;
