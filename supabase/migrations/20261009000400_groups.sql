-- Ustoz–talaba mini tizimi: guruh, taklif kodi, topshiriq, topshirish,
-- natija.
--
-- * Har qanday hisobli foydalanuvchi guruh ochishi mumkin va o'sha guruhda
--   ustoz bo'ladi. Ilovadagi “Ustoz” rolini tanlash hech qanday server
--   huquqi bermaydi (review vakolati alohida — app_reviewers).
-- * Talaba guruhga faqat taklif kodi bilan qo'shiladi.
-- * Topshiriq savollari ilova kontent paketidagi savol id lari; to'g'ri
--   javoblar kaliti alohida jadvalda — talabaga ko'rinmaydi, ball serverda
--   hisoblanadi.
-- * Guruh a'zolari faqat o'z guruhini, talaba faqat o'z natijasini, ustoz
--   o'z guruhidagi barcha natijalarni ko'radi.

create table public.study_groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 3 and 80),
  join_code text not null unique,
  created_at timestamptz not null default now(),
  archived boolean not null default false
);

create table public.group_members (
  group_id uuid not null references public.study_groups (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  member_role text not null check (member_role in ('teacher', 'student')),
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);
create index group_members_user on public.group_members (user_id);

create table public.assignments (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.study_groups (id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 3 and 120),
  question_ids text[] not null check (cardinality(question_ids) between 1 and 50),
  time_limit_minutes int check (time_limit_minutes between 1 and 180),
  due_at timestamptz,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now()
);
create index assignments_group on public.assignments (group_id, created_at desc);

-- Faqat ustoz o'qiydi; ballni server shu kalit bilan hisoblaydi.
create table public.assignment_keys (
  assignment_id uuid primary key references public.assignments (id) on delete cascade,
  correct_indexes int[] not null
);

create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid not null references public.assignments (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  answers int[] not null,
  score int not null,
  total int not null,
  submitted_at timestamptz not null default now(),
  unique (assignment_id, user_id)
);

alter table public.study_groups enable row level security;
alter table public.group_members enable row level security;
alter table public.assignments enable row level security;
alter table public.assignment_keys enable row level security;
alter table public.submissions enable row level security;

create function public._is_member(p_group uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.group_members m
                 where m.group_id = p_group and m.user_id = auth.uid());
$$;
create function public._is_teacher(p_group uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.group_members m
                 where m.group_id = p_group and m.user_id = auth.uid()
                   and m.member_role = 'teacher');
$$;
revoke all on function public._is_member(uuid), public._is_teacher(uuid) from public, anon;
grant execute on function public._is_member(uuid), public._is_teacher(uuid) to authenticated;

create policy "groups: members read" on public.study_groups
  for select to authenticated using (public._is_member(id));
create policy "members: same group read" on public.group_members
  for select to authenticated using (public._is_member(group_id));
create policy "assignments: members read" on public.assignments
  for select to authenticated using (public._is_member(group_id));
create policy "keys: teacher read" on public.assignment_keys
  for select to authenticated using (
    exists (select 1 from public.assignments a
            where a.id = assignment_id and public._is_teacher(a.group_id)));
create policy "submissions: own or teacher read" on public.submissions
  for select to authenticated using (
    user_id = auth.uid()
    or exists (select 1 from public.assignments a
               where a.id = assignment_id and public._is_teacher(a.group_id)));

create function public.create_group(p_name text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  gid uuid;
  code text;
begin
  if uid is null then
    raise exception 'not signed in' using errcode = '42501';
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
  insert into public.group_members (group_id, user_id, member_role)
  values (gid, uid, 'teacher');
  return jsonb_build_object('id', gid, 'join_code', code);
end;
$$;

create function public.join_group(p_code text) returns uuid
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
  if (select count(*) from public.group_members where group_id = gid) >= 200 then
    raise exception 'group full' using errcode = '54000';
  end if;
  insert into public.group_members (group_id, user_id, member_role)
  values (gid, uid, 'student')
  on conflict (group_id, user_id) do nothing;
  return gid;
end;
$$;

create function public.leave_group(p_group uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  delete from public.group_members
    where group_id = p_group and user_id = auth.uid() and member_role = 'student';
end;
$$;

create function public.create_assignment(
  p_group uuid, p_title text, p_question_ids text[], p_correct int[],
  p_due timestamptz default null, p_time_limit int default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  aid uuid;
begin
  if not public._is_teacher(p_group) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if cardinality(p_question_ids) <> cardinality(p_correct) then
    raise exception 'key length mismatch' using errcode = '22023';
  end if;
  insert into public.assignments (group_id, title, question_ids, due_at, time_limit_minutes, created_by)
  values (p_group, btrim(p_title), p_question_ids, p_due, p_time_limit, auth.uid())
  returning id into aid;
  insert into public.assignment_keys (assignment_id, correct_indexes) values (aid, p_correct);
  return aid;
end;
$$;

-- Talaba javoblarini yuboradi; ball serverda kalit bilan hisoblanadi.
-- Bitta topshiriqqa bir marta; muddat o'tgan bo'lsa qabul qilinmaydi.
create function public.submit_assignment(p_assignment uuid, p_answers int[]) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  a public.assignments;
  k int[];
  s int := 0;
  i int;
begin
  select * into a from public.assignments where id = p_assignment;
  if not found or not exists (
    select 1 from public.group_members m
    where m.group_id = a.group_id and m.user_id = auth.uid() and m.member_role = 'student'
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if a.due_at is not null and now() > a.due_at then
    raise exception 'past due' using errcode = '22023';
  end if;
  select correct_indexes into k from public.assignment_keys where assignment_id = p_assignment;
  if cardinality(p_answers) <> cardinality(k) then
    raise exception 'answer count mismatch' using errcode = '22023';
  end if;
  for i in 1 .. cardinality(k) loop
    if p_answers[i] = k[i] then
      s := s + 1;
    end if;
  end loop;
  insert into public.submissions (assignment_id, user_id, answers, score, total)
  values (p_assignment, auth.uid(), p_answers, s, cardinality(k));
  return jsonb_build_object('score', s, 'total', cardinality(k));
exception when unique_violation then
  raise exception 'already submitted' using errcode = '23505';
end;
$$;

revoke all on function
  public.create_group(text), public.join_group(text), public.leave_group(uuid),
  public.create_assignment(uuid, text, text[], int[], timestamptz, int),
  public.submit_assignment(uuid, int[])
  from public, anon;
grant execute on function
  public.create_group(text), public.join_group(text), public.leave_group(uuid),
  public.create_assignment(uuid, text, text[], int[], timestamptz, int),
  public.submit_assignment(uuid, int[])
  to authenticated;
