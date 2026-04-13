-- ============================================================
-- 기존 dev user 재생성 (email_confirmed_at, encrypted_password 확실히 설정)
-- ============================================================

create extension if not exists pgcrypto with schema extensions;

do $$
declare
  v_user_id uuid;
  v_email text := 'dev@worldsoccer.app';
  v_password text := 'DevPass2026!';
begin
  -- 기존 dev user 정리 (cascade로 profiles/players 등 관련 데이터도 삭제됨)
  delete from auth.users where email = v_email;

  -- 새로 생성
  v_user_id := gen_random_uuid();

  insert into auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_user_meta_data,
    raw_app_meta_data,
    created_at,
    updated_at,
    is_sso_user,
    is_anonymous
  ) values (
    v_user_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    v_email,
    extensions.crypt(v_password, extensions.gen_salt('bf')),
    now(),
    jsonb_build_object('name', '개발자'),
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
    now(),
    now(),
    false,
    false
  );

  insert into auth.identities (
    id,
    user_id,
    provider_id,
    provider,
    identity_data,
    last_sign_in_at,
    created_at,
    updated_at
  ) values (
    gen_random_uuid(),
    v_user_id,
    v_user_id::text,
    'email',
    jsonb_build_object(
      'sub', v_user_id::text,
      'email', v_email,
      'email_verified', true
    ),
    now(),
    now(),
    now()
  );

  raise notice '개발용 계정 재생성: %', v_email;
end $$;
