# TODOS

## AI Avatar

- **ISSUE-004** — `RateLimitException` caught via fragile string matching
  **Priority:** P3
  `ai_avatar_share_sheet.dart:427`: `e.toString().contains('429')` should be `e is RateLimitException`

- **ISSUE-005** — All core dependencies pinned to `any` — no reproducible builds
  **Priority:** P2
  `pubspec.yaml`: 28 dependencies use `any`. `flutter_riverpod` 2→3 is a breaking major version.
  Pin all to current resolved versions from `pubspec.lock`.

- **ISSUE-006** — `AiAvatarChatPage` force-unwraps `avatar.avatarUrl!` without type-system guarantee
  **Priority:** P2
  `ai_avatar_chat_page.dart:1198,1215`: Use `if (avatar == null || avatar.avatarUrl == null) return null` pattern.

- **ISSUE-007** — 4 unimplemented navigation stubs (silent no-ops)
  **Priority:** P1
  `feed_page.dart:436` post detail · `ai_avatar_detail_page.dart:207` edit · `buddy_list_page.dart:116` buddy profile · `settings_page.dart:210` open source licenses

## Completed

- **ISSUE-001** — `copyWith` cannot clear nullable fields — **Completed:** v1.0.2 (2026-03-23)
- **ISSUE-002** — `_isSharing` spinner hangs when `shareLink` is null — **Completed:** v1.0.2 (2026-03-23)
- **ISSUE-003** — Shared avatar chat opens viewer's own avatar — **Completed:** v1.0.2 (2026-03-23)
- **F2** — Guest chat path mis-classifies all history messages as AI bubbles — **Completed:** v1.0.2 (2026-03-23)
- **F7** — Sentinel force-cast `as String?` unsafe on wrong-typed input — **Completed:** v1.0.2 (2026-03-23)
- **F10** — Empty-string avatarId from trailing-slash deep links reaches Edge Function — **Completed:** v1.0.2 (2026-03-23)
