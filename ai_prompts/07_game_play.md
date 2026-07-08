# Game Play Screen Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## IMPORTANT: LANDSCAPE-FIRST DESIGN

This is the MOST IMPORTANT screen in the app. It MUST be designed for landscape orientation first. The game table fills the center, video squares are around the table, cards are at the bottom.

## Screen: Baloot Game Play (Landscape)

**Requirements:**
- Full landscape orientation (locked)
- Dark background (`#0A0A0F`)
- Status bar hidden, immersive mode
- No bottom navigation (hidden during game)

### Layout (Landscape):

```
┌─────────────────────────────────────────────────────────┐
│ [Back] [Room: "Friday Night"]  [Score: A:8 B:12]  [⚙️]  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│              [Partner Video Square]                     │
│              [Name] [Mic] [Score]                       │
│                                                         │
│  [Opponent]    ┌──────────────────┐    [Opponent]       │
│  [Video]      │                    │    [Video]        │
│  [Name]       │   GAME TABLE       │    [Name]        │
│  [Mic]        │                    │    [Mic]         │
│               │   [Played Cards]   │                    │
│               │   [Middle Area]    │                    │
│               └──────────────────┘                    │
│                                                         │
│              [Your Video Square]                         │
│              [Your Name] [Mic] [Camera]                 │
│                                                         │
│    ┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐┌─┐  [Your Cards Fan]        │
│    └─┘└─┘└─┘└─┘└─┘└─┘└─┘└─┘                           │
│                                                         │
│  [Chat] [Mic] [Cam] [Voice] [Settings] [Leave]          │
└─────────────────────────────────────────────────────────┘
```

### Top Bar (overlay, semi-transparent):
- Back/exit button (left)
<!-- RTL: Back (right) -->
- Room name (center, truncated if long)
- Score display: "Us: 8 — Them: 12" (gold for leading team)
- Settings gear icon (right)
<!-- RTL: Settings (left) -->

### Video Squares (4 positions):
- **Partner (top center):** Purple team border
- **Opponent 1 (left center):** Gold team border
<!-- RTL: Opponent 1 (right center) -->
- **Opponent 2 (right center):** Gold team border
<!-- RTL: Opponent 2 (left center) -->
- **You (bottom center):** Purple team border
- Each video square:
  - 16:9 ratio, rounded corners
  - Player camera feed or avatar (dark gradient circle with initials)
  - Player name (below video, small)
  - Mic indicator (bottom right of video):
    - Green dot (mic on)
    - Red dot with line (mic muted)
  - Turn indicator (glowing border when it's their turn)
  - Camera toggle indicator (small camera/camera-off icon)
  - If camera off: Show stylish avatar with player initials on dark bg

### Game Table (center):
- Dark green felt texture (subtle gradient: `from-green-900/20 to-green-950/30`)
- Rounded rectangle with subtle border (`border-green-800/30`)
- Currently played cards in center (if any)
- Trick count indicator
- Trump suit indicator (if Hokm declared): Gold suit icon
- Current game type: "Sun" / "Hokm — Hearts" etc.
- Score prominently displayed above table

### Player's Cards (bottom, fanned):
- 8 cards (or fewer as game progresses)
- Cards fanned horizontally with overlap
- Selected card rises up slightly
- Tap to select/play a card
- Valid cards slightly brighter, invalid cards slightly dimmed
- Card back design: Purple gradient with subtle gold pattern
- Card face: Clean, readable, high contrast

### Score Display:
- "Us: [score] — Them: [score]"
- Leading team's score in gold
- Round target: "/120" (Sun) or varies for Hokm rounds
- Current round indicator: "Round 3/8"

### Controls Bar (bottom, overlay):
- Chat button (opens chat overlay)
  <!-- RTL positioning note -->
- Mic toggle (on/off with visual feedback)
- Camera toggle (on/off with visual feedback)
- Voice settings (speaker/earpandyce mode)
- Settings (game rules, sound volume)
- Leave Room (with confirmation dialog)

### Game State Overlays:
- **Waiting for cards:** "Dealing..." animation
- **Your turn:** Glowing border on your cards, "Your Turn" text
- **Partner's turn:** Subtle highlight on partner's video
- **Hokm declaration:** Trump suit indicator (trump is the face-up card's suit)
- **Trick won:** Brief animation showing who won the trick
- **Round end:** Score summary overlay
- **Game end:** Winner announcement with celebration

**Output:** HTML game play screen (landscape orientation)

---

## Design Notes

- THIS IS THE MOST CRITICAL SCREEN — it must feel immersive, like sitting at a real card table
- Landscape-first design is MANDATORY
- Video squares must be clear but not dominate — game table is the focus
- Cards must be readable even at small sizes
- Turn indicators must be obvious — whose turn is it?
- Score must be always visible
- Mic/camera toggles should be easy to hit but not accidentally
- Auto-hiding UI after 3 seconds of inactivity (tap to show again)
- Sound effects for: card play, trick win, round end
- Gold accents for wins, achievements, scores
- No clutter during active play — info overlays only when needed
- All text supports RTL
- Player positions must flip in RTL (opponents swap sides)