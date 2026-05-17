# Private Room Lobby Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screen: Private Room Lobby

### 01 Room Lobby Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top bar:
  - Back arrow (left)
  <!-- RTL: Back arrow (right) -->
  - Room name (center, `text-[18px]`, bold)
  - Room type badge: "Private" / "Voice Only" / "Live Stream" / "Camera On"
  - Settings gear icon (right)
  <!-- RTL: Settings icon (left) -->

- Room info card:
  - Room code: "ABC123" (large, monospaced, purple bg)
  - Copy button (copy icon + "Copy Code")
  - Share button (share icon + "Share Link")
  - Room status: "Waiting for players..." (animated dots)

- Player seats (2x2 grid):
  - Each seat (`player-video` variant, larger):
    - **Occupied seat:**
      - Player avatar/video (large, centered)
      - Player name below
      - Level badge (e.g., "Lv. 5")
      - Team indicator: "Team A" (purple accent) / "Team B" (gold accent)
      - Mic status:
        - Green circle + mic icon (mic on)
        - Red circle + mic-off icon (mic muted)
      - Camera status:
        - Camera icon visible (camera on)
        - Camera-off icon (camera off)
      - Ready status:
        - "Ready" badge (green, bold)
        - "Not Ready" badge (gray)
      - Kick button (visible only to room creator, small X icon, top right of seat)
    - **Empty seat:**
      - Dashed border circle (purple, low opacity)
      - "Waiting..." text (b-on-surface-muted)
      - Pulsing animation on border
      - Invite button: "Invite" (ghost-btn, small)
  - Seat positions labeled:
    - Bottom: "You" (always)
    - Top: "Your Partner"
    - Left: "Opponent 1"
    <!-- RTL: Right: "Opponent 1" -->
    - Right: "Opponent 2"
    <!-- RTL: Left: "Opponent 2" -->

- Room settings summary:
  - Voice: "On" / "Off" (with mic icon)
  - Camera: "On" / "Off" (with camera icon)
  - Spectators: "Allowed" / "Not Allowed"
  - Room type: "Private" / "Public"

- Bottom action bar:
  - "Leave Room" (ghost-btn, left)
  <!-- RTL: Leave Room (right) -->
  - "Start Game" (primary-btn, center, disabled until all 4 players ready)
  <!-- Conditions for Start Game:
    - All 4 seats filled
    - All players marked "Ready"
    - Only room creator can start -->

- Chat drawer (swipe up from bottom):
  - Compact chat with room messages
  - Quick messages: "Ready!", "One moment", "Let's go!"
  - Full chat input

**Output:** HTML room lobby screen

---

## Design Notes

- The lobby should feel social — like entering a card room
- Player video/audio status must be crystal clear
- Empty seats should feel inviting, not empty
- Room code should be easy to copy and share
- "Start Game" button MUST be disabled until all conditions are met
- Team assignment must be visible (who's on which team)
- The room creator has special privileges (start game, kick players)
- Kick button only visible to the room creator
- After game starts, this screen transitions to the game play screen
- All text supports RTL