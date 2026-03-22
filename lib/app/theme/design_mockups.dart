// ============================================================
// VerveForge — Screen Mockups (Design Reference)
// This file is a DESIGN DOCUMENT only — not production code.
// It documents the intended visual layout of key screens
// using ASCII art + widget pseudocode.
// ============================================================

// ──────────────────────────────────────────────────────────
// SCREEN 1: FEED (动态流)
// ──────────────────────────────────────────────────────────
//
// ┌─────────────────────────────────────────────────┐
// │  StatusBar (dark/transparent)                    │
// ├─────────────────────────────────────────────────┤
// │  VerveForge                    🔔  [+ Post]      │  AppBar h=56
// ├─────────────────────────────────────────────────┤
// │  [All] [Following] [Trending]                    │  TabBar (pill style)
// ├─────────────────────────────────────────────────┤
// │                                                  │
// │  ┌───────────────────────────────────────────┐  │
// │  │ 🏃 Alex Chen  ·  2h ago          ···      │  │  CapCard standard
// │  │                                            │  │  cardMargin: h16,v6
// │  │  PR today on back squat 💪                 │  │
// │  │  180kg × 3 — new personal best!            │  │
// │  │                                            │  │
// │  │  [IMG][IMG]                                │  │  2-col image grid
// │  │                                            │  │
// │  │  ❤ 47   💬 12   ↗ Share                   │  │  actions row
// │  └───────────────────────────────────────────┘  │
// │                                                  │
// │  ┌───────────────────────────────────────────┐  │
// │  │ 🏋 Maria K  ·  4h ago  HYROX 🏷️          │  │  CapCard w/ badge
// │  │                                            │  │
// │  │  Race in 12 days. Station splits:          │  │
// │  │                                            │  │
// │  │  SkiErg ——— 4:12  ██████░░░░              │  │  mini progress bar
// │  │  RowErg ——— 4:31  █████░░░░░              │  │  AppRadius.bXS
// │  │  Burpees ── 2:55  ███░░░░░░░              │  │
// │  │                                            │  │
// │  │  ❤ 89   💬 6    ↗ Share                   │  │
// │  └───────────────────────────────────────────┘  │
// │                                                  │
// ├─────────────────────────────────────────────────┤
// │  Feed  │  Gyms  │  ⊕  │  Profile  │  Nearby     │  NavBar h=60
// └─────────────────────────────────────────────────┘
//
// Token usage:
//   background: AppColors.darkBackground / lightBackground
//   cardBg: AppColors.darkCard / lightCard
//   cardRadius: AppRadius.bLG (24px)
//   cardPadding: AppSpacing.cardPadding (20px)
//   actionGap: AppSpacing.sm (8px)
//   divider: AppColors.darkDivider (0.5px)

// ──────────────────────────────────────────────────────────
// SCREEN 2: CHALLENGE DETAIL (挑战赛)
// ──────────────────────────────────────────────────────────
//
// ┌─────────────────────────────────────────────────┐
// │  ←  HYROX Community Race          Week 3 / 8   │  AppBar + progress chip
// ├─────────────────────────────────────────────────┤
// │                                                  │
// │  ┌───────────────────────────────────────────┐  │
// │  │                                            │  │  CapCard.capability
// │  │  🏆  Current Season                        │  │  icon=trophy, glow
// │  │                                            │  │
// │  │  Season 3 — Spring Sprint                  │  │
// │  │  12,450 pts  to next rank ▓▓▓▓▓▓░░░       │  │  progress bar
// │  │                                            │  │
// │  │  Rank: SILVER  →  GOLD  (2,550 pts away)  │  │
// │  └───────────────────────────────────────────┘  │
// │                                                  │
// │  LEADERBOARD                          [Your pos] │  section header (label)
// │  ──────────────────────────────────────────────  │  divider 0.5px
// │                                                  │
// │  1  🥇  Jordan P.   ████████████  34,200         │
// │  2  🥈  Liu Wei     ██████████░░  31,800         │
// │  3  🥉  Sam Torres  █████████░░░  29,400         │
// │  ──                                              │
// │  ⋮                                               │
// │  16  YOU  Alex C.   ████░░░░░░░░  18,900         │  highlighted row
// │                                                  │
// │  [Join Challenge]                                │  ElevatedButton full-w
// │                                                  │
// ├─────────────────────────────────────────────────┤
// │  Feed  │  Gyms  │  ⊕  │  Profile  │  Nearby     │
// └─────────────────────────────────────────────────┘
//
// Token usage:
//   rankBar: LinearGradient(intensityGradient[6..10])
//   buttonRadius: AppRadius.bMD (14px)
//   buttonHeight: 52px (from theme)
//   sectionLabel: AppTextStyles.label + letterSpacing 1.2

