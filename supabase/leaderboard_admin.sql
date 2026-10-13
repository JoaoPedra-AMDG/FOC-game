-- Run once on the FOC FAST Supabase project. The initial admin must sign up
-- with this email and confirm it before the editor can change scores.
create schema if not exists leaderboard_private;
revoke all on schema leaderboard_private from public, anon, authenticated;
grant usage on schema leaderboard_private to authenticated;

create or replace function leaderboard_private.is_leaderboard_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from auth.users as u
    where u.id = (select auth.uid())
      and lower(u.email) = '2603341@students.wits.ac.za'
      and u.email_confirmed_at is not null
  );
$$;

revoke all on function leaderboard_private.is_leaderboard_admin() from public, anon, authenticated;
grant execute on function leaderboard_private.is_leaderboard_admin() to authenticated;

-- The public app uses this read-only status check to show the editor only to
-- the approved account. The score policies below are the actual protection.
create or replace function public.leaderboard_admin_status()
returns boolean
language sql
stable
security invoker
set search_path = ''
as $$
  select leaderboard_private.is_leaderboard_admin();
$$;

revoke all on function public.leaderboard_admin_status() from public, anon, authenticated;
grant execute on function public.leaderboard_admin_status() to authenticated;

alter table public.torque_chase_scores
  add column if not exists hidden boolean not null default false;

drop policy if exists "Anyone can read scores" on public.torque_chase_scores;
drop policy if exists "Visitors can submit scores" on public.torque_chase_scores;
drop policy if exists "Visitors can read visible scores" on public.torque_chase_scores;
drop policy if exists "Visitors can submit visible scores" on public.torque_chase_scores;
drop policy if exists "Admin can read all scores" on public.torque_chase_scores;
drop policy if exists "Admin can add scores" on public.torque_chase_scores;
drop policy if exists "Admin can edit scores" on public.torque_chase_scores;
drop policy if exists "Admin can delete scores" on public.torque_chase_scores;

create policy "Visitors can read visible scores"
  on public.torque_chase_scores for select
  to anon
  using (not hidden);

create policy "Visitors can submit visible scores"
  on public.torque_chase_scores for insert
  to anon
  with check (not hidden);

create policy "Admin can read all scores"
  on public.torque_chase_scores for select
  to authenticated
  using ((select leaderboard_private.is_leaderboard_admin()));

create policy "Admin can add scores"
  on public.torque_chase_scores for insert
  to authenticated
  with check ((select leaderboard_private.is_leaderboard_admin()));

create policy "Admin can edit scores"
  on public.torque_chase_scores for update
  to authenticated
  using ((select leaderboard_private.is_leaderboard_admin()))
  with check ((select leaderboard_private.is_leaderboard_admin()));

create policy "Admin can delete scores"
  on public.torque_chase_scores for delete
  to authenticated
  using ((select leaderboard_private.is_leaderboard_admin()));

grant select, insert, update, delete on public.torque_chase_scores to authenticated;
grant usage, select on sequence public.torque_chase_scores_id_seq to authenticated;
