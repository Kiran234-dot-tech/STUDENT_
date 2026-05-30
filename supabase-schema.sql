create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  color text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subject_id uuid references public.subjects(id) on delete set null,
  name text not null,
  type text not null,
  source text not null check (source in ('local', 'drive')),
  link text,
  tags text[] not null default '{}',
  notes text,
  doc_date date not null default current_date,
  size bigint not null default 0,
  original_name text,
  starred boolean not null default false,
  views integer not null default 0,
  last_opened timestamptz,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.subjects enable row level security;
alter table public.documents enable row level security;

drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile"
on public.profiles for select
to authenticated
using ((select auth.uid()) = id);

drop policy if exists "Users can create own profile" on public.profiles;
create policy "Users can create own profile"
on public.profiles for insert
to authenticated
with check ((select auth.uid()) = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

drop policy if exists "Users can view own subjects" on public.subjects;
create policy "Users can view own subjects"
on public.subjects for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can create own subjects" on public.subjects;
create policy "Users can create own subjects"
on public.subjects for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update own subjects" on public.subjects;
create policy "Users can update own subjects"
on public.subjects for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete own subjects" on public.subjects;
create policy "Users can delete own subjects"
on public.subjects for delete
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can view own documents" on public.documents;
create policy "Users can view own documents"
on public.documents for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can create own documents" on public.documents;
create policy "Users can create own documents"
on public.documents for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update own documents" on public.documents;
create policy "Users can update own documents"
on public.documents for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete own documents" on public.documents;
create policy "Users can delete own documents"
on public.documents for delete
to authenticated
using ((select auth.uid()) = user_id);
