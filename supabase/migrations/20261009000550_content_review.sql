-- Kontent tekshiruvi: tekshiruvchi (reviewer) karta yoki savolni ko'rib,
-- qaror yozadi. Qaror kontent holatini AVTOMATIK o'zgartirmaydi — karta faqat
-- tahririyat yangilagan keyingi kontent paketida "tekshirilgan" bo'ladi.
--
-- Vakolat: faqat app_reviewers (admin beradi). "Ustoz" roli yoki admin hisobi
-- o'zi tekshiruvchi qilmaydi — admin ham alohida reviewer qilib qo'yilishi kerak.

create table public.content_reviews (
  id uuid primary key default gen_random_uuid(),
  item_kind text not null check (item_kind in ('analyte', 'quiz')),
  item_id text not null check (char_length(item_id) between 1 and 80),
  content_version text not null check (char_length(content_version) between 1 and 40),
  reviewer_id uuid not null references auth.users (id) on delete cascade,
  decision text not null check (decision in ('approve', 'changes')),
  comment text check (comment is null or char_length(comment) <= 2000),
  created_at timestamptz not null default now()
);

create index content_reviews_item on public.content_reviews (item_kind, item_id, created_at desc);

alter table public.content_reviews enable row level security;

-- Qarorlarni faqat tekshiruvchilar va admin hisobi ko'radi.
create policy content_reviews_read on public.content_reviews
  for select to authenticated
  using (public.is_reviewer() or public.is_admin_account());

revoke all on public.content_reviews from anon, authenticated;
grant select on public.content_reviews to authenticated;

create function public.review_submit(
  p_kind text, p_item text, p_version text, p_decision text, p_comment text
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  new_id uuid;
  note text := nullif(btrim(coalesce(p_comment, '')), '');
begin
  if uid is null or not public.is_reviewer() then
    raise exception 'reviewer only' using errcode = '42501';
  end if;
  if p_decision = 'changes' and note is null then
    raise exception 'comment required' using errcode = '22023';
  end if;
  -- Spamga qarshi: kuniga 300 ta qaror.
  if (select count(*) from public.content_reviews r
      where r.reviewer_id = uid and r.created_at > now() - interval '1 day') >= 300 then
    raise exception 'rate limited' using errcode = '54000';
  end if;
  insert into public.content_reviews (item_kind, item_id, content_version, reviewer_id, decision, comment)
  values (p_kind, btrim(p_item), btrim(p_version), uid, p_decision, note)
  returning id into new_id;
  return new_id;
end;
$$;

revoke all on function public.review_submit(text, text, text, text, text) from public, anon;
grant execute on function public.review_submit(text, text, text, text, text) to authenticated;
