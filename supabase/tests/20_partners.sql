-- Qabul testlari: hamkorlar va reklama (10_acceptance.sql dan keyin:
-- t.login, t.vars, admin ad01, Alice a1 va Bob b1 hisoblari bor).
--
--   * hamkorni faqat admin (aal2) yaratadi va e'lon qiladi, har amal jurnalga;
--   * e'lon qilinmagan, to'xtatilgan, muddati o'tgan yoki hali boshlanmagan
--     hamkor hech kimga (mehmon ham) ko'rinmaydi;
--   * oddiy foydalanuvchi yoza olmaydi;
--   * hodisa yozish cheklangan, faqat kunlik hisoblagich;
--   * hamkorlik arizasi: cheklov, izolyatsiya, admin javobi.

create function t.partner(p_name text, p_from int, p_to int, p_with_contact boolean default true)
returns jsonb language sql as $$
  select jsonb_build_object(
    'name', p_name,
    'kind', 'distributor',
    'summary', jsonb_build_object('uz', 'Rasmiy distribyutor', 'ru', 'Официальный дистрибьютор'),
    'regions', jsonb_build_array('tashkent_city', 'samarkand'),
    'phone', case when p_with_contact then '+998 71 200-00-00' end,
    'telegram', case when p_with_contact then 'lab_partner' end,
    'starts_on', ((now() at time zone 'Asia/Tashkent')::date + p_from)::text,
    'ends_on', ((now() at time zone 'Asia/Tashkent')::date + p_to)::text,
    'links', jsonb_build_array(
      jsonb_build_object('target', 'maker', 'catalog_id', 'mindray'),
      jsonb_build_object('target', 'model', 'catalog_id', 'mindray-bs-240',
                         'registration_no', 'TT/0000/00')));
$$;
grant execute on function t.partner(text, int, int, boolean) to authenticated;

-- ===================================== faqat admin (aal2) hamkor yaratadi
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  perform public.admin_partner_save(null, t.partner('Hack LLC', -1, 30));
  raise exception 'Bob created a partner';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  insert into public.partners (name, kind, starts_on, ends_on)
  values ('Hack LLC', 'distributor', current_date, current_date + 30);
  raise exception 'Bob inserted a partner directly';
exception when insufficient_privilege then null;
end $$;
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal1');
do $$ begin
  perform public.admin_partner_save(null, t.partner('No 2FA LLC', -1, 30));
  raise exception 'admin without 2FA created a partner';
exception when insufficient_privilege then null;
end $$;

select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
insert into t.vars values
  ('p_live', public.admin_partner_save(null, t.partner('Live Lab Systems', -1, 30))::text),
  ('p_expired', public.admin_partner_save(null, t.partner('Expired LLC', -30, -1))::text),
  ('p_future', public.admin_partner_save(null, t.partner('Future LLC', 1, 30))::text),
  ('p_nocontact', public.admin_partner_save(null, t.partner('Silent LLC', -1, 30, false))::text);
do $$
declare live uuid := (select v::uuid from t.vars where k = 'p_live');
begin
  assert (select status from public.partners where id = live) = 'draft', 'new partner is a draft';
  assert (select count(*) from public.partner_links where partner_id = live) = 2, 'links saved';
  assert (select registration_no from public.partner_links
          where partner_id = live and target = 'model') = 'TT/0000/00', 'registration no saved';
  assert (select count(*) from public.partners) = 4, 'admin sees drafts';
  assert jsonb_array_length(public.admin_partners()) = 4, 'admin list';
  assert jsonb_array_length(public.partners_feed()) = 0, 'drafts never reach the feed (even admin)';
end $$;
-- Aloqasiz hamkor e'lon qilinmaydi; registration_no faqat modelga.
do $$ begin
  perform public.admin_partner_set_status((select v::uuid from t.vars where k = 'p_nocontact'), 'published');
  raise exception 'partner without contacts was published';
exception when invalid_parameter_value then null;
end $$;
do $$ begin
  perform public.admin_partner_save(null, t.partner('Bad Reg', -1, 30)
    || jsonb_build_object('links', jsonb_build_array(jsonb_build_object(
         'target', 'maker', 'catalog_id', 'mindray', 'registration_no', 'X-123'))));
  raise exception 'registration number accepted on a maker link';
exception when check_violation then null;
end $$;
do $$ begin
  perform public.admin_partner_save(null, t.partner('Bad Region', -1, 30)
    || jsonb_build_object('regions', jsonb_build_array('atlantis')));
  raise exception 'unknown region accepted';
exception when check_violation then null;
end $$;
do $$ begin
  perform public.admin_partner_save(null, t.partner('Bad Dates', 5, 1));
  raise exception 'end before start accepted';
exception when check_violation then null;
end $$;

