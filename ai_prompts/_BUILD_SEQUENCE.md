# Bloot AI Generation Build Sequence

Follow this strict order to build the Bloot UI.

---

## The Golden Rule

**ALWAYS** include `00_master_rules.md` as the "System Context" or "Preamble" for **EVERY** single prompt. The AI considers this the "Constitution".

---

## Phase 1: The Foundation (Entry)

1. **01_onboarding.md**
   - Why: Establishes brand identity and premium feel. High visual impact, low logic.
   - Screens: Splash, Welcome

2. **02_authentication.md**
   - Why: Phone-based auth with OTP, profile setup. Trust building for social platform.
   - Screens: Login, OTP, Complete Profile

---

## Phase 2: The Core (Home & Discovery)

3. **03_home.md**
   - Why: The primary user experience. Live streams, quick actions, tournaments.
   - Screens: Home (Hero, Quick Actions, Live Streams, Tournaments)

4. **04_discover_streams.md**
   - Why: Stream discovery with filters. The social discovery engine.
   - Screens: Discover Streams (Tabs, Filters, Stream Cards)

---

## Phase 3: The Game (Rooms & Play)

5. **06_private_room.md**
   - Why: Room lobby with 4 player seats. Where social connection happens before game.
   - Screens: Room Lobby (4 Seats, Mic/Camera, Ready States)

6. **08_create_room.md**
   - Why: Room creation form. Enables social play.
   - Screens: Create Room (Name, Type, Settings)

7. **07_game_play.md**
   - Why: THE MOST IMPORTANT SCREEN. The Baloot game in landscape. Where core value lives.
   - Screens: Game Play (4 Video Squares, Table, Cards, Score, Controls)

---

## Phase 4: The Social (Streaming & Chat)

8. **05_watch_stream.md**
   - Why: Stream viewer for spectators. The social engine that drives engagement.
   - Screens: Stream Viewer (4 Videos, Game Table, Chat, Interactions)

9. **11_chat_messages.md**
   - Why: Direct messages, room invitations, chat during game.
   - Screens: Chat List, DM, Room Invitations

---

## Phase 5: Identity (Profile & Settings)

10. **10_profile.md**
    - Why: Player stats, level, previous games. Social proof and identity.
    - Screens: Profile, Stats, Edit Profile

11. **12_settings_edge_cases.md**
    - Why: App settings, privacy, legal, error states.
    - Screens: Settings, Privacy, Terms, Error, Offline, Loading, Success

---

## Phase 6: Competition & Admin (Tournaments + Admin Dashboard)

12. **09_tournaments.md**
    - Why: Competitive play, prize pools. Long-term retention driver.
    - Screens: Tournament List, Tournament Detail, Join Tournament

13. **13_admin_dashboard.md**
    - Why: Platform management. Critical for operations, moderation, tournament creation, and economy.
    - Screens: Dashboard, Users, Reports, Tournaments, Games, Rooms, Streams, Economy, Achievements, Leaderboards, Notifications, Analytics, Settings

---

## Build Tips

### For Stitch/Cursor:
"Using the styles defined in `00_master_rules.md`, generate the UI described in `[Filename]`..."

### Testing Order:
1. Generate screen
2. Open in browser (mobile viewport for portrait, landscape for game)
3. Check touch targets (min 48px, 44px for game controls)
4. Verify colors match tokens (purple/gold/dark theme)
5. Add `dir="rtl"` and verify layout doesn't break
6. Test landscape orientation for game screens
7. Verify LIVE badges are prominent and animated
8. Confirm video squares have mic/camera indicators

### Quality Gates:
- Dark theme only (no light mode in MVP)
- LIVE badge always visible and animated on streams
- Player names and scores clearly visible
- Mic/camera status on every player video square
- Game table fills center of landscape screen
- Cards are readable and tappable
- Gold used sparingly for wins/achievements/VIP
- Purple is the dominant accent, not gold
- No generic game UI patterns — this is premium, not casual gaming