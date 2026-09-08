-- انسخ هذا كامـلًا في Supabase ← SQL Editor ← Run
create table if not exists aa_users (id text primary key, data jsonb not null default '{}'::jsonb, deleted boolean not null default false, updated_at timestamptz not null default now());
create table if not exists aa_auctions (id text primary key, data jsonb not null default '{}'::jsonb, deleted boolean not null default false, updated_at timestamptz not null default now());
create table if not exists aa_bids (id text primary key, auction_id text not null, data jsonb not null default '{}'::jsonb, deleted boolean not null default false, updated_at timestamptz not null default now());
create table if not exists aa_announcements (id text primary key, data jsonb not null default '{}'::jsonb, deleted boolean not null default false, updated_at timestamptz not null default now());
create table if not exists aa_threads (id text primary key, data jsonb not null default '{}'::jsonb, deleted boolean not null default false, updated_at timestamptz not null default now());
create table if not exists aa_messages (id text primary key, thread_id text not null, data jsonb not null default '{}'::jsonb, deleted boolean not null default false, updated_at timestamptz not null default now());

create index if not exists aa_users_u on aa_users(updated_at);
create index if not exists aa_auctions_u on aa_auctions(updated_at);
create index if not exists aa_bids_u on aa_bids(updated_at);
create index if not exists aa_announcements_u on aa_announcements(updated_at);
create index if not exists aa_threads_u on aa_threads(updated_at);
create index if not exists aa_messages_u on aa_messages(updated_at);

create or replace function aa_touch() returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

do $$ declare t text; begin
  foreach t in array array['aa_users','aa_auctions','aa_bids','aa_announcements','aa_threads','aa_messages'] loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists app_all on %I', t);
    execute format('create policy app_all on %I for all to anon using (true) with check (true)', t);
    execute format('drop trigger if exists aa_touch_t on %I', t);
    execute format('create trigger aa_touch_t before insert or update on %I for each row execute function aa_touch()', t);
  end loop; end $$;
