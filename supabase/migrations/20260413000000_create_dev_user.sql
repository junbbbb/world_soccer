-- ============================================================
-- 개발용 테스트 계정 생성 (dev@worldsoccer.app)
-- DEV 로그인 버튼(kDebugMode에서만 노출)이 이 계정으로 로그인.
-- ============================================================

do $$
declare
  v_user_id uuid;
  v_email text := 'dev@worldsoccer.app';
  v_password text := 'DevPass2026!';
begin
  -- 이미 존재하면 skip (멱등성)
  select id into v_user_id from auth.users where email = v_email;
  if v_user_id is not null then
    raise notice '개발용 계정이 이미 존재합니다: %', v_email;
    return;
  end if;

  v_user_id := gen_random_uuid();

  -- auth.users insert
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
    crypt(v_password, gen_salt('bf')),
    now(),
    jsonb_build_object('name', '개발자'),
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
    now(),
    now(),
    false,
    false
  );

  -- auth.identities insert (이메일/비밀번호 로그인 플로우에 필요)
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

  raise notice '개발용 계정 생성 완료: %', v_email;
end $$;
