# Bloot — Anti-Patterns

## Overview

Anti-patterns are things we **explicitly do NOT do** in Bloot. This document defines what's off-limits and why. If a design decision contradicts a pattern on this list, it's wrong — regardless of how common it is in other apps.

These aren't suggestions. They're rules.

---

## 1. NO Generic Game UI

### What This Means

Bloot is not a generic mobile game. It's a premium social platform for a specific card game with a specific culture.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Cartoon avatars | Childish, undermines premium feel | Real photos, sophisticated default avatars |
| Chip/coin animations | Casino vibes, not our identity | Clean score counters, gold accents on achievements |
| Generic card backs | Every card game uses them | Custom Bloot card design, culturally relevant |
| Star/sparkle effects on everything | TikTok-style gamification | Subtle, purposeful animations only |
| Bright primary colors | Feels like a kids' game | Dark theme, purple and gold accents |
| Popup ads between rounds | Breaks immersion and premium promise | No ads. Ever. |
| Loot box / gacha mechanics | Anti-premium, manipulative | Direct, transparent rewards |

### The Rule

> If it looks like it belongs in a generic mobile game, it doesn't belong in Bloot.

---

## 2. NO Light Mode (In MVP)

### What This Means

For the MVP, Bloot ships with **dark mode only**. No light theme toggle. No system-adaptive theming.

| Anti-Pattern | Why It's Wrong |
|-------------|---------------|
| Light background | Breaks the premium, cinematic atmosphere |
| System-follows-light-mode | Forces an experience we haven't designed |
| Gray-on-white cards | Undermines glass morphism and depth system |
| Light mode toggle in settings | Invites comparison, dilutes design focus |

### Why

- Balout is played at night, in dim rooms, in social gatherings
- Video calls look terrible on white backgrounds
- The entire color system is built for dark surfaces
- Light mode doubles design and engineering effort
- Target audience overwhelmingly prefers dark themes

### The Rule

> Dark is not a theme choice. Dark is the Bloot identity. One theme, done perfectly.

---

## 3. NO Stock Game Graphics

### What This Means

No clip-art cards, no Shutterstock backgrounds, no generic poker-table green felt.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Standard playing card designs | Not Balout, not premium | Custom Bloot card art with Arabic calligraphy |
| Green felt table background | Poker cliché, not our aesthetic | Dark #0A0A0F surface with subtle purple undertones |
| Generic card suit icons (♠♥♦♣) | Balout doesn't use these suits | Custom Balout suit designs (مكّة, سنة) |
| Stock photo backgrounds | Fake, generic | Custom illustrations or dark geometric patterns |
| Emoji as game elements | Unprofessional | Purpose-designed iconography |

### The Rule

> Every visual element in Bloot is custom-designed or intentionally selected. No stock assets ever.

---

## 4. NO Hidden Mic/Camera Status

### What This Means

Voice and video status must be **always visible** for all players. There is no state where a player's mic or camera status is ambiguous.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Mic status only in settings | Users can't see who's listening | Mic icon always visible next to avatar |
| Camera status buried | Creates privacy concern | Video square clearly shows on/off state |
| "Mic on" without visual feedback | User doesn't know they're broadcasting | Audio wave animation when mic is active |
| Muted without indication | Others think they're ignoring you | Red mic-off icon clearly visible |
| Camera off with no replacement | Empty space looks broken | Avatar replaces video square |

### Critical UI Rules

```
Mic ON:   🟣 Purple audio wave animation next to player
Mic OFF:  🔴 Red mic-off icon, NO animation
Cam ON:   Live video feed visible
Cam OFF:  Avatar image with subtle "camera off" icon overlay
```

### The Rule

> If your mic is on, everyone knows. If your camera is off, everyone sees your avatar. Zero ambiguity, always.

---

## 5. NO Complex Navigation During Gameplay

### What This Means

