# Discover Streams Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screen: Stream Discovery

### 01 Discover Streams Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: Back arrow + "Discover Streams" headline
<!-- RTL: "اكتشف البثوث" -->
- Search bar:
  - Placeholder: "Search players, rooms, or streams"
  - Search icon left (right in RTL)
  - Clear button when text entered
  - `search-input` style with dark surface bg
- Filter tabs (horizontal scroll, sticky):
  - "Popular" (active, purple underline)
  - "New"
  - "Top Rated"
  - "Tournaments"
  - "Voice Only"
  - Following"
- Advanced filter button (top right): Opens bottom sheet
  - Room type: Baloot / Streaming / Competitive / All
  - Status: Playing / Waiting / Finished
  - Language: Arabic / English / All
  - Apply / Reset
- Stream grid (2 columns on mobile):
  - Each stream card (`stream-card`):
    - Large thumbnail (16:9 ratio)
    - LIVE badge (top left, red pulse)
    - Viewer count (top right, with eye icon)
    - Stream type badge: "Baloot" (purple) / "Stream" (gold) / "Tournament" (green)
    - Host avatar (small circle) + Host name (below thumbnail)
    - Stream title (1-2 lines max, truncate)
    - Gold "Support" count with star icon
    - Purple "Join Stream" button (small, card footer)
    - Tap card → Watch Stream screen
- Pull to refresh
- Infinite scroll loading

**Empty State (No results):**
- "No streams found"
- "Try different filters or start your own"
- CTA: "Create Room" (ghost-btn)

**Search Results:**
- Grouped by: "Players" / "Rooms" / "Streams"
- Player items: Avatar + name + level + "Follow" button
- Room items: Room name + player count + type badge + "Join" button

**Output:** HTML discover streams screen

---

## Design Notes

- Discover should feel like browsing a live platform
- LIVE badges must be immediately visible on every card
- Stream thumbnails should auto-play preview on hover (when implemented)
- Purple for game-related badges, Gold for streaming/VIP, Green for tournaments
- Search should be fast and responsive
- Filters should be easily accessible but not overwhelming
- All cards should have subtle hover/press animation
- Support RTL for Arabic search