// ──────────────────────────────────────────────────────────
// SCREEN 3: WORKOUT CREATE (记录训练)
// ──────────────────────────────────────────────────────────
//
// ┌─────────────────────────────────────────────────┐
// │  ←  Log Workout                            ✓    │
// ├─────────────────────────────────────────────────┤
// │                                                  │
// │  WORKOUT TYPE                                    │  label (AppTextStyles.label)
// │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐        │
// │  │  🏋  │  │  🏃  │  │  🤸  │  │  ···  │        │  Chip grid
// │  │HYROX │  │ Run  │  │Cross │  │ More │        │  AppRadius.bPill (20px)
// │  └──────┘  └──────┘  └──────┘  └──────┘        │  selectedColor: cardTint15
// │                                                  │
// │  ┌─────────────────────────────────────────┐    │  CapCard.step (1/3)
// │  │  Step 1 of 3                            │    │
// │  │  ────────────────────────────────░░░    │    │  progress bar
// │  │                                         │    │
// │  │  DURATION           DATE                │    │
// │  │  [  01 : 24  ]     [Mar 22, 2026  ]    │    │  inline inputs
// │  │                                         │    │
// │  │  INTENSITY                              │    │
// │  │  ◉──────────────────○  7 / 10          │    │  Slider
// │  │  ████████████████░░░░  HARD             │    │  intensityGradient[6]
// │  └─────────────────────────────────────────┘    │
// │                                                  │
// │  NOTES                                           │
// │  ┌─────────────────────────────────────────┐    │  TextField
// │  │  How did it feel?                        │    │  AppRadius.bMD input
// │  └─────────────────────────────────────────┘    │
// │                                                  │
// │  ┌─────────────────────────────────────────┐    │
// │  │              Next  →                    │    │  ElevatedButton
// │  └─────────────────────────────────────────┘    │  radius: AppRadius.bMD
// │                                                  │
// └─────────────────────────────────────────────────┘
//
// Token usage:
//   stepCard: CapCard.step, stepIndex=1, totalSteps=3
//   intensitySlider: custom track using intensityGradient
//   inputFill: AppColors.darkCard / lightCard
//   inputFocusedBorder: primary 2px, AppRadius.bMD

// ──────────────────────────────────────────────────────────
// SCREEN 4: AI AVATAR (AI 分身)
// ──────────────────────────────────────────────────────────
//
// ┌─────────────────────────────────────────────────┐
// │  ←  My AI Avatar              [Edit]  [Share ↗] │
// ├─────────────────────────────────────────────────┤
// │                                                  │
// │          ┌────────────┐                          │
// │          │    [AVT]   │   Hero: 80×80 circular   │
// │          └────────────┘   border: 2px white      │
// │                                                  │
// │         Alex's AI Double                         │  h2 center
// │       Responds like you would 🤖                 │  caption center
// │                                                  │
// │  AUTO-REPLY         ●────── ON                   │  Switch row
// │  ──────────────────────────────────────────────  │
// │                                                  │
// │  ┌───────────────────────────────────────────┐  │  CapCard.capability
// │  │  🧠  Personality                           │  │
// │  │  Competitive · Supportive · Detail-focused │  │  chip row
// │  └───────────────────────────────────────────┘  │
// │                                                  │
// │  ┌───────────────────────────────────────────┐  │  CapCard.capability
// │  │  💬  Speaking Style                        │  │
// │  │  Direct and data-driven, uses sports refs  │  │  body text
// │  └───────────────────────────────────────────┘  │
// │                                                  │
// │  RECENT CONVERSATIONS                            │  label
// │  ──────────────────────────────────────────────  │
// │  Sam T.  "Will you make it to HYROX this..."   ▶ │
// │  Liu W.  "What's your training this week?"     ▶ │
// │                                                  │
// │  ┌─────────────────────────────────────────┐    │
// │  │      Chat with your Avatar  💬           │    │  ElevatedButton
// │  └─────────────────────────────────────────┘    │
// │                                                  │
// └─────────────────────────────────────────────────┘
//
// Token usage:
//   avatar: CircleAvatar, border: BoxDecoration circle
//   capabilityCards: CapCard.capability with glow shadow
//   autoReplySwitch: Switch widget, activeColor: AppColors.success

