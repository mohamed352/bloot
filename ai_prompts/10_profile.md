# Profile Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screens: Profile, Stats, Edit Profile

### 01 Profile Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Header section:
  - Profile photo (large, 100px circle)
  - Gold ring if VIP/high level
  - Display name (headline)
  - Username: @username (b-on-surface-muted)
  - Level badge: "Level 12" with progress bar to next level
  - Stats row (3 items):
    - Wins: "47" (with trophy icon, gold)
    - Games Played: "128" (with game icon)
    - Followers: "1.2K" (with people icon)

- Quick actions row:
  - "Edit Profile" (ghost-btn)
  - "Share Profile" (ghost-btn)
  - Settings gear icon

- Tab bar (3 tabs):
  1. **Stats**
  2. **History**
  3. **About**

**Stats Tab:**
- Win rate card: "36.7%" with circular progress (gold)
- Game type breakdown:
  - Sun: 32 games (25% win rate)
  - Hokm: 96 games (42% win rate)
- Level progress: "Level 12 — 3,450/5,000 XP to Level 13"
- Achievements section (horizontal scroll):
  - Achievement badges: "First Win", "10 Streak", "Hokm Master", "Stream Star"
  - Gold for earned, gray for locked
  - Tap to see details

**History Tab:**
- Recent games list (vertical):
  - Each item:
    - Game result: "Won" (green) / "Lost" (red)
    - Score: "87-33" (your score bold, gold if won)
    - Game type: "Sun" / "Hokm"
    - Duration: "23 min"
    - Players: Small avatars of 4 players
    - Date: "2 hours ago"
  - Filter: All / Won / Lost

**About Tab:**
- Bio: "Baloot lover since 2015. Come play!"
- Member since: "Joined January 2026"
- Favorite mode: "Hokm"
- Region: "Saudi Arabia"

**Output:** HTML profile screen

### 02 Edit Profile Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: Back arrow + "Edit Profile"
- Profile photo:
  - Current photo (large circle)
  - Camera icon overlay
  - "Change Photo" button
- Form fields:
  - Display name input (current value pre-filled)
  - Username input (current value pre-filled, @ prefix)
  - Bio textarea (current bio, max 150 characters, character counter)
  - Region selector (dropdown)
  - Favorite mode selector: "Sun" / "Hokm" / "Both"
- Save button (primary-btn, full width, purple)
- Cancel text link

**Output:** HTML edit profile screen

---

## Design Notes

- Profile should feel like a social gaming profile, not a settings page
- Gold accents on achievements and wins create aspiration
- Level progress bar should be visible and motivating
- Stats should be honest and detailed (no hiding losses)
- History items should be scannable — won/lost at a glance
- Achievements create long-term goals and retention
- Edit profile should be simple and fast
- All text supports RTL