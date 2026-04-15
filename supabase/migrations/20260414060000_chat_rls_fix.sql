-- ============================================================
-- chat RLS 무한 재귀 수정
--
-- 기존: chat_room_members_select 정책 안에서 다시 chat_room_members 를
-- SELECT 하도록 작성되어 PostgreSQL 이 재귀 감지(42P17)로 차단.
-- chat_rooms_select / chat_messages_select 도 chat_room_members 를
-- 참조하므로 같은 문제.
--
-- 해결: SECURITY DEFINER 헬퍼 함수로 RLS 를 우회하여
-- 순환 참조를 끊는다. (Supabase 공식 권장 패턴)
-- ============================================================

-- 재귀 유발 정책 제거
drop policy if exists "chat_rooms_select"        on public.chat_rooms;
drop policy if exists "chat_room_members_select" on public.chat_room_members;
drop policy if exists "chat_messages_select"     on public.chat_messages;
drop policy if exists "chat_messages_insert"     on public.chat_messages;

-- ── 헬퍼 ──

create or replace function public.is_chat_room_member(p_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.chat_room_members
    where room_id = p_room_id and player_id = auth.uid()
  );
$$;

comment on function public.is_chat_room_member(uuid)
  is 'RLS 재귀 방지용. 현재 유저가 해당 방의 멤버인지 반환.';

-- ── 정책 재작성 ──

-- 방: 내가 멤버면 조회
create policy "chat_rooms_select" on public.chat_rooms
  for select using (public.is_chat_room_member(id));

-- 멤버 목록: 같은 방의 멤버끼리 서로 조회
create policy "chat_room_members_select" on public.chat_room_members
  for select using (public.is_chat_room_member(room_id));

-- 메시지 조회: 방 멤버만
create policy "chat_messages_select" on public.chat_messages
  for select using (public.is_chat_room_member(room_id));

-- 메시지 작성: 본인 + 방 멤버
create policy "chat_messages_insert" on public.chat_messages
  for insert with check (
    sender_id = auth.uid() and public.is_chat_room_member(room_id)
  );
