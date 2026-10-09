-- Hamkor firmalar va reklama: hamkor profili, katalogga bog'lanishlar,
-- hamkorlik arizalari va kunlik hisoblagichlar.
--
-- * Hamma (mehmon ham) faqat E'LON QILINGAN va FAOL hamkorni o'qiydi:
--   bugun (Asia/Tashkent) boshlanish..tugash oralig'ida. Admin (aal2)
--   hammasini ko'radi. Yozish faqat admin RPC'lari orqali; har amal
--   admin_audit ga yoziladi.
-- * Reklama katalog ma'lumotiga ta'sir qilmaydi: bu jadvallar katalogga
--   faqat id orqali ishora qiladi (katalog — ilova ichidagi asset, faktlar,
--   tartib va tekshiruv holati u yerda).
-- * Hisoblagichlar faqat kunlik agregat (hamkor × kun × joy). Kim ko'rgani
--   saqlanmaydi. Spamga qarshi: bir chaqiruvda ≤ 20 hodisa, bir hisobga
--   kuniga ≤ 100 hodisa — buning uchun hisobga bitta qator (bugungi son),
--   kun almashganda ustidan yoziladi. Mehmon va admin hodisasi sanalmaydi.
-- * Hamkorlik arizasi: faqat hisobli foydalanuvchi, kuniga ≤ 3 ta.

-- O'zbekiston hududlari (ilovada nomlari uch tilda).
create function public._uz_regions() returns text[]
language sql immutable set search_path = '' as $$
  select array['all', 'tashkent_city', 'tashkent', 'andijan', 'bukhara', 'fergana',
               'jizzakh', 'kashkadarya', 'khorezm', 'namangan', 'navoi', 'samarkand',
               'sirdarya', 'surkhandarya', 'karakalpakstan']::text[];
$$;

-- -------------------------------------------------------------- partners
create table public.partners (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 2 and 120),
  kind text not null check (kind in ('manufacturer', 'distributor', 'service')),
  -- Kompaniya bergan logo: `partner-logos` bucket'idagi ochiq URL (yoki https).
  logo_url text check (logo_url is null or (logo_url ~ '^https://' and char_length(logo_url) <= 500)),
  -- Qisqa tavsif: {"uz": "...", "ru": "...", "en": "..."} (har biri ≤ 300).
  summary jsonb not null default '{}'::jsonb check (jsonb_typeof(summary) = 'object'),
  regions text[] not null default '{}' check (regions <@ public._uz_regions()),
  phone text check (phone is null or phone ~ '^\+?[0-9 ()-]{7,20}$'),
  telegram text check (telegram is null or telegram ~ '^[A-Za-z0-9_]{5,32}$'),
  website text check (website is null or (website ~ '^https://' and char_length(website) <= 300)),
  email text check (email is null or (email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'
                                      and char_length(email) <= 120)),
  -- Reklama materiali (buklet) havolasi.
  brochure_url text check (brochure_url is null or (brochure_url ~ '^https://' and char_length(brochure_url) <= 500)),
  starts_on date not null,
  ends_on date not null,
  status text not null default 'draft' check (status in ('draft', 'published', 'paused')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ends_on >= starts_on)
);

-- Hamkor qaysi ishlab chiqaruvchi/model bilan bog'liq (katalog id lari).
-- Guvohnoma raqami — apparatning O'zbekistonda ro'yxatdan o'tganlik
-- guvohnomasi (hamkor beradi; faqat model uchun, ixtiyoriy).
create table public.partner_links (
  partner_id uuid not null references public.partners (id) on delete cascade,
  target text not null check (target in ('maker', 'model')),
  catalog_id text not null check (catalog_id ~ '^[a-z0-9][a-z0-9-]{1,79}$'),
  registration_no text check (
    registration_no is null
    or (target = 'model' and char_length(btrim(registration_no)) between 3 and 60)
  ),
  primary key (partner_id, target, catalog_id)
);
create index partner_links_target on public.partner_links (target, catalog_id);

alter table public.partners enable row level security;
alter table public.partner_links enable row level security;

