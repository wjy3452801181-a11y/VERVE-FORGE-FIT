# VerveForge

**Record · Discover · Challenge**

A fitness social app for HYROX, CrossFit, Yoga, and Pilates enthusiasts in major cities.

> [中文版 README](README_ZH.md)

## Features

- **Workout Logging** — Record training sessions with photos, sync from Apple Health
- **Gym Directory** — User-contributed gym database with map view (AMap SDK)
- **Buddy Discovery** — Find nearby training partners by sport type and city
- **Real-time Chat** — Connect and plan workouts with your buddies
- **Challenges** — Create or join fitness challenges, track progress on leaderboards
- **Social Feed** — Share training updates, like and comment

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.27+ (Material 3, Dark Mode) |
| Backend | Supabase (Auth + PostgreSQL + Realtime + Storage + Edge Functions) |
| State Management | Riverpod |
| Routing | go_router |
| Maps | AMap Flutter SDK (GCJ-02 coordinate system) |
| Health Data | Apple HealthKit via `health` plugin |
| CI/CD | GitHub Actions → TestFlight |

## Getting Started

### Prerequisites

- Flutter SDK >= 3.24.0
- Xcode 15+ (for iOS development)
- A Supabase project ([supabase.com](https://supabase.com))
- AMap developer account ([lbs.amap.com](https://lbs.amap.com))

### Setup

```bash
# Clone the repository
git clone https://github.com/your-username/verveforge.git
cd verveforge

# Copy environment variables
cp .env.example .env
# Edit .env with your Supabase URL, keys, and AMap keys

# Run setup script
chmod +x scripts/setup.sh
./scripts/setup.sh

# Run the app
flutter run
```

### Database Setup

Run the SQL migration files in `supabase/migrations/` in order (00001 to 00014) on your Supabase project via the SQL Editor.

## Project Structure

```
lib/
├── main.dart              # App entry point
├── app/                   # App config (theme, router)
├── core/                  # Shared utilities, constants, errors
├── features/              # Feature modules
│   └── <feature>/
│       ├── data/          # Repository (Supabase interaction)
│       ├── domain/        # Models
│       ├── presentation/  # Pages and widgets
│       └── providers/     # Riverpod state management
├── l10n/                  # Localization (zh_CN, zh_TW, en)
└── shared/                # Shared widgets and providers
```

## Localization

VerveForge supports three languages:
- Simplified Chinese — Default
- Traditional Chinese — Hong Kong users
- English

## Privacy and Compliance

- **PIPL** (China) — Data export, account deletion, explicit consent
- **PDPO** (Hong Kong) — Privacy policy in Traditional Chinese and English

## License

[MIT](LICENSE)
