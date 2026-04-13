-- ============================================================
-- dev user 재생성 (500 "Database error querying schema" 수정)
-- identities.provider_id는 email provider의 경우 이메일 주소여야 함.
-- ============================================================

create extension if not exists pgcrypto with schema extensions;

do $$
declare
  v_user_id uuid;
  v_email text := 'dev@worldsoccer.app';
  v_password text := 'DevPass2026!';
begin
  -- 기존 dev user 및 identities 정리 (cascade)
  delete from auth.users where email = v_email;

  v_user_id := gen_random_uuid();

  -- auth.users insert (모든 필수 token 필드 빈 문자열로 명시)
  insert into auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at,
    is_anonymous
  ) values (
    v_user_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    v_email,
    extensions.crypt(v_password, extensions.gen_salt('bf')),
    now(),
    null,
    '',
    null,
    '',
    null,
    '',
    '',
    null,
    now(),
    jsonb_build_object('provider', 'email', 'providers', jsonb_build_array('email')),
    jsonb_build_object('name', '개발자'),
    false,
    now(),
    now(),
    null,
    null,
    '',
    '',
    null,
    '',
    0,
    null,
    '',
    null,
    false,
    null,
    false
  );

  -- auth.identities insert
  -- 중요: email provider의 경우 provider_id는 이메일 주소여야 함.
  insert into auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) values (
    v_email,
    v_user_id,
    jsonb_build_object(
      'sub', v_user_id::text,
      'email', v_email,
      'email_verified', true,
      'phone_verified', false
    ),
    'email',
    now(),
    now(),
    now()
  );

  raise notice '개발용 계정 재생성 완료: % (id: %)', v_email, v_user_id;
end $$;
