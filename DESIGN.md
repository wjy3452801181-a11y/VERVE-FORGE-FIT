# VerveForge Design System

> The authoritative reference for every design decision in this codebase.
> When in doubt, consult this document before touching a pixel.

---

## Design Philosophy

**Monochrome restraint + single-moment electricity.**

99% of the UI lives in pure black, white, and grey. The palette is deliberately quiet — it signals focus, discipline, and premium sport-tech quality. Color is never decorative. It appears exactly once, at the moment that earns it: the achievement.

> "Restraint is strength. One volt of electricity is enough to change the weight of the whole screen."

### Three Tiers of Visual Hierarchy

1. **Monochrome base** — All navigation, cards, text, inputs, and layout. Black/white/grey only.
2. **AI Avatar sub-brand (blue)** — `AppColors.info` (#3498DB). Used exclusively within the AI Avatar feature: step indicators, primary CTAs, status dots, glass card borders. Never bleeds into other features.
3. **Verve Volt (achievement only)** — `AppColors.volt` (#E8FF00). Appears only at PR moments, leaderboard #1, achievement unlocks. Maximum 3 instances per screen. Never used for navigation, buttons, or backgrounds.

---

## Color System

**File:** `lib/app/theme/app_colors.dart`

### Brand Colors (Monochrome)

| Token | Value | Usage |
|---|---|---|
| `AppColors.primary` | `#111111` | Primary text, active icons, filled buttons (non-AI) |
| `AppColors.secondary` | `#555555` | Secondary text, inactive icons |
| `AppColors.accent` | `#333333` | Emphasis within monochrome context |

### Verve Volt — Achievement Color

| Token | Value | Usage |
|---|---|---|
| `AppColors.volt` | `#E8FF00` | PR numbers, leaderboard #1 badge, achievement unlock |
| `AppColors.voltDark` | `#9AB000` | Volt in light-mode backgrounds (contrast-safe) |
| `AppColors.voltGlow` | `#33E8FF00` | Dark mode glow behind volt elements |
| `AppColors.voltGlowStrong` | `#66E8FF00` | Strong glow (hover/active) |
| `AppColors.voltSurface` | volt 10% alpha | Chip/badge background in volt context |
| `AppColors.voltSurfaceStrong` | volt 18% alpha | Stronger chip background |

**Volt rules (STRICT):**
- ✅ PR (personal best) number highlight
- ✅ Leaderboard #1 badge
- ✅ Achievement unlock / badge celebration
- ✅ Current season champion identifier
- ✅ WorkoutBar full score (10/10)
- ❌ Navigation, buttons, card backgrounds, body text
- ❌ More than 3 instances on one screen

### AI Avatar Sub-brand — Info Blue

| Token | Value | Usage |
|---|---|---|
| `AppColors.info` | `#3498DB` | All interactive elements within AI Avatar feature |

**Info blue rules:**
- ✅ AI Avatar wizard step indicator (dots + connectors)
- ✅ AI Avatar primary CTA buttons (full gradient)
- ✅ AI Avatar secondary CTAs (outlined glass: blue border + blue text)
- ✅ Auto-reply status dot (enabled state)
- ✅ Error state retry button within AI Avatar
- ✅ Glass card border tint in AI Avatar pages
- ❌ Any feature outside AI Avatar
- ❌ Navigation bars, standard Feed/Gym/Challenge/Profile screens

### Semantic Colors

| Token | Value | Usage |
|---|---|---|
| `AppColors.success` | `#2ECC71` | Success states, completion indicators |
| `AppColors.warning` | `#F39C12` | Warning states, caution indicators |
| `AppColors.error` | `#E74C3C` | Error states, destructive actions |
| `AppColors.info` | `#3498DB` | Info states AND AI Avatar sub-brand (dual role) |

### Dark Mode Palette

| Token | Value | Usage |
|---|---|---|
| `AppColors.darkBackground` | `#0A0A0A` | Scaffold background |
| `AppColors.darkSurface` | `#141414` | Surface (sheets, nav bar bg) |
| `AppColors.darkCard` | `#1A1A1A` | Card background |
| `AppColors.darkCardHover` | `#222222` | Card hover/pressed |
| `AppColors.darkTextPrimary` | `#F5F5F5` | Primary text |
| `AppColors.darkTextSecondary` | `#999999` | Secondary/caption text |
| `AppColors.darkDivider` | `#2A2A2A` | Dividers |
| `AppColors.darkBorder` | `#333333` | Card borders |

### Light Mode Palette

| Token | Value | Usage |
|---|---|---|
| `AppColors.lightBackground` | `#FFFFFF` | Scaffold background |
| `AppColors.lightSurface` | `#F8F8F8` | Surface |
| `AppColors.lightCard` | `#F2F2F2` | Card background |
| `AppColors.lightTextPrimary` | `#111111` | Primary text |
| `AppColors.lightTextSecondary` | `#888888` | Secondary/caption text |
| `AppColors.lightDivider` | `#E0E0E0` | Dividers |
| `AppColors.lightBorder` | `#E5E5E5` | Card borders |

### Training Intensity Scale

10-step greyscale from `#E0E0E0` (intensity 1) to `#111111` (intensity 10). No color injection — intensity is communicated through greyscale depth only.

---

## Typography

**Font:** Inter (4 weights bundled)
**File:** `lib/app/theme/app_text_styles.dart`

| Token | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `AppTextStyles.h1` | 28px | 700 | 1.3 | Page hero titles |
| `AppTextStyles.h2` | 22px | 600 | 1.3 | Section headers, overlay titles |
| `AppTextStyles.h3` | 18px | 600 | 1.4 | Sub-section headers |
| `AppTextStyles.subtitle` | 16px | 500 | 1.4 | Card titles, avatar names |
| `AppTextStyles.body` | 15px | 400 | 1.5 | Body copy, list items |
| `AppTextStyles.caption` | 13px | 400 | 1.4 | Secondary info, timestamps |
| `AppTextStyles.label` | 12px | 500 | 1.3 | Chips, badges, small tags |
| `AppTextStyles.button` | 16px | 600 | 1.2 | Button labels |
| `AppTextStyles.number` | 24px | 700 | 1.2 | Stats, metrics, leaderboard numbers |

**Rules:**
- Never use font weights not in the bundle (100, 200, 300, 800, 900 are not available)
- Volt color on numbers only at achievement moments
- Body text is always monochrome; AI Avatar pages may use `AppColors.info` for name/title highlights

---

## Spacing System

**File:** `lib/app/theme/app_spacing.dart`
**Base unit:** 4px grid

### Core Scale

| Token | Value | Semantic |
|---|---|---|
| `AppSpacing.xs` | 4px | Micro gaps, icon-to-icon |
| `AppSpacing.sm` | 8px | Tight gaps, inline elements |
| `AppSpacing.md` | 16px | Component internal padding, standard gaps |
| `AppSpacing.lg` | 24px | Card-to-card spacing, section gaps |
| `AppSpacing.xl` | 32px | Major section separations |
| `AppSpacing.xxl` | 48px | Page-level breathing room |
| `AppSpacing.xxxl` | 64px | Hero sections |

### Semantic Shortcuts

| Token | Value | Usage |
|---|---|---|
| `AppSpacing.pageHorizontal` | 16px | Page left/right margin |
| `AppSpacing.pageVertical` | 24px | Page top/bottom margin |
| `AppSpacing.pagePadding` | symmetric(h:16, v:24) | Full page padding |
| `AppSpacing.cardPadding` | all(20px) | Card interior padding |
| `AppSpacing.cardPaddingCompact` | all(16px) | Compact card padding |
| `AppSpacing.cardMargin` | symmetric(h:16, v:6) | Card outer margin |
| `AppSpacing.buttonPadding` | symmetric(h:32, v:16) | Primary button padding |

### SizedBox Helpers

Prefer `AppSpacing.vGapMD` over `SizedBox(height: 16)` for semantic clarity:
- Vertical: `vGapXS` / `vGapSM` / `vGapMD` / `vGapLG` / `vGapXL` / `vGapXXL`
- Horizontal: `hGapXS` / `hGapSM` / `hGapMD` / `hGapLG`
- Non-standard: `vGap6`, `vGap10`, `vGap12`, `vGap14`, `vGap20`, `hGap10`, `hGap12`, `hGap14`

---

## Shape & Elevation

### Border Radius

| Usage | Radius |
|---|---|
| Cards (standard) | 24px (`cardTheme` default) |
| Buttons, chips | 14px |
| Input fields | 14px |
| Overlays, bottom sheets | 20px |
| Glassmorphism cards (AI Avatar) | `AppSpacing.md` = 16px |
| Small badges, dots | circular |

### Elevation

Material 3 with elevation 0 everywhere. Depth is expressed through:
- Border color (subtle, 0.5px)
- Background color differentiation (`darkCard` vs `darkSurface`)
- `BoxShadow` with low alpha (10-20%)
- For AI Avatar: `BlurRadius: 24` glow with `AppColors.info` at 20% alpha

---

## Component Patterns

### Cards

**Standard card:**
```dart
Card(
  // Uses cardTheme: 24px radius, darkCard bg, 0.5px border
  child: Padding(padding: AppSpacing.cardPaddingCompact, child: ...),
)
```

**Glassmorphism card (AI Avatar only):**
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(AppSpacing.md),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      padding: AppSpacing.cardPaddingCompact,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
        ),
      ),
    ),
  ),
)
```

### CTA Button Hierarchy

**One primary CTA per screen. Supporting actions are secondary.**

**Primary CTA (gradient fill):**
```dart
// Full gradient — only one per screen
decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(AppSpacing.md),
  gradient: const LinearGradient(
    colors: [AppColors.info, Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
)
// Text/icon: Colors.white
```

**Secondary CTA (outlined glass):**
```dart
// Outlined with blue border — supporting actions
decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(AppSpacing.md),
  color: isDark
      ? AppColors.info.withValues(alpha: 0.06)
      : AppColors.info.withValues(alpha: 0.04),
  border: Border.all(
    color: AppColors.info.withValues(alpha: 0.35),
    width: 1.5,
  ),
)
// Text/icon: AppColors.info (not white)
```

**Standard `FilledButton` (AI Avatar):**
```dart
FilledButton.styleFrom(backgroundColor: AppColors.info)
```

### Empty States

Every empty state must have three elements:
1. **Icon** — grey, 48-56px, communicates what's missing
2. **Primary message** — `AppTextStyles.subtitle`, centred
3. **Primary action** — `FilledButton` or outlined button with `AppColors.info`

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Icon(Icons.robot_2_outlined, size: 56, color: Colors.grey.shade400),
    AppSpacing.vGapMD,
    Text(l10n.aiAvatarEmpty, style: AppTextStyles.subtitle),
    AppSpacing.vGapSM,
    Text(l10n.aiAvatarEmptyTip, style: AppTextStyles.caption),
    AppSpacing.vGapLG,
    FilledButton.icon(
      onPressed: onAction,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(l10n.aiAvatarCreate),
      style: FilledButton.styleFrom(backgroundColor: AppColors.info),
    ),
  ],
)
```

