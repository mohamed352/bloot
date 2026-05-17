# Bloot — Visual Language

## Strategy: "Premium Dark Social Gaming"

Bloot's visual language creates the feeling of sitting in a premium card room late at night — dim lighting, focused attention, rich colors, and the glow of screens and gold. Every visual decision reinforces: **this is a premium social experience.**

---

## 5-Layer Visual System

### Layer 1: Atmosphere — The Deep

This is the void. The room. The night sky of the card table.

```
Primary Background: #0A0A0F
```

- Never pure black (#000000). Always slightly warm with a purple undertone.
- This layer is the emotional foundation — dark, focused, immersive.
- Used for: full-screen backgrounds, game table surface, app root.

---

### Layer 2: Brand — The Identity

Purple and gold. The two colors that say "Bloot" without a logo.

```
Primary Purple: #8B5CF6
Primary Gold:   #F59E0B
```

| Color | Hex | RGB | Usage |
|-------|-----|-----|-------|
| Purple 500 | #8B5CF6 | 139, 92, 246 | Primary actions, links, live indicators, brand accent |
| Purple 400 | #A78BFA | 167, 139, 250 | Hover states, secondary highlights |
| Purple 300 | #C4B5FD | 196, 181, 253 | Disabled/low-contrast purple elements |
| Purple 600 | #7C3AED | 124, 58, 237 | Pressed states, deep accents |
| Purple 700 | #6D28D9 | 109, 40, 217 | Extreme contrast, header highlights |
| Gold 500 | #F59E0B | 245, 158, 11 | Achievements, premium badges, VIP elements, winner highlights |
| Gold 400 | #FBBF24 | 251, 191, 36 | Gold hover, secondary gold |
| Gold 300 | #FCD34D | 252, 211, 77 | Gold disabled/low contrast |
| Gold 600 | #D97706 | 217, 119, 6 | Gold pressed, deep gold accents |
| Gold 700 | #B45309 | 180, 83, 9 | Extreme gold contrast |

**Usage Rules:**
- Purple = interactive, actionable, digital
- Gold = earned, achieved, premium, celebratory
- Never use gold for standard buttons — gold is reserved for achievements and premium
- Purple is the primary action color. Gold is the reward color.

---

### Layer 3: Surface — The Cards & Containers

The elevated layers — cards, panels, modals, input fields.

| Surface | Value | Usage |
|---------|-------|-------|
| Card BG | #161622 | Room cards, profile cards, settings panels |
| Card BG Hover | #1E1E2E | Hovered card states |
| Sheet BG | #161622 | Bottom sheets, modal backgrounds |
| Input BG | #1C1C2C | Text fields, search bars |
| Border Subtle | rgba(139, 92, 246, 0.15) | Default card borders, dividers |
| Border Focus | rgba(139, 92, 246, 0.4) | Focused input borders |
| Divider | rgba(255, 255, 255, 0.06) | Section dividers, list separators |

**Elevation Model:**

| Elevation | Shadow | Usage |
|-----------|--------|-------|
| 0 (Flat) | none | Full-screen backgrounds |
| 1 (Resting) | 0 1px 2px rgba(0,0,0,0.3) | Cards in lists |
| 2 (Raised) | 0 2px 8px rgba(0,0,0,0.4) | Selected cards, active elements |
| 3 (Floating) | 0 4px 16px rgba(0,0,0,0.5) | Modals, bottom sheets |
| 4 (Top) | 0 8px 32px rgba(0,0,0,0.6) | Dialogs, critical overlays |

---

### Layer 4: Details — The Refinements

Micro-interactions, glass effects, achievement highlights.

**Glass Morphism:**
```css
.glass-panel {
  background: rgba(22, 22, 34, 0.7);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(139, 92, 246, 0.15);
  border-radius: 16px;
}
```

| Effect | Specification | Usage |
|--------|---------------|-------|
| Button Press | scale(0.96), 100ms ease-out | All interactive buttons |
| Card Lift | translateY(-2px) + shadow increase | Hovered/focused cards |
| Gold Shimmer | gradient animation, 2s linear infinite | Achievement badges, winner crown |
| Live Pulse | opacity 0.6→1.0, 1.5s ease-in-out | LIVE indicator dot |
| Ripple | purple ripple from touch point, 300ms | Tap feedback on surfaces |

**Border Radius:**

| Element | Radius | Values |
|---------|--------|--------|
| Small (chips, tags) | 8px | --radius-sm |
| Medium (cards, inputs) | 16px | --radius-md |
| Large (modals, sheets) | 24px | --radius-lg |
| XL (full-screen panels) | 32px | --radius-xl |
| Circle (avatars, LIVE dot) | 50% | --radius-full |
| Card corners (game cards) | 12px | --radius-card |

---

### Layer 5: Immersion — The Living Interface

Video, audio, live indicators — the elements that make it feel real.

| Element | Visual Treatment |
|---------|-----------------|
| Video Square | Rounded corners (16px), subtle purple border on active speaker, shadow elevation 2 |
| Live Badge | Red dot + "مباشر" text, pulsing animation, gold outline for featured streams |
| Audio Wave | Purple gradient bars animating based on volume, 3-bar indicator |
| Player Avatar | Circular (50%), purple ring when speaking, gold ring when MVP |
| Card in Hand | Slight rotation, shadow elevation 2, gold glow when playable |
| Chat Bubble | Glass morphism background, slide-in animation from bottom |

**Live Indicator Specifications:**
- Dot size: 8px circle
- Dot color: #EF4444 (Red 500)
- Pulse: scale 1.0 → 1.4 → 1.0, opacity 0.6 → 1.0 → 0.6, duration 1.5s
- Text: "مباشر" in Bold weight, 10px
- Container: rounded-full, bg rgba(239,68,68,0.2), border 1px solid rgba(239,68,68,0.5)

---

## Full Color Table

### Base Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Black (background) | #0A0A0F | 10, 10, 15 | App background |
| White (text) | #FFFFFF | 255, 255, 255 | Primary text on dark |
| Gray 100 | #F5F5F5 | 245, 245, 245 | Secondary text |
| Gray 200 | #E5E5E5 | 229, 229, 229 | Tertiary text |
| Gray 300 | #D4D4D4 | 212, 212, 212 | Placeholder text |
| Gray 400 | #A3A3A3 | 163, 163, 163 | Disabled text |
| Gray 500 | #737373 | 115, 115, 115 | Hint text |
| Gray 600 | #525252 | 82, 82, 82 | Borders on dark |
| Gray 700 | #404040 | 64, 64, 64 | Dividers on dark |
| Gray 800 | #262626 | 38, 38, 38 | Surface borders |
| Gray 900 | #171717 | 23, 23, 23 | Elevated surfaces |

### Semantic Colors

| Name | Hex | Usage |
|------|-----|-------|
| Success | #22C55E | Connected, correct, win |
| Warning | #F59E0B | Caution, pending |
| Error | #EF4444 | Disconnected, error, loss |
| Info | #3B82F6 | Informational, neutral |
| Live Red | #EF4444 | Live indicator, recording |

### Opacity Scale

| Opacity | Value | Usage |
|---------|-------|-------|
| 100% | 1.0 | Primary text, active elements |
| 87% | 0.87 | Secondary text |
| 60% | 0.6 | Tertiary text, subtle borders |
| 38% | 0.38 | Disabled text, dividers |
| 12% | 0.12 | Hover overlays |
| 6% | 0.06 | Focus overlays, subtle backgrounds |
| 4% | 0.04 | Divider lines |

---

## Motion Specifications

| Animation | Duration | Easing | Usage |
|-----------|----------|--------|-------|
| Micro (button press) | 100ms | ease-out | Button presses, toggles |
| Small (fade, slide) | 200ms | ease-in-out | Tooltips, dropdowns |
| Medium (card transition) | 300ms | ease-in-out | Page transitions, card deals |
| Large (screen transition) | 400ms | cubic-bezier(0.4, 0, 0.2, 1) | Screen navigation |
| Emphasis (deal animation) | 600ms | cubic-bezier(0.2, 0, 0, 1) | Card dealing, achievement reveal |
| Live pulse | 1500ms | ease-in-out | LIVE dot, audio indicator |

**Spring Physics for Cards:**
```css
--spring-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
--spring-smooth: cubic-bezier(0.22, 1, 0.36, 1);
```

---

## Grid & Spacing

| Token | Value | Usage |
|-------|-------|-------|
| --space-1 | 4px | Inline spacing, icon gaps |
| --space-2 | 8px | Compact padding |
| --space-3 | 12px | Standard inner padding |
| --space-4 | 16px | Card padding, component gaps |
| --space-5 | 20px | Section padding |
| --space-6 | 24px | Large gaps |
| --space-8 | 32px | Section margins |
| --space-10 | 40px | Screen padding |
| --space-12 | 48px | Large screen sections |
| --space-16 | 64px | Page sections |

**Game Table Layout (Landscape):**
- Video squares: 4 corners, 20% width each
- Play area center: 60% width
- Controls bottom bar: 64px height
- Status top bar: 48px height

---

## Iconography

- **System:** Lucide Icons (outline style, 1.5px stroke weight)
- **Sizes:** 16px (inline), 20px (default), 24px (prominent), 32px (feature)
- **Color:** Inherit from parent text color, purple for interactive, gold for premium
- **RTL:** All directional icons flip for RTL (arrows, chevrons, etc.)

---

*Every visual element should reinforce one thing: you're in a premium card room, and the experience is alive.*