-- Hamma: faqat e'lon qilingan va bugun faol. (Funksiya chaqirilmaydi —
-- anon rolida ham ishlaydi.)
create policy "partners: live for everyone" on public.partners
  for select to anon, authenticated
  using (
    status = 'published'
    and starts_on <= (now() at time zone 'Asia/Tashkent')::date
    and ends_on >= (now() at time zone 'Asia/Tashkent')::date
  );
create policy "partners: admins read all" on public.partners
  for select to authenticated using (public.is_admin());

-- Bog'lanish faqat ko'rinadigan hamkor bilan birga ko'rinadi (ichki so'rovga
-- ham partners siyosati qo'llanadi).
create policy "partner links: with a visible partner" on public.partner_links
  for select to anon, authenticated
  using (exists (select 1 from public.partners p where p.id = partner_id));

create function public._partner_json(p public.partners) returns jsonb
language sql stable security definer set search_path = '' as $$
  select to_jsonb(p) || jsonb_build_object('links', coalesce((
    select jsonb_agg(jsonb_build_object(
             'target', l.target, 'catalog_id', l.catalog_id,
             'registration_no', l.registration_no)
           order by l.target, l.catalog_id)
    from public.partner_links l where l.partner_id = p.id), '[]'::jsonb));
$$;
revoke all on function public._partner_json(public.partners) from public, anon, authenticated;

-- Ilova o'qiydigan ro'yxat: chaqiruvchi huquqi bilan (RLS qo'llanadi) va
-- faqat faol hamkorlar — admin uchun ham (qoralama reklama joyiga chiqmaydi).
create function public.partners_feed() returns jsonb
language sql stable security invoker set search_path = '' as $$
  select coalesce(jsonb_agg(
           to_jsonb(p) || jsonb_build_object('links', coalesce((
             select jsonb_agg(jsonb_build_object(
                      'target', l.target, 'catalog_id', l.catalog_id,
                      'registration_no', l.registration_no)
                    order by l.target, l.catalog_id)
             from public.partner_links l where l.partner_id = p.id), '[]'::jsonb))
           order by p.name), '[]'::jsonb)
  from public.partners p
  where p.status = 'published'
    and p.starts_on <= (now() at time zone 'Asia/Tashkent')::date
    and p.ends_on >= (now() at time zone 'Asia/Tashkent')::date;
$$;

-- ---------------------------------------------------------- admin: write
-- E'lon qilish shartlari: tavsif (kamida bitta tilda), kamida bitta aloqa
-- va kamida bitta bog'lanish (aks holda reklama hech qayerda ko'rinmaydi).
create function public._partner_check_publishable(p_partner uuid) returns void
language plpgsql stable security definer set search_path = '' as $$
declare
  p public.partners;
begin
  select * into p from public.partners where id = p_partner;
  if not found then
    raise exception 'partner not found' using errcode = 'P0002';
  end if;
  if p.summary = '{}'::jsonb then
    raise exception 'not publishable: summary' using errcode = '22023';
  end if;
  if coalesce(p.phone, p.telegram, p.website, p.email) is null then
    raise exception 'not publishable: contact' using errcode = '22023';
  end if;
  if not exists (select 1 from public.partner_links l where l.partner_id = p_partner) then
    raise exception 'not publishable: links' using errcode = '22023';
  end if;
end;
$$;
revoke all on function public._partner_check_publishable(uuid) from public, anon, authenticated;

-- Yaratish (p_id = null) yoki tahrirlash. Bog'lanishlar to'liq almashtiriladi.
-- Yangi hamkor — qoralama; e'lon qilish alohida amal.
create function public.admin_partner_save(p_id uuid, p jsonb) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  pid uuid := p_id;
  v_summary jsonb;
  v_regions text[];
  v_links jsonb := coalesce(p -> 'links', '[]'::jsonb);
  action text;
