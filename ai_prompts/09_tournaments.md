# Tournaments Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screens: Tournament List, Tournament Detail

### 01 Tournament List Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: Back arrow + "Tournaments" headline
<!-- RTL: "البطولات" -->
- Filter tabs (horizontal scroll):
  - "All" (active, purple)
  - "Active Now"
  - "Upcoming"
  - "Completed"
  - "My Tournaments"
- Tournament cards (vertical list):
  - Each card (`stream-card` style):
    - Tournament banner (gradient bg with trophy icon)
    - Status badge: "Live" (red) / "Upcoming" (purple) / "Completed" (gray)
    - Tournament name: "Friday Championship"
    - Prize pool: "5,000 coins" (gold accent, trophy icon)
    - Date/time: "Starts in 2h 30m" or "Starts Today 8:00 PM"
    - Participants: "23/64 players"
    - Entry fee: "Free" (green) or "100 coins" (gold)
    - Game type: "Sun & Hokm" / "Hokm Only"
    - "Join" button or "View" if already started
    - Gold border for premium tournaments
- Empty state (No tournaments):
  - Trophy illustration
  - "No tournaments right now"
  - "Check back soon or create your own room"
  - CTA: "Create Room" (ghost-btn)

**Output:** HTML tournament list screen

### 02 Tournament Detail Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: Back arrow + Tournament name
- Hero section:
  - Tournament banner (large, gradient)
  - Status badge (Live/Upcoming/Completed)
  - Tournament name (large headline)
  - Prize pool prominently: "5,000 Coins" (gold, large)
- Info cards:
  - **Details card:**
    - Date & Time
    - Game Type: "Sun & Hokm"
    - Format: "Single Elimination" / "Round Robin"
    - Rounds: "5 rounds"
    - Entry: "Free" or "100 coins"
  - **Rules card:**
    - "Standard Khaleeji Rules"
    - "120 points for Sun (152 for Hokm)"
    - "Best of 8 rounds for Hokm"
    - "30 seconds per turn"
    - Expandable "Full Rules" link
  - **Participants card:**
    - Player count: "23/64"
    - Horizontal scroll of participant avatars
    - "View All" link
  - **Bracket card** (if tournament is active):
    - Visual bracket showing matchups
    - Your position highlighted
    - Round indicators
- Bottom sticky bar:
  - "Join Tournament" (primary-btn, gold gradient if free entry, regular purple if paid)
  - Or "Tournament Full" (gray, disabled) if max participants reached
  - Or "Withdraw" (ghost-btn, red text) if already joined

**Prize Distribution (collapsible):**
- 1st Place: "2,500 coins" (gold trophy)
- 2nd Place: "1,500 coins" (silver trophy)
- 3rd Place: "700 coins" (bronze trophy)
- 4th Place: "300 coins"

**Output:** HTML tournament detail screen

---

## Design Notes

- Tournaments should feel prestigious — gold accents, trophy icons
- Prize pool must be the most prominent element
- Status badges must be clear and accurate
- Time countdown should create urgency
- Participant avatars create social proof
- Bracket visualization should be intuitive
- Join button should be impossible to miss
- Gold borders for premium/high-stakes tournaments
- All text supports RTL