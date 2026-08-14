# Bloot — Agent Guide

> **Last updated:** May 2026  
> **Purpose:** Quick-reference for any AI agent or developer working on the Bloot project.

---

## 1. Project Overview

| Field | Value |
|-------|-------|
| **Name** | Bloot (بلوت) |
| **Type** | Baloot social game & streaming platform |
| **Target market** | Gulf / MENA region |
| **Primary language** | Arabic (RTL-first) |
| **Secondary language** | English |
| **Platform** | Flutter mobile app (iOS + Android) |
| **Backend** | Firebase (Auth, Firestore, Storage, Cloud Functions) |
| **Voice/Video** | Agora RTC SDK |
| **Design theme** | Dark-only, premium card-room aesthetic |
| **MVP scope** | Dark-only, Arabic + English, 1:1 voice/video, 4-player rooms |

### What is Baloot?

Baloot is a traditional Saudi/Khaleeji trick-taking card game played by 4 players in 2 teams. Bloot uses the **32-card Saudi Baloot** deck (ranks 7‑8‑9‑10‑J‑Q‑K‑A); each player receives 8 cards. There are three game types:

- **Sun (صن)** — No trump suit; the buyer must score more than 60 card points.
- **Hokm (حكم)** — The trump suit is the face-up card's suit; the buyer must outscore the opponents.
- **Ashkal (أشكل)** — A special Sun bid where the face-up card is given to the bidder's partner.

Bloot wraps this game in a **social streaming platform** — players sit in virtual rooms with live voice and video, while spectators watch, chat, and support streamers.

---

## 2. Folder Structure

```
bloot/
├── android/                    # Android native shell
├── ios/                        # iOS native shell
├── lib/
│   ├── app/                    # App-level config, router, theme
│   │   ├── app.dart            # MaterialApp entry
│   │   ├── router.dart         # go_router configuration
│   │   └── theme.dart          # ThemeData & ColorManager
│   ├── core/
│   │   ├── constants/          # App-wide constants
│   │   ├── extensions/         # Dart extension methods
│   │   ├── network/            # Network client, interceptors
│   │   ├── services/           # Agora service, push notifications, etc.
│   │   └── utils/              # Helpers, validators, formatters
│   ├── features/
│   │   ├── auth/               # Authentication (Apple/Google/email sign-in, profile setup)
│   │   ├── home/               # Home feed, live streams, quick actions
│   │   ├── discover/           # Stream discovery, search, filters
│   │   ├── rooms/              # Room creation, lobby, private rooms
│   │   ├── game/               # Baloot game engine, game play UI
│   │   ├── stream/             # Stream viewing, spectator mode
│   │   ├── chat/               # DM, room chat, quick messages
│   │   ├── profile/            # User profile, stats, edit profile
│   │   └── settings/           # App settings, privacy, about
│   ├── shared/
│   │   ├── widgets/            # Reusable UI components
│   │   ├── models/             # Shared data models (freezed)
│   │   └── l10n/               # AR/EN localization files
│   └── main.dart               # Entry point
├── assets/
│   ├── fonts/                  # Cairo, Inter font files
│   ├── images/                 # Static images, icons
│   └── animations/             # Lottie / Rive files
├── test/                       # Unit & widget tests
├── docs/                       # Project documentation
│   ├── AGENTS.md               # This file
│   ├── DESIGN.md               # Master design system
│   ├── ai_context.md           # AI context & skills
│   ├── ai_project_context.md   # AI project context
│   ├── firebase_schema.md      # Firestore schema
│   ├── implementation_plan.md  # Master implementation plan
│   ├── master_flow_map.md      # All screen flow diagrams
│   └── coderules/              # Code rules directory
├── pubspec.yaml                # Dependencies
└── analysis_options.yaml       # Lint rules
```

---

## 3. Brand Identity Quick Reference

### Colors