-- ===================================== e'lon qilinmagan — hech kimga ko'rinmaydi
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  assert (select count(*) from public.partners) = 0, 'Bob must not see drafts';
  assert (select count(*) from public.partner_links) = 0, 'Bob must not see draft links';
  assert public.partners_feed() = '[]'::jsonb, 'empty feed';
end $$;

-- ===================================== e'lon: faqat faol muddatdagisi ko'rinadi
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
select public.admin_partner_set_status((select v::uuid from t.vars where k = k2), 'published')
from (values ('p_live'), ('p_expired'), ('p_future')) as x(k2);

select t.login('00000000-0000-0000-0000-0000000000b1');
do $$
declare feed jsonb := public.partners_feed();
begin
  assert jsonb_array_length(feed) = 1, 'only the live partner: ' || feed::text;
  assert feed -> 0 ->> 'name' = 'Live Lab Systems', 'live partner name';
  assert jsonb_array_length(feed -> 0 -> 'links') = 2, 'links in feed';
  assert feed -> 0 -> 'summary' ->> 'uz' = 'Rasmiy distribyutor', 'summary';
  assert (select count(*) from public.partners) = 1, 'RLS: expired/future hidden';
  assert (select count(*) from public.partner_links) = 2, 'RLS: only live links';
end $$;
-- Oddiy foydalanuvchi yoza olmaydi.
do $$ begin
  update public.partners set name = 'Hijacked';
  raise exception 'Bob updated a partner';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  insert into public.partner_links values
    ((select v::uuid from t.vars where k = 'p_live'), 'model', 'roche-cobas-c-311', null);
  raise exception 'Bob linked a partner';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.admin_partner_set_status((select v::uuid from t.vars where k = 'p_live'), 'paused');
  raise exception 'Bob paused a partner';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.admin_partners();
  raise exception 'Bob listed all partners';
exception when insufficient_privilege then null;
end $$;
reset role;

-- Mehmon (anon) ham faqat faol hamkorni o'qiydi, lekin yoza olmaydi.
select set_config('request.jwt.claims', '{"role": "anon"}', false);
set role anon;
do $$ begin
  assert jsonb_array_length(public.partners_feed()) = 1, 'anon feed';
  assert (select count(*) from public.partners) = 1, 'anon table read';
end $$;
do $$ begin
  perform public.partner_track(jsonb_build_array(jsonb_build_object(
    'partner', gen_random_uuid(), 'placement', 'card', 'kind', 'impression')));
  raise exception 'anon tracked events';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.partner_request_create('Anon LLC', 'Anon', '+998901112233', null);
  raise exception 'anon created a partner request';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform count(*) from public.partner_requests;
  raise exception 'anon read partner requests';
exception when insufficient_privilege then null;
end $$;
reset role;

-- ===================================== hodisalar: faqat kunlik hisoblagich
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$
declare
  live uuid := (select v::uuid from t.vars where k = 'p_live');
  expired uuid := (select v::uuid from t.vars where k = 'p_expired');
  n int;
begin
  n := public.partner_track(jsonb_build_array(
    jsonb_build_object('partner', live, 'placement', 'card', 'kind', 'impression'),
    jsonb_build_object('partner', live, 'placement', 'card', 'kind', 'contact'),
    jsonb_build_object('partner', live, 'placement', 'lab_home', 'kind', 'impression'),
    jsonb_build_object('partner', expired, 'placement', 'card', 'kind', 'impression')));
  assert n = 3, 'expired partner is not counted, got ' || n;
  assert (select count(*) from public.partner_events) = 0, 'Bob must not read the counters';
end $$;
do $$ begin
  perform public.partner_track(jsonb_build_array(jsonb_build_object(
    'partner', (select v from t.vars where k = 'p_live'), 'placement', 'banner', 'kind', 'impression')));
  raise exception 'unknown placement accepted';
exception when invalid_parameter_value then null;
end $$;
do $$ begin
  insert into public.partner_events (partner_id, day, placement, impressions)
  values ((select v::uuid from t.vars where k = 'p_live'), current_date, 'card', 1000000);
  raise exception 'Bob inserted counters directly';
exception when insufficient_privilege then null;
end $$;
-- Bir chaqiruvda 20 dan ortiq hodisa — rad.
do $$ begin
  perform public.partner_track((select jsonb_agg(jsonb_build_object(
    'partner', (select v from t.vars where k = 'p_live'), 'placement', 'card', 'kind', 'impression'))
    from generate_series(1, 21)));
  raise exception 'batch of 21 accepted';
exception when program_limit_exceeded then null;
end $$;
-- Kunlik cheklov: 4 (yuqorida) + 4 × 20 + 16 = 100, keyingisi rad.
do $$
declare
  batch jsonb := (select jsonb_agg(jsonb_build_object(
    'partner', (select v from t.vars where k = 'p_live'), 'placement', 'category', 'kind', 'impression'))
    from generate_series(1, 20));
  i int;
begin
  for i in 1 .. 4 loop
    perform public.partner_track(batch);
  end loop;
  perform public.partner_track((select jsonb_agg(e) from (
    select e from jsonb_array_elements(batch) e limit 16) s));
