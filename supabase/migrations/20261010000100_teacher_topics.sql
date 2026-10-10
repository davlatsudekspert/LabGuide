-- Ustoz roli, taxallus/tartib raqam va o'quv dasturi mavzulari
-- (egasi qarori 2026-10-10, docs/DECISIONS.md “Ustoz va mavzular”).
--
-- * Ustoz: email (OTP) bilan kirgan hisob o'zini ustoz sifatida
--   ro'yxatdan o'tkazadi (`register_teacher`). Bu faqat guruh ochish
--   huquqini beradi; ustoz huquqi faqat o'zi yaratgan guruhlarga tegishli.
--   Ustoz admin EMAS — admin vakolati (`app_admins`) o'zgarmaydi va faqat
--   serverda beriladi.
-- * Ism-familiya serverda saqlanmaydi: guruhda ko'rinadigan nom — talaba
--   o'zi tanlagan taxallus (ixtiyoriy) yoki tartib raqami (“Talaba 07”).
--   `display_name` endi ixtiyoriy taxallus; `seat_no` — guruhdagi tartib
--   raqami (qayta ishlatilmaydi).
-- * Talaba endi boshqa talabalarni ko'rmaydi: a'zolar ro'yxati — faqat
--   o'z qatori, guruh ustozi qatori va (ustozga) hamma.
-- * Mavzu: ustoz o'quv dasturidagi mavzuni guruhga “ochadi”
--   (`group_topics`), dars bosqichlarini belgilaydi (ma'ruza, savol-javob)
--   va mavzu testini boshlaydi/yakunlaydi. Test — oddiy topshiriq
--   (`assignments.topic_id`), ball va har savol natijasi serverda.
--
-- Mavjud migratsiyalar o'zgartirilmaydi; funksiyalar `create or replace`
-- bilan yangilanadi (imzo va huquqlar o'sha-o'sha).

-- ------------------------------------------------------------ ustoz hisobi
create table public.teacher_accounts (
  user_id uuid primary key references auth.users (id) on delete cascade,
  registered_at timestamptz not null default now()
);
alter table public.teacher_accounts enable row level security;
create policy "teachers: own row" on public.teacher_accounts
  for select to authenticated using (user_id = auth.uid());
revoke all on public.teacher_accounts from anon, authenticated;
grant select on public.teacher_accounts to authenticated;

create function public.is_teacher_account() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.teacher_accounts t where t.user_id = auth.uid());
$$;

