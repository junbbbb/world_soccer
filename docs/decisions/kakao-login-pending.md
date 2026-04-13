# 카카오 로그인 보류

## 상태: 보류 (2026-04-12)

## 문제
- Supabase GoTrue 서버가 카카오 OAuth 요청 시 `account_email` scope를 기본 포함
- 카카오 개발자 콘솔에서 `account_email` 동의항목은 **비즈 앱** 전환 후에만 추가 가능
- 클라이언트에서 scopes 파라미터를 지정해도 서버 기본값이 우선 적용됨
- 결과: KOE205 (`invalid_scope`) 에러

## 해결 방법
1. **카카오 개발자 콘솔 → 비즈 앱 전환** (무료, 개인 개발자 가능)
2. 전환 후 동의항목에서 `account_email`을 **선택 동의**로 추가
3. Supabase에서 "Allow users without an email" 이미 ON 상태이므로, 유저가 이메일 동의를 거부해도 로그인 가능

## Supabase 설정 (완료)
- Kakao provider: Enabled
- Allow users without an email: ON

## 카카오 동의항목 (완료)
- 닉네임: 필수 동의 (목적: 서비스 내 사용자 식별 및 프로필 표시)
- 프로필 이미지: 선택 동의 (목적: 서비스 내 프로필 이미지 표시)
- account_email: 미설정 (비즈 앱 전환 필요)

## TODO
- [ ] 카카오 개발자 콘솔에서 비즈 앱 전환
- [ ] account_email 동의항목 추가 (선택 동의)
- [ ] 로그인 화면에 카카오 로그인 버튼 복원