end $$;
do $$ begin
  perform public.partner_track(jsonb_build_array(jsonb_build_object(
    'partner', (select v from t.vars where k = 'p_live'), 'placement', 'card', 'kind', 'contact')));
  raise exception 'daily quota exceeded but accepted';
exception when program_limit_exceeded then null;
end $$;
-- Admin o'z reklamasini ko'rishi hisobotga qo'shilmaydi.
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
do $$
declare live uuid := (select v::uuid from t.vars where k = 'p_live');
begin
  assert public.partner_track(jsonb_build_array(jsonb_build_object(
    'partner', live, 'placement', 'card', 'kind', 'impression'))) = 0, 'admin events not counted';
  assert (select impressions from public.partner_events
          where partner_id = live and placement = 'card') = 1, 'card impressions';
  assert (select contacts from public.partner_events
          where partner_id = live and placement = 'card') = 1, 'card contacts';
  assert (select impressions from public.partner_events
          where partner_id = live and placement = 'category') = 96, 'category impressions';
  assert (select count(*) from public.partner_events
          where partner_id = (select v::uuid from t.vars where k = 'p_expired')) = 0,
    'expired partner has no counters';
  -- Faqat kunlik agregat: foydalanuvchi ustuni yo'q.
  assert not exists (select 1 from information_schema.columns
                     where table_schema = 'public' and table_name = 'partner_events'
                       and column_name in ('user_id', 'actor', 'ip', 'device')),
    'no personal columns in partner_events';
end $$;

-- To'xtatilgan hamkor darhol yo'qoladi; jurnalda hammasi bor.
select public.admin_partner_set_status((select v::uuid from t.vars where k = 'p_live'), 'paused');
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$ begin
  assert public.partners_feed() = '[]'::jsonb, 'paused partner hidden';
  assert (select count(*) from public.partners) = 0, 'paused partner hidden (RLS)';
end $$;
reset role;
do $$ begin
  assert (select count(*) from public.admin_audit where action = 'partner_created') = 4,
    'creations audited';
  assert (select count(*) from public.admin_audit where action = 'partner_published') = 3,
    'publications audited';
  assert (select count(*) from public.admin_audit where action = 'partner_paused') = 1,
    'pause audited';
end $$;

-- ===================================== hamkorlik arizasi
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000b1');
insert into t.vars values ('preq', public.partner_request_create(
  'Med Lab Trade', 'Bob B.', '+998 90 123-45-67', 'Sales@MedLab.test',
  'Mindray BS-240', 'Hamkor bo‘lmoqchimiz')::text);
do $$ begin
  perform public.partner_request_create('No Contact LLC', 'Bob', null, null);
  raise exception 'request without phone and email accepted';
exception when check_violation then null;
end $$;
do $$ begin
  assert (select email from public.partner_requests) = 'sales@medlab.test', 'email normalized';
  perform public.partner_request_create('Second LLC', 'Bob', null, 'b@test.local');
  perform public.partner_request_create('Third LLC', 'Bob', null, 'b@test.local');
  perform public.partner_request_create('Fourth LLC', 'Bob', null, 'b@test.local');
  raise exception 'fourth request in a day accepted';
exception when program_limit_exceeded then null;
end $$;
do $$ begin
  perform public.admin_partner_request_update(
    (select v::uuid from t.vars where k = 'preq'), 'accepted', 'self-accept');
  raise exception 'Bob accepted his own request';
exception when insufficient_privilege then null;
end $$;
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$ begin
  assert (select count(*) from public.partner_requests) = 0, 'Alice must not see Bob requests';
end $$;
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
select public.admin_partner_request_update((select v::uuid from t.vars where k = 'preq'),
  'in_review', 'Rahmat! Ertaga qo‘ng‘iroq qilamiz.');
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$
declare r public.partner_requests;
begin
  select * into r from public.partner_requests where id = (select v::uuid from t.vars where k = 'preq');
  assert r.status = 'in_review', 'status visible to the requester';
  assert r.admin_reply = 'Rahmat! Ertaga qo‘ng‘iroq qilamiz.', 'reply visible to the requester';
  assert r.replied_at is not null, 'replied at';
end $$;
reset role;
do $$ begin
  assert (select count(*) from public.admin_audit where action = 'partner_request') = 1,
    'request handling audited';
end $$;

-- ===================================== logo: faqat admin yuklaydi
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  insert into storage.objects (bucket_id, name) values ('partner-logos', 'fake.png');
  raise exception 'Bob uploaded a partner logo';
exception when insufficient_privilege then null;
end $$;
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
insert into storage.objects (bucket_id, name) values ('partner-logos', 'live-lab.png');
reset role;
do $$ begin
  assert (select public from storage.buckets where id = 'partner-logos'), 'logos bucket is public';
end $$;

select 'partners: all checks passed' as result;
