-- Admin panel: statistika, foydalanuvchilar ro'yxati, reviewer vakolati.
-- (Hisobni o'chirish — `functions/delete-account` Edge Function, service
-- role bilan: auth foydalanuvchisi va uning fayllari Storage API orqali.)
--
-- Hisoblash qoidalari (ilovada ham shu matn ko'rsatiladi):
-- * Ro'yxatdan o'tgan hisob — emailini OTP bilan tasdiqlagan, o'chirilmagan
--   foydalanuvchi. Mehmonlar serverda hisob ochmaydi va sanalmaydi; kod
--   so'rab tasdiqlamaganlar ham sanalmaydi.
-- * Yangi hisob sanasi — email birinchi marta tasdiqlangan kun
--   (Asia/Tashkent). “Oxirgi 7 kun” bugun bilan birga 7 kalendar kun.
-- * Faol foydalanuvchi — tanlangan davrda ilovani hisobiga kirgan holda
--   kamida bir marta ochgan ro'yxatdan o'tgan foydalanuvchi
--   (profiles.last_seen_on; kuniga bir marta yangilanadi).
-- * Billing ulanmaguncha Free/Pro taqsimoti qaytarilmaydi (null).

create function public._require_admin() returns void
language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
end;
$$;
revoke all on function public._require_admin() from public, anon, authenticated;

create function public._registered_users()
returns table (id uuid, email text, confirmed_on date)
language sql stable security definer set search_path = '' as $$
  select u.id, u.email,
         (u.email_confirmed_at at time zone 'Asia/Tashkent')::date
  from auth.users u
  where u.email_confirmed_at is not null
    and u.deleted_at is null
    and not coalesce(u.is_anonymous, false);
$$;
revoke all on function public._registered_users() from public, anon, authenticated;

create function public.admin_stats() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  today date := (now() at time zone 'Asia/Tashkent')::date;
  result jsonb;
begin
  perform public._require_admin();
  with reg as (select * from public._registered_users()),
  prof as (
    select p.* from public.profiles p join reg on reg.id = p.id
  )
  select jsonb_build_object(
    'generated_at', now(),
    'timezone', 'Asia/Tashkent',
    'registered', (select count(*) from reg),
    'new_today', (select count(*) from reg where confirmed_on = today),
    'new_7d', (select count(*) from reg where confirmed_on > today - 7),
    'new_30d', (select count(*) from reg where confirmed_on > today - 30),
    'active_today', (select count(*) from prof where last_seen_on = today),
    'active_7d', (select count(*) from prof where last_seen_on > today - 7),
    'active_30d', (select count(*) from prof where last_seen_on > today - 30),
    'by_role', coalesce((select jsonb_object_agg(role, n) from
      (select role, count(*) n from prof group by role) r), '{}'::jsonb),
    'by_language', coalesce((select jsonb_object_agg(language, n) from
      (select language, count(*) n from prof group by language) l), '{}'::jsonb),
    'without_profile', (select count(*) from reg where not exists
      (select 1 from public.profiles p where p.id = reg.id)),
    'billing', null,
    'support', jsonb_build_object(
      'new', (select count(*) from public.support_threads where status = 'new'),
      'in_review', (select count(*) from public.support_threads where status = 'in_review'),
      'answered', (select count(*) from public.support_threads where status = 'answered'),
      'closed', (select count(*) from public.support_threads where status = 'closed'),
      'awaiting_reply', (select count(*) from public.support_threads
        where status in ('new', 'in_review'))
    )
  ) into result;
  return result;
end;
$$;

-- Emailni to'liq ko'rsatmaslik: ro'yxatda “ab***@gmail.com”.
create function public._mask_email(e text) returns text
language sql immutable set search_path = '' as $$
  select case
    when e is null or position('@' in e) = 0 then null
    else left(split_part(e, '@', 1), 2) || '***@' || split_part(e, '@', 2)
  end;
$$;

create function public.admin_list_users(
  p_query text default null,
  p_role text default null,
  p_language text default null,
  p_limit int default 20,
  p_offset int default 0
) returns table (
  user_id uuid, email_masked text, role text, language text,
  registered_on date, last_seen_on date, total bigint
)
language plpgsql stable security definer set search_path = '' as $$
declare
  q text := nullif(btrim(lower(p_query)), '');
begin
  perform public._require_admin();
  return query
    with reg as (select * from public._registered_users()),
    filtered as (
      select reg.id, reg.email, reg.confirmed_on, p.role, p.language, p.last_seen_on
      from reg left join public.profiles p on p.id = reg.id
      where (q is null or lower(reg.email) like '%' || q || '%')
        and (p_role is null or p.role = p_role)
        and (p_language is null or p.language = p_language)
    )
    select f.id, public._mask_email(f.email), f.role, f.language, f.confirmed_on,
           f.last_seen_on, count(*) over ()
    from filtered f
    order by f.confirmed_on desc, f.id
    limit least(greatest(p_limit, 1), 100) offset greatest(p_offset, 0);
end;
$$;

-- To'liq emailni ko'rish — alohida amal va jurnalga yoziladi.
create function public.admin_reveal_email(p_user uuid) returns text
language plpgsql security definer set search_path = '' as $$
declare
  e text;
begin
  perform public._require_admin();
  select email into e from auth.users where id = p_user;
  perform public._audit('reveal_email', p_user::text);
  return e;
end;
$$;

create function public.admin_set_reviewer(p_user uuid, p_enabled boolean) returns void
language plpgsql security definer set search_path = '' as $$
begin
  perform public._require_admin();
  if p_enabled then
    insert into public.app_reviewers (user_id, granted_by) values (p_user, auth.uid())
    on conflict (user_id) do nothing;
  else
    delete from public.app_reviewers where user_id = p_user;
  end if;
  perform public._audit(
    case when p_enabled then 'reviewer_granted' else 'reviewer_revoked' end,
    p_user::text);
end;
$$;

revoke all on function
  public.admin_stats(),
  public.admin_list_users(text, text, text, int, int),
  public.admin_reveal_email(uuid),
  public.admin_set_reviewer(uuid, boolean)
  from public, anon;
grant execute on function
  public.admin_stats(),
  public.admin_list_users(text, text, text, int, int),
  public.admin_reveal_email(uuid),
  public.admin_set_reviewer(uuid, boolean)
  to authenticated;
