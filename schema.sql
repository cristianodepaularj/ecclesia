-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- ROLES IMPLEMENTATION
-- We will use a column 'role' in the 'profiles' table.
-- roles: 'admin', 'member'

-- 1. PROFILES (Church Member Registry)
create table if not exists public.profiles (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users(id) unique, -- Link to App User (Nullable)
  email text, 
  full_name text not null,
  phone text,
  birth_date date,
  address text,
  baptism_date date,
  marital_status text,
  ministry_role text, 
  photo_url text, 
  internal_notes text, 
  role text default 'member' check (role in ('admin', 'member')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.profiles enable row level security;

-- HELPER FUNCTION TO PREVENT RECURSION
-- This function runs with "security definer" privileges (admin rights), 
-- bypassing RLS when checking for the role. This breaks the infinite loop.
create or replace function public.is_admin()
returns boolean as $$
begin
  return exists (
    select 1 from public.profiles
    where user_id = auth.uid() and role = 'admin'
  );
end;
$$ language plpgsql security definer;

-- Policies for Profiles
-- DROP existing policies to avoid "policy already exists" error
drop policy if exists "Admins can do everything on profiles" on public.profiles;
drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;

-- Admins can do everything.
create policy "Admins can do everything on profiles"
  on public.profiles for all
  using ( public.is_admin() );

-- Self access
create policy "Users can view own profile"
  on public.profiles for select
  using ( user_id = auth.uid() );

create policy "Users can update own profile"
  on public.profiles for update
  using ( user_id = auth.uid() );

-- 2. SERVICES
create table if not exists public.services (
  id uuid default uuid_generate_v4() primary key,
  title text not null, 
  day_of_week text, 
  time time, 
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.services enable row level security;

drop policy if exists "Everyone can view services" on public.services;
drop policy if exists "Admins can manage services" on public.services;

create policy "Everyone can view services"
  on public.services for select
  to authenticated
  using ( true );

create policy "Admins can manage services"
  on public.services for all
  using ( public.is_admin() );


-- 3. EVENTS
create table if not exists public.events (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  event_type text, 
  start_time timestamp with time zone not null,
  end_time timestamp with time zone,
  location text,
  responsible text,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.events enable row level security;

drop policy if exists "Everyone can view events" on public.events;
drop policy if exists "Admins can manage events" on public.events;

create policy "Everyone can view events"
  on public.events for select
  to authenticated
  using ( true );

create policy "Admins can manage events"
  on public.events for all
  using ( public.is_admin() );


-- 4. NEWS
create table if not exists public.news (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  content text not null,
  image_url text, 
  published_at timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.news enable row level security;

drop policy if exists "Everyone can view news" on public.news;
drop policy if exists "Admins can manage news" on public.news;

create policy "Everyone can view news"
  on public.news for select
  to authenticated
  using ( true );

create policy "Admins can manage news"
  on public.news for all
  using ( public.is_admin() );


-- 5. VIDEOS
create table if not exists public.videos (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  youtube_id text not null,
  description text,
  published_at timestamp with time zone default timezone('utc'::text, now()) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.videos enable row level security;

drop policy if exists "Everyone can view videos" on public.videos;
drop policy if exists "Admins can manage videos" on public.videos;

create policy "Everyone can view videos"
  on public.videos for select
  to authenticated
  using ( true );

create policy "Admins can manage videos"
  on public.videos for all
  using ( public.is_admin() );


-- 6. FINANCE
create table if not exists public.finances (
  id uuid default uuid_generate_v4() primary key,
  amount numeric(12,2) not null,
  type text not null check (type in ('income', 'expense')),
  category text not null,
  description text,
  date date default CURRENT_DATE,
  member_id uuid references public.profiles(id), 
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);
alter table public.finances enable row level security;

drop policy if exists "Admins can do everything on finances" on public.finances;

create policy "Admins can do everything on finances"
  on public.finances for all
  using ( public.is_admin() );


-- TRIGGER FOR NEW USER LINKING
create or replace function public.handle_new_user()
returns trigger as $$
declare
  existing_profile_id uuid;
begin
  select id into existing_profile_id from public.profiles where email = new.email limit 1;
  
  if existing_profile_id is not null then
    update public.profiles set user_id = new.id where id = existing_profile_id;
  else
    insert into public.profiles (user_id, email, full_name, role)
    values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', new.email), 'member');
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Drop trigger if exists to avoid error on rerun
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
