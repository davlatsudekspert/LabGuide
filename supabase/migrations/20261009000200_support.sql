-- “Taklif va yordam”: foydalanuvchi murojaatlari va admin javoblari.
--
-- * Har foydalanuvchi faqat o'z yozishmalarini ko'radi; admin (aal2) —
--   hammasini. Yozish faqat funksiyalar orqali (to'g'ridan-to'g'ri
--   INSERT/UPDATE siyosati yo'q).
-- * Spamga qarshi: kuniga 5 ta yangi murojaat, soatiga 30 ta xabar,
--   mavzu ≤ 120, xabar ≤ 4000 belgi; bir xabarga bitta rasm.
-- * Rasm yopiq `support-attachments` bucket'ida, foydalanuvchining o'z
--   papkasida (`<user_id>/...`), PNG/JPEG, ≤ 5 MB; kuniga 10 tagacha.
-- * Admin javobini faqat inson yozadi: avtomatik javob funksiyasi yo'q.

create table public.support_threads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null check (kind in ('suggestion', 'bug', 'question')),
  subject text not null check (char_length(btrim(subject)) between 3 and 120),
  status text not null default 'new'
    check (status in ('new', 'in_review', 'answered', 'closed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_user_message_at timestamptz not null default now(),
  last_admin_message_at timestamptz,
  user_read_at timestamptz not null default now(),
  admin_read_at timestamptz
);
create index support_threads_user on public.support_threads (user_id, updated_at desc);
create index support_threads_status on public.support_threads (status, updated_at desc);

create table public.support_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.support_threads (id) on delete cascade,
  author_id uuid references auth.users (id) on delete set null,
  from_admin boolean not null default false,
  body text not null check (char_length(btrim(body)) between 1 and 4000),
  attachment_path text,
  created_at timestamptz not null default now()
);
create index support_messages_thread on public.support_messages (thread_id, created_at);

alter table public.support_threads enable row level security;
alter table public.support_messages enable row level security;

create policy "threads: owner or admin read" on public.support_threads
  for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

create policy "messages: thread owner or admin read" on public.support_messages
  for select to authenticated
  using (
    public.is_admin()
    or exists (
      select 1 from public.support_threads t
      where t.id = thread_id and t.user_id = auth.uid()
    )
  );

-- Biriktirma yo'li foydalanuvchining o'z papkasida va haqiqatan yuklangan
-- bo'lishi shart (boshqaning faylini “o'ziniki” qilib bo'lmaydi).
create function public._check_attachment(p_path text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if p_path is null then
    return;
  end if;
  if split_part(p_path, '/', 1) <> auth.uid()::text
     or not exists (
       select 1 from storage.objects o
       where o.bucket_id = 'support-attachments' and o.name = p_path
     ) then
    raise exception 'invalid attachment' using errcode = '22023';
  end if;
end;
$$;
revoke all on function public._check_attachment(text) from public, anon, authenticated;

create function public._support_rate_limit() returns void
language plpgsql security definer set search_path = '' as $$
begin
  if (select count(*) from public.support_messages m
      where m.author_id = auth.uid() and not m.from_admin
        and m.created_at > now() - interval '1 hour') >= 30 then
    raise exception 'rate limited: messages' using errcode = '54000';
  end if;
end;
$$;
revoke all on function public._support_rate_limit() from public, anon, authenticated;

create function public.support_create_thread(
  p_kind text, p_subject text, p_body text, p_attachment text default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  tid uuid;
begin
  if uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if (select count(*) from public.support_threads t
      where t.user_id = uid and t.created_at > now() - interval '1 day') >= 5 then
    raise exception 'rate limited: threads' using errcode = '54000';
  end if;
  perform public._support_rate_limit();
  perform public._check_attachment(p_attachment);
  insert into public.support_threads (user_id, kind, subject)
  values (uid, p_kind, btrim(p_subject))
  returning id into tid;
  insert into public.support_messages (thread_id, author_id, from_admin, body, attachment_path)
  values (tid, uid, false, btrim(p_body), p_attachment);
  return tid;
end;
$$;

-- Foydalanuvchi o'z murojaatiga yana yozadi. Javob berilgan yoki yopilgan
-- murojaat “Yangi” holatiga qaytadi — admin uni javob kutayotganlar
-- ro'yxatida ko'radi.
create function public.support_post_message(
  p_thread uuid, p_body text, p_attachment text default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  mid uuid;
begin
  if uid is null or not exists (
    select 1 from public.support_threads t where t.id = p_thread and t.user_id = uid
  ) then
    raise exception 'thread not found' using errcode = '42501';
  end if;
  perform public._support_rate_limit();
  perform public._check_attachment(p_attachment);
  insert into public.support_messages (thread_id, author_id, from_admin, body, attachment_path)
  values (p_thread, uid, false, btrim(p_body), p_attachment)
  returning id into mid;
  update public.support_threads
    set last_user_message_at = now(), updated_at = now(), user_read_at = now(),
        status = case when status in ('answered', 'closed') then 'new' else status end
    where id = p_thread;
  return mid;
end;
$$;

create function public.support_mark_read(p_thread uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  update public.support_threads set user_read_at = now()
    where id = p_thread and user_id = auth.uid();
  if not found then
    raise exception 'thread not found' using errcode = '42501';
  end if;
end;
$$;

-- --------------------------------------------------------------- admin side
create function public.admin_reply(p_thread uuid, p_body text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  mid uuid;
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if not exists (select 1 from public.support_threads where id = p_thread) then
    raise exception 'thread not found' using errcode = 'P0002';
  end if;
  insert into public.support_messages (thread_id, author_id, from_admin, body)
  values (p_thread, auth.uid(), true, btrim(p_body))
  returning id into mid;
  update public.support_threads
    set last_admin_message_at = now(), admin_read_at = now(), updated_at = now(),
        status = 'answered'
    where id = p_thread;
  perform public._audit('support_reply', p_thread::text,
    jsonb_build_object('message', mid, 'length', char_length(btrim(p_body))));
  return mid;
end;
$$;

create function public.admin_set_thread_status(p_thread uuid, p_status text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  old_status text;
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select status into old_status from public.support_threads where id = p_thread for update;
  if not found then
    raise exception 'thread not found' using errcode = 'P0002';
  end if;
  update public.support_threads set status = p_status, updated_at = now() where id = p_thread;
  perform public._audit('support_status', p_thread::text,
    jsonb_build_object('from', old_status, 'to', p_status));
end;
$$;

create function public.admin_mark_read(p_thread uuid) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  update public.support_threads set admin_read_at = now() where id = p_thread;
end;
$$;

revoke all on function
  public.support_create_thread(text, text, text, text),
  public.support_post_message(uuid, text, text),
  public.support_mark_read(uuid),
  public.admin_reply(uuid, text),
  public.admin_set_thread_status(uuid, text),
  public.admin_mark_read(uuid)
  from public, anon;
grant execute on function
  public.support_create_thread(text, text, text, text),
  public.support_post_message(uuid, text, text),
  public.support_mark_read(uuid),
  public.admin_reply(uuid, text),
  public.admin_set_thread_status(uuid, text),
  public.admin_mark_read(uuid)
  to authenticated;

-- ------------------------------------------------------------- attachments
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('support-attachments', 'support-attachments', false, 5242880,
        array['image/png', 'image/jpeg'])
on conflict (id) do update
  set public = false, file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

create policy "support files: upload to own folder, 10 per day"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = auth.uid()::text
    and (
      select count(*) from storage.objects o
      where o.bucket_id = 'support-attachments'
        and o.owner = auth.uid()
        and o.created_at > now() - interval '1 day'
    ) < 10
  );

create policy "support files: owner or admin read"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'support-attachments'
    and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin())
  );
