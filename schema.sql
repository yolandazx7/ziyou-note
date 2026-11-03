-- Run in Supabase SQL Editor. Never expose service_role keys in client code.
create table if not exists public.entries (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  content jsonb not null default '{}'::jsonb,
  revision integer not null default 1 check (revision >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists entries_user_created_idx on public.entries(user_id, created_at);
alter table public.entries enable row level security;
revoke all on public.entries from anon;
grant select, insert, update on public.entries to authenticated;
drop policy if exists entries_select_own on public.entries;
drop policy if exists entries_insert_own on public.entries;
drop policy if exists entries_update_own on public.entries;
create policy entries_select_own on public.entries for select to authenticated using ((select auth.uid()) = user_id);
create policy entries_insert_own on public.entries for insert to authenticated with check ((select auth.uid()) = user_id);
create policy entries_update_own on public.entries for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
-- Prevent changes to ownership, id, revision jumps, or timestamps from the browser.
create or replace function public.entries_guard() returns trigger language plpgsql set search_path = '' as $$
begin
 if tg_op = 'UPDATE' then
  if new.id <> old.id or new.user_id <> old.user_id or new.created_at <> old.created_at then raise exception 'Immutable entry fields'; end if;
  if new.revision <> old.revision + 1 then raise exception 'Revision must increase by one'; end if;
 end if;
 new.updated_at = now();
 return new;
end;$$;
drop trigger if exists entries_guard_trigger on public.entries;
create trigger entries_guard_trigger before update on public.entries for each row execute function public.entries_guard();