begin
  perform public._require_admin();
  if p is null or jsonb_typeof(p) <> 'object'
     or jsonb_typeof(coalesce(p -> 'summary', '{}'::jsonb)) <> 'object'
     or jsonb_typeof(coalesce(p -> 'regions', '[]'::jsonb)) <> 'array'
     or jsonb_typeof(v_links) <> 'array' or jsonb_array_length(v_links) > 200 then
    raise exception 'invalid partner' using errcode = '22023';
  end if;
  if exists (select 1 from jsonb_each(coalesce(p -> 'summary', '{}'::jsonb)) s
             where s.key not in ('uz', 'ru', 'en') or jsonb_typeof(s.value) <> 'string'
                or char_length(btrim(s.value #>> '{}')) > 300) then
    raise exception 'invalid summary' using errcode = '22023';
  end if;
  select coalesce(jsonb_object_agg(s.key, btrim(s.value #>> '{}')), '{}'::jsonb) into v_summary
    from jsonb_each(coalesce(p -> 'summary', '{}'::jsonb)) s
    where btrim(s.value #>> '{}') <> '';
  select coalesce(array_agg(distinct r), '{}') into v_regions
    from jsonb_array_elements_text(coalesce(p -> 'regions', '[]'::jsonb)) r;

  if pid is null then
    insert into public.partners (name, kind, logo_url, summary, regions, phone, telegram,
                                 website, email, brochure_url, starts_on, ends_on)
    values (btrim(p ->> 'name'), p ->> 'kind', nullif(btrim(p ->> 'logo_url'), ''), v_summary,
            v_regions, nullif(btrim(p ->> 'phone'), ''), nullif(btrim(p ->> 'telegram'), ''),
            nullif(btrim(p ->> 'website'), ''), nullif(btrim(p ->> 'email'), ''),
            nullif(btrim(p ->> 'brochure_url'), ''), (p ->> 'starts_on')::date,
            (p ->> 'ends_on')::date)
    returning id into pid;
    action := 'partner_created';
  else
    update public.partners set
      name = btrim(p ->> 'name'), kind = p ->> 'kind',
      logo_url = nullif(btrim(p ->> 'logo_url'), ''), summary = v_summary, regions = v_regions,
      phone = nullif(btrim(p ->> 'phone'), ''), telegram = nullif(btrim(p ->> 'telegram'), ''),
      website = nullif(btrim(p ->> 'website'), ''), email = nullif(btrim(p ->> 'email'), ''),
      brochure_url = nullif(btrim(p ->> 'brochure_url'), ''),
      starts_on = (p ->> 'starts_on')::date, ends_on = (p ->> 'ends_on')::date,
      updated_at = now()
    where id = pid;
    if not found then
      raise exception 'partner not found' using errcode = 'P0002';
    end if;
    action := 'partner_updated';
  end if;

  delete from public.partner_links where partner_id = pid;
  insert into public.partner_links (partner_id, target, catalog_id, registration_no)
  select pid, l ->> 'target', l ->> 'catalog_id', nullif(btrim(l ->> 'registration_no'), '')
  from jsonb_array_elements(v_links) l;

  -- E'lon qilingan hamkor tahrirdan keyin ham shartlarga mos bo'lishi kerak.
  if (select status from public.partners where id = pid) = 'published' then
    perform public._partner_check_publishable(pid);
  end if;
  perform public._audit(action, pid::text, jsonb_build_object(
    'name', btrim(p ->> 'name'), 'links', jsonb_array_length(v_links)));
  return pid;
end;
$$;

create function public.admin_partner_set_status(p_id uuid, p_status text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  old_status text;
begin
  perform public._require_admin();
  select status into old_status from public.partners where id = p_id for update;
  if not found then
    raise exception 'partner not found' using errcode = 'P0002';
  end if;
  if p_status = 'published' then
    perform public._partner_check_publishable(p_id);
  end if;
  update public.partners set status = p_status, updated_at = now() where id = p_id;
  perform public._audit(
    case p_status when 'published' then 'partner_published'
                  when 'paused' then 'partner_paused'
                  else 'partner_draft' end,
    p_id::text, jsonb_build_object('from', old_status, 'to', p_status));
end;
$$;

-- Admin ro'yxati: barcha hamkorlar (qoralama, to'xtatilgan, muddati o'tgan).
create function public.admin_partners() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
begin
  perform public._require_admin();
  return (select coalesce(jsonb_agg(public._partner_json(p) order by p.updated_at desc), '[]'::jsonb)
          from public.partners p);
end;
$$;

-- ------------------------------------------------------- partner events
create table public.partner_events (
  partner_id uuid not null references public.partners (id) on delete cascade,
  day date not null,
  placement text not null check (placement in ('card', 'category', 'lab_home', 'partner_page')),
  impressions int not null default 0 check (impressions >= 0),
  contacts int not null default 0 check (contacts >= 0),
  primary key (partner_id, day, placement)
);
alter table public.partner_events enable row level security;
create policy "partner events: admins read" on public.partner_events
  for select to authenticated using (public.is_admin());

-- Spamga qarshi: hisob uchun faqat bugungi hodisalar soni (bitta qator).
create table public.partner_event_quota (
  user_id uuid primary key references auth.users (id) on delete cascade,
  day date not null,
  used int not null check (used >= 0)
);
alter table public.partner_event_quota enable row level security;
-- Siyosat yo'q: mijoz o'qiy ham, yoza ham olmaydi.

-- p_events: [{"partner": uuid, "placement": "card", "kind": "impression"}, ...]
-- Qaytaradi: sanalgan hodisalar soni (faol bo'lmagan hamkor sanalmaydi).
create function public.partner_track(p_events jsonb) returns int
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  today date := (now() at time zone 'Asia/Tashkent')::date;
  n int;
  used_today int;
  e jsonb;
  pid uuid;
  accepted int := 0;
begin
  if uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_events is null or jsonb_typeof(p_events) <> 'array' then
    raise exception 'invalid events' using errcode = '22023';
  end if;
  n := jsonb_array_length(p_events);
  if n > 20 then
    raise exception 'rate limited: batch' using errcode = '54000';
  end if;
  for e in select value from jsonb_array_elements(p_events) loop
    if jsonb_typeof(e) <> 'object'
       or coalesce(e ->> 'kind', '') not in ('impression', 'contact')
       or coalesce(e ->> 'placement', '') not in ('card', 'category', 'lab_home', 'partner_page')
       or coalesce(e ->> 'partner', '') !~ '^[0-9a-fA-F-]{36}$' then
      raise exception 'invalid event' using errcode = '22023';
    end if;
  end loop;
  -- Admin o'z reklamasini ko'rib chiqishi hisobotga qo'shilmaydi.
  if n = 0 or public.is_admin_account() then
    return 0;
  end if;

  insert into public.partner_event_quota as q (user_id, day, used)
  values (uid, today, n)
  on conflict (user_id) do update
    set used = case when q.day = today then q.used + n else n end, day = today
  returning used into used_today;
  if used_today > 100 then
    raise exception 'rate limited: events' using errcode = '54000';
  end if;

  for e in select value from jsonb_array_elements(p_events) loop
    pid := (e ->> 'partner')::uuid;
    if exists (select 1 from public.partners p
               where p.id = pid and p.status = 'published'
                 and p.starts_on <= today and p.ends_on >= today) then
      insert into public.partner_events as pe (partner_id, day, placement, impressions, contacts)
      values (pid, today, e ->> 'placement',
              (e ->> 'kind' = 'impression')::int, (e ->> 'kind' = 'contact')::int)
      on conflict (partner_id, day, placement) do update
        set impressions = pe.impressions + excluded.impressions,
            contacts = pe.contacts + excluded.contacts;
      accepted := accepted + 1;
    end if;
  end loop;
  return accepted;
end;
$$;

-- ----------------------------------------------------- partner requests
create table public.partner_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  company text not null check (char_length(btrim(company)) between 2 and 120),
  contact_name text not null check (char_length(btrim(contact_name)) between 2 and 80),
  phone text check (phone is null or phone ~ '^\+?[0-9 ()-]{7,20}$'),
  email text check (email is null or (email ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'
                                      and char_length(email) <= 120)),
  products text not null default '' check (char_length(products) <= 1000),
  message text not null default '' check (char_length(message) <= 2000),
  status text not null default 'new'
    check (status in ('new', 'in_review', 'accepted', 'declined')),
  admin_reply text check (admin_reply is null or char_length(btrim(admin_reply)) between 1 and 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  replied_at timestamptz,
  check (phone is not null or email is not null)
);
create index partner_requests_user on public.partner_requests (user_id, created_at desc);
create index partner_requests_status on public.partner_requests (status, created_at desc);
alter table public.partner_requests enable row level security;
create policy "partner requests: owner or admin read" on public.partner_requests
  for select to authenticated using (user_id = auth.uid() or public.is_admin());

create function public.partner_request_create(
  p_company text, p_contact text, p_phone text, p_email text,
  p_products text default '', p_message text default ''
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  rid uuid;
begin
  if uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if (select count(*) from public.partner_requests r
      where r.user_id = uid and r.created_at > now() - interval '1 day') >= 3 then
    raise exception 'rate limited: partner requests' using errcode = '54000';
  end if;
  insert into public.partner_requests (user_id, company, contact_name, phone, email, products, message)
  values (uid, btrim(p_company), btrim(p_contact), nullif(btrim(p_phone), ''),
          nullif(btrim(lower(p_email)), ''), btrim(coalesce(p_products, '')),
          btrim(coalesce(p_message, '')))
  returning id into rid;
  return rid;
end;
$$;

-- Admin holatni o'zgartiradi va (ixtiyoriy) javob yozadi — arizachi o'z
-- arizasida ko'radi. Javobni faqat inson yozadi.
create function public.admin_partner_request_update(
  p_id uuid, p_status text, p_reply text default null
) returns void
language plpgsql security definer set search_path = '' as $$
declare
  old_status text;
  reply text := nullif(btrim(p_reply), '');
begin
  perform public._require_admin();
  select status into old_status from public.partner_requests where id = p_id for update;
  if not found then
    raise exception 'request not found' using errcode = 'P0002';
  end if;
  update public.partner_requests set
    status = p_status,
    admin_reply = coalesce(reply, admin_reply),
    replied_at = case when reply is null then replied_at else now() end,
    updated_at = now()
  where id = p_id;
  perform public._audit('partner_request', p_id::text, jsonb_build_object(
    'from', old_status, 'to', p_status, 'replied', reply is not null));
end;
$$;

-- --------------------------------------------------------------- logos
-- Ochiq bucket (logo reklama materiali); yuklash/almashtirish faqat admin.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('partner-logos', 'partner-logos', true, 1048576, array['image/png', 'image/jpeg'])
on conflict (id) do update
  set public = true, file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "partner logos: admin upload" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'partner-logos' and public.is_admin());
create policy "partner logos: admin update" on storage.objects
  for update to authenticated
  using (bucket_id = 'partner-logos' and public.is_admin());
create policy "partner logos: admin delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'partner-logos' and public.is_admin());

-- ---------------------------------------------------------- privileges
revoke all on
  public.partners, public.partner_links, public.partner_events,
  public.partner_event_quota, public.partner_requests
  from anon, authenticated;
grant select on public.partners, public.partner_links to anon, authenticated;
grant select on public.partner_events, public.partner_requests to authenticated;

revoke all on function public._uz_regions() from public;
grant execute on function public._uz_regions() to anon, authenticated;
revoke all on function public.partners_feed() from public;
grant execute on function public.partners_feed() to anon, authenticated;
revoke all on function
  public.admin_partner_save(uuid, jsonb),
  public.admin_partner_set_status(uuid, text),
  public.admin_partners(),
  public.partner_track(jsonb),
  public.partner_request_create(text, text, text, text, text, text),
  public.admin_partner_request_update(uuid, text, text)
  from public, anon;
grant execute on function
  public.admin_partner_save(uuid, jsonb),
  public.admin_partner_set_status(uuid, text),
  public.admin_partners(),
  public.partner_track(jsonb),
  public.partner_request_create(text, text, text, text, text, text),
  public.admin_partner_request_update(uuid, text, text)
  to authenticated;
