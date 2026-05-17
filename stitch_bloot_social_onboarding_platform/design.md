---
name: Bloot
version: "1.0.0"
colors:
  primary: "#8B5CF6"
  primaryDark: "#7C3AED"
  primaryLight: "#A78BFA"
  gold: "#F59E0B"
  goldLight: "#FBBF24"
  goldDark: "#D97706"
  surface: "#0A0A0F"
  surfaceElevated: "#161622"
  surfaceMuted: "#1E1E2E"
  surfaceHover: "#252538"
  onSurface: "#FFFFFF"
  onSurfaceMuted: "#9CA3AF"
  onSurfaceSecondary: "#6B7280"
  border: "rgba(139, 92, 246, 0.15)"
  borderLight: "rgba(139, 92, 246, 0.25)"
  borderGold: "rgba(245, 158, 11, 0.3)"
  success: "#22C55E"
  warning: "#F59E0B"
  error: "#EF4444"
  info: "#3B82F6"
  live: "#FF1A1A"

typography:
  fontFamily: Inter
  fontFamilyArabic: Cairo
  scale:
    display:
      fontSize: 28px
      fontWeight: 800
      letterSpacing: 0.15em
      lineHeight: 1.2
    headline:
      fontSize: 22px
      fontWeight: 700
      lineHeight: 1.3
    title:
      fontSize: 15px
      fontWeight: 600
      lineHeight: 1.4
    body:
      fontSize: 14px
      fontWeight: 400
      lineHeight: 1.5
    caption:
      fontSize: 12px
      fontWeight: 400
      lineHeight: 1.4
    label:
      fontSize: 13px
      fontWeight: 600
      lineHeight: 1.4
    score:
      fontSize: 24px
      fontWeight: 700
      lineHeight: 1.1

rounded:
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  full: 9999px

spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 32px

shadows:
  button: "0 4px 14px rgba(139, 92, 246, 0.25)"
  buttonGold: "0 4px 14px rgba(245, 158, 11, 0.3)"
  card: "0 2px 8px rgba(0, 0, 0, 0.2)"
  elevated: "0 8px 24px rgba(0, 0, 0, 0.3)"
  glow: "0 0 40px rgba(139, 92, 246, 0.15)"

language: en
orientation: portrait-primary
landscapeForGame: true
darkOnly: true
---

# Bloot Design System

## Overview

Bloot is a premium Baloot social platform — live voice, video, streaming, and tournaments. The design philosophy centers on **Premium Dark Social Gaming**: deep blacks, rich purple accents, gold highlights, and an immersive card-room atmosphere. It feels like entering an exclusive card room — sophisticated, social, and alive.

**Key Principles:**
- Social First: Voice, video, and chat always accessible
- Immersive Gameplay: Landscape game, minimal UI during play, auto-hiding controls
- Premium Feel: Dark-only theme, gold accents on wins, subtle purple glows
- Gulf Heritage: Arabic RTL-first, Khaleeji Balout rules, culturally authentic
- Live Always: LIVE badges, viewer counts, real-time status on every screen
- Fair & Clear: Transparent game rules, visible mic/camera status, no hidden states

## Language Policy

**CRITICAL: All UI screens are generated in English only.**

- Do NOT include Arabic text on generated screens
- Add RTL implementation notes as HTML comments (`<!-- RTL: ... -->`)
- Localization to Arabic is handled programmatically by the app framework
- Use `Inter` font family for generated screens, `Cairo` loaded for reference

## Theme Policy

**CRITICAL: Dark mode only for MVP.**

- All screens use dark background (`#0A0A0F`)
- No light mode toggle or light variants in Phase 1
- Game screens additionally use landscape orientation
- Status bar and navigation bar should match dark background

## Colors

### Brand Colors
- **Primary** (`#8B5CF6`): CTAs, primary buttons, active states, brand identity
- **Primary Dark** (`#7C3AED`): Hover/pressed states
- **Primary Light** (`#A78BFA`): Subtle highlights, disabled states
- **Gold** (`#F59E0B`): VIP, wins, achievements, important highlights
- **Gold Light** (`#FBBF24`): Gold hover states
- **Gold Dark** (`#D97706`): Gold pressed states

### Surface Colors (Dark Only)
- **Surface** (`#0A0A0F`): Default page background
- **Surface Elevated** (`#161622`): Cards, modals, elevated containers
- **Surface Muted** (`#1E1E2E`): Inputs, secondary surfaces, video squares
- **Surface Hover** (`#252538`): Hover states on dark surfaces

### Text Colors
- **On Surface** (`#FFFFFF`): Primary text on dark backgrounds
- **On Surface Muted** (`#9CA3AF`): Secondary text, placeholders
- **On Surface Secondary** (`#6B7280`): Captions, helper text

