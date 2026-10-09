-- Jadval huquqlari aniq: ba'zi Supabase loyihalari public sxemada anon va
-- authenticated ga barcha huquqni beradi. Bu yerda mijoz faqat RLS ruxsat
-- bergan qatorlarni O'QIYDI; yozish faqat SECURITY DEFINER funksiyalar
-- orqali (ular vakolatni o'zi tekshiradi). anon hech narsa olmaydi.

revoke all on
  public.profiles, public.admin_allowlist, public.app_admins, public.app_reviewers,
  public.admin_audit, public.support_threads, public.support_messages,
  public.study_groups, public.group_members, public.assignments,
  public.assignment_keys, public.submissions
  from anon, authenticated;

grant select on
  public.profiles, public.admin_audit, public.support_threads, public.support_messages,
  public.study_groups, public.group_members, public.assignments,
  public.assignment_keys, public.submissions
  to authenticated;

revoke all on sequence public.admin_audit_id_seq from anon, authenticated;
