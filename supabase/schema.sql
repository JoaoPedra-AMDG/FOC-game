-- Run this in the Supabase SQL editor for a new project.
create table if not exists public.torque_chase_scores (
  id bigint generated always as identity primary key,
  nickname text not null check (
    char_length(nickname) between 2 and 16
    and nickname ~ '^[A-Za-z0-9 _-]+$'
  ),
  max_rpm integer not null check (max_rpm between 0 and 10000),
  created_at timestamptz not null default now()
);

create index if not exists torque_chase_scores_rank_idx
  on public.torque_chase_scores (max_rpm desc, created_at asc);

alter table public.torque_chase_scores enable row level security;

create policy "Anyone can read scores"
  on public.torque_chase_scores for select
  to anon
  using (true);

create policy "Visitors can submit scores"
  on public.torque_chase_scores for insert
  to anon
  with check (true);

grant usage on schema public to anon;
grant select, insert on public.torque_chase_scores to anon;
grant usage, select on sequence public.torque_chase_scores_id_seq to anon;
