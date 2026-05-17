# Watch Stream Screen Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## IMPORTANT: This screen should work in BOTH portrait and landscape

The viewer experience needs to show: 4 player video squares + game table + chat. In portrait, video squares are smaller. In landscape, they fill the width.

## Screen: Watch Live Stream

**Requirements:**
- Dark background (`#0A0A0F`)
- Top bar (overlay on video):
  - Back arrow (left)
  <!-- RTL: Back arrow (right) -->
  - LIVE badge (red, pulsing)
  - Viewer count with eye icon
  - Stream title (truncated if too long)
  - Report button (flag icon, right side)
  <!-- RTL: Report button (left side) -->

- Main content area (portrait layout):
  - Top section: 4 player video squares in 2x2 grid
    - Each square (`player-video`):
      - Player camera feed or avatar placeholder
      - Player name (bottom, small text)
      - Team indicator: "Team A" (purple border) or "Team B" (gold border)
      - Mic status icon (green if active, red if muted)
      - Camera status icon (small, overlay)
    - Grid spacing: 8px gap
  - Middle section: Game Table
    - Compact Baloot table view
    - Currently played cards in center
    - Score display: "Team A: 8 — Team B: 12" with gold for leading team
    - Turn indicator: "Ahmed's Turn" with subtle highlight
    - Tab toggle: "Table View" / "Cards View"
  - Bottom section: Chat & Interactions
    - Chat messages area (vertical scroll, capped height)
      - Each message: Avatar + name + text + timestamp
      - System messages: "[Player] joined the room" in b-on-surface-muted
    - Chat input:
      - Text input with placeholder "Say something..."
      - Send button (purple)

- Floating interaction buttons (right side, portrait):
<!-- RTL: Left side -->
  - Like (heart icon) with count
  - Gift/Send (diamond icon, gold)
  - Share (share icon)
  - Follow host (person+ icon)

- Landscape orientation:
  - Full-width 4 video squares across top
  - Game table fills center
  - Chat as side panel (right side)
  <!-- RTL: Chat on left side -->
  - Interaction buttons float over game table

**Viewer Rules:**
- Viewer CANNOT play, only watches
- Viewer CAN chat, like, send gifts, follow
- 4 video squares always visible
- Game table shows current state
- Cards of individual players are NOT shown (only played cards visible)

**Output:** HTML watch stream screen (portrait + landscape notes)

---

## Design Notes

- This is a VIEWER-ONLY experience — no game controls
- Video squares must be prominent and always visible
- LIVE badge must be animated and visible at all times
- Game table should be readable but compact (viewer doesn't need full interactivity)
- Chat should scroll smoothly without blocking the game view
- Interaction buttons should not obstruct the game table
- Mic status is critical — viewers want to know who's talking
- Team colors (purple vs gold) should be immediately recognizable
- Consider: option to expand/collapse chat
- Viewer count should update in real-time
- All text supports RTL