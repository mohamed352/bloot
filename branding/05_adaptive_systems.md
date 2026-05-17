# Bloot — Adaptive Systems

## Strategy Overview

Bloot is built for Gulf smartphone users playing Balout on their phones. Our adaptive choices reflect this reality:

1. **Dark-only** — The game happens at night, in gatherings, in dim rooms. Light mode doesn't match the experience.
2. **RTL-first** — Arabic is the primary language. LTR is the adaptation.
3. **Portrait for everything except the game** — Social, browsing, and setup in portrait. Gameplay in landscape.
4. **One-hand friendly** — During gameplay, all controls should be reachable with thumbs.

---

## Theme: Dark-Only (MVP)

### Why No Light Mode

- Balout is played predominantly at night and in social gatherings
- The brand identity is built around a dark, premium atmosphere
- Video calls and streams benefit from dark UI (less eye strain)
- Light mode doubles the design and development effort
- The target audience (Gulf users) overwhelmingly prefers dark themes

### Dark Theme Specification

| Token | Value | Usage |
|-------|-------|-------|
| --bg-primary | #0A0A0F | App background, game table |
| --bg-secondary | #12121E | Slightly elevated surface |
| --bg-card | #161622 | Cards, panels, containers |
| --bg-card-hover | #1E1E2E | Hovered card state |
| --bg-sheet | #161622 | Bottom sheets, modals |
| --bg-input | #1C1C2C | Input fields |
| --bg-overlay | rgba(0, 0, 0, 0.6) | Overlay behind modals |
| --text-primary | #FFFFFF | Primary text |
| --text-secondary | #A3A3A3 | Secondary text |
| --text-tertiary | #737373 | Hint text |
| --text-disabled | #525252 | Disabled text |
| --accent-primary | #8B5CF6 | Purple — primary interactive |
| --accent-secondary | #F59E0B | Gold — achievement/premium |
| --success | #22C55E | Connected, win |
| --error | #EF4444 | Error, disconnected |
| --warning | #F59E0B | Caution |
| --info | #3B82F6 | Informational |
| --border-subtle | rgba(139, 92, 246, 0.15) | Default borders |
| --border-focus | rgba(139, 92, 246, 0.4) | Focused borders |
| --border-divider | rgba(255, 255, 255, 0.06) | Dividers |

### Status Bar & System Bars

```css
/* Android / iOS system bars */
--status-bar-style: dark-content-on-dark;
--status-bar-bg: #0A0A0F;
--navigation-bar-bg: #0A0A0F;
```

### Pure Black for OLED

On OLED devices, `#0A0A0F` is close enough to pure black to trigger pixel-off behavior while avoiding the banding issues of `#000000`. If true OLED mode is desired, a separate `--bg-primary-oled: #000000` token can be toggled, but all surface colors remain the same (they need to be visible on black).

---

## RTL as Primary Direction

### RTL-First Architecture

Bloot is not a LTR app with RTL bolted on. RTL is the primary direction.

```css
:root {
  direction: rtl;
  text-align: start;
}
```

### What This Means for Implementation

| Aspect | LTR (Secondary) | RTL (Primary) |
|--------|-----------------|----------------|
| Text direction | Right-to-left | Right-to-left ✅ |
| Navigation flow | ← Back is left | ← Back is right ✅ |
| Card dealing | Left-to-right | Right-to-left ✅ |
| Icon direction | Arrows point ← | Arrows point → ✅ |
| List item layout | Meta on right | Meta on left ✅ |
| Padding | Logical: inline-start | Logical: inline-start ✅ |
| Swipe gestures | Swipe right = back | Swipe left = back ✅ |
| Progress | Left → Right | Right → Left ✅ |

### Logical Properties (Required)

All spacing, borders, and positioning must use **logical CSS properties**:

```css
/* CORRECT — Use logical properties */
.element {
  margin-inline-start: 16px;
  padding-inline-end: 8px;
  border-inline-start: 2px solid var(--accent-primary);
  inset-inline-start: 0;
  text-align: start;
}

/* WRONG — Never use physical properties forbidirectional layout */
.element {
  margin-left: 16px;
  padding-right: 8px;
  border-left: 2px solid var(--accent-primary);
  left: 0;
  text-align: right;
}
```

### Mirroring Rules

| Component | Mirrors in RTL? | Notes |
|-----------|-----------------|-------|
| Back arrow | YES | Point → instead of ← |
| FAB position | YES | Inline-end instead of right |
| Progress bar fill | YES | Fills from right |
| Card dealing order | YES | Deals right-to-left |
| Number display | NO | Numbers stay LTR within RTL |
| Clock | NO | Clock stays LTR |
| Logo | NO | Bloot logo doesn't flip |
| Icons (non-directional) | NO | Pause, play, volume stay same |