During active gameplay, the navigation must be **minimal and non-disruptive**. No hamburger menus, no tab bars, no drill-down flows.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Bottom tab bar during game | Takes space, tempts exit | Auto-hide after 3s, tap to reveal |
| Hamburger menu during game | Too many options, breaks focus | Single settings icon, slide-in panel |
| Deep navigation during game | Players should never leave mid-game | All essential controls accessible on screen |
| Confirmation dialogs during play | Blocks game flow | Inline confirmations (undo-able) |
| Settings page during game | Why are you in settings? | Quick settings overlay, not a page |

### Game Screen Layout

```
LANDSCAPE GAME LAYOUT:

┌─────────────────────────────────────────────┐
│ [Settings] [Score]        [Live] [Mic] [Cam] │ ← Top bar, auto-hides
│                                              │
│  ┌─────┐                            ┌─────┐ │
│  │ P2  │                            │ P1  │ │
│  └─────┘                            └─────┘ │
│                                              │
│              ┌──────────┐                    │
│              │  Played  │                    │
│              │  Cards   │                    │
│              └──────────┘                    │
│                                              │
│  ┌─────┐                            ┌─────┐ │
│  │Me(P4)│                           │ P3  │ │
│  └─────┘                            └─────┘ │
│                                              │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ │              │ ← My hand
│  │C1│ │C2│ │C3│ │C4│ │C5│ │  [Play] [Pass] │
│  └──┘ └──┘ └──┘ └──┘ └──┘ │              │
└─────────────────────────────────────────────┘
```

### The Rule

> During gameplay, the only thing that matters is the game. Everything else hides.

---

## 6. NO Silent Live Indicators

### What This Means

If someone is streaming, the LIVE indicator must be **obvious, animated, and unmistakable**. A static "online" badge is not enough.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Static "Live" text | Easy to miss, feels dead | Pulsing red dot + "مباشر" text |
| Green "online" dot | "Online" ≠ "Live streaming" | Red pulsing dot = live stream |
| No visual indicator | Viewers can't find live content | Prominent LIVE badge on thumbnails and in-stream |
| Live indicator only in one place | Easy to miss on scroll | LIVE badge on room card, streamer avatar, and home feed |

### LIVE Badge Specification

```
Required elements:
  1. Red dot: 8px, #EF4444, pulsing (1.5s cycle)
  2. Text: "مباشر" in Bold, 10-12px
  3. Background: rgba(239, 68, 68, 0.2)
  4. Border: 1px solid rgba(239, 68, 68, 0.5)
  5. ALL four required. No exceptions.

Featured streams add:
  1. Gold ring around streamer avatar
  2. Slightly larger badge
```

### The Rule

> A live stream is the most important thing on the platform. The visual indicator must stop the scroll.

---

## 7. NO Childish Colors

### What This Means

