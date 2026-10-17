-- Asosiy menyu (Bosh sahifa) reklama joylari: laboratoriya xizmati va apparat
-- firmasi.
--
-- * Yangi hamkor turi `laboratory` (laboratoriya xizmati): katalogdagi
--   apparat/ishlab chiqaruvchiga bog'lanmaydi, shuning uchun e'lon qilish
--   uchun "kamida bitta bog'lanish" sharti bu tur uchun talab qilinmaydi.
-- * Yangi hisobot joylari: `home_lab`, `home_equipment`.
-- Qolgan qoidalar (faqat e'lon qilingan va faol hamkor, mehmon/admin
-- hodisasi sanalmaydi, kunlik limitlar) o'zgarmaydi.

alter table public.partners drop constraint partners_kind_check;
alter table public.partners add constraint partners_kind_check
  check (kind in ('manufacturer', 'distributor', 'service', 'laboratory'));

alter table public.partner_events drop constraint partner_events_placement_check;
alter table public.partner_events add constraint partner_events_placement_check
  check (placement in ('card', 'category', 'lab_home', 'partner_page',
                       'home_lab', 'home_equipment'));

create or replace function public._partner_check_publishable(p_partner uuid) returns void
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
  -- Laboratoriya xizmati katalog apparatiga bog'lanmaydi (bosh sahifa joyi).
  if p.kind <> 'laboratory'
     and not exists (select 1 from public.partner_links l where l.partner_id = p_partner) then
    raise exception 'not publishable: links' using errcode = '22023';
  end if;
end;
$$;

create or replace function public.partner_track(p_events jsonb) returns int
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
       or coalesce(e ->> 'placement', '') not in
            ('card', 'category', 'lab_home', 'partner_page', 'home_lab', 'home_equipment')
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
