# Home Screen Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screen: Home (Main Feed)

### 01 Home Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top bar:
  - User avatar (circle, 40px) — tap to go to Profile
  - Display name + Level badge (e.g., "Ahmed • Level 5")
  - Gold coins/points indicator (icon + number, gold color)
  - Notification bell icon (with red dot if unread)
- Hero Banner (card with gradient):
  - Background: Purple-to-dark gradient with card suit pattern overlay
  - Headline: "Baloot Live"
<!-- RTL: "بلوت مباشر" -->
  - Subtitle: "Your voice, your passion, your table"
<!-- RTL: "صوتك، شغفك، طاولتك" -->
  - CTA button: "Discover Streams" (primary-btn, full width)
  - Subtle animated glow on banner edges
- Quick Actions Row (horizontal scroll, 4 cards):
  1. **Play with Friends** — Icon: people — "Create or join a private room"
  2. **Voice Tables** — Icon: mic — "Play with voice only, no camera"
  3. **Live Stream** — Icon: videocam — "Watch players live"
  4. **Tournaments** — Icon: emoji_events — "Compete and win prizes"
  - Each card: purple-tinted bg, icon, title, brief description
  - Tap to navigate to respective screen
- Section header: "Live Now" with "See All" link (b-purple)
- Live Streams List (vertical scroll):
  - Each stream card (`stream-card`):
    - Thumbnail: Player/room photo or gradient placeholder
    - LIVE badge (red, animated pulse) — top left corner
    - Viewer count with eye icon — top right
    - Stream title: "Ahmed & Khalid vs Faisal Band"
    - Host avatar (small) + Host name
    - Room type badge: "Baloot" / "Streaming" / "Competitive"
    - Player count: "2/4 players"
    - Tap to watch stream
- Section header: "Upcoming Tournaments" with "View All" link
- Tournament preview cards (horizontal scroll):
  - Tournament name
  - Date/time
  - Prize pool (gold accent)
  - Participants: "23/64"
  - Entry fee or "Free Entry"
  - Gold border for premium tournaments
- Bottom navigation (5 items):
  - Home (house icon, active, purple)
  - Discover (search icon)
  - Play (play_circle icon, center, larger, gold outline)
  - Chat (chat icon)
  - Profile (person icon)

**Empty State (No streams):**
- Illustration: Cards scattered, subtle purple glow
- "No live streams right now"
- "Start your own room or check back soon"
- CTA: "Create Room" (ghost-btn)

**Output:** HTML home screen

---

## Design Notes

- Home screen is the hub — must feel alive and social
- LIVE badges must be prominent and animated
- Quick action cards should feel premium, not generic game buttons
- Stream cards need to clearly show: who's streaming, what type, viewer count
- Gold coins displayed prominently (gamification element)
- Bottom nav with center "Play" button as focal point
- The play button in center should be slightly raised/larger
- Pull to refresh for new streams
- Skeleton loading for all sections
- All text supports RTL