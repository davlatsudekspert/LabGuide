-- Guruhlar, 2-bosqich: vaqt chegarasi serverda, har savol natijasi,
-- a'zoni chiqarish. 10_acceptance.sql dan keyin ishlaydi (t.login, t.vars).
--
-- Hisoblar: ustoz T, talabalar S1 va S2, begona X.

insert into auth.users (id, email, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000c1', 'teacher@test.local', now()),
  ('00000000-0000-0000-0000-0000000000c2', 'student1@test.local', now()),
  ('00000000-0000-0000-0000-0000000000c3', 'student2@test.local', now()),
  ('00000000-0000-0000-0000-0000000000c4', 'outsider@test.local', now());

-- 10_acceptance dagi topshiriq: har savol natijasi ham saqlangan.
do $$ begin
  assert (select correct from public.submissions
          where user_id = '00000000-0000-0000-0000-0000000000b1')
         = array[true, false, true], 'per-question result stored';
end $$;

set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000c1');
insert into t.vars select 'g2_code', public.create_group('Klinik biokimyo', 'Karimova N.') ->> 'join_code';
insert into t.vars select 'g2', id::text from public.study_groups where name = 'Klinik biokimyo';
select t.login('00000000-0000-0000-0000-0000000000c2');
select public.join_group((select v from t.vars where k = 'g2_code'), 'Aliyev A.');
select t.login('00000000-0000-0000-0000-0000000000c3');
select public.join_group((select v from t.vars where k = 'g2_code'), 'Valiyeva B.');

-- Ustoz: muddat o'tmishda yoki kalit manfiy bo'lsa — rad.
select t.login('00000000-0000-0000-0000-0000000000c1');
do $$ begin
  perform public.create_assignment((select v::uuid from t.vars where k = 'g2'),
    'Eski muddat', array['q1'], array[0], now() - interval '1 hour');
  raise exception 'past due date accepted';
exception when invalid_parameter_value then null;
end $$;
do $$ begin
  perform public.create_assignment((select v::uuid from t.vars where k = 'g2'),
    'Manfiy kalit', array['q1'], array[-1]);
  raise exception 'negative key accepted';
exception when invalid_parameter_value then null;
end $$;
insert into t.vars select 'a_timed', public.create_assignment(
  (select v::uuid from t.vars where k = 'g2'), 'Vaqtli: buyrak',
  array['urea-1', 'creatinine-1', 'egfr-1'], array[2, 0, 1], null, 10)::text;
insert into t.vars select 'a_due', public.create_assignment(
  (select v::uuid from t.vars where k = 'g2'), 'Muddatli: jigar',
  array['alt-1'], array[1], now() + interval '1 hour', null)::text;
do $$ begin
  -- Ustoz topshiriqni o'zi yecha olmaydi.
  perform public.start_assignment((select v::uuid from t.vars where k = 'a_timed'));
  raise exception 'teacher started an assignment';
exception when insufficient_privilege then null;
end $$;

-- S1: boshlamasdan vaqtli topshiriqni topshira olmaydi.
select t.login('00000000-0000-0000-0000-0000000000c2');
do $$ begin
  perform public.submit_assignment((select v::uuid from t.vars where k = 'a_timed'),
                                   array[2, 0, 1]);
  raise exception 'timed submit without start accepted';
exception when invalid_parameter_value then null;
end $$;
insert into t.vars select 's1_start',
  public.start_assignment((select v::uuid from t.vars where k = 'a_timed')) ->> 'started_at';
do $$
declare r jsonb;
begin
  -- Qayta boshlash vaqtni yangilamaydi.
  r := public.start_assignment((select v::uuid from t.vars where k = 'a_timed'));
  assert r ->> 'started_at' = (select v from t.vars where k = 's1_start'), 'start is idempotent';
  assert (r ->> 'time_limit_minutes')::int = 10, 'limit returned';
  assert (select count(*) from public.assignment_attempts) = 1, 'student sees own attempt only';
  assert (select count(*) from public.assignment_keys) = 0, 'student still has no key';
  r := public.submit_assignment((select v::uuid from t.vars where k = 'a_timed'),
                                array[2, -1, 0]);
  assert (r ->> 'score')::int = 1 and (r ->> 'total')::int = 3, 'score: ' || r::text;
  assert r -> 'correct' = '[true, false, false]'::jsonb, 'correct: ' || r::text;
  assert (select correct from public.submissions
          where assignment_id = (select v::uuid from t.vars where k = 'a_timed'))
         = array[true, false, false], 'own per-question result readable';
end $$;

-- S2: vaqt chegarasi (10 daq + 2 daq) o'tgach — rad.
select t.login('00000000-0000-0000-0000-0000000000c3');
select public.start_assignment((select v::uuid from t.vars where k = 'a_timed'));
reset role;
update public.assignment_attempts set started_at = now() - interval '13 minutes'
  where user_id = '00000000-0000-0000-0000-0000000000c3';
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000c3');
do $$ begin
  assert (select count(*) from public.submissions) = 0, 'S2 does not see S1 result';
  perform public.submit_assignment((select v::uuid from t.vars where k = 'a_timed'),
                                   array[2, 0, 1]);
  raise exception 'submit after time limit accepted';
exception when invalid_parameter_value then null;
end $$;
-- Chegaradan oldin (11 daqiqa — 2 daqiqalik qo'shimcha vaqt ichida) — qabul.
reset role;
update public.assignment_attempts set started_at = now() - interval '11 minutes'
  where user_id = '00000000-0000-0000-0000-0000000000c3';
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000c3');
do $$
declare r jsonb;
begin
  r := public.submit_assignment((select v::uuid from t.vars where k = 'a_timed'),
                                array[2, 0, 1]);
  assert (r ->> 'score')::int = 3, 'within grace: ' || r::text;
end $$;

-- Muddat o'tgan topshiriqni boshlab bo'lmaydi.
reset role;
update public.assignments set due_at = now() - interval '1 minute'
  where id = (select v::uuid from t.vars where k = 'a_due');
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000c2');
do $$ begin
  perform public.start_assignment((select v::uuid from t.vars where k = 'a_due'));
  raise exception 'started after due';
exception when invalid_parameter_value then null;
end $$;

-- Begona X: hech narsa ko'rmaydi va boshlay olmaydi.
select t.login('00000000-0000-0000-0000-0000000000c4');
do $$ begin
  assert (select count(*) from public.study_groups) = 0, 'outsider sees no group';
  assert (select count(*) from public.assignments) = 0, 'outsider sees no assignment';
  assert (select count(*) from public.assignment_attempts) = 0, 'outsider sees no attempt';
  assert (select count(*) from public.submissions) = 0, 'outsider sees no submission';
  perform public.start_assignment((select v::uuid from t.vars where k = 'a_timed'));
  raise exception 'outsider started an assignment';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.remove_member((select v::uuid from t.vars where k = 'g2'),
                               '00000000-0000-0000-0000-0000000000c2');
  raise exception 'outsider removed a member';
exception when insufficient_privilege then null;
end $$;

-- Talaba boshqa talabani chiqara olmaydi.
select t.login('00000000-0000-0000-0000-0000000000c2');
do $$ begin
  perform public.remove_member((select v::uuid from t.vars where k = 'g2'),
                               '00000000-0000-0000-0000-0000000000c3');
  raise exception 'student removed a member';
exception when insufficient_privilege then null;
end $$;

-- Ustoz: hamma urinish va natijalarni ko'radi; talabani chiqaradi, o'zini emas.
select t.login('00000000-0000-0000-0000-0000000000c1');
do $$ begin
  assert (select count(*) from public.assignment_attempts) = 2, 'teacher sees attempts';
  assert (select count(*) from public.submissions
          where assignment_id = (select v::uuid from t.vars where k = 'a_timed')) = 2,
    'teacher sees both results';
  assert (select count(*) from public.group_members
          where group_id = (select v::uuid from t.vars where k = 'g2')) = 3, 'three members';
end $$;
select public.remove_member((select v::uuid from t.vars where k = 'g2'),
                            '00000000-0000-0000-0000-0000000000c3');
select public.remove_member((select v::uuid from t.vars where k = 'g2'),
                            '00000000-0000-0000-0000-0000000000c1');
do $$ begin
  assert (select count(*) from public.group_members
          where group_id = (select v::uuid from t.vars where k = 'g2')) = 2,
    'student removed, teacher stays';
  assert exists (select 1 from public.group_members
                 where user_id = '00000000-0000-0000-0000-0000000000c1'
                   and member_role = 'teacher'), 'teacher cannot remove self';
end $$;

-- Chiqarilgan S2 guruhni endi ko'rmaydi.
select t.login('00000000-0000-0000-0000-0000000000c3');
do $$ begin
  assert (select count(*) from public.study_groups) = 0, 'removed student sees no group';
  assert (select count(*) from public.assignments) = 0, 'removed student sees no assignment';
end $$;
reset role;

-- anon yangi jadval va funksiyalarga ham kira olmaydi.
set role anon;
do $$ begin
  perform count(*) from public.assignment_attempts;
  raise exception 'anon read attempts';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.start_assignment(gen_random_uuid());
  raise exception 'anon started an assignment';
exception when insufficient_privilege then null;
end $$;
reset role;

select 'groups classroom: all checks passed' as result;
