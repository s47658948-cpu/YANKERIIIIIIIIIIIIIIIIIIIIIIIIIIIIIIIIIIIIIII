-- YANKER COMPLETE DATABASE SCHEMA
-- Run this whole file in Supabase SQL Editor.
-- Safe for a new database and safe to re-run.

create extension if not exists pgcrypto;

create table if not exists public.requests (
  id uuid primary key,
  name text not null default '',
  username text not null,
  password_hash text not null default '',
  discord text not null default '',
  city_age integer not null default 0,
  real_age integer not null default 0,
  playtime text not null default '',
  reason text not null default '',
  status text not null default 'pending',
  reviewed_by text,
  reviewed_at bigint,
  created_at bigint not null
);

alter table public.requests add column if not exists rank text not null default '1';
update public.requests set rank = '1' where rank is null;
alter table public.requests add column if not exists city_age integer not null default 0;
alter table public.requests add column if not exists real_age integer not null default 0;
alter table public.requests add column if not exists playtime text not null default '';
alter table public.requests add column if not exists discord text not null default '';
alter table public.requests add column if not exists reason text not null default '';
alter table public.requests add column if not exists reviewed_by text;
alter table public.requests add column if not exists reviewed_at bigint;
alter table public.requests add column if not exists status text not null default 'pending';
alter table public.requests add column if not exists created_at bigint not null default 0;

create index if not exists requests_username_idx on public.requests(username);
create index if not exists requests_status_idx on public.requests(status);
create index if not exists requests_created_at_idx on public.requests(created_at desc);

create table if not exists public.members (
  id uuid primary key,
  name text not null default '',
  username text not null unique,
  password_hash text not null default '',
  discord text not null default '',
  rank text not null default '1',
  status text not null default 'online',
  joined_at bigint not null
);

alter table public.members add column if not exists password_hash text not null default '';
alter table public.members add column if not exists discord text not null default '';
alter table public.members add column if not exists rank text not null default '1';
alter table public.members add column if not exists status text not null default 'online';
alter table public.members add column if not exists joined_at bigint not null default 0;

create index if not exists members_rank_idx on public.members(rank);
create index if not exists members_joined_at_idx on public.members(joined_at desc);

create table if not exists public.site_users (
  id uuid primary key,
  username text not null unique,
  display_name text not null default '',
  password_hash text not null,
  role text not null default 'user',
  created_at bigint not null
);

create index if not exists site_users_username_idx on public.site_users(username);

create table if not exists public.announcements (
  id uuid primary key,
  title text not null default '',
  body text not null default '',
  author text not null default '',
  created_at bigint not null,
  published boolean not null default true
);

create index if not exists announcements_created_at_idx
  on public.announcements(created_at desc);

create table if not exists public.tickets (
  id uuid primary key,
  username text not null,
  name text not null default '',
  subject text not null default '',
  status text not null default 'open',
  category text not null default 'member',
  created_at bigint not null,
  updated_at bigint not null
);

alter table public.tickets add column if not exists category text not null default 'member';
alter table public.tickets add column if not exists updated_at bigint not null default 0;

update public.tickets
set category = 'member'
where category is null or trim(category) = '';

create index if not exists tickets_username_idx on public.tickets(username);
create index if not exists tickets_category_idx on public.tickets(category);
create index if not exists tickets_status_idx on public.tickets(status);
create index if not exists tickets_updated_at_idx on public.tickets(updated_at desc);

create table if not exists public.ticket_messages (
  id uuid primary key,
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  sender text not null default 'user',
  sender_name text not null default '',
  body text not null default '',
  created_at bigint not null
);

alter table public.ticket_messages add column if not exists sender_role text not null default 'user';
alter table public.ticket_messages add column if not exists sender_username text not null default '';
alter table public.ticket_messages add column if not exists message text not null default '';

alter table public.ticket_messages add column if not exists sender text not null default 'user';
alter table public.ticket_messages add column if not exists sender_name text not null default '';
alter table public.ticket_messages add column if not exists body text not null default '';

create index if not exists ticket_messages_ticket_idx
  on public.ticket_messages(ticket_id, created_at);

create table if not exists public.penalties (
  id uuid primary key,
  username text not null,
  name text not null default '',
  reason text not null,
  amount numeric not null default 0,
  issued_by text not null default '',
  created_at bigint not null
);

create index if not exists penalties_username_idx on public.penalties(username);
create index if not exists penalties_created_at_idx on public.penalties(created_at desc);

-- Optional persistent settings used by the site.
create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at bigint not null default 0
);

update public.ticket_messages
set sender = coalesce(nullif(sender,''), sender_role, 'user')
where sender is null or sender = '';

update public.ticket_messages
set sender_name = coalesce(nullif(sender_name,''), sender_username, '')
where sender_name is null or sender_name = '';

update public.ticket_messages
set body = coalesce(nullif(body,''), message, '')
where body is null or body = '';

-- Refresh PostgREST schema cache after creating the tables.
notify pgrst, 'reload schema';
