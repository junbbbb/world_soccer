-- 팀 로고 업로드용 Storage 버킷 + RLS.
-- 경로 컨벤션: team-logos/{team_id}/{file_id}.{ext}
-- 첫 폴더명이 team_id 라서 권한 체크에 사용.

-- ── 버킷 생성 (public read) ──
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'team-logos',
  'team-logos',
  true,
  2 * 1024 * 1024,  -- 2MB
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

-- ── 읽기: public (버킷 public=true 로도 허용되지만 명시) ──
create policy "team_logos_public_read" on storage.objects
  for select
  using (bucket_id = 'team-logos');

-- ── 쓰기/수정/삭제: 해당 팀의 admin 만 ──
-- path 의 첫 폴더 = team_id 로 해석. (storage.foldername(name))[1]
create policy "team_logos_admin_insert" on storage.objects
  for insert
  with check (
    bucket_id = 'team-logos'
    and exists (
      select 1 from public.team_members tm
      where tm.team_id::text = (storage.foldername(name))[1]
        and tm.player_id = auth.uid()
        and tm.role = 'admin'
    )
  );

create policy "team_logos_admin_update" on storage.objects
  for update
  using (
    bucket_id = 'team-logos'
    and exists (
      select 1 from public.team_members tm
      where tm.team_id::text = (storage.foldername(name))[1]
        and tm.player_id = auth.uid()
        and tm.role = 'admin'
    )
  );

create policy "team_logos_admin_delete" on storage.objects
  for delete
  using (
    bucket_id = 'team-logos'
    and exists (
      select 1 from public.team_members tm
      where tm.team_id::text = (storage.foldername(name))[1]
        and tm.player_id = auth.uid()
        and tm.role = 'admin'
    )
  );
