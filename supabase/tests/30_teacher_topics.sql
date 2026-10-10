-- Ustoz roli, taxallus/tartib raqam, mavzu ochish va mavzu testi
-- (20261010000100_teacher_topics.sql). 10_acceptance.sql dan keyin
-- ishlaydi (t.login, t.vars, admin hisobi ad01).
--
-- Hisoblar: ustoz T, ikkinchi ustoz T2 (begona guruh), talabalar S1 va S2,
-- kod tasdiqlanmagan U.

insert into auth.users (id, email, email_confirmed_at) values
  ('00000000-0000-0000-0000-0000000000d1', 'teacher-t@test.local', now()),
  ('00000000-0000-0000-0000-0000000000d2', 'teacher-t2@test.local', now()),
  ('00000000-0000-0000-0000-0000000000d3', 'student-s1@test.local', now()),
  ('00000000-0000-0000-0000-0000000000d4', 'student-s2@test.local', now());
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000d5', 'unconfirmed@test.local');

set role authenticated;

-- ------------------------------------------------ ustoz sifatida ro'yxat
select t.login('00000000-0000-0000-0000-0000000000d5');
do $$ begin
  perform public.register_teacher();
  raise exception 'unconfirmed email registered as teacher';
exception when insufficient_privilege then null;
end $$;

select t.login('00000000-0000-0000-0000-0000000000d1');
do $$ begin
  assert not (public.my_access() ->> 'teacher')::boolean, 'not a teacher yet';
  perform public.create_group('Ro''yxatsiz', null);
  raise exception 'group without teacher registration';
exception when insufficient_privilege then null;
end $$;
select public.register_teacher();
select public.register_teacher(); -- qayta chaqirish xato emas
do $$ begin
  assert (public.my_access() ->> 'teacher')::boolean, 'teacher flag';
  -- Ustoz admin emas: admin vakolati o'zgarmaydi.
  assert not (public.my_access() ->> 'admin_account')::boolean, 'teacher is not admin';
  assert not (public.my_access() ->> 'admin')::boolean, 'teacher is not admin (aal)';
  assert (select count(*) from public.teacher_accounts) = 1, 'own teacher row';
end $$;
insert into t.vars select 'tg_code', public.create_group('KLD ixtisoslashtirish', null) ->> 'join_code';
insert into t.vars select 'tg', id::text from public.study_groups
  where name = 'KLD ixtisoslashtirish';
do $$ begin
  assert char_length((select v from t.vars where k = 'tg_code')) between 6 and 8, 'code length';
  assert (select display_name from public.group_members
          where user_id = '00000000-0000-0000-0000-0000000000d1') is null,
    'teacher name not required';
end $$;

select t.login('00000000-0000-0000-0000-0000000000d2');
select public.register_teacher();
do $$ begin
  assert (select count(*) from public.teacher_accounts) = 1, 'T2 sees only own teacher row';
  assert (select count(*) from public.study_groups) = 0, 'T2 sees no foreign group';
end $$;

-- ------------------------------------- talabalar: taxallus yoki raqam
select t.login('00000000-0000-0000-0000-0000000000d3');
select public.join_group((select v from t.vars where k = 'tg_code'), null);
select public.join_group((select v from t.vars where k = 'tg_code'), 'Boshqa'); -- qayta: o'zgarmaydi
select t.login('00000000-0000-0000-0000-0000000000d4');
select public.join_group((select v from t.vars where k = 'tg_code'), '  Yulduz  ');
do $$ begin
  assert (select seat_no from public.group_members
          where user_id = '00000000-0000-0000-0000-0000000000d4') = 2, 'S2 seat 2';
  assert (select display_name from public.group_members
          where user_id = '00000000-0000-0000-0000-0000000000d4') = 'Yulduz', 'alias trimmed';
  -- Talaba boshqa talabani ko'rmaydi: o'z qatori + ustoz qatori.
  assert (select count(*) from public.group_members) = 2, 'student sees self and teacher only';
  assert not exists (select 1 from public.group_members
                     where user_id = '00000000-0000-0000-0000-0000000000d3'),
    'student does not see other student';
end $$;
select public.set_member_alias((select v::uuid from t.vars where k = 'tg'), '');
do $$ begin
  assert (select display_name from public.group_members
          where user_id = '00000000-0000-0000-0000-0000000000d4') is null, 'alias cleared';
end $$;

