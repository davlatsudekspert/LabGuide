-- Guruhlar, 2-bosqich (ilovadagi “Guruh va topshiriqlar” bo'limi uchun):
--
-- * Vaqt chegarasi serverda: talaba topshiriqni `start_assignment` bilan
--   boshlaydi (boshlanish vaqti bir marta yoziladi, qayta chaqirilsa o'sha
--   vaqt qaytadi); `submit_assignment` vaqt chegarasi + 2 daqiqa (tarmoq
--   kechikishi) dan keyin javob qabul qilmaydi.
-- * Har savol natijasi (`submissions.correct`) serverda hisoblanadi:
--   talaba o'z xatolarini, ustoz kim qaysi savolda xato qilganini ko'radi.
--   Kalitning o'zi baribir faqat ustozga ochiq.
-- * Ustoz talabani guruhdan chiqara oladi (o'zini va boshqa ustozni emas).
-- * Topshiriq yaratishda muddat kelajakda va kalit indekslari manfiy emas.
--
-- Mavjud migratsiyalar o'zgartirilmaydi; funksiyalar `create or replace`
-- bilan yangilanadi (imzo va huquqlar o'sha-o'sha).

create table public.assignment_attempts (
  assignment_id uuid not null references public.assignments (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  started_at timestamptz not null default now(),
  primary key (assignment_id, user_id)
);
alter table public.assignment_attempts enable row level security;
create policy "attempts: own or teacher read" on public.assignment_attempts
  for select to authenticated using (
    user_id = auth.uid()
    or exists (select 1 from public.assignments a
               where a.id = assignment_id and public._is_teacher(a.group_id)));
revoke all on public.assignment_attempts from anon, authenticated;
grant select on public.assignment_attempts to authenticated;

alter table public.submissions add column correct boolean[];
-- Avvalgi topshiriqlar uchun ham hisoblab qo'yiladi.
update public.submissions s
  set correct = (
    select array_agg(s.answers[i] is not distinct from k.correct_indexes[i] order by i)
    from public.assignment_keys k,
         generate_subscripts(k.correct_indexes, 1) as i
    where k.assignment_id = s.assignment_id)
  where s.correct is null;

-- Talaba: guruh a'zosi (talaba roli), muddat o'tmagan.
create function public.start_assignment(p_assignment uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  a public.assignments;
  st timestamptz;
begin
  select * into a from public.assignments where id = p_assignment;
  if not found or not exists (
    select 1 from public.group_members m
    where m.group_id = a.group_id and m.user_id = auth.uid() and m.member_role = 'student'
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select started_at into st from public.assignment_attempts
    where assignment_id = p_assignment and user_id = auth.uid();
  if st is null then
    if a.due_at is not null and now() > a.due_at then
      raise exception 'past due' using errcode = '22023';
    end if;
    insert into public.assignment_attempts (assignment_id, user_id)
    values (p_assignment, auth.uid())
    on conflict do nothing;
    select started_at into st from public.assignment_attempts
      where assignment_id = p_assignment and user_id = auth.uid();
  end if;
  return jsonb_build_object(
    'started_at', st,
    'server_now', now(),
    'time_limit_minutes', a.time_limit_minutes,
    'due_at', a.due_at);
end;
$$;

create or replace function public.submit_assignment(p_assignment uuid, p_answers int[]) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  a public.assignments;
  k int[];
  st timestamptz;
  s int := 0;
  c boolean[] := '{}';
  i int;
  grace constant interval := interval '2 minutes';
begin
  select * into a from public.assignments where id = p_assignment;
  if not found or not exists (
    select 1 from public.group_members m
    where m.group_id = a.group_id and m.user_id = auth.uid() and m.member_role = 'student'
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select started_at into st from public.assignment_attempts
    where assignment_id = p_assignment and user_id = auth.uid();
  -- Muddatdan oldin boshlagan talabaga tarmoq uchun qisqa qo'shimcha vaqt.
  if a.due_at is not null and now() > a.due_at
       + (case when st is not null and st <= a.due_at then grace else interval '0' end) then
    raise exception 'past due' using errcode = '22023';
  end if;
  if a.time_limit_minutes is not null and (
       st is null or now() > st + make_interval(mins => a.time_limit_minutes) + grace) then
    raise exception 'time over' using errcode = '22023';
  end if;
  select correct_indexes into k from public.assignment_keys where assignment_id = p_assignment;
  if cardinality(p_answers) <> cardinality(k) then
    raise exception 'answer count mismatch' using errcode = '22023';
  end if;
  for i in 1 .. cardinality(k) loop
    c := c || (p_answers[i] is not distinct from k[i]);
    if p_answers[i] = k[i] then
      s := s + 1;
    end if;
  end loop;
  insert into public.submissions (assignment_id, user_id, answers, score, total, correct)
  values (p_assignment, auth.uid(), p_answers, s, cardinality(k), c);
  return jsonb_build_object('score', s, 'total', cardinality(k), 'correct', to_jsonb(c));
exception when unique_violation then
  raise exception 'already submitted' using errcode = '23505';
end;
$$;

create or replace function public.create_assignment(
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
  if exists (select 1 from unnest(p_correct) x where x is null or x < 0)
     or exists (select 1 from unnest(p_question_ids) q where q is null or btrim(q) = '') then
    raise exception 'bad key' using errcode = '22023';
  end if;
  if p_due is not null and p_due <= now() then
    raise exception 'due in the past' using errcode = '22023';
  end if;
  insert into public.assignments (group_id, title, question_ids, due_at, time_limit_minutes, created_by)
  values (p_group, btrim(p_title), p_question_ids, p_due, p_time_limit, auth.uid())
  returning id into aid;
  insert into public.assignment_keys (assignment_id, correct_indexes) values (aid, p_correct);
  return aid;
end;
$$;

-- Ustoz talabani chiqaradi (leave_group kabi: topshirgan natijasi
-- o'chmaydi, qayta qo'shilsa ham ikkinchi marta topshira olmaydi).
create function public.remove_member(p_group uuid, p_user uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not public._is_teacher(p_group) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  delete from public.group_members
    where group_id = p_group and user_id = p_user and member_role = 'student';
end;
$$;

revoke all on function
  public.start_assignment(uuid), public.remove_member(uuid, uuid)
  from public, anon;
grant execute on function
  public.start_assignment(uuid), public.remove_member(uuid, uuid)
  to authenticated;
