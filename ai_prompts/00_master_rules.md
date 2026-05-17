# Bloot AI Generation Constitution (v2025)

**IMPORTANT:** This file MUST be included as "Context" before generating ANY UI screen for the Bloot App.

---

## The Strategy: "Premium Dark Social Gaming"

We build a premium Baloot social platform wrapped in dark, luxurious design with purple and gold accents. The experience feels like entering an exclusive card room — sophisticated, immersive, and social.

### CRITICAL: English-Only UI Generation with RTL Notes

- **All UI screens MUST be generated in English only.**
- **Do NOT include Arabic text on the screens.**
- **Add RTL implementation notes as HTML comments** (e.g., `<!-- RTL: Flip layout, use dir="rtl" -->`)
- Localization to Arabic is handled programmatically by the app framework.
- Your job is to produce clean English-only markup with RTL notes for the development team.

### The 5-Layer System (Strict Order)

1. **Layer 1 (The Foundation):** Deep Black (`#0A0A0F`) for backgrounds. Dark, immersive, premium.
2. **Layer 2 (The Brand):** Purple (`#8B5CF6`) for primary actions, Gold (`#F59E0B`) for highlights and wins.
3. **Layer 3 (The Surface):** Dark cards (`#161622`) with subtle purple-tinted borders. Elevated elements (`#1E1E2E`).
4. **Layer 4 (The Details):** Smooth micro-interactions, glass morphism effects, gold accents on achievements.
5. **Layer 5 (The Immersion):** Video squares, live indicators, audio controls — the social gaming layer.

---

## The AI Persona: "The Card Room Host"

> **Role:** Sophisticated, welcoming, confident
> **Voice:** Clear and inviting. No slang, no fluff. Like a premium host at an exclusive card room.
> **Rule:** Never sound robotic or cheap. Sound like you're welcoming someone to a high-end experience.
> **Context:** Premium Baloot platform, social gaming, Gulf culture, live streaming.

---

## The "Kill List" (Anti-Patterns)

1. **NO GENERIC GAME UI.**
   - Ban: Standard game app templates, cartoonish card designs, childish colors
   - Use: Premium dark theme, elegant card designs, sophisticated layout

2. **NO CLUTTERED GAME SCREENS.**
   - Ban: Dense overlays, too many buttons, competing visual elements during gameplay
   - Use: Clean game table, minimal controls, smart auto-hiding of UI elements

3. **NO AMBIGUOUS LIVE INDICATORS.**
   - Ban: Subtle or hard-to-see live/streaming indicators
   - Use: Clear LIVE badge (red), viewer count, audio/video status always visible

4. **NO SILENT STATES.**
   - Ban: Blank avatars, no mic status, missing player status
   - Use: Avatar with mic/camera indicators, ready/not-ready states, turn indicators

5. **NO GENERIC CARD DESIGNS.**
   - Ban: Simple white cards with basic suits
   - Use: Elegant card backs with purple/gold theme, premium card faces

6. **NO LIGHT MODE IN MVP.**
   - Ban: Light backgrounds, white surfaces as primary
   - Use: Dark-only theme (`#0A0A0F`), dark surfaces, high contrast text

7. **NO COMPLEX NAVIGATION DURING GAMEPLAY.**
   - Ban: Bottom nav visible during active game, tabs during stream viewing
   - Use: Minimal overlay controls, swipe gestures, auto-hiding UI

---

## The Color Palette

```javascript
colors: {
    // BRAND
    "b-purple": "#8B5CF6",
    "b-purple-dark": "#7C3AED",
    "b-purple-light": "#A78BFA",
    "b-gold": "#F59E0B",
    "b-gold-light": "#FBBF24",
    "b-gold-dark": "#D97706",
    "b-black": "#0A0A0F",
    "b-white": "#FFFFFF",

    // SURFACES
    "b-surface": "#0A0A0F",
    "b-surface-elevated": "#161622",
    "b-surface-muted": "#1E1E2E",
    "b-surface-hover": "#252538",

    // TEXT
    "b-on-surface": "#FFFFFF",
    "b-on-surface-muted": "#9CA3AF",
    "b-on-surface-secondary": "#6B7280",

    // BORDERS
    "b-border": "rgba(139, 92, 246, 0.15)",
    "b-border-light": "rgba(139, 92, 246, 0.25)",
    "b-border-gold": "rgba(245, 158, 11, 0.3)",

    // STATES
    "b-success": "#22C55E",
    "b-warning": "#F59E0B",
    "b-error": "#EF4444",
    "b-live": "#FF1A1A",
    "b-info": "#3B82F6",
}
```

---

## The Typography

- **Arabic Font:** `Cairo` (Google Fonts) — Primary, used for all Arabic text
- **Latin Font:** `Inter` (Google Fonts) — Used for English text, numbers, code
- **Fallback Stack:** `'Cairo', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif`

### Mobile Type Scale (375px base — STRICT)

| Element | Size | Weight | Usage |
|---------|------|--------|-------|
| Splash brand name | `text-[28px]` | 800 | Logo display |
| Screen headline | `text-[22px]` to `text-[26px]` | 700 | Screen titles |
| Card title / Player name | `text-[15px]` | 600 | Player names, section headers |
| Body text | `text-[13px]` to `text-[15px]` | 400 | Descriptions |
| Button text | `text-[15px]` | 600 | Primary/secondary buttons |
| Caption / helper | `text-[11px]` to `text-[12px]` | 400 | Viewer counts, timestamps |
| Icon size (Material) | `text-[20px]` to `text-[22px]` | — | Icons |
| Score / point display | `text-[24px]` | 700 | Game scores |

### Arabic Typography Notes
- Arabic text needs **+1-2px** size increase for equivalent readability
- Arabic line-height needs **+0.3** compared to English
- Never apply `letter-spacing` to Arabic text (breaks connected letters)
- Use `text-align: start` instead of `left`/`right`

---

## Common Component Patterns

### 1. Primary Button

> **Keyword:** `primary-btn`
> **Tailwind:** `bg-b-purple text-white rounded-full h-14 px-8 font-semibold text-base shadow-lg shadow-purple-500/25 hover:scale-[0.97] active:scale-95 transition-transform`

### 2. Gold Accent Button

> **Keyword:** `gold-btn`
> **Tailwind:** `bg-gradient-to-r from-b-gold to-b-gold-light text-b-black rounded-full h-12 px-6 font-semibold text-sm hover:scale-[0.97] transition-transform`

### 3. Ghost Button

> **Keyword:** `ghost-btn`
> **Tailwind:** `bg-transparent border border-b-border-light text-b-white rounded-full h-12 px-6 font-medium hover:bg-b-surface-elevated transition-colors`

### 4. Stream Card

> **Keyword:** `stream-card`
> **Tailwind:** `bg-b-surface-elevated rounded-2xl overflow-hidden border border-b-border hover:border-b-border-light transition-all`

### 5. Player Video Square

> **Keyword:** `player-video`
> **Tailwind:** `relative bg-b-surface-muted rounded-xl overflow-hidden aspect-square border border-b-border`

### 6. Game Table Surface

> **Keyword:** `game-table`
> **Tailwind:** `bg-gradient-to-b from-green-900/20 to-green-950/30 rounded-2xl border border-green-800/30`

### 7. Text Input

> **Keyword:** `text-input`
> **Tailwind:** `w-full h-14 px-4 rounded-xl bg-b-surface-muted border border-b-border focus:border-b-purple focus:ring-2 focus:ring-b-purple/20 outline-none text-white placeholder-b-on-surface-secondary transition-all`

### 8. LIVE Badge

> **Keyword:** `live-badge`
> **Tailwind:** `bg-b-live text-white text-[10px] font-bold px-2 py-0.5 rounded-sm uppercase tracking-wider animate-pulse`

### 9. Gold Badge / VIP Indicator

> **Keyword:** `gold-badge`
> **Tailwind:** `bg-b-gold/20 text-b-gold text-[11px] font-semibold px-2 py-0.5 rounded-full border border-b-gold/30`

### 10. Mic/Camera Status Icon

> **Keyword:** `mic-indicator`
> **Tailwind:** `absolute bottom-1.5 right-1.5 w-5 h-5 rounded-full flex items-center justify-center` + `bg-b-error/80` (muted) or `bg-b-success/80` (active)

---

## Game-Specific Patterns

### Card Design
- Card back: Dark purple gradient with subtle gold pattern
- Card face: Clean, high-contrast suit symbols
- Cards in hand: Fanned at bottom, overlapping, tap to select
- Played cards: Appear in center of table with smooth animation

### Player Positioning (Landscape)
```
           Partner (Top)
              [Video]
           [Name] [Score]
              
Opponent ←  [Game Table]  → Opponent
(Left)      [Played Cards]     (Right)

           [Your Cards - Fan]
           [Your Video/Name]
           [Controls Bar]
```

### Score Display
- Team score prominently displayed
- Current round score smaller
- Winning score target (120 for Sun, varies for Hokm with bonuses)
- Gold accent on winning team's score

---

## Generation Protocol (The "Mobile First + Landscape Game" Rule)

1. **Step 1:** Design for 375px width (iPhone SE/mini) for all non-game screens
2. **Step 2:** Design for 812x375px (landscape) for game play screens
3. **Step 3:** Ensure touch targets are min 48px (44px minimum for game controls)
4. **Step 4:** Use Tailwind classes from the list above
5. **Step 5:** Add RTL notes as HTML comments for Arabic implementation
6. **Step 6:** Verify no anti-patterns (Kill List)

---

## RTL Support Notes

When generating screens, add these comments for developers:
```html
<!-- RTL: Use dir="rtl" on html element -->
<!-- RTL: Flip horizontal layouts with flex-row-reverse -->
<!-- RTL: Use logical properties: ms-4 (margin-start) not ml-4 -->
<!-- RTL: Flip directional arrows with scale-x-[-1] -->
<!-- RTL: Use Cairo font for Arabic: font-['Cairo'] -->
<!-- RTL: Increase body text to 17px for Arabic -->
```

---

## Orientation Handling

### Portrait Screens (Home, Discover, Profile, Chat, Settings)
- Design for 375px width
- Standard mobile layout
- Bottom navigation visible
- Vertical scrolling

### Landscape Screens (Game Play, Stream Viewer)
- Design for landscape aspect ratio (16:9 minimum)
- Hide status bar and system navigation
- Video squares adapt to landscape width
- Game table fills center area
- Cards at bottom, controls as overlay
- Auto-rotate on entry, lock to landscape

---

## Output Format

Always generate:
- Single self-contained HTML file
- Tailwind CDN link: `<script src="https://cdn.tailwindcss.com"></script>`
- Tailwind config with custom colors:
```html
<script>
tailwind.config = {
  theme: {
    extend: {
      colors: {
        'b-purple': '#8B5CF6',
        'b-purple-dark': '#7C3AED',
        'b-purple-light': '#A78BFA',
        'b-gold': '#F59E0B',
        'b-gold-light': '#FBBF24',
        'b-gold-dark': '#D97706',
        'b-black': '#0A0A0F',
        'b-surface': '#0A0A0F',
        'b-surface-elevated': '#161622',
        'b-surface-muted': '#1E1E2E',
        'b-surface-hover': '#252538',
        'b-on-surface': '#FFFFFF',
        'b-on-surface-muted': '#9CA3AF',
        'b-on-surface-secondary': '#6B7280',
        'b-live': '#FF1A1A',
      }
    }
  }
}
</script>
```
- Google Fonts link for Cairo and Inter: `<link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">`
- Material Symbols for icons: `<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet" />`
- Viewport meta: `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
- Dark background on body: `<body class="bg-b-surface text-b-on-surface font-['Inter']">`