-- O'zini ustoz sifatida ro'yxatdan o'tkazish: faqat emaili kod bilan
-- tasdiqlangan (anonim bo'lmagan) hisob. Admin vakolatiga ta'sir qilmaydi.
create function public.register_teacher() returns void
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null or not exists (
    select 1 from auth.users u
    where u.id = uid and u.email_confirmed_at is not null
      and u.deleted_at is null and not u.is_anonymous
  ) then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  insert into public.teacher_accounts (user_id) values (uid)
  on conflict (user_id) do nothing;
end;
$$;

-- Guruh egasi va ro'yxatdan o'tgan ustoz (o'z guruhi).
create function public._owns_group(p_group uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.study_groups g
    join public.teacher_accounts t on t.user_id = g.owner_id
    where g.id = p_group and g.owner_id = auth.uid());
$$;
revoke all on function public._owns_group(uuid) from public, anon, authenticated;

-- Ilova ko'rinishi uchun: `teacher` qo'shildi (admin/reviewer o'sha-o'sha).
create or replace function public.my_access() returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'admin_account', public.is_admin_account(),
    'aal', coalesce(auth.jwt() ->> 'aal', 'aal1'),
    'admin', public.is_admin(),
    'reviewer', public.is_reviewer(),
    'teacher', public.is_teacher_account()
  );
$$;

-- -------------------------------------------- a'zolar: taxallus va raqam
alter table public.study_groups add column next_seat int not null default 1;
alter table public.group_members alter column display_name drop not null;
alter table public.group_members add column seat_no int;
alter table public.group_members
  add constraint group_members_seat_unique unique (group_id, seat_no);

-- Avvalgi talabalarga qo'shilish tartibida raqam.
with numbered as (
  select group_id, user_id,
         row_number() over (partition by group_id order by joined_at, user_id) as n
  from public.group_members where member_role = 'student')
update public.group_members m set seat_no = n.n
  from numbered n where m.group_id = n.group_id and m.user_id = n.user_id;
update public.study_groups g set next_seat = 1 + coalesce(
  (select max(seat_no) from public.group_members m where m.group_id = g.id), 0);

-- Talabaga tartib raqami (guruh qatori bloklanadi — raqam takrorlanmaydi).
create function public._assign_seat() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.member_role = 'student' then
    update public.study_groups set next_seat = next_seat + 1
      where id = new.group_id
      returning next_seat - 1 into new.seat_no;
  else
    new.seat_no := null;
  end if;
  return new;
end;
$$;
revoke all on function public._assign_seat() from public, anon, authenticated;
create trigger labguide_assign_seat
  before insert on public.group_members
  for each row execute function public._assign_seat();

drop policy "members: same group read" on public.group_members;
create policy "members: own, teacher row, or teacher reads all" on public.group_members
  for select to authenticated using (
    user_id = auth.uid()
    or public._is_teacher(group_id)
    or (member_role = 'teacher' and public._is_member(group_id)));

-- Guruh: faqat ro'yxatdan o'tgan ustoz ochadi; ustoz nomi ixtiyoriy.
create or replace function public.create_group(p_name text, p_display_name text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  gid uuid;
  code text;
begin
  if uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if not public.is_teacher_account() then
    raise exception 'not a teacher' using errcode = '42501';
  end if;
  if (select count(*) from public.study_groups where owner_id = uid and not archived) >= 10 then
    raise exception 'rate limited: groups' using errcode = '54000';
  end if;
  loop
    -- 8 belgi, adashtiradigan 0/O/1/I siz.
    code := (
      select string_agg(substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789',
                               1 + floor(random() * 32)::int, 1), '')
      from generate_series(1, 8));
    exit when not exists (select 1 from public.study_groups where join_code = code);
  end loop;
  insert into public.study_groups (owner_id, name, join_code)
  values (uid, btrim(p_name), code) returning id into gid;
  insert into public.group_members (group_id, user_id, member_role, display_name)
  values (gid, uid, 'teacher', nullif(btrim(coalesce(p_display_name, '')), ''));
  return jsonb_build_object('id', gid, 'join_code', code);
end;
$$;

-- Talaba: kod bilan; taxallus ixtiyoriy (bo'lmasa — tartib raqami).
create or replace function public.join_group(p_code text, p_display_name text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  gid uuid;
begin
  if uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  select id into gid from public.study_groups
    where join_code = upper(btrim(p_code)) and not archived;
  if gid is null then
    raise exception 'invalid code' using errcode = 'P0002';
  end if;
  if exists (select 1 from public.group_members
             where group_id = gid and user_id = uid) then
    return gid;
  end if;
  if (select count(*) from public.group_members where group_id = gid) >= 200 then
    raise exception 'group full' using errcode = '54000';
  end if;
  insert into public.group_members (group_id, user_id, member_role, display_name)
  values (gid, uid, 'student', nullif(btrim(coalesce(p_display_name, '')), ''))
  on conflict (group_id, user_id) do nothing;
  return gid;
end;
$$;

-- O'z taxallusini o'zgartirish (bo'sh — tartib raqami ko'rinadi).
create function public.set_member_alias(p_group uuid, p_alias text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  update public.group_members
    set display_name = nullif(btrim(coalesce(p_alias, '')), '')
    where group_id = p_group and user_id = auth.uid();
  if not found then
    raise exception 'forbidden' using errcode = '42501';
  end if;
end;
$$;

-- ------------------------------------------------------------- mavzular
alter table public.assignments add column topic_id text;

create table public.group_topics (
  group_id uuid not null references public.study_groups (id) on delete cascade,
  -- curriculum.json dagi mavzu id si (ilova kontenti; server matn saqlamaydi).
  topic_id text not null check (topic_id ~ '^[A-Za-z0-9][A-Za-z0-9_.:-]{0,79}$'),
  opened_at timestamptz not null default now(),
  lecture_done_at timestamptz,
  oral_done_at timestamptz,
  test_assignment_id uuid references public.assignments (id) on delete set null,
  primary key (group_id, topic_id)
);
alter table public.group_topics enable row level security;
create policy "topics: members read" on public.group_topics
  for select to authenticated using (public._is_member(group_id));
revoke all on public.group_topics from anon, authenticated;
grant select on public.group_topics to authenticated;

-- Ustoz mavzuni guruhga ochadi (qayta chaqirilsa — o'zgarmaydi).
create function public.open_topic(p_group uuid, p_topic text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not public._owns_group(p_group) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_topic is null or p_topic !~ '^[A-Za-z0-9][A-Za-z0-9_.:-]{0,79}$' then
    raise exception 'bad topic' using errcode = '22023';
  end if;
  if (select count(*) from public.group_topics where group_id = p_group) >= 300 then
    raise exception 'rate limited: topics' using errcode = '54000';
  end if;
  insert into public.group_topics (group_id, topic_id) values (p_group, p_topic)
  on conflict do nothing;
end;
$$;

-- Dars bosqichi o'tildi: 'lecture' (ma'ruza) yoki 'oral' (savol-javob).
create function public.mark_topic_stage(p_group uuid, p_topic text, p_stage text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if p_stage not in ('lecture', 'oral') then
    raise exception 'bad stage' using errcode = '22023';
  end if;
  perform public.open_topic(p_group, p_topic);
  update public.group_topics set
    lecture_done_at = case when p_stage = 'lecture'
                           then coalesce(lecture_done_at, now()) else lecture_done_at end,
    oral_done_at = case when p_stage = 'oral'
                        then coalesce(oral_done_at, now()) else oral_done_at end
    where group_id = p_group and topic_id = p_topic;
end;
$$;

-- “Testni boshlash”: shu mavzu bo'yicha topshiriq yaratiladi va talabalarda
-- ochiladi. Bitta mavzuga bitta test.
create function public.start_topic_test(
  p_group uuid, p_topic text, p_title text, p_question_ids text[], p_correct int[],
  p_time_limit int default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  aid uuid;
begin
  if not public._owns_group(p_group) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  perform public.open_topic(p_group, p_topic);
  if (select test_assignment_id from public.group_topics
      where group_id = p_group and topic_id = p_topic) is not null then
    raise exception 'test already started' using errcode = '23505';
  end if;
  aid := public.create_assignment(p_group, p_title, p_question_ids, p_correct,
                                  null, p_time_limit);
  update public.assignments set topic_id = p_topic where id = aid;
  update public.group_topics set test_assignment_id = aid
    where group_id = p_group and topic_id = p_topic;
  return aid;
end;
$$;

-- Testni yakunlash: shu daqiqadan yangi urinish yo'q (boshlaganlar uchun
-- submit_assignment dagi qisqa qo'shimcha vaqt qoladi).
create function public.finish_topic_test(p_group uuid, p_topic text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  aid uuid;
begin
  if not public._owns_group(p_group) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select test_assignment_id into aid from public.group_topics
    where group_id = p_group and topic_id = p_topic;
  if aid is null then
    raise exception 'no test' using errcode = 'P0002';
  end if;
  update public.assignments set due_at = now()
    where id = aid and (due_at is null or due_at > now());
end;
$$;

revoke all on function
  public.is_teacher_account(), public.register_teacher(),
  public.set_member_alias(uuid, text), public.open_topic(uuid, text),
  public.mark_topic_stage(uuid, text, text),
  public.start_topic_test(uuid, text, text, text[], int[], int),
  public.finish_topic_test(uuid, text)
  from public, anon;
grant execute on function
  public.is_teacher_account(), public.register_teacher(),
  public.set_member_alias(uuid, text), public.open_topic(uuid, text),
  public.mark_topic_stage(uuid, text, text),
  public.start_topic_test(uuid, text, text, text[], int[], int),
  public.finish_topic_test(uuid, text)
  to authenticated;