### Error States

Every error state must have three elements:
1. **Icon** — `Icons.cloud_off_rounded`, grey, 48px
2. **Error message** — `AppTextStyles.subtitle`
3. **Retry button** — `FilledButton.icon` with `Icons.refresh_rounded`, `AppColors.info` bg

### Loading States

Use `CircularProgressIndicator()` centred with `Center(child: ...)`. No skeleton screens — the app uses real-time data.

---

## Motion & Animation

### Transition Durations

| Use Case | Duration | Curve |
|---|---|---|
| Micro interactions (tap feedback) | 200ms | `Curves.easeOut` |
| State changes (show/hide elements) | 250–300ms | `Curves.easeInOut` |
| Page-level transitions | 350ms | `Curves.easeInOut` |
| Data loading (spinner visibility) | 400ms | `Curves.easeIn` |
| Celebration overlays (entrance) | 500–600ms | `Curves.easeOut` |
| Auto-dismiss delays | 1500–2000ms | — |

### Celebration Overlay Pattern

Used for creation success moments (AI Avatar creation, achievement unlocks):

```dart
showGeneralDialog(
  context: context,
  barrierDismissible: false,
  barrierColor: Colors.black.withValues(alpha: 0.85),
  transitionDuration: const Duration(milliseconds: 500),
  transitionBuilder: (context, animation, _, child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
  },
  pageBuilder: (context, _, __) => OverlayWidget(),
);
// Auto-dismiss after 1800ms
```

