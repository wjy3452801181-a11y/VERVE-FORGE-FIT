# VerveForge

**Record · Discover · Challenge**

A fitness social app for HYROX, CrossFit, Yoga, and Pilates enthusiasts in major cities worldwide.

> [中文版 README](README_ZH.md)

---

## Features

### Core
- **Workout Logging** — Record training sessions with photos, Apple Health sync, intensity tracking (1-10 scale)
- **Gym Directory** — User-contributed gym database with map view (AMap SDK), reviews and favorites
- **Buddy Discovery** — Find nearby training partners by sport type, city, and experience level
- **Real-time Chat** — 1-on-1 messaging with buddies, plan workouts together
- **Challenges** — Create or join fitness challenges, check-in tracking, leaderboards
- **Social Feed** — Share training updates, like, comment, follow other athletes

### AI Avatar
- **AI Training Partner** — Create a personalized AI avatar that reflects your fitness personality
- **Auto-Reply** — AI avatar can respond to messages based on your training style and preferences
- **Profile Sharing** — Share your AI avatar's public profile with a unique link
- **Smart Content Filter** — Keyword-based filtering for safe AI-generated responses

### UI System
- **Cap Card** — Glassmorphism card components (Step Card / Quote Card / Capability Card / Stats Card)
- **Dark & Light Mode** — True dark mode (#0A0A0A) with adaptive theme switching
- **Web Preview** — Standalone HTML/CSS preview for the Cap Card design system

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.24+ (Material 3, Dark/Light Mode) |
| Backend | Supabase (Auth + PostgreSQL + Realtime + Storage + Edge Functions) |
| State Management | Riverpod |
| Routing | go_router |
| Maps | AMap Flutter SDK (GCJ-02 coordinate system) |
| Health Data | Apple HealthKit via `health` plugin |
| Auth | Apple Sign-In + Supabase Auth |
| Web | Flutter Web + Custom CSS (Cap Card UI System) |
| Font | Inter (400/500/600/700/900) |

## Getting Started

### Prerequisites

- Flutter SDK >= 3.24.0
- Dart SDK >= 3.6.2
- Xcode 15+ (for iOS)
- A Supabase project — [supabase.com](https://supabase.com)
- AMap developer account — [lbs.amap.com](https://lbs.amap.com) (optional, for map features)

### Setup

```bash
# Clone
git clone https://github.com/wjy3452801181-a11y/VERVE-FORGE-FIT.git
cd VERVE-FORGE-FIT

# Environment variables
cp .env.production.example .env
# Edit .env with your Supabase URL, Anon Key, and AMap keys

# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run

# Run on Web
flutter run -d chrome
```

### Database Setup

Run the SQL migration files in `supabase/migrations/` in order (00001 → 00024) on your Supabase project via the SQL Editor.

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── app/
│   ├── app.dart               # MaterialApp config
│   ├── router.dart            # go_router routes
│   └── theme/
│       ├── app_colors.dart    # Color system (B&W + tint/glow)
│       ├── app_theme.dart     # Dark & Light ThemeData
│       └── app_text_styles.dart
├── core/
│   ├── constants/             # Supabase tables, AMap config
│   ├── errors/                # Error handler
│   ├── extensions/            # Context extensions
│   └── utils/                 # Validators
├── features/
│   ├── ai_avatar/             # AI avatar creation, chat, sharing
│   ├── auth/                  # Login (Apple Sign-In)
│   ├── buddy/                 # Buddy discovery & requests
│   ├── challenge/             # Fitness challenges
│   ├── chat/                  # Real-time messaging
│   ├── gym/                   # Gym directory & map
│   ├── notification/          # Push notifications
│   ├── post/                  # Social feed
│   ├── profile/               # User profile & settings
│   └── workout/               # Workout logging & stats
├── l10n/                      # i18n (zh_CN, en)
└── shared/widgets/
    ├── cap_card.dart           # Glassmorphism card system
    ├── avatar_widget.dart
    ├── sport_type_icon.dart
    └── ...

web/
├── index.html                 # Flutter Web entry
├── cap-card-preview.html      # Cap Card UI preview page
└── styles/cap-card.css        # Cap Card CSS (CSS variables, dark mode)

supabase/
├── migrations/                # 24 SQL migration files
├── functions/                 # Edge Functions (AI avatar logic)
└── snippets/                  # SQL verification scripts
```

## Cap Card UI System

The Cap Card is a shared component library with 4 card types:

| Type | Description |
|------|-------------|
| **Step Card** | Gradient border, numbered badge, progress bar (light→dark) |
| **Quote Card** | Left accent line, quotation mark, author attribution |
| **Capability Card** | Glowing icon area, bold title, tag labels |
| **Stats Card** | 3-column data display with dividers |

Preview: open `web/cap-card-preview.html` in any browser. Supports dark/light toggle.

## Localization

- **简体中文** — Default
- **English** — International users

## Privacy & Compliance

- **PIPL** (China) — Data export, account deletion, explicit consent
- **PDPO** (Hong Kong) — Privacy policy in Traditional Chinese and English

## License

[MIT](LICENSE)