select t.login('00000000-0000-0000-0000-0000000000d1');
do $$ begin
  assert (select count(*) from public.group_members
          where group_id = (select v::uuid from t.vars where k = 'tg')) = 3, 'teacher sees all';
  assert (select seat_no from public.group_members
          where user_id = '00000000-0000-0000-0000-0000000000d3') = 1, 'S1 seat 1';
  assert (select display_name from public.group_members
          where user_id = '00000000-0000-0000-0000-0000000000d3') is null, 'S1 no alias';
  assert (select seat_no from public.group_members
          where user_id = '00000000-0000-0000-0000-0000000000d1') is null, 'teacher has no seat';
end $$;
-- Chiqib qayta qo'shilgan talaba yangi raqam oladi (raqam qayta ishlatilmaydi).
select t.login('00000000-0000-0000-0000-0000000000d4');
select public.leave_group((select v::uuid from t.vars where k = 'tg'));
select public.join_group((select v from t.vars where k = 'tg_code'), null);
do $$ begin
  assert (select seat_no from public.group_members
          where user_id = '00000000-0000-0000-0000-0000000000d4') = 3, 'seat not reused';
end $$;

-- Begona guruhda taxallus o'zgartirib bo'lmaydi.
select t.login('00000000-0000-0000-0000-0000000000d2');
do $$ begin
  perform public.set_member_alias((select v::uuid from t.vars where k = 'tg'), 'X');
  raise exception 'alias set in foreign group';
exception when insufficient_privilege then null;
end $$;

-- ------------------------------------------------------- mavzu ochish
-- Talaba ham, begona ustoz ham mavzu ocha/test boshlay olmaydi.
select t.login('00000000-0000-0000-0000-0000000000d3');
do $$ begin
  perform public.open_topic((select v::uuid from t.vars where k = 'tg'), 'd001-P');
  raise exception 'student opened a topic';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  insert into public.group_topics (group_id, topic_id)
  values ((select v::uuid from t.vars where k = 'tg'), 'd001-P');
  raise exception 'student wrote group_topics directly';
exception when insufficient_privilege then null;
end $$;
select t.login('00000000-0000-0000-0000-0000000000d2');
do $$ begin
  perform public.open_topic((select v::uuid from t.vars where k = 'tg'), 'd001-P');
  raise exception 'foreign teacher opened a topic';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.start_topic_test((select v::uuid from t.vars where k = 'tg'), 'd001-P',
    'Begona test', array['q1'], array[0], 10);
  raise exception 'foreign teacher started a test';
exception when insufficient_privilege then null;
end $$;

select t.login('00000000-0000-0000-0000-0000000000d1');
do $$ begin
  perform public.open_topic((select v::uuid from t.vars where k = 'tg'), 'bad topic; drop');
  raise exception 'bad topic id accepted';
exception when invalid_parameter_value then null;
end $$;
do $$ begin
  perform public.mark_topic_stage((select v::uuid from t.vars where k = 'tg'), 'd001-P', 'test');
  raise exception 'bad stage accepted';
exception when invalid_parameter_value then null;
end $$;
select public.open_topic((select v::uuid from t.vars where k = 'tg'), 'd001-P');
select public.open_topic((select v::uuid from t.vars where k = 'tg'), 'd001-P');
select public.mark_topic_stage((select v::uuid from t.vars where k = 'tg'), 'd001-P', 'lecture');
select public.mark_topic_stage((select v::uuid from t.vars where k = 'tg'), 'd001-P', 'oral');
insert into t.vars select 'tt', public.start_topic_test(
  (select v::uuid from t.vars where k = 'tg'), 'd001-P', '1-kun testi',
  array['kdl-t-004', 'kdl-t-011', 'urea-1'], array[1, 0, 2], 15)::text;
do $$
declare r public.group_topics;
begin
  select * into r from public.group_topics where topic_id = 'd001-P';
  assert r.lecture_done_at is not null and r.oral_done_at is not null, 'stages marked';
  assert r.test_assignment_id = (select v::uuid from t.vars where k = 'tt'), 'test linked';
  assert (select topic_id from public.assignments
          where id = (select v::uuid from t.vars where k = 'tt')) = 'd001-P', 'assignment topic';
  assert (select time_limit_minutes from public.assignments
          where id = (select v::uuid from t.vars where k = 'tt')) = 15, 'time limit';
