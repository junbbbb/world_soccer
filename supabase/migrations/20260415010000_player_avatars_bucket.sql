-- ============================================================
-- 선수 아바타 스토리지 버킷
-- 경로: {player_id}/avatar_{ts}.{ext}
-- 읽기 public. 쓰기/수정/삭제는 본인 (경로 첫 폴더 == auth.uid()::text).
-- ============================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'player-avatars',
  'player-avatars',
  true,
  2097152, -- 2MB
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

-- 읽기 public
drop policy if exists "player_avatars_read" on storage.objects;
create policy "player_avatars_read" on storage.objects
  for select using (bucket_id = 'player-avatars');

-- 본인 업로드
drop policy if exists "player_avatars_insert_own" on storage.objects;
create policy "player_avatars_insert_own" on storage.objects
  for insert with check (
    bucket_id = 'player-avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- 본인 수정
drop policy if exists "player_avatars_update_own" on storage.objects;
create policy "player_avatars_update_own" on storage.objects
  for update using (
    bucket_id = 'player-avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- 본인 삭제
drop policy if exists "player_avatars_delete_own" on storage.objects;
create policy "player_avatars_delete_own" on storage.objects
  for delete using (
    bucket_id = 'player-avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
