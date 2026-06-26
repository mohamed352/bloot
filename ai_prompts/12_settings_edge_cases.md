# Settings & Edge Cases Prompt

## Context

Include `00_master_rules.md` before using this prompt.

## CRITICAL: English Only with RTL Notes

All UI screens MUST be generated in **English only**. Add RTL implementation notes as HTML comments.

## Screens: Settings, Privacy, Terms, Error, Offline, Loading, Success

### 01 Settings Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: "Settings" headline
- Account section:
  - Edit Profile (chevron)
  - Change Username (chevron)
  - Linked Accounts (chevron)
  - Block List (chevron)
- Game section:
  - Voice Chat (toggle: on/off)
  - Camera (toggle: on/off)
  - Speaker Mode (dropdown: Speaker/Earpiece)
  - Auto-rotate for Game (toggle: on/off)
  - Game Speed Default (dropdown: Normal/Fast/Relaxed)
  - Sound Effects (toggle: on/off)
  - Background Music (toggle: on/off)
- Privacy section:
  - Online Status (toggle: visible/hidden)
  - Show Profile (dropdown: Everyone/Followers/Private)
  - Notifications (toggle + subsections):
    - Room Invitations (toggle)
    - New Followers (toggle)
    - Game Results (toggle)
  - Muted Users (chevron)
- Support section:
  - Help Center (chevron)
  - Contact Support (chevron)
  - Report a Problem (chevron)
  - Terms of Service (chevron)
  - Privacy Policy (chevron)
  - About Bloot (chevron)
- Danger section:
  - Log Out (red text)
  - Delete Account (red text, smaller)
- Version info: "Bloot v1.0.0"

**Output:** HTML settings screen

### 02 Privacy Policy Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: Back arrow + "Privacy Policy"
- Scrollable content:
  - Introduction
  - What data we collect (name, phone, gameplay data, voice/video)
  - How we use data (matching, streaming, improvement)
  - Voice and video data (stored briefly, not permanently)
  - Data sharing (not sold to third parties)
  - Security measures
  - Your rights
  - Contact information
- Clean typography, clear sections with headers
- Last updated date at bottom

**Output:** HTML privacy policy screen

### 03 Terms & Conditions Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Top: Back arrow + "Terms of Service"
- Scrollable content:
  - Service description
  - Account responsibilities
  - Gameplay rules (fair play, no cheating)
  - Streaming rules (no prohibited content)
  - Virtual currency/coins policy
  - Prohibited behavior (harassment, cheating, exploiting)
  - Account suspension/termination
  - Liability limitations
  - Dispute resolution
- Same clean layout as Privacy Policy

**Output:** HTML terms screen

### 04 Error State Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Center content:
  - Illustration: Broken connection or warning icon (purple themed)
  - "Something went wrong"
  - "We couldn't load this page. Please try again."
- Error code (small, muted): "Error: ERR_500"
- Primary CTA: "Try Again" (primary-btn)
- Secondary: "Contact Support" (text link)

**Output:** HTML error screen

### 05 Offline Screen

**Requirements:**
- Dark background (`#0A0A0F`)
- Center content:
  - Illustration: No wifi signal (purple themed)
  - "You're offline"
  - "Please check your internet connection and try again."
- Primary CTA: "Retry" (primary-btn)
- Secondary info:
  - "Some features may be unavailable offline"
  - "Your game progress is saved and will sync when you're back online"

**Output:** HTML offline screen

### 06 Loading State Screen

**Requirements:**
- Overlay or full screen
- Center:
  - Spinner (purple, circular, animated)
  - "Loading..." or context-specific:
    - "Finding players..."
    - "Joining room..."
    - "Starting game..."
- Semi-transparent dark background if overlay
- Prevent interaction with background
- Game-specific loading:
  - Card dealing animation (optional)
  - Room joining progress indicator

**Output:** HTML loading overlay

### 07 Success State (Generic)

**Requirements:**
- Dark background (`#0A0A0F`)
- Center content:
  - Animated checkmark (gold, not green — premium feel)
  - Success message (context-specific)
  - Description (optional)
- Examples:
  - "Room created successfully"
  - "Profile updated"
- Auto-dismiss or manual close

**Output:** HTML success state component

---

## Design Notes

- Legal pages should be easy to read on dark background
- Settings should be organized logically with clear sections
- Game-specific settings are unique to this app (voice, camera, rotation)
- Error/offline states should feel on-brand (purple/gold, not generic red)
- Loading states should be contextual and game-themed where appropriate
- Success states use gold (not green) to match the premium feel
- All text supports RTL