| Token | Hex | Usage |
|-------|-----|-------|
| Purple | `#8B5CF6` | Primary actions, brand accent, team A |
| Purple Dark | `#7C3AED` | Pressed/active states |
| Purple Light | `#A78BFA` | Hover, secondary purple |
| Gold | `#F59E0B` | Wins, achievements, VIP, highlights |
| Gold Light | `#FBBF24` | Gold hover states |
| Gold Dark | `#D97706` | Gold pressed states |
| Black | `#0A0A0F` | Main background |
| Surface Elevated | `#161622` | Cards, elevated surfaces |
| Surface Muted | `#1E1E2E` | Input backgrounds, subtle surfaces |
| Surface Hover | `#252538` | Hover states on surfaces |
| On-Surface | `#FFFFFF` | Primary text |
| On-Surface Muted | `#9CA3AF` | Secondary text |
| On-Surface Secondary | `#6B7280` | Tertiary/caption text |
| Live Red | `#FF1A1A` | LIVE badge, streaming indicator |
| Success Green | `#22C55E` | Mic active, ready states |
| Error Red | `#EF4444` | Errors, mic muted, destructive |
| Info | `#3B82F6` | Informational, links |

### Typography

| Role | Font | Example Weight |
|------|------|---------------|
| Arabic text | Cairo | 400–800 |
| English/numbers | Inter | 300–700 |
| Arabic fallback | Cairo | — |
| Latin fallback | Inter | — |

### Design Principles

1. **Premium dark** — Every surface is dark; no light mode in MVP.
2. **Arabic-first RTL** — All layouts must work right-to-left; English as secondary.
3. **Voice/video critical** — Mic and camera status must be visible everywhere.
4. **Landscape game** — Game play screens lock to landscape; all other screens are portrait.
5. **Minimal game UI** — During active play, auto-hide controls; tap to reveal.

---

## 4. Build Order Reference

Generating UI or implementing features should follow this strict order:

| Phase | Prompt File | Screens | Why |
|-------|-------------|---------|-----|
| 1 | `01_onboarding.md` | Splash, Welcome | Brand identity, entry point |
| 1 | `02_authentication.md` | Login, OTP, Profile Setup | Trust, onboarding funnel |
| 2 | `03_home.md` | Home feed, streams, actions | Core experience |
| 2 | `04_discover_streams.md` | Discovery, search, filters | Social discovery |
| 3 | `06_private_room.md` | Room lobby, player seats | Social connection |
| 3 | `08_create_room.md` | Create room form | Room creation |
| 3 | `07_game_play.md` | Baloot game (landscape) | **Core value** |
| 4 | `05_watch_stream.md` | Stream viewer (spectator) | Engagement engine |
| 4 | `11_chat_messages.md` | DM, room chat, invitations | Social layer |
| 5 | `10_profile.md` | Profile, stats, edit | Identity |
| 5 | `12_settings_edge_cases.md` | Settings, errors, offline | Completion |

> **Always** include `00_master_rules.md` as preamble context before any generation.

---

## 5. Key Technical Notes

- **Dark-only MVP** — No light theme implementation. `ThemeData.brightness` is always `Brightness.dark`.
- **Landscape game** — Game play forces landscape; use `SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])`.
- **Voice/video is critical** — Agora RTC SDK integration; mic/camera indicators must render on every player square.
- **RTL-first** — Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `TextDirection.rtl` as default. LTR is the fallback.
- **Feature-first architecture** — Domain → Data → Presentation per feature folder.
- **State management** — `flutter_bloc` / Cubit; `freezed` for immutable models.
- **Navigation** — `go_router` with named routes.
- **Single app, two modes** — Player mode (playing the game) and Viewer mode (watching stream). Same app, different UI paths.
- **Firestore collections** — See `firebase_schema.md` for the complete schema.
- **Card game engine** — Baloot rules engine lives in `features/game/domain/`. Must handle Sun and Hokm game types.
- **Real-time** — Firestore real-time listeners for game state, Agora for voice/video channels.