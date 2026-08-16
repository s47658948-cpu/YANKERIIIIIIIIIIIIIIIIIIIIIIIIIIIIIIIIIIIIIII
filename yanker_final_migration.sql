-- YANKER FINAL MIGRATION
-- Safe to run in Supabase SQL Editor.
-- Creates the ticket/cafe/penalty tables before any UPDATE.

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

create table if not exists public.ticket_messages (
  id uuid primary key,
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  sender text not null default 'user',
  sender_name text not null default '',
  body text not null default '',
  created_at bigint not null
);

-- Compatibility columns if an earlier migration created different names.
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

alter table public.penalties add column if not exists paid boolean not null default false;
alter table public.penalties add column if not exists paid_at bigint;
update public.penalties set paid = false where paid is null;

create index if not exists penalties_username_idx on public.penalties(username);
create index if not exists penalties_created_at_idx on public.penalties(created_at desc);

create table if not exists public.site_users (
  id uuid primary key,
  username text unique not null,
  display_name text not null default '',
  password_hash text not null,
  role text not null default 'user',
  created_at bigint not null
);

create index if not exists site_users_username_idx on public.site_users(username);

-- Done.