### Border Colors
- **Border** (`rgba(139, 92, 246, 0.15)`): Subtle borders on dark surfaces
- **Border Light** (`rgba(139, 92, 246, 0.25)`): Active/hover borders
- **Border Gold** (`rgba(245, 158, 11, 0.3)`): Gold accent borders, VIP outlines

### State Colors
- **Success** (`#22C55E`): Confirmations, mic on, ready states
- **Warning** (`#F59E0B`): Pending states (shared with gold)
- **Error** (`#EF4444`): Errors, mic muted, destructive actions
- **Info** (`#3B82F6`): Informational, links
- **Live** (`#FF1A1A`): Live streaming badge, pulsing indicator

## Typography

**Primary Font:** Inter (Google Fonts)
**Arabic Font:** Cairo (loaded but not used in generated markup)

### Type Scale (Mobile — 375px base)

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| display | 28px | 800 | Splash brand name, score display |
| headline | 22px | 700 | Screen headlines, section titles |
| title | 15px | 600 | Player names, card titles |
| body | 14px | 400 | Body text, descriptions |
| caption | 12px | 400 | Viewer counts, timestamps, helper text |
| label | 13px | 600 | Form labels, button text |
| score | 24px | 700 | Game scores, point values |

**Rules:**
- Never exceed 28px for any text element
- Body text minimum: 14px (15-17px for Arabic)
- Arabic text needs +1-2px size and +0.3 line-height
- Never apply letter-spacing to Arabic text
- Use `text-align: start` instead of left/right
- Score display uses gold accent for winning team

## Spacing & Layout

### Base Spacing Scale
- `xs`: 4px — tight gaps, icon padding
- `sm`: 8px — inline spacing, small gaps
- `md`: 12px — standard padding, card internal gaps
- `lg`: 16px — section padding, screen horizontal margins
- `xl`: 24px — large section separations
- `xxl`: 32px — major section breaks

### Layout Rules
- Portrait screens: Design for 375px width (iPhone SE/mini)
- Game screen: Design for **landscape** (812x375px minimum)
- Max content width: 448px (`max-w-md`) for portrait screens
- Horizontal padding: 24px (`px-6`) for portrait, 16px (`px-4`) for landscape
- Touch targets: Minimum 48×48px (44px minimum for game controls)
- Status bar: Match background color (dark)
- Bottom nav: 5 items, center "Play" button prominent with gold outline

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 8px | Small buttons, chips, badges, LIVE badge |
| md | 12px | Input fields, small cards, icon containers |
| lg | 16px | Medium cards, stream cards, modals |
| xl | 24px | Large cards, bottom sheets, game table |
| full | 9999px | Primary CTAs, pills, avatars |

## Shadows

- **Button (Purple)**: `0 4px 14px rgba(139, 92, 246, 0.25)` — primary button glow
- **Button (Gold)**: `0 4px 14px rgba(245, 158, 11, 0.3)` — gold/CTA button glow
- **Card**: `0 2px 8px rgba(0, 0, 0, 0.2)` — subtle card elevation on dark bg
- **Elevated**: `0 8px 24px rgba(0, 0, 0, 0.3)` — modals, floating elements, dropdowns
- **Glow**: `0 0 40px rgba(139, 92, 246, 0.15)` — brand glow behind focal elements

## Components

### Primary Button
- Background: Gradient `from-b-purple to-purple-600` or solid `#8B5CF6`
- Text: White, 15px, semibold
- Height: 52px
- Radius: Full rounded (pill)
- Shadow: Purple button shadow
- Active state: `scale-[0.97]`
- Hover: Slightly deeper shadow

### Gold Accent Button
- Background: Gradient `from-b-gold to-b-gold-light`
- Text: Black (`#0A0A0F`), 15px, semibold
- Height: 48px
- Radius: Full rounded
- Shadow: Gold button shadow
- Active state: `scale-[0.97]`
- Use for: Join actions, game start, tournament entry

### Ghost Button
- Background: Transparent
- Border: 1px solid `rgba(139, 92, 246, 0.25)`
- Text: White, 15px, medium
- Height: 48px
- Radius: Full rounded
- Hover: Background `#161622`

### Stream Card
- Background: `#161622`
- Border: 1px solid `rgba(139, 92, 246, 0.15)`
- Radius: 16px
- Padding: 0 (image takes full width at top)
- Hover: Border `rgba(139, 92, 246, 0.25)`

### Player Video Square
- Background: `#1E1E2E`
- Border: 1px solid `rgba(139, 92, 246, 0.15)` (team purple) or `rgba(245, 158, 11, 0.3)` (team gold)
- Radius: 12px
- Aspect ratio: 1:1 or 16:9 based on layout
- Player name overlay at bottom
- Mic indicator: Green circle (on) or Red circle with line (muted) at bottom-right

### Game Table Surface
- Background: `bg-gradient-to-b from-green-900/20 to-green-950/30`
- Border: 1px solid `rgba(34, 197, 94, 0.15)`
- Radius: 16px (12px on smaller screens)
- Subtle felt texture feel

