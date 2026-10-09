-- Kontent tekshiruvi: faqat admin bergan tekshiruvchi qaror yozadi va o'qiydi.
-- 10_acceptance.sql dan keyin: bob (b1) — reviewer, alice (a1) — oddiy hisob.

set role authenticated;

-- Oddiy hisob qaror yoza olmaydi va qarorlarni ko'rmaydi.
select t.login('00000000-0000-0000-0000-0000000000a1');
do $$ begin
  perform public.review_submit('analyte', 'glucose-plasma-fasting', '2026.10.08-dev.6', 'approve', null);
  raise exception 'non-reviewer submitted a review';
exception when insufficient_privilege then null;
end $$;

-- Tekshiruvchi: tasdiq izohsiz mumkin, "o'zgartirish kerak" — izoh bilan.
select t.login('00000000-0000-0000-0000-0000000000b1');
do $$ begin
  perform public.review_submit('analyte', 'glucose-plasma-fasting', '2026.10.08-dev.6', 'approve', '  ');
  perform public.review_submit('quiz', 'dilution-equation', '2026.10.08-dev.6', 'changes', 'Izohga manba kerak');
end $$;
do $$ begin
  perform public.review_submit('quiz', 'dilution-equation', '2026.10.08-dev.6', 'changes', '');
  raise exception 'changes without comment accepted';
exception when invalid_parameter_value then null;
end $$;
do $$ begin
  perform public.review_submit('lesson', 'x', 'v', 'approve', null);
  raise exception 'unknown item kind accepted';
exception when check_violation then null;
end $$;
do $$ begin
  assert (select count(*) from public.content_reviews) = 2, 'reviewer sees reviews';
  assert (select comment from public.content_reviews where decision = 'approve') is null,
    'blank comment stored as null';
end $$;
-- To'g'ridan-to'g'ri yozish yopiq (faqat funksiya orqali).
do $$ begin
  insert into public.content_reviews (item_kind, item_id, content_version, reviewer_id, decision)
  values ('analyte', 'x', 'v', '00000000-0000-0000-0000-0000000000b1', 'approve');
  raise exception 'direct insert allowed';
exception when insufficient_privilege then null;
end $$;

select t.login('00000000-0000-0000-0000-0000000000a1');
do $$ begin
  assert (select count(*) from public.content_reviews) = 0, 'non-reviewer must not read reviews';
end $$;
reset role;

set role anon;
do $$ begin
  perform public.review_submit('analyte', 'x', 'v', 'approve', null);
  raise exception 'anon submitted';
exception when insufficient_privilege then null;
end $$;
reset role;

select 'content review: all checks passed' as result;