Bloot is a premium, adult-oriented platform. The color palette reflects sophistication, not playfulness.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Bright saturated blues | Feels like a kids' app or tech startup | Purple (#8B5CF6) — sophisticated, digital |
| Neon green accents | Arcade vibes | Green (#22C55E) only for success states |
| Bright yellow as primary | Childish, not premium | Gold (#F59E0B) — warm, earned, rich |
| Pastel palettes | Soft, not confident | Deep dark (#0A0A0F) — bold, immersive |
| Rainbow gradients | Circus, not card room | Purple-to-dark gradients only |
| Candy-colored buttons | Mobile game energy | Purple buttons, gold for achievements |
| Multiple bright accent colors | Visual noise, no hierarchy | 2 accents: purple (interactive) + gold (achievement) |

### The Rule

> Two accent colors: purple for doing, gold for earning. Everything else is dark. Anything else looks childish.

---

## 8. NO Pure Black (#000000)

### What This Means

Pure black is harsh, causes banding on OLED, and doesn't match the warm, premium atmosphere Bloot creates.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| #000000 background | Harsh, cold, banding issues | #0A0A0F — warm black with purple undertone |
| Pure black borders | Too stark on dark surfaces | rgba(255,255,255,0.06) — subtle, not harsh |
| Pure black shadows | Unrealistic on dark bg | Colored shadows with purple tint |
| #000000 text on light surfaces | OK on light, but we don't have light surfaces | N/A in dark mode |

### Shadow Colors

```css
/* CORRECT — Purple-tinted shadows for depth */
box-shadow: 0 4px 16px rgba(0, 0, 0, 0.5);        /* Dark shadow */
box-shadow: 0 2px 8px rgba(139, 92, 246, 0.15);    /* Purple shadow */
box-shadow: 0 0 20px rgba(139, 92, 246, 0.1);      /* Purple glow */

/* WRONG — Pure black shadows look harsh on dark */
box-shadow: 0 4px 16px #000000;                      /* Never */
```

### The Rule

> Pure black (#000000) is banned. Our background is #0A0A0F. Our shadows have purple tint. Our darkness has warmth.

---

## 9. NO English-Only Thinking (RTL-First)

### What This Means

Bloot is an Arabic-first, RTL-first application. English is the secondary language. LTR is the adaptation.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Designing LTR first, then "translating" | Layouts break, text overflows, feel wrong | Design RTL first, LTR is the adaptation |
| Using `left`/`right` CSS properties | Hard-coded direction, breaks in RTL | Use logical properties (inline-start, inline-end) |
| `text-align: right` for Arabic | Breaks when mixed content is present | `text-align: start` always |
| Icons that don't flip in RTL | Back arrows point wrong way | All directional icons mirror in RTL |
| English-only error messages | Users don't understand what went wrong | Arabic primary, English only in error codes |
| LTR date/time formats | Confusing for Arabic readers | Arabic date formats, Arabic-Indic numerals for context |
| Screenshots showing LTR layout | Misleading for developers and stakeholders | All design docs show RTL first |

### Critical RTL Checklist

```
✅ All layouts use logical CSS properties
✅ Text direction defaults to RTL
✅ Icons mirror correctly in RTL
✅ Card dealing goes right-to-left
✅ Progress bars fill right-to-left
✅ Swipe back gesture is left-to-right
✅ Navigation back button is on the RIGHT side
✅ Avatars in lists are on the END side
✅ All screenshots in design docs are RTL
✅ Arabic text has correct line-height (1.7+)
✅ NO letter-spacing on Arabic text
```

### The Rule

> If the design doesn't work in RTL first, it doesn't work. Period.

---

## 10. NO Cluttered Game Screens

### What This Means

The game screen must be **immersive and focused**. Every element on the screen during active gameplay must earn its place.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Visible tab bar during game | Wastes space, tempts exit | Auto-hide after 3 seconds |
| Chat window always open | Blocks game view | Swipe up to reveal, auto-minimize |
| Ads during gameplay | Destroys immersion and premium feel | No ads. Ever. |
| Floating action buttons | Distracts from game | Single settings icon, auto-hides |
| Multiple notifications | Overwhelms during play | Queue notifications for between hands |
| Decorative elements on game table | Visual noise | Clean dark surface, minimal chrome |
| Stats overlay during play | Too much information | Stats accessible on demand, not always visible |

### Game Screen Element Budget

```
MAXIMUM elements visible during active play:
  - 4 video squares (essential)
  - Player names + mic indicators (essential)
  - Score display (essential)
  - My hand of cards (essential)
  - Played cards center area (essential)
  - Turn indicator (essential)
  - Mic toggle (essential)
  - Cam toggle (essential)
  = 8 essential elements MAX

  Everything else HIDES after 3 seconds of inactivity:
  - Settings icon
  - Chat peek
  - Detailed stats
  - Room info
  - Exit button
```

### The Rule

> If it doesn't help play the game, it shouldn't be on the screen during the game.

---

## 11. NO Ambiguous Player Status

### What This Means

At all times, every player's status must be **instantly clear**. No guessing if someone is connected, disconnected, speaking, muted, or away.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| No status indicator | Is the player even there? | Always-on status: connected (green), disconnected (red), speaking (purple glow) |
| Static mic icon only | Mic on or off? | Animated wave when speaking, red slash when muted |
| "Connecting..." with no follow-up | Is it working? | Clear progress: Connecting → Connected OR Disconnected |
| Avatar with no state | Everyone looks the same | Colored rings: purple=speaking, gold=MVP, red=disconnected |
| "Away" status with no auto-action | Players stuck waiting | Auto-pause game after 30s of inactivity, clear indicator |

### Player Status System

```
Status Indicators (always visible):

Connected + Active:
  - Full color avatar
  - Subtle border
  - Mic icon (animated if speaking, static if silent)

Connected + Speaking:
  - Purple glow ring around avatar (#8B5CF6)
  - 3-bar audio wave animation
  - Name highlighted

Connected + Muted:
  - Full color avatar
  - Mic-off icon (red)
  - No audio animation

Connected + Camera Off:
  - Full color avatar (replaces video)
  - Camera-off icon overlay
  - Dark border

Disconnected:
  - Grayscale avatar
  - Red border "—" indicator
  - "إعادة اتصال..." text
  - Auto-reconnect countdown visible

Away / Inactive:
  - Dimmed avatar (opacity 0.6)
  - Yellow idle indicator
  - Auto-pause after 30s
```

### The Rule

> A glance should tell you everything about every player's state. Zero ambiguity. Zero guessing.

---

## 12. NO Generic Card Designs

### What This Means

Balout cards are the heart of the game. They must be custom-designed, culturally resonant, and premium-quality.

| Anti-Pattern | Why It's Wrong | What We Do Instead |
|-------------|---------------|-------------------|
| Standard playing card designs | Balout uses specific card values and format | Custom card faces matching Balout rules |
| Clip-art card icons | Unprofessional, cheap | Custom illustrated card faces |
| Small, hard-to-read ranks | Players can't identify cards quickly | Clear, large rank indicators |
| No card back design | Looks unfinished | Custom card back with Bloot pattern |
| Same card design as competitors | No differentiation | Unique Bloot card art, culturally relevant |
| Digital-only card feel | Misses the tactile enjoyment | Subtle shadow and depth effects on cards |

### Card Design Requirements

```
Card face:
  - Arabic rank indicators (where applicable)
  - Clear suit symbols designed for Balout (not standard poker suits)
  - High contrast on dark background
  - Must be readable at 36dp × 52dp minimum
  - Gold accents on face cards (King, Queen)

Card back:
  - Custom Bloot geometric pattern
  - Purple (#8B5CF6) and dark (#161622) color scheme
  - Bloot logo watermark
  - Cannot reveal card identity from back

Card interactions:
  - Lift on hover/press (Y: -4px)
  - Clear selection state (Y: -12px + purple border)
  - Opacity reduction on unplayable cards (0.4)
  - Gold glow on playable cards during turn
  - Deal animation: stagger 100ms per card
```

### The Rule

> The cards are the game. If they look generic, the whole experience feels generic.

---

## Summary: The Anti-Pattern Test

Before adding any UI element, ask:

1. **Is it generic?** → Remove or redesign
2. **Is it light-mode?** → Not in MVP
3. **Is it stock?** → Replace with custom
4. **Is mic/camera status hidden?** → Make it always visible
5. **Is it complex navigation during gameplay?** → Remove or auto-hide
6. **Is the LIVE indicator static and silent?** → Add animation
7. **Are colors childish?** → Use purple and gold only
8. **Is the background pure black?** → Change to #0A0A0F
9. **Is it LTR-first?** → Redesign for RTL-first
10. **Is the game screen cluttered?** → Remove, hide, or simplify
11. **Is player status ambiguous?** → Add clear indicators
12. **Are the cards generic?** → Custom design required

> If any answer is "yes," it's an anti-pattern. Fix it before shipping.