// ──────────────────────────────────────────────────────────
// SCREEN 5: PROFILE (我的)
// ──────────────────────────────────────────────────────────
//
// ┌─────────────────────────────────────────────────┐
// │  My Profile                      ⚙              │  AppBar
// ├─────────────────────────────────────────────────┤
// │                                                  │
// │  ┌──────┐  Alex Chen                            │
// │  │ [IMG]│  @alexchen · SILVER 🥈                │  avatar + name row
// │  └──────┘  "Train like a machine, live..."      │  bio
// │                                                  │
// │  ┌──────────┬──────────┬──────────┐             │
// │  │  4,200   │   127    │   48     │             │
// │  │  Points  │ Workouts │  Buddies │             │  stats row
// │  └──────────┴──────────┴──────────┘             │
// │                                                  │
// │  TRAINING                                        │  section header label
// │  ─────────────────────────────────────           │
// │  📅  Workout Calendar                          ▶ │  ListTile h=52
// │  📋  Workout History                           ▶ │
// │  🏢  Find Gyms                                 ▶ │
// │  ⭐  Saved Gyms                                ▶ │
// │  🤖  AI Avatar                                 ▶ │
// │                                                  │
// │  SOCIAL                                          │
// │  ─────────────────────────────────────           │
// │  🏆  Challenges                                ▶ │
// │  👥  Buddies                                   ▶ │
// │  💬  Messages                                  ▶ │
// │                                                  │
// │  ACCOUNT                                         │
// │  ─────────────────────────────────────           │
// │  🔒  Privacy Policy                            ▶ │
// │                                                  │
// ├─────────────────────────────────────────────────┤
// │  Feed  │  Gyms  │  ⊕  │  Profile  │  Nearby     │
// └─────────────────────────────────────────────────┘
//
// Token usage:
//   stats divider: Container h=1px, AppColors.darkDivider
//   section header: AppTextStyles.label, letterSpacing 1.2, AppColors.secondary
//   listTile: ListTile, AppSpacing.vGapSM between items
//   avatar: CachedNetworkImage, CircleAvatar 72px

// ──────────────────────────────────────────────────────────
// COMPONENT LIBRARY SUMMARY
// ──────────────────────────────────────────────────────────
//
// Design Token Status:
// ✅ AppColors   — 6 groups, 30+ tokens
// ✅ AppTextStyles — 9 styles (h1–number), Inter
// ✅ AppSpacing  — 10 base values + 20 EdgeInsets + SizedBox shortcuts
// ✅ AppRadius   — 7 values + 10 BorderRadius constants
// ✅ AppShadows  — 5 levels + iconGlow + overlay + textSubtle
// ✅ AppAnimations — 6 durations + 5 curves + factories + Tweens
// ✅ design_system.dart — single barrel export
//
// Component Status:
// ✅ CapCard     — 4 types, glassmorphism, hover, now uses tokens
// 🔲 StatBadge  — inline metric display (to build)
// 🔲 WorkoutBar — horizontal intensity bar (to build)
// 🔲 RankChip   — Bronze/Silver/Gold pill (to build)
// 🔲 SkeletonCard — shimmer loading state (to build)
