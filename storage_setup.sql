-- Enable the storage extension if not already enabled (usually enabled by default in Supabase)
-- Note: 'storage' schema usually exists.

-- 1. Create Buckets
-- We insert into storage.buckets. 
-- 'public' = true means the files can be read without a signed token (if policy allows).
insert into storage.buckets (id, name, public)
values ('member-photos', 'member-photos', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('news-images', 'news-images', true)
on conflict (id) do nothing;


-- 2. Storage Policies (RLS) for Objects
-- We need to enable RLS on storage.objects if it's not already.
alter table storage.objects enable row level security;

-- Helper to check admin (reusing our function or logic)
-- Note: storage policies sometimes run in a different context, so we use auth.uid() directly or our verified helper.

-- DROP policies to ensure idempotency
drop policy if exists "Public AccessMemberPhotos" on storage.objects;
drop policy if exists "Admin UploadMemberPhotos" on storage.objects;
drop policy if exists "Admin UpdateMemberPhotos" on storage.objects;
drop policy if exists "Admin DeleteMemberPhotos" on storage.objects;

drop policy if exists "Public AccessNewsImages" on storage.objects;
drop policy if exists "Admin UploadNewsImages" on storage.objects;
drop policy if exists "Admin UpdateNewsImages" on storage.objects;
drop policy if exists "Admin DeleteNewsImages" on storage.objects;

-- --- Member Photos Policies ---

-- Everyone can view member photos (Public Read)
create policy "Public AccessMemberPhotos"
on storage.objects for select
using ( bucket_id = 'member-photos' );

-- Admins can insert (Upload)
create policy "Admin UploadMemberPhotos"
on storage.objects for insert
with check ( bucket_id = 'member-photos' AND public.is_admin() );

-- Admins can update
create policy "Admin UpdateMemberPhotos"
on storage.objects for update
using ( bucket_id = 'member-photos' AND public.is_admin() );

-- Admins can delete
create policy "Admin DeleteMemberPhotos"
on storage.objects for delete
using ( bucket_id = 'member-photos' AND public.is_admin() );


-- --- News Images Policies ---

-- Everyone can view news images
create policy "Public AccessNewsImages"
on storage.objects for select
using ( bucket_id = 'news-images' );

-- Admins can insert
create policy "Admin UploadNewsImages"
on storage.objects for insert
with check ( bucket_id = 'news-images' AND public.is_admin() );

-- Admins can update
create policy "Admin UpdateNewsImages"
on storage.objects for update
using ( bucket_id = 'news-images' AND public.is_admin() );

-- Admins can delete
create policy "Admin DeleteNewsImages"
on storage.objects for delete
using ( bucket_id = 'news-images' AND public.is_admin() );
