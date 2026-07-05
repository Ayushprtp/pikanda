-- Harden security-definer functions per Supabase advisor findings:
-- 1) anon must not execute app functions (they're for signed-in users only)
do $$
declare fn record;
begin
  for fn in
    select p.oid::regprocedure as sig
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
  loop
    execute format('revoke execute on function %s from anon', fn.sig);
  end loop;
end $$;
alter default privileges in schema public revoke execute on functions from anon;

-- 2) pin search_path on the remaining helpers
alter function public.gen_invite_code() set search_path = public;
alter function public.level_name_for(int) set search_path = public;
alter function public.pet_stage_for(int) set search_path = public;
