-- LabGuide backend: profillar, admin/reviewer vakolati, audit jurnali.
--
-- Xavfsizlik tamoyillari:
-- * Admin vakolati faqat SERVERDA beriladi: `admin_allowlist` dagi email
--   egasi emailni OTP bilan tasdiqlaganda (auth.users.email_confirmed_at)
--   trigger `app_admins` ga yozadi. Ilova emailni solishtirib hech qanday
--   huquq bermaydi; mijoz `app_admins`/`admin_allowlist` ga yoza olmaydi.
-- * Admin funksiyalari ikki bosqichli himoyani talab qiladi: JWT dagi
--   `aal = aal2` (TOTP tasdiqlangan sessiya).
-- * Muhim admin amallari `admin_audit` ga yoziladi; jurnalni hech kim
--   o'zgartira yoki o'chira olmaydi (faqat qo'shiladi).
-- * Barcha jadvallarda RLS yoqilgan; yozish faqat SECURITY DEFINER
--   funksiyalar orqali, ular har chaqiruvda vakolatni tekshiradi.

set check_function_bodies = off;

-- ---------------------------------------------------------------- profiles
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null default 'student'
    check (role in ('doctor', 'lab', 'student', 'teacher')),
  language text not null default 'uz' check (language in ('uz', 'ru', 'en')),
  created_at timestamptz not null default now(),
  -- Faollik kuni (Asia/Tashkent). Ilova hisobga kirgan holda ochilganda
  -- kuniga bir marta yangilanadi — aniq vaqt, qurilma yoki IP saqlanmaydi.
  last_seen_on date
);
alter table public.profiles enable row level security;
create policy "profiles: own row" on public.profiles
  for select to authenticated using (id = auth.uid());

-- ------------------------------------------------------------ admin grant
create table public.admin_allowlist (
  email text primary key check (email = lower(email))
);
alter table public.admin_allowlist enable row level security;
-- Siyosat yo'q: mijoz ro'yxatni o'qiy ham, o'zgartira ham olmaydi.
insert into public.admin_allowlist (email) values ('davlatsudekspert@gmail.com');

create table public.app_admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  granted_at timestamptz not null default now(),
  granted_reason text not null
);
alter table public.app_admins enable row level security;

create table public.app_reviewers (
  user_id uuid primary key references auth.users (id) on delete cascade,
  granted_at timestamptz not null default now(),
  granted_by uuid references auth.users (id) on delete set null
);
alter table public.app_reviewers enable row level security;

create table public.admin_audit (
  id bigint generated always as identity primary key,
  at timestamptz not null default now(),
  actor uuid,
  action text not null,
  target text,
  details jsonb not null default '{}'::jsonb
);
alter table public.admin_audit enable row level security;

-- Faqat ichki yozuvchi (SECURITY DEFINER funksiyalardan chaqiriladi).
create function public._audit(p_action text, p_target text, p_details jsonb default '{}'::jsonb)
returns void language sql security definer set search_path = '' as $$
  insert into public.admin_audit (actor, action, target, details)
  values (auth.uid(), p_action, p_target, coalesce(p_details, '{}'::jsonb));
$$;
revoke all on function public._audit(text, text, jsonb) from public, anon, authenticated;

-- Tasdiqlangan email allowlist'da bo'lsa admin beriladi; email o'zgarib
-- allowlist'dan chiqsa yoki tasdiq olib tashlansa — vakolat olinadi.
create function public._sync_admin_grant() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  eligible boolean := new.email_confirmed_at is not null
    and new.deleted_at is null
    and exists (select 1 from public.admin_allowlist a where a.email = lower(new.email));
begin
  if eligible then
    insert into public.app_admins (user_id, granted_reason)
    values (new.id, 'verified allowlisted email')
    on conflict (user_id) do nothing;
    if found then
      insert into public.admin_audit (actor, action, target, details)
      values (new.id, 'admin_granted', new.id::text,
              jsonb_build_object('reason', 'verified allowlisted email'));
    end if;
  else
    delete from public.app_admins where user_id = new.id;
    if found then
      insert into public.admin_audit (actor, action, target, details)
      values (new.id, 'admin_revoked', new.id::text,
              jsonb_build_object('reason', 'email not verified or not allowlisted'));
    end if;
  end if;
  return new;
end;
$$;
revoke all on function public._sync_admin_grant() from public, anon, authenticated;

create trigger labguide_sync_admin_grant
  after insert or update of email, email_confirmed_at, deleted_at on auth.users
  for each row execute function public._sync_admin_grant();

-- ------------------------------------------------------------ access checks
create function public.is_admin_account() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.app_admins a where a.user_id = auth.uid());
$$;

-- Admin amallari uchun: admin hisobi VA ikki bosqichli tasdiqlangan sessiya.
create function public.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select public.is_admin_account() and coalesce(auth.jwt() ->> 'aal', '') = 'aal2';
$$;

create function public.is_reviewer() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.app_reviewers r where r.user_id = auth.uid());
$$;

-- Ilova qaysi bo'limlarni ko'rsatishni shu javobdan biladi. Bu faqat
-- ko'rinish uchun: har bir admin/reviewer amali serverda qayta tekshiriladi.
create function public.my_access() returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'admin_account', public.is_admin_account(),
    'aal', coalesce(auth.jwt() ->> 'aal', 'aal1'),
    'admin', public.is_admin(),
    'reviewer', public.is_reviewer()
  );
$$;

-- Hisobli foydalanuvchi ilovani ochganda: profil (rol, til) va faollik kuni.
create function public.touch_profile(p_role text, p_language text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  today date := (now() at time zone 'Asia/Tashkent')::date;
begin
  if uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  insert into public.profiles (id, role, language, last_seen_on)
  values (uid, p_role, p_language, today)
  on conflict (id) do update
    set role = excluded.role,
        language = excluded.language,
        last_seen_on = today;
end;
$$;

revoke all on function public.is_admin_account(), public.is_admin(), public.is_reviewer(),
  public.my_access(), public.touch_profile(text, text) from public, anon;
grant execute on function public.is_admin_account(), public.is_admin(), public.is_reviewer(),
  public.my_access(), public.touch_profile(text, text) to authenticated;

-- Admin jurnalni o'qiydi (o'zgartirish/o'chirish siyosati yo'q).
create policy "audit: admins read" on public.admin_audit
  for select to authenticated using (public.is_admin());