end $$;
do $$ begin
  perform public.start_topic_test((select v::uuid from t.vars where k = 'tg'), 'd001-P',
    'Ikkinchi', array['q1'], array[0], 5);
  raise exception 'second test for the same topic';
exception when unique_violation then null;
end $$;

-- ------------------------------------------------- talaba testni yechadi
select t.login('00000000-0000-0000-0000-0000000000d3');
do $$
declare r jsonb;
begin
  assert (select count(*) from public.group_topics) = 1, 'student sees opened topic';
  assert (select count(*) from public.assignment_keys) = 0, 'student has no key';
  perform public.start_assignment((select v::uuid from t.vars where k = 'tt'));
  r := public.submit_assignment((select v::uuid from t.vars where k = 'tt'), array[1, 1, 2]);
  assert (r ->> 'score')::int = 2, 'server score: ' || r::text;
  assert (select correct from public.submissions) = array[true, false, true], 'own answers';
end $$;
select t.login('00000000-0000-0000-0000-0000000000d4');
do $$ begin
  assert (select count(*) from public.submissions) = 0, 'S2 does not see S1 answers';
end $$;
-- S2 boshqa talaba nomidan yoza olmaydi (jadvalga to'g'ridan-to'g'ri yozish yopiq).
do $$ begin
  insert into public.submissions (assignment_id, user_id, answers, score, total)
  values ((select v::uuid from t.vars where k = 'tt'),
          '00000000-0000-0000-0000-0000000000d4', array[1, 0, 2], 3, 3);
  raise exception 'direct submission insert';
exception when insufficient_privilege then null;
end $$;

-- Begona ustoz va admin natijalarni ko'rmaydi.
select t.login('00000000-0000-0000-0000-0000000000d2');
do $$ begin
  assert (select count(*) from public.submissions) = 0, 'foreign teacher sees no results';
  assert (select count(*) from public.group_topics) = 0, 'foreign teacher sees no topics';
  assert (select count(*) from public.group_members) = 0, 'foreign teacher sees no members';
end $$;
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
do $$ begin
  assert (select count(*) from public.submissions
          where assignment_id = (select v::uuid from t.vars where k = 'tt')) = 0,
    'admin sees no topic results';
  assert (select count(*) from public.group_topics) = 0, 'admin sees no topics';
  assert (select count(*) from public.teacher_accounts) = 0, 'admin sees no teacher list';
end $$;

-- Ustoz: o'z guruhi natijasi (har savol bo'yicha) ko'rinadi.
select t.login('00000000-0000-0000-0000-0000000000d1');
do $$ begin
  assert (select count(*) from public.submissions
          where assignment_id = (select v::uuid from t.vars where k = 'tt')) = 1, 'teacher sees';
  assert (select correct from public.submissions
          where assignment_id = (select v::uuid from t.vars where k = 'tt'))
         = array[true, false, true], 'per-question for teacher';
end $$;
select public.finish_topic_test((select v::uuid from t.vars where k = 'tg'), 'd001-P');
do $$ begin
  assert (select due_at <= now() from public.assignments
          where id = (select v::uuid from t.vars where k = 'tt')), 'test finished';
  perform public.finish_topic_test((select v::uuid from t.vars where k = 'tg'), 'd002-P');
  raise exception 'finished a missing test';
exception when no_data_found then null;
end $$;

-- Yakunlangan testni yangi talaba boshlay olmaydi.
reset role;
update public.assignments set due_at = now() - interval '1 minute'
  where id = (select v::uuid from t.vars where k = 'tt');
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000d4');
do $$ begin
  perform public.start_assignment((select v::uuid from t.vars where k = 'tt'));
  raise exception 'started a finished test';
exception when invalid_parameter_value then null;
end $$;
reset role;

-- anon: hech narsa.
set role anon;
do $$ begin
  perform public.register_teacher();
  raise exception 'anon registered as teacher';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform count(*) from public.group_topics;
  raise exception 'anon read topics';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform count(*) from public.teacher_accounts;
  raise exception 'anon read teachers';
exception when insufficient_privilege then null;
end $$;
reset role;

-- Admin vakolati baribir faqat allowlist + tasdiqlangan emailga.
do $$ begin
  assert not exists (select 1 from public.app_admins
                     where user_id in (select user_id from public.teacher_accounts)),
    'no teacher became admin';
end $$;

select 'teacher topics: all checks passed' as result;