---

## Orientation

### Portrait Mode (Default)

All screens **except active gameplay** are portrait-only:

- Home / Feed
- Room List
- Room Preview / Waiting
- Profile
- Settings
- Chat (full screen)
- Streams (viewing)

### Landscape Mode (Game)

Active gameplay **forces landscape orientation**:

- The game table (4-player view)
- Card play area
- Score tracking
- In-game voice/video

### Orientation Transition

```
Portrait → Landscape:
  Transition duration: 400ms
  Easing: cubic-bezier(0.4, 0, 0.2, 1)
  Layout morphs (not a hard cut):
    - Video squares fly to corners
    - Table expands horizontally
    - Bottom bar becomes side bar
  Haptic: single light tap on rotation start

Landscape → Portrait:
  Auto-rotates when game ends
  Same transition in reverse
  No haptic
```

### Orientation Lock

| Screen | Orientation | Lock? |
|--------|------------|-------|
| Home | Portrait | Yes — locked portrait |
| Room List | Portrait | Yes — locked portrait |
| Waiting Room | Portrait | No — allow rotation |
| Active Game | Landscape | Yes — forced landscape |
| Between Hands | Landscape | Yes — stay landscape |
| Game Results | Portrait | Yes — force portrait |
| Stream View | Portrait | No — allow rotation |
| Profile | Portrait | Yes — locked portrait |
| Settings | Portrait | Yes — locked portrait |
| Chat Full Screen | Portrait | Yes — locked portrait |

---

## Responsive Breakpoints

Bloot targets mobile-first. The breakpoints account for common phone sizes in the Gulf market.

### Width Breakpoints

| Token | Value | Target Devices |
|-------|-------|----------------|
| --bp-sm | 320px | iPhone SE, small Android |
| --bp-md | 375px | iPhone 12/13/14, standard phones |
| --bp-lg | 414px | iPhone Pro Max, large phones |
| --bp-xl | 428px | iPhone Pro Max (newest) |
| --bp-2xl | 480px | Foldable (unfolded), tablets |

### Height Breakpoints (for game layout)

| Token | Value | Usage |
|-------|-------|-------|
| --bp-h-short | 568px | Short devices (landscape mode reference) |
| --bp-h-medium | 667px | Standard height |
| --bp-h-tall | 812px | Tall devices (portrait reference) |
| --bp-h-xl | 896px | Extra tall |

### Landscape-Specific Breakpoints (for game table)

| Token | Value | Notes |
|-------|-------|--------|
| --bp-landscape-sm | 568px width | Minimum landscape width |
| --bp-landscape-md | 667px width | Standard landscape |
| --bp-landscape-lg | 736px width | Wide landscape |
| --bp-landscape-xl | 812px+ | Tablet landscape |

### Responsive Rules

```css
/* Mobile-first (base = 320px) */
.room-card {
  padding: 12px;
  gap: 8px;
}

/* Standard phones (375px+) */
@media (min-width: 375px) {
  .room-card {
    padding: 16px;
    gap: 12px;
  }
}

/* Large phones (414px+) */
@media (min-width: 414px) {
  .room-card {
    padding: 20px;
    gap: 16px;
  }
}

/* Tablets and folds */
@media (min-width: 480px) {
  .room-card {
    padding: 24px;
    gap: 20px;
  }
  .room-list {
    grid-template-columns: repeat(2, 1fr);
  }
}
```

---

## Font Scaling

### Scale Factors

| Setting | Scale Factor | CSS Value |
|---------|-------------|-----------|
| Small | 0.875x | `font-size: 14px` root |
| Default | 1.0x | `font-size: 16px` root |
| Large | 1.25x | `font-size: 20px` root |
| XL | 1.5x | `font-size: 24px` root |

### Scaling Rules

1. **All UI text scales** with the `rem` root. This includes labels, buttons, chat, etc.
2. **Game scores** scale but maintain minimum size (12px absolute minimum).
3. **Card dimensions** do NOT scale — they're fixed size for gameplay accuracy.
4. **Spacing** uses `rem` tokens and scales proportionally.
5. **Icons** scale with text (using `em` sizing on icons).
6. **Video squares** maintain minimum size (120px × 90px) regardless of scale.
7. **Maximum scale**: 1.5x — beyond this, layout integrity breaks.

### Game-Specific Fixed Sizes

These elements do NOT scale with font size and remain at fixed pixel sizes:

