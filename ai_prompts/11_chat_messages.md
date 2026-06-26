# Chat & Messages Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screens: Chat List, Direct Message, Room Invitations

### 01 Chat List Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: "Messages" headline + compose icon (new message)
- Filter tabs:
  - "All" (active, purple)
  - "Rooms" (invitation icon)
  - "Direct" (chat icon)
- Chat list (vertical):
  - Each item:
    - Avatar (circle, 48px)
    - Name: "Ahmed" or "Friday Night Room"
    - Last message preview (1 line, truncated, b-on-surface-muted)
    - Timestamp: "2m ago" (b-on-surface-secondary)
    - Unread badge (purple circle with count)
    - Room invitation badge (gold) if applicable
    - Swipe actions: Archive, Mute
- Empty state:
  - "No messages yet"
  - "Start a conversation or join a room"
  - CTA: "Create Room" (ghost-btn)

**Output:** HTML chat list screen

### 02 Direct Message Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top bar:
  - Back arrow
  - Other user's avatar + name + online status
  - Video call icon / Voice call icon (if available)
- Messages area (scrollable):
  - Your messages: Right-aligned, purple bubble
  <!-- RTL: Your messages: Left-aligned -->
  - Other's messages: Left-aligned, dark surface bubble
  <!-- RTL: Other's messages: Right-aligned -->
  - Timestamps between message groups
  - System messages: Centered, b-on-surface-muted
- Quick-action chips (above keyboard):
  - "Good game!" / "Nice move!" / "Let's play again" / "GG"
- Input area:
  - Text input with placeholder "Type a message..."
  - Attachment icon (image)
  - Emoji icon
  - Send button (purple, disabled if empty)

**Output:** HTML direct message screen

### 03 Room Invitation Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Shown as overlay/modal from chat list
- Room invitation card:
  - Host avatar + name
  - "Ahmed invited you to play Baloot"
  - Room name: "Friday Night"
  - Room type: "Private" / "Voice Only" / "Camera On"
  - Players: "2/4 — Waiting for 2 more"
  - Time: "Invited 3 minutes ago"
- Action buttons:
  - "Join Room" (primary-btn, gold gradient — excitement)
  - "Decline" (ghost-btn, b-on-surface-muted text)
- Auto-expire: "Expires in 30 minutes" countdown

**Output:** HTML room invitation modal

---

## Design Notes

- Chat should feel like a messaging app, not an afterthought
- Room invitations should be exciting — gold accents and clear CTA
- Unread badges must be prominent (doesn't want users to miss invitations)
- Quick-action chips reduce typing for common game messages
- Messages are intimate — purple for yours, dark surface for others
- All text supports RTL
- Message bubbles should use logical start/end alignment for RTL