### Text Input
- Background: `#1E1E2E`
- Border: 1px solid `rgba(139, 92, 246, 0.15)`
- Height: 50px
- Radius: 12px
- Padding: 16px horizontal
- Focus: Border `#8B5CF6`, ring 2px `rgba(139, 92, 246, 0.2)`
- Placeholder: `#6B7280`, 14px

### LIVE Badge
- Background: `#FF1A1A`
- Text: White, 10px, bold, uppercase, tracking-wide
- Padding: 2px 8px
- Radius: 4px
- Animation: `animate-pulse`

### Gold Badge / VIP Indicator
- Background: `rgba(245, 158, 11, 0.2)`
- Text: `#F59E0B`, 11px, semibold
- Border: 1px solid `rgba(245, 158, 11, 0.3)`
- Radius: Full (pill)

### Mic/Camera Status Icon
- Size: 20px circle (`w-5 h-5`)
- Background: Green `rgba(34, 197, 94, 0.8)` for active
- Background: Red `rgba(239, 68, 68, 0.8)` for muted/off
- Icon: White mic/camera symbol
- Position: Bottom-right of video square

### Card Design (Baloot)
- Card back: Purple gradient (`from-b-purple to-purple-800`) with subtle gold diamond pattern
- Card face: Clean, high contrast, white/cream background
- Card in hand: Slight rotation, overlapping, tap to select (rises up)
- Card played: Center of table with smooth animation

## Game-Specific Patterns

### Player Positioning (Landscape)
```
           Partner (Top)
              [Video]
              
Opponent ←  [Game Table]  → Opponent
(Left)      [Cards Area]     (Right)

           [Your Cards Fan]
           [Your Video/Name]
           [Controls Bar]
```

- You: Bottom center (purple team border)
- Partner: Top center (purple team border)
- Opponents: Left and right (gold team border)
<!-- RTL: Swap opponent positions -->

### Score Display
- "Us: [score] — Them: [score]"
- Leading team's score in gold
- Sun: "/120" target
- Hokm: varies with bonuses

## Animations

### Entrance Animations
Use subtle fade-up for content load:
```css
@keyframes fade-up {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
```
- Duration: 0.5s — 0.7s
- Stagger delay: 0.1s per element

### LIVE Indicator
```css
@keyframes pulse-live {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
```

### Card Play Animation
- Card slides from hand to center: 300ms ease-out
- Trick win: Brief gold flash on winning team's side

### Button States
- Default: Full color, shadow
- Pressed: `scale-[0.97]`, darker shadow
- Loading: Spinner replaces text, disabled

## Orientation Rules

- **All screens except game**: Portrait (375px width)
- **Game play (07_game_play)**: Landscape-first (812x375px minimum)
- **Stream viewer (05_watch_stream)**: Portrait primary, landscape optional
- Game screen locks to landscape on entry
- Auto-rotate on game exit

## Do's and Don'ts

### Do
- Use purple as primary accent, gold sparingly for wins/VIP
- Maintain consistent dark background (`#0A0A0F`)
- Show LIVE badge on every stream card (animated, red)
- Show mic/camera status on every player video square
- Use subtle purple glow effects behind focal elements
- Keep game screens minimal — auto-hide UI after 3 seconds
- Use gold accents only for achievements, wins, premium elements
- Design landscape-first for game play screens

### Don't
- Don't use light backgrounds (dark-only for MVP)
- Don't use `#000000` — always `#0A0A0F` for depth
- Don't design game screens in portrait (landscape only)
- Don't hide mic/camera status (critical social signal)
- Don't use generic game UI patterns (this is premium, not casual)
- Don't clutter game screens with competing UI elements
- Don't use font sizes larger than 28px
- Don't mix Arabic and English on the same generated screen
- Don't let LIVE badges be subtle (must always be prominent)

## Responsive Behavior

- Portrait base: 375px (iPhone SE/mini)
- Game base: 812x375px (landscape)
- Touch targets: Never below 48×48px (44px for game cards)
- Text: Never below 12px
- Video squares: Minimum 80x80px on small screens

## Platform Notes

- This is a **mobile app** (not web admin)
- Game play screen requires landscape orientation
- Voice/video (Agora/WebRTC) is core functionality
- Bottom navigation has 5 items with prominent center "Play" button
- Status bar should match dark background
- Safe area insets must be respected for notched devices
- This app is **dark-only** for MVP (no light mode)

## RTL Notes for Developers

When implementing Arabic (RTL):
- Add `dir="rtl"` on html element
- Use `margin-inline-start` instead of `margin-left`
- Use `text-align: start` instead of `left`/`right`
- Flip directional icons with `scale-x-[-1]`
- Use `font-family: 'Cairo'` for Arabic text
- Increase body text to 15-17px for Arabic
- Swap opponent positions in game layout
- Chat messages: Your messages on start side, others on end side