---

## Accessibility

### Touch Targets

Minimum 44×44px for all interactive elements (per Apple HIG / WCAG 2.1).

### Semantics

**Decorative elements** (status dots, background shapes): wrap with `ExcludeSemantics`.

**Custom interactive elements** (InkWell, GestureDetector): wrap with `Semantics`:
```dart
Semantics(
  label: 'Descriptive action label',
  button: true,
  excludeSemantics: true,
  child: InkWell(onTap: ..., child: ...),
)
```

**Icon-only buttons**: always provide `tooltip`:
```dart
IconButton(
  icon: const Icon(Icons.clear_rounded),
  tooltip: context.l10n.aiChatClear,
  onPressed: ...,
)
```

**Non-interactive chips** (`onTap: null`): wrap with `ExcludeSemantics` to prevent screen readers from announcing untappable items.

### Color Contrast

- Primary text on dark background: `#F5F5F5` on `#0A0A0A` — passes AAA (18.6:1)
- Primary text on light background: `#111111` on `#FFFFFF` — passes AAA (18.1:1)
- `AppColors.info` (#3498DB) on dark bg (`#0A0A0A`): 4.9:1 — passes AA (requires 4.5:1 for normal text)
- `AppColors.volt` (#E8FF00) on dark bg: passes AAA — use without concern in dark mode
- `AppColors.volt` on light bg: use `AppColors.voltDark` (#9AB000) instead for text

---

## AI Avatar Feature — Design Language

The AI Avatar feature uses a distinct visual sub-language within the monochrome system.

### Background Gradient

Both Create wizard and Shared View use a directional gradient background:

```dart
// Dark mode
colors: [Color(0xFF0D0D0D), Color(0xFF1A1A2E), Color(0xFF16213E)]
// Light mode
colors: [Color(0xFFF8F9FA), Color(0xFFE8EAF6), Color(0xFFF3E5F5)]
```

### Avatar Emoji Display

Preset avatars use emoji rendered at 48px inside a circular container (96×96px) with `AppColors.info` border and glow.

### Information Hierarchy on Detail Page

**Required order (top to bottom):**
1. Avatar identity (emoji + name + owner info)
2. Primary CTA: Chat (full gradient, primary)
3. Personality traits (glassmorphism card)
4. Auto-reply status (glassmorphism card with status dot)
5. Secondary CTA: Share (outlined glass)
6. Secondary CTA: Update Profile / Profile Learning (outlined glass)

### Wizard Step Indicator

All 3 steps use `AppColors.info`:
- Active/completed dots: `AppColors.info` fill + `AppColors.info` glow shadow
- Connector lines: `AppColors.info`
- Active step label: `AppColors.info`
- Inactive dots: `Colors.grey.shade300` (light) / `Colors.grey.shade700` (dark)

---

## Localisation

**Files:** `lib/l10n/app_*.arb`
**Locales:** `en`, `zh`, `zh_CN`, `zh_TW`
**Generator:** `flutter gen-l10n` → `lib/l10n/app_localizations*.dart`

All user-visible strings must be in ARB files. Never hardcode Chinese or English strings in Dart source.

Key namespacing conventions:
- `ai*` — AI Avatar feature
- `workout*` — Training log feature
- `challenge*` — Challenge feature
- `gym*` — Gym discovery feature
- `buddy*` — Friend/buddy system
- `profile*` — User profile
- `settings*` — App settings
- `common*` — Shared across features

---

## Navigation

**Router:** `go_router` (`lib/app/router.dart`)

Navigation patterns:
- `context.push(route)` — push onto stack (detail pages, overlays)
- `context.go(route)` — replace stack (tab navigation)
- Redirect params: `?redirect=<encoded_path>` for post-auth deep links

AI Avatar routes (defined in `AppRoutes`):
- `AppRoutes.aiAvatarChat` — chat with own avatar
- `AppRoutes.aiAvatarChat/$avatarId` — chat with specific avatar
- `AppRoutes.aiAvatarShared/$shareToken` — public shared view

---

## Anti-Patterns

Do not:
- Use `AppColors.volt` outside achievement/PR moments
- Use `AppColors.info` outside the AI Avatar feature
- Create custom gradient buttons outside the established CTA pattern
- Use elevation > 0 (depth is expressed through color and borders)
- Skip empty states — "暂无数据" alone is never sufficient
- Skip error states — bare error text with no recovery action is never acceptable
- Hardcode colors as hex literals in feature code — always use `AppColors.*` tokens
- Add glassmorphism outside AI Avatar pages (it's a feature-specific visual language)
- Use font weights not in the bundle (400, 500, 600, 700 only)

---

*Last updated: 2026-03-22 — baseline from AI Avatar 7-pass design review*
