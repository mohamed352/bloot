# Create Room Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screen: Create Room

### 01 Create Room Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: Back arrow + "Create Room" headline
<!-- RTL: "إنشاء غرفة" -->
- Form (scrollable):

  **Room Name Section:**
  - Room name input
  - Placeholder: "Friday Night Baloot"
  - Max 30 characters
  - Character counter
  - Optional field (auto-generated if empty)

  **Room Type Selection (3 cards, single select):**
  1. **Private Room**
     - Icon: lock
     - "Play with friends"
     - "Invite-only, no spectators"
     - Purple border when selected
  2. **Public Room**
     - Icon: public
     - "Open to anyone"
     - "Anyone can join if seats available"
     - Purple border when selected
  3. **Live Stream**
     - Icon: videocam
     - "Stream for viewers"
     - "Anyone can watch, only invited can play"
     - Gold border when selected

  **Game Settings Section:**

  - **Voice Chat** (toggle switch)
    - Default: On
    - Subtitle: "Players can hear each other"
  - **Camera** (toggle switch)
    - Default: Off
    - Subtitle: "Players can see each other"
  - **Allow Spectators** (toggle switch)
    - Default: Off
    - Subtitle: "Viewers can watch without playing"
    - Note: Only available for Public and Stream room types

  **Advanced Settings (collapsible):**
  - **Minimum Level** (dropdown)
    - Options: "None", "Level 3", "Level 5", "Level 10"
    - Subtitle: "Only players above this level can join"
  - **Game Speed** (selection chips)
    - "Normal" (30s per turn)
    - "Fast" (15s per turn)
    - "Relaxed" (60s per turn)
  - **Room Password** (optional input)
    - For private rooms
    - "Add a password for extra security"

  **Room Preview Card:**
  - Shows how the room will look in discovery
  - Room name, type badge, settings icons
  - "2/4 players" (just you currently)
  - Preview updates as settings change

- Bottom sticky bar:
  - "Create Room" (primary-btn, full width, gold gradient for excitement)
  - Cancel text link above

**Output:** HTML create room screen

---

## Design Notes

- The form should feel like setting up a game night — inviting, not bureaucratic
- Room type cards should be visually distinct and easy to understand
- Toggle switches should have clear on/off states (purple for on, gray for off)
- Advanced settings should be collapsed by default (reduce overwhelm)
- Preview card gives instant feedback on how room appears to others
- Game speed chips should feel quick to select
- Password field only appears for private rooms
- Gold gradient on Create button creates excitement
- All text supports RTL