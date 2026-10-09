-- Qabul testlari: ikkita oddiy hisob (A, B), alohida admin hisobi.
-- Har blok xato topsa butun skript to'xtaydi (ON_ERROR_STOP).
--
-- Foydalanuvchini taqlid qilish: `set role authenticated` +
-- `select t.login(uid, aal)` (Supabase JWT claims kabi).

create schema t;
grant usage on schema t to authenticated;
create function t.login(p_uid uuid, p_aal text default 'aal1', p_email text default null)
returns void language sql as $$
  select set_config('request.jwt.claims',
    jsonb_build_object('sub', p_uid, 'role', 'authenticated', 'aal', p_aal,
                       'email', p_email)::text, false);
$$;
grant execute on function t.login(uuid, text, text) to authenticated;
-- Sinov o'zgaruvchilari (thread id va h.k.) — sessiya bo'ylab.
create table t.vars (k text primary key, v text);
grant all on t.vars to authenticated;

-- ============================================================ foydalanuvchilar
-- Admin email egasi hali tasdiqlamagan: admin emas.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000ad01', 'DavlatSudekspert@gmail.com');
do $$ begin
  assert not exists (select 1 from public.app_admins), 'unconfirmed email must not be admin';
end $$;

-- OTP bilan tasdiqladi: server admin vakolatini berdi va jurnalga yozdi.
update auth.users set email_confirmed_at = now()
  where id = '00000000-0000-0000-0000-00000000ad01';
do $$ begin
  assert exists (select 1 from public.app_admins
                 where user_id = '00000000-0000-0000-0000-00000000ad01'), 'admin not granted';
  assert (select count(*) from public.admin_audit where action = 'admin_granted') = 1,
    'grant not audited';
end $$;

-- A va B: oddiy hisoblar. A hali kod so'ragan, lekin tasdiqlamagan.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'alice@test.local'),
  ('00000000-0000-0000-0000-0000000000b1', 'bob@test.local');
update auth.users set email_confirmed_at = now()
  where id = '00000000-0000-0000-0000-0000000000b1';

-- ============================================================ admin: 2FA
set role authenticated;
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal1');
do $$ begin
  assert (public.my_access() ->> 'admin_account')::boolean, 'admin account flag';
  assert not (public.my_access() ->> 'admin')::boolean, 'aal1 must not be admin';
  perform public.admin_stats();
  raise exception 'admin_stats without 2FA must fail';
exception when insufficient_privilege then null;
end $$;

select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
do $$
declare s jsonb := public.admin_stats();
begin
  assert (s ->> 'registered')::int = 2, 'registered: admin + bob, got ' || s::text;
  assert (s -> 'billing') = 'null'::jsonb, 'billing must stay null until connected';
end $$;
reset role;

-- ====================================== 1. yangi hisob statistikada BIR marta
update auth.users set email_confirmed_at = now()
  where id = '00000000-0000-0000-0000-0000000000a1';
-- Qayta kirish va profilni ikki marta yangilash sanoqni oshirmaydi.
update auth.users set last_sign_in_at = now()
  where id = '00000000-0000-0000-0000-0000000000a1';
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000a1');
select public.touch_profile('lab', 'ru');
select public.touch_profile('lab', 'ru');
select t.login('00000000-0000-0000-0000-0000000000b1');
select public.touch_profile('teacher', 'uz');
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
do $$
declare s jsonb := public.admin_stats();
begin
  assert (s ->> 'registered')::int = 3, 'registered after Alice confirmed: ' || s::text;
  assert (s ->> 'new_today')::int = 3, 'new today: ' || s::text;
  assert (s ->> 'active_today')::int = 2, 'active today (a, b): ' || s::text;
  assert (s -> 'by_role' ->> 'lab')::int = 1 and (s -> 'by_role' ->> 'teacher')::int = 1,
    'by role: ' || s::text;
  assert (s -> 'by_language' ->> 'ru')::int = 1, 'by language: ' || s::text;
  assert (s ->> 'without_profile')::int = 1, 'admin has no profile yet: ' || s::text;
end $$;
reset role;

-- ================================= 2. murojaat admin panelga keladi
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000a1');
insert into t.vars values ('thread', public.support_create_thread(
  'bug', 'Kalkulyatorda xato', 'eGFR natijasi chiqmayapti'));
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
do $$
declare tid uuid := (select v::uuid from t.vars where k = 'thread');
begin
  assert (select status from public.support_threads where id = tid) = 'new', 'status new';
  assert (public.admin_stats() -> 'support' ->> 'awaiting_reply')::int = 1, 'awaiting reply';
  assert (select count(*) from public.support_messages where thread_id = tid) = 1, 'admin sees message';
end $$;

-- ================================= 3. admin javobi aynan yuboruvchiga
select public.admin_reply((select v::uuid from t.vars where k = 'thread'),
                          'Rahmat, tekshiramiz.');
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$
declare
  tid uuid := (select v::uuid from t.vars where k = 'thread');
  th public.support_threads;
