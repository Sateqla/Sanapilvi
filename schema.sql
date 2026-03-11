-- Supabase Schema for Live Word Cloud Application

-- 1. Create the Sessions table
create table sessions (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Create the Words table
create table words (
  id uuid default gen_random_uuid() primary key,
  session_id uuid references sessions(id) on delete cascade not null,
  word text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Set up Row Level Security (RLS)
-- Enable RLS on both tables
alter table sessions enable row level security;
alter table words enable row level security;

-- For this MVP, we will allow anonymous read/write access so anyone with the link can participate
create policy "Allow public insert to sessions" on sessions for insert with check (true);
create policy "Allow public select on sessions" on sessions for select using (true);

create policy "Allow public insert to words" on words for insert with check (true);
create policy "Allow public select on words" on words for select using (true);

-- 4. Enable Realtime updates
-- Check if the realtime publication exists, if not, create it
-- Then add our 'words' table to it so we can subscribe to changes
alter publication supabase_realtime add table words;

-- 5. Automated Cleanup (Scheduled Delete)
-- Requires pg_cron extension. You can run this in the Supabase SQL editor to
-- schedule a daily job that deletes sessions (and cascadingly words) older than 2 months.
-- create extension if not exists pg_cron;
-- select cron.schedule(
--   'delete-old-sessions',   -- name of the cron job
--   '0 3 * * *',             -- run every day at 03:00 GMT
--   $$ delete from sessions where created_at < now() - interval '2 months' $$
-- );