| Element | Fixed Size | Reason |
|---------|-----------|--------|
| Playing card | 52px × 36dp | Game accuracy depends on card proportions |
| Card rank label | 14px (absolute) | Must remain readable |
| Video square | Minimum 120px × 90px | Must see faces |
| LIVE badge | 44px × 20dp fixed | Must remain visible |
| Game table border | Fixed proportions | Affects gameplay |

---

## Safe Areas & Notched Devices

### iPhone Notch & Dynamic Island

```css
/* Safe area insets */
--safe-top: env(safe-area-inset-top);      /* 47px on notch iPhones */
--safe-bottom: env(safe-area-inset-bottom);  /* 34px on home indicator iPhones */
--safe-left: env(safe-area-inset-left);      /* 0px on most, 44px on landscape notch */
--safe-right: env(safe-area-inset-right);    /* 0px on most, 44px on landscape notch */
```

### Game Layout in Landscape (with notch)

```
┌──────────────────────────────────────────────────────────┐
│ ← Safe Area (right notch)          Safe Area (left) →  │
│  ┌──────────┐                          ┌──────────┐     │
│  │ Player 2 │                          │ Player 1 │     │
│  │  Video   │                          │  Video   │     │
│  └──────────┘                          └──────────┘     │
│                                                          │
│                   ┌───────────┐                          │
│                   │  Game     │                           │
│                   │  Table    │                           │
│                   │  Center   │                           │
│                   └───────────┘                          │
│  ┌──────────┐                          ┌──────────┐     │
│  │ Partner  │                          │ Player 3 │     │
│  │  Video   │                          │  Video   │     │
│  └──────────┘                          └──────────┘     │
│  ┌──────────────────────────────────────┐                │
│  │ My Cards (bottom)    │ Controls      │                │
│  └──────────────────────────────────────┘                │
└──────────────────────────────────────────────────────────┘
```

### Safe Area Rules

1. **No interactive elements** in the safe area margins
2. **Background colors** extend into safe areas (no white strips)
3. **Game table** accounts for safe areas and maintains 4:3 aspect ratio
4. **Bottom sheet** handles respect safe area bottom inset
5. **Status bar** area uses `--bg-primary` (#0A0A0F)
6. **Home indicator** area gets extra bottom padding (34px)

---

## Rotation Handling

### Rotation Animation

When transitioning from portrait to landscape (entering game):

```
1. Lock orientation to landscape
2. Display rotation animation (300ms, ease-in-out)
3. Animate layout:
   - Header collapses
   - Bottom nav disappears
   - Video squares fly to corners (400ms)
   - Game table expands (400ms)
   - Cards slide in from bottom (300ms staggered)
4. Enable game controls after all animations complete
```

### Rotation Back (Exiting Game)

```
1. Game confirms exit (was it intentional?)
2. If yes:
   - Animate game table collapse (300ms)
   - Video squares shrink (300ms)
   - Unlock orientation
   - Transition to portrait layout (400ms)
3. If accidental:
   - Show "هل تريد الخروج؟" dialog
   - Cancel = stay in game
   - Confirm = proceed with exit
```

### Preventing Accidental Rotation

During gameplay, the device orientation is **locked to landscape**. The only way to exit is:

1. Tapping an explicit "Exit" button (top corner)
2. The game ending (automatic rotation back to portrait)
3. System-level rotation lock override (user must confirm)

---

## Dynamic Type & Accessibility Scaling

### Platform Font Scaling

| Platform | Integration | Behavior |
|----------|-------------|----------|
| iOS | `UIFontMetrics` and Dynamic Type | Scale within Bloot's min/max bounds |
| Android | `sp` units with configuration | Scale within Bloot's min/max bounds |
| Flutter | `MediaQuery.textScaler` | Capped at 1.5x |

### Maximum Scale Caps

```css
html {
  font-size: clamp(14px, 100%, 24px); /* Cap at 1.5x */
}

.game-card-rank {
  font-size: max(12px, 0.875rem); /* Never below 12px */
}
```

### Accessibility Considerations

| Setting | Bloot Behavior |
|---------|---------------|
| Bold Text (iOS/Android) | Increase all weights by 100 (400→500, 500→600) |
| High Contrast | Increase border opacity from 15% to 40%, increase text opacity minimums |
| Reduce Motion | Disable all spring/bounce animations, use 200ms linear instead |
| VoiceOver/TalkBack | All game elements have semantic labels, card values announced |
| Switch Control | All interactive elements are focusable, logical tab order RTL |
| Screen Magnification | Game table uses fixed dimensions that zoom cleanly |

---

*Dark. RTL. Portrait-then-landscape. Arabic-first. Every adaptive decision serves the player at the table.*