begin
  select * into th from public.support_threads where id = tid;
  assert th.status = 'answered', 'answered';
  assert th.last_admin_message_at > th.user_read_at, 'unread badge for the user';
  assert (select count(*) from public.support_messages where thread_id = tid and from_admin) = 1,
    'user sees the admin reply';
  perform public.support_mark_read(tid);
  select * into th from public.support_threads where id = tid;
  assert not (th.last_admin_message_at > th.user_read_at), 'read after opening';
end $$;

select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  assert (select count(*) from public.support_threads) = 0, 'Bob must not see Alice threads';
  assert (select count(*) from public.support_messages) = 0, 'Bob must not see Alice messages';
end $$;

-- ================================= 4. foydalanuvchi qayta javob beradi
select t.login('00000000-0000-0000-0000-0000000000a1');
select public.support_post_message((select v::uuid from t.vars where k = 'thread'),
                                   'Yana: iOS 18 da ham shunday.');
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
do $$
declare tid uuid := (select v::uuid from t.vars where k = 'thread');
begin
  assert (select status from public.support_threads where id = tid) = 'new',
    'user reply reopens to new';
  assert (select count(*) from public.support_messages where thread_id = tid) = 3, '3 messages';
end $$;
select public.admin_set_thread_status((select v::uuid from t.vars where k = 'thread'), 'in_review');
reset role;
do $$ begin
  assert (select count(*) from public.admin_audit
          where action in ('support_reply', 'support_status')) = 2, 'admin actions audited';
end $$;

-- ================= 5. boshqa hisob yozishmani ham, admin panelni ham ocha olmaydi
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  perform public.support_post_message((select v::uuid from t.vars where k = 'thread'), 'hack');
  raise exception 'Bob posted into Alice thread';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.support_mark_read((select v::uuid from t.vars where k = 'thread'));
  raise exception 'Bob marked Alice thread';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.admin_stats();
  raise exception 'Bob opened admin stats';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.admin_reply((select v::uuid from t.vars where k = 'thread'), 'fake admin');
  raise exception 'Bob replied as admin';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform * from public.admin_list_users();
  raise exception 'Bob listed users';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  insert into public.app_admins (user_id, granted_reason)
  values ('00000000-0000-0000-0000-0000000000b1', 'self');
  raise exception 'Bob made himself admin';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  insert into public.admin_allowlist values ('bob@test.local');
  raise exception 'Bob edited the allowlist';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  update public.support_threads set status = 'closed';
  raise exception 'Bob updated threads directly';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  assert (select count(*) from public.admin_audit) = 0, 'Bob must not read the audit log';
end $$;
-- JWT ichida admin emaili bo'lsa ham (ilova tomonidan soxtalashtirilgan)
-- va aal2 bo'lsa ham — admin emas: vakolat foydalanuvchi id siga bog'liq.
select t.login('00000000-0000-0000-0000-0000000000b1', 'aal2', 'davlatsudekspert@gmail.com');
do $$ begin
  assert not public.is_admin(), 'email claim must not grant admin';
  perform public.admin_stats();
  raise exception 'email claim opened admin panel';
exception when insufficient_privilege then null;
end $$;
-- Ustoz roli review vakolatini bermaydi.
do $$ begin
  assert not public.is_reviewer(), 'teacher role must not grant review rights';
end $$;
reset role;

-- ================= 6. xabarlar saqlanadi (yangi sessiya/tranzaksiya)
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$ begin
  assert (select count(*) from public.support_messages) = 3, 'messages persisted';
end $$;

-- ================================================ spam va fayl cheklovlari
do $$
declare i int;
begin
  for i in 1 .. 4 loop
    perform public.support_create_thread('question', 'Savol ' || i, 'Matn');
  end loop;
  perform public.support_create_thread('question', 'Oltinchi savol', 'Matn');
  raise exception 'sixth thread in a day was accepted';
exception when program_limit_exceeded then null;
end $$;
do $$ begin
  perform public.support_create_thread('question', 'ab', 'Juda qisqa mavzu');
  raise exception 'short subject accepted';
exception when check_violation or program_limit_exceeded then null;
end $$;

insert into storage.objects (bucket_id, name)
values ('support-attachments', '00000000-0000-0000-0000-0000000000a1/s1.png');
do $$ begin
  insert into storage.objects (bucket_id, name)
  values ('support-attachments', '00000000-0000-0000-0000-0000000000b1/evil.png');
  raise exception 'uploaded into another user folder';
exception when insufficient_privilege then null;
end $$;
reset role;
-- Bob o'z papkasiga rasm yuklagan (postgres sifatida qo'yiladi).
insert into storage.objects (bucket_id, name, owner)
values ('support-attachments', '00000000-0000-0000-0000-0000000000b1/b.png',
        '00000000-0000-0000-0000-0000000000b1');
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$ begin
  assert (select count(*) from storage.objects) = 1, 'Alice sees only her file';
  perform public.support_post_message((select v::uuid from t.vars where k = 'thread'),
    'boshqaning fayli', '00000000-0000-0000-0000-0000000000b1/b.png');
  raise exception 'attached another user file';
exception when invalid_parameter_value then null;
end $$;
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
do $$ begin
  assert (select count(*) from storage.objects) = 2, 'admin sees attachments';
end $$;

-- ============================================== admin: ro'yxat, email, jurnal
do $$
declare r record;
begin
  select * into r from public.admin_list_users('alice', null, null, 20, 0);
  assert r.email_masked = 'al***@test.local', 'masked email: ' || r.email_masked;
  assert r.total = 1, 'search total';
  assert (select count(*) from public.admin_list_users(null, 'teacher', null, 20, 0)) = 1, 'role filter';
  assert (select max(total) from public.admin_list_users(null, null, null, 1, 0)) = 3, 'page total';
  assert (select count(*) from public.admin_list_users(null, null, null, 1, 1)) = 1, 'second page';
  assert public.admin_reveal_email('00000000-0000-0000-0000-0000000000a1') = 'alice@test.local', 'reveal';
  perform public.admin_set_reviewer('00000000-0000-0000-0000-0000000000b1', true);
end $$;
do $$ begin
  update public.admin_audit set action = 'x';
  raise exception 'audit log was modified';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  delete from public.admin_audit;
  raise exception 'audit log was deleted';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  assert (select count(*) from public.admin_audit
          where action in ('reveal_email', 'reviewer_granted')) = 2, 'reveal + reviewer audited';
end $$;
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  assert public.is_reviewer(), 'admin-granted reviewer';
end $$;
reset role;

-- Admin emaili o'zgarsa vakolat olinadi.
update auth.users set email = 'other@test.local'
  where id = '00000000-0000-0000-0000-00000000ad01';
do $$ begin
  assert not exists (select 1 from public.app_admins), 'admin revoked after email change';
end $$;
update auth.users set email = 'davlatsudekspert@gmail.com'
  where id = '00000000-0000-0000-0000-00000000ad01';

-- ================================================================ guruhlar
set role authenticated;
select t.login('00000000-0000-0000-0000-0000000000a1');
insert into t.vars select 'group_code', public.create_group('Biokimyo 2-kurs') ->> 'join_code';
insert into t.vars select 'group', id::text from public.study_groups;
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  assert (select count(*) from public.study_groups) = 0, 'not a member yet';
  perform public.join_group('wrong-code');
  raise exception 'joined with a wrong code';
exception when no_data_found then null;
end $$;
select public.join_group(lower((select v from t.vars where k = 'group_code')));
do $$ begin
  assert (select count(*) from public.study_groups) = 1, 'member sees group';
  perform public.create_assignment((select v::uuid from t.vars where k = 'group'),
    'Hack', array['q1'], array[0]);
  raise exception 'student created an assignment';
exception when insufficient_privilege then null;
end $$;
select t.login('00000000-0000-0000-0000-0000000000a1');
insert into t.vars select 'assignment', public.create_assignment(
  (select v::uuid from t.vars where k = 'group'), '1-mavzu: glyukoza',
  array['glucose-1', 'glucose-2', 'glucose-3'], array[1, 0, 2])::text;
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$
declare r jsonb;
begin
  assert (select count(*) from public.assignments) = 1, 'student sees assignment';
  assert (select count(*) from public.assignment_keys) = 0, 'student must not see the key';
  r := public.submit_assignment((select v::uuid from t.vars where k = 'assignment'),
                                array[1, 1, 2]);
  assert (r ->> 'score')::int = 2 and (r ->> 'total')::int = 3, 'server-side score: ' || r::text;
end $$;
-- (Alohida blok: EXCEPTION bandi o'z blokidagi o'zgarishlarni bekor qiladi.)
do $$ begin
  perform public.submit_assignment((select v::uuid from t.vars where k = 'assignment'),
                                   array[1, 0, 2]);
  raise exception 'second submission accepted';
exception when unique_violation then null;
end $$;
select t.login('00000000-0000-0000-0000-00000000ad01', 'aal2');
do $$ begin
  -- Admin ham guruh a'zosi bo'lmasa, guruh ichini ko'rmaydi.
  assert (select count(*) from public.study_groups) = 0, 'non-member admin sees no group';
  assert (select count(*) from public.submissions) = 0, 'non-member sees no submissions';
end $$;
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$ begin
  assert (select count(*) from public.submissions) = 1, 'teacher sees submissions';
  assert (select count(*) from public.assignment_keys) = 1, 'teacher sees key';
end $$;
reset role;

-- anon hech narsani o'qiy olmaydi.
set role anon;
do $$ begin
  perform count(*) from public.support_threads;
  raise exception 'anon read threads';
exception when insufficient_privilege then null;
end $$;
do $$ begin
  perform public.my_access();
  raise exception 'anon called my_access';
exception when insufficient_privilege then null;
end $$;
reset role;

select 'acceptance: all checks passed' as result;
