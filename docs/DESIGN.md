---
# ═══════════════════════════════════════════════════════════════════
# BLOOT — MASTER DESIGN SYSTEM TOKENS
# ═══════════════════════════════════════════════════════════════════

brand:
  name: Bloot
  tagline: "Live Baloot — Play. Stream. Compete."
  aesthetic: "Premium Dark Card Room"
  target_market: "Gulf / MENA"

language_policy:
  primary: ar          # Arabic — RTL
  secondary: en        # English — LTR
  default_direction: rtl
  ui_generation: en    # All UI screens generated in English with RTL notes

colors:
  brand:
    purple:        "#8B5CF6"
    purple_dark:   "#7C3AED"
    purple_light:  "#A78BFA"
    gold:          "#F59E0B"
    gold_light:    "#FBBF24"
    gold_dark:     "#D97706"
  surface:
    black:          "#0A0A0F"
    elevated:       "#161622"
    muted:          "#1E1E2E"
    hover:          "#252538"
    card_elevated:  "#161622"
    input_bg:       "#1E1E2E"
    overlay:        "rgba(10, 10, 15, 0.75)"
    game_table_top: "#0D2818"
    game_table_bot: "#091A10"
  text:
    on_surface:           "#FFFFFF"
    on_surface_muted:     "#9CA3AF"
    on_surface_secondary: "#6B7280"
    on_surface_disabled:  "#4B5563"
    purple_text:          "#C4B5FD"
    gold_text:            "#FDE68A"
  border:
    default:    "rgba(139, 92, 246, 0.15)"
    light:      "rgba(139, 92, 246, 0.25)"
    gold:       "rgba(245, 158, 11, 0.30)"
    game_table: "rgba(34, 197, 94, 0.25)"
    input:     "rgba(139, 92, 246, 0.20)"
    input_focus: "#8B5CF6"
  state:
    success:  "#22C55E"
    warning:  "#F59E0B"
    error:    "#EF4444"
    live:     "#FF1A1A"
    info:     "#3B82F6"
  shadow:
    purple_glow:  "0 0 20px rgba(139, 92, 246, 0.30)"
    gold_glow:    "0 0 20px rgba(245, 158, 11, 0.25)"
    card_shadow:  "0 4px 24px rgba(0, 0, 0, 0.40)"
    button_shadow: "0 8px 16px rgba(139, 92, 246, 0.25)"

typography:
  families:
    arabic:     "Cairo"
    latin:      "Inter"
    fallback:   "'Cairo', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif"
  weights:
    light:    300
    regular:  400
    medium:   500
    semiBold: 600
    bold:     700
    extraBold: 800
  scale:
    splash_brand:
      size: 28
      weight: 800
      lineHeight: 1.2
      usage: "Logo / splash display name"
    screen_headline:
      size: 24
      weight: 700
      lineHeight: 1.3
      usage: "Screen titles, hero headlines"
    section_header:
      size: 18
      weight: 700
      lineHeight: 1.3
      usage: "Section headers, card titles"
    card_title:
      size: 15
      weight: 600
      lineHeight: 1.4
      usage: "Player names, stream titles"
    body:
      size: 14
      weight: 400
      lineHeight: 1.5
      usage: "Descriptions, body text"
    body_medium:
      size: 14
      weight: 500
      lineHeight: 1.5
      usage: "Emphasized body text"
    button:
      size: 15
      weight: 600
      lineHeight: 1.2
      usage: "Primary and secondary buttons"
    caption:
      size: 12
      weight: 400
      lineHeight: 1.4
      usage: "Timestamps, viewer counts, helper text"
    micro:
      size: 10
      weight: 700
      lineHeight: 1.0
      usage: "LIVE badge, micro labels"
    score:
      size: 24
      weight: 700
      lineHeight: 1.1
      usage: "Game score display"
  arabic_adjustments:
    size_increase_px: 2
    lineHeight_increase: 0.3
    no_letter_spacing: true
    alignment: "start"

spacing:
  unit: 4          # Base spacing unit in px
  scale:
    xs: 4
    sm: 8
    md: 12
    lg: 16
    xl: 20
    xxl: 24
    xxxl: 32
    section: 48
  padding:
    screen_horizontal: 16
    screen_vertical: 16
    card_internal: 16
    card_external: 12
    input_internal: 16
    button_internal_horizontal: 24
    button_internal_vertical: 14
  gaps:
    card_grid: 12
    list_item: 12
    video_grid: 8

layout:
  border_radius:
    sm: 8
    md: 12
    lg: 16
    xl: 20
    xxl: 24
    full: 9999
    pill: 9999
    card: 16
    input: 12
    button: 9999
    badge: 6
    avatar: 9999
    video_square: 12
    game_table: 16
  sizes:
    avatar_sm: 32
    avatar_md: 40
    avatar_lg: 48
    avatar_xl: 64
    avatar_profile: 100
    avatar_video: 48
    button_height: 52
    button_height_sm: 44
    input_height: 56
    input_height_sm: 44
    bottom_nav_height: 64
    top_bar_height: 56
    icon_size_sm: 16
    icon_size_md: 20
    icon_size_lg: 24
    icon_size_xl: 32
    min_touch_target: 48
    min_game_touch: 44
    card_thumbnail_ratio: "16:9"
    video_square_ratio: "1:1"
    stream_preview_ratio: "16:9"

animations:
  durations:
    micro: 150       # Press, toggle, hover
    standard: 250    # Page transitions, reveals
    emphasis: 400    # Hero animations, modals
    slow: 600        # Splash, onboarding
  curves:
    standard: "cubic-bezier(0.4, 0.0, 0.2, 1)"
    decelerate: "cubic-bezier(0.0, 0.0, 0.2, 1)"
    accelerate: "cubic-bezier(0.4, 0.0, 1.0, 1.0)"
    spring: "cubic-bezier(0.175, 0.885, 0.32, 1.275)"
  presets:
    button_press: "scale 0.97 → 0.95, 150ms, standard"
    card_hover: "border-color transition, 250ms, standard"
    fade_in: "opacity 0 → 1, 250ms, decelerate"
    slide_up: "translateY(20) → 0, 400ms, decelerate"
    pulse_live: "opacity pulse 0.8 → 1, 2000ms, infinite"
    card_deal: "scale 0.5 → 1, rotate 10deg → 0, 400ms, spring"

components:
  primary_button:
    bg: "linear-gradient(135deg, #8B5CF6, #7C3AED)"
    text_color: "#FFFFFF"
    border_radius: 9999
    height: 52
    padding_horizontal: 32
    font_size: 15
    font_weight: 600
    shadow: "0 8px 16px rgba(139, 92, 246, 0.25)"
    states:
      pressed: "scale(0.97), bg darkened to #6D28D9"
      disabled: "opacity 0.50"
      loading: "spinner replaces text"

  gold_button:
    bg: "linear-gradient(135deg, #F59E0B, #FBBF24)"
    text_color: "#0A0A0F"
    border_radius: 9999
    height: 48
    padding_horizontal: 24
    font_size: 14
    font_weight: 600
    shadow: "0 8px 16px rgba(245, 158, 11, 0.25)"
    states:
      pressed: "scale(0.97)"
      disabled: "opacity 0.50"

  ghost_button:
    bg: "transparent"
    text_color: "#FFFFFF"
    border: "1px solid rgba(139, 92, 246, 0.25)"
    border_radius: 9999
    height: 48
    padding_horizontal: 24
    font_size: 14
    font_weight: 500
    states:
      hover: "bg #1E1E2E"
      pressed: "bg #252538"

  stream_card:
    bg: "#161622"
    border_radius: 16
    border: "1px solid rgba(139, 92, 246, 0.15)"
    overflow: hidden
    states:
      hover: "border-color rgba(139, 92, 246, 0.25)"
    children:
      thumbnail: "16:9 ratio, bg #1E1E2E"
      live_badge: "absolute top-left"
      viewer_count: "absolute top-right"
      stream_info: "padding 12px below"

  player_video_square:
    bg: "#1E1E2E"
    border_radius: 12
    overflow: hidden
    aspect_ratio: "1:1"
    border: "1px solid rgba(139, 92, 246, 0.15)"
    children:
      video_feed: "full-width, full-height"
      player_name: "bottom, text 12px semiBold"
      team_border: "purple (#8B5CF6) for team A, gold (#F59E0B) for team B"
      mic_indicator: "absolute bottom-right, 20x20 circle"
      camera_indicator: "absolute top-right, small icon"
      turn_indicator: "glowing border when active"

  game_table_surface:
    bg: "linear-gradient(180deg, rgba(13,40,24,0.20), rgba(9,26,16,0.30))"
    border_radius: 16
    border: "1px solid rgba(34, 197, 94, 0.25)"
    padding: 16
    usage: "Center game area during Baloot play"

  text_input:
    bg: "#1E1E2E"
    height: 56
    padding_horizontal: 16
    border_radius: 12
    border: "1px solid rgba(139, 92, 246, 0.20)"
    text_color: "#FFFFFF"
    placeholder_color: "#6B7280"
    states:
      focus: "border #8B5CF6, shadow 0 0 0 3px rgba(139,92,246,0.15)"
      error: "border #EF4444, error text below"
      disabled: "opacity 0.50"

  live_badge:
    bg: "#FF1A1A"
    text_color: "#FFFFFF"
    font_size: 10
    font_weight: 700
    padding: "2px 8px"
    border_radius: 4
    text: "LIVE"
    animation: "pulse, opacity 0.8→1, 2s infinite"
    position: "absolute, top-left of container"

  gold_badge:
    bg: "rgba(245, 158, 11, 0.20)"
    text_color: "#F59E0B"
    font_size: 11
    font_weight: 600
    padding: "2px 8px"
    border_radius: 9999
    border: "1px solid rgba(245, 158, 11, 0.30)"
    usage: "VIP, premium, achievement badges"

  mic_camera_indicator:
    active_mic:
      bg: "rgba(34, 197, 94, 0.80)"
      icon: "mic_on"
      size: 20
      position: "absolute bottom-right"
    muted_mic:
      bg: "rgba(239, 68, 68, 0.80)"
      icon: "mic_off"
      size: 20
      position: "absolute bottom-right"
    camera_on:
      icon: "videocam"
      size: 14
      position: "absolute top-right"
    camera_off:
      icon: "videocam_off"
      size: 14
      position: "absolute top-right"

  bottom_navigation:
    height: 64
    bg: "#0A0A0F"
    border_top: "1px solid rgba(139, 92, 246, 0.10)"
    items:
      home: { icon: "home", label: "Home" }
      discover: { icon: "search", label: "Discover" }
      play: { icon: "play_circle", label: "Play", style: "center raised, gold outline" }
      chat: { icon: "chat", label: "Chat" }
      profile: { icon: "person", label: "Profile" }
    active_color: "#8B5CF6"
    inactive_color: "#6B7280"

dark_mode:
  mvp_status: "dark-only"
  note: "No light theme in MVP. All screens use dark surfaces."
  surfaces:
    background: "#0A0A0F"
    card: "#161622"
    input: "#1E1E2E"
    hover: "#252538"
    overlay: "rgba(10, 10, 15, 0.75)"
  text_hierarchy:
    primary: "#FFFFFF"
    secondary: "#9CA3AF"
    tertiary: "#6B7280"
    disabled: "#4B5563"
  brand_accents:
    primary: "#8B5CF6"
    secondary: "#F59E0B"

responsive:
  mobile_portrait:
    width: 375
    orientation: portrait
    usage: "All screens except game play"
  mobile_landscape:
    width: 812
    height: 375
    orientation: landscape
    usage: "Game play, stream viewer"
  breakpoints:
    small: 320
    medium: 375
    large: 428
    tablet: 768

game_specific:
  card_design:
    back: "Dark purple gradient with subtle gold pattern overlay"
    face: "Clean, high-contrast suit symbols on white/cream"
    width_ratio: 0.65     # standard playing card ratio
    corner_radius: 8
    shadow: "0 2px 8px rgba(0,0,0,0.50)"
    fan_overlap: "-20px per card"
    selected_lift: "8px up"
    valid_opacity: 1.0
    invalid_opacity: 0.4
  score_display:
    format: "Us: {score} — Them: {score}"
    leading_accent: gold
    target_sun: 120
    target_hokm: "varies by bid"
    round_format: "Round {current}/{total}"
  player_positions:
    landscape_layout: |
      ┌──────────────────────────────────────────────┐
      │ [Bar]                Score              [⚙]  │
      │              [Partner Video]                  │
      │ [Opp1 Video]   [Game Table]   [Opp2 Video]   │
      │              [Your Video]                    │
      │         [Your Cards — Fan]                   │
      │         [Controls Bar]                       │
      └──────────────────────────────────────────────┘
    rtl_note: "Opp1 and Opp2 swap positions in RTL layout"
---
# ═══════════════════════════════════════════════════════════════════
# END OF DESIGN TOKENS
# ═══════════════════════════════════════════════════════════════════

---

# Bloot — MASTER Design System

> This is the single source of truth for every visual decision in the Bloot app. Every contributor, AI agent, and designer must reference this file before creating or modifying UI.

---

## 1. Overview

Bloot is a **premium Baloot social streaming platform** targeting the Gulf/MENA market. The design language is:

- **Dark-first** — Every surface is dark. No light mode exists in MVP.
- **Arabic-first RTL** — Layouts are built right-to-left first, then flipped for English.
- **Card-room luxury** — The UI should evoke the feeling of entering an exclusive, sophisticated card room.
- **Social at the core** — Voice/video status, live indicators, and player presence are never hidden.

Design principles, in order of priority:

1. **Clarity over decoration** — Players need to read cards, see scores, and know whose turn it is instantly.
2. **Premium, not generic** — No template game UI. No cartoonish colors. Every surface has purpose.
3. **Voice/video always visible** — Mic and camera indicators appear on every player square.
4. **Dark immersion** — Deep blacks with carefully layered surfaces. Never flat or monotone.
5. **Gold used sparingly** — Gold is for wins, achievements, and VIP. Purple is the primary accent.

---

## 2. Language Policy

| Aspect | Rule |
|--------|------|
| **UI generation language** | English only. All wireframes, mockups, and HTML prototypes must be in English. |
| **RTL notes** | Add `<!-- RTL: ... -->` comments for every directional element. |
| **Arabic text** | Never hardcode Arabic in UI screens. Localization is programmatic. |
| **Arabic rendering** | Cairo font, +2px size increase, +0.3 line-height, no letter-spacing. |
| **Text alignment** | Use `text-align: start` (logical property), never `left`/`right`. |
| **Layout direction** | Use `flex-direction: row-reverse` for RTL, logical properties for margins/padding. |
| **Icon flipping** | Directional icons (arrows, back icons) flip in RTL using `scale-x-[-1]`. |

---

## 3. Colors

### 3.1 Brand Colors

The brand palette is built around **purple** (primary accent, trust, action) and **gold** (achievement, premium, celebration).

| Token | Hex | Usage |
|-------|-----|-------|
| `purple` | `#8B5CF6` | Primary buttons, links, active states, team A border |
| `purpleDark` | `#7C3AED` | Pressed/active button states, darker purple accents |
| `purpleLight` | `#A78BFA` | Hover states, secondary purple accents, purple text on dark |
| `gold` | `#F59E0B` | Wins, achievements, VIP badges, team B border, CTA excitement |
| `goldLight` | `#FBBF24` | Gold hover states, lighter gold accents |
| `goldDark` | `#D97706` | Gold pressed/active states |

**Usage rules:**
- Purple is the **dominant** accent. Use it for primary actions and branding.
- Gold is **sporadic**. Use it only for wins, achievements, premium features, and special CTAs.
- Never use purple and gold at equal visual weight on the same element.

### 3.2 Surface Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `black` | `#0A0A0F` | Main screen background, bottom navigation bg |
| `surfaceElevated` | `#161622` | Cards, list items, elevated containers |
| `surfaceMuted` | `#1E1E2E` | Input backgrounds, subtle containers, muted surfaces |
| `surfaceHover` | `#252538` | Hover states on interactive surfaces |
| `cardElevated` | `#161622` | Cards that need extra elevation above surfaceElevated |
| `inputBg` | `#1E1E2E` | Text input backgrounds |
| `overlay` | `rgba(10,10,15,0.75)` | Semi-transparent overlay for modals, bottom sheets |

**Surface hierarchy:** The 4-level system creates depth without relying on shadows:
1. **Foundation** — `#0A0A0F` (screen background)
2. **Level 1** — `#161622` (cards, containers)
3. **Level 2** — `#1E1E2E` (inputs, nested surfaces)
4. **Level 3** — `#252538` (hover, pressed states)

### 3.3 Text Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `onSurface` | `#FFFFFF` | Primary text — headlines, body, button labels |
| `onSurfaceMuted` | `#9CA3AF` | Secondary text — descriptions, captions |
| `onSurfaceSecondary` | `#6B7280` | Tertiary text — timestamps, helper text |
| `onSurfaceDisabled` | `#4B5563` | Disabled text |
| `purpleText` | `#C4B5FD` | Purple accent text (links, highlights) |
| `goldText` | `#FDE68A` | Gold accent text (wins, achievements) |

### 3.4 Border Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `borderDefault` | `rgba(139,92,246,0.15)` | Default card and container borders |
| `borderLight` | `rgba(139,92,246,0.25)` | Hover or emphasized borders |
| `borderGold` | `rgba(245,158,11,0.30)` | Premium, VIP, or achievement borders |
| `borderGameTable` | `rgba(34,197,94,0.25)` | Game table border |
| `borderInput` | `rgba(139,92,246,0.20)` | Input field borders |
| `borderInputFocus` | `#8B5CF6` | Input field focus borders |

### 3.5 State Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#22C55E` | Mic active, ready states, online indicators |
| `warning` | `#F59E0B` | Warning alerts, countdown overdue |
| `error` | `#EF4444` | Error states, mic muted, destructive actions |
| `live` | `#FF1A1A` | LIVE badge, streaming indicator |
| `info` | `#3B82F6` | Informational states |

### 3.6 Shadow Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `purpleGlow` | `0 0 20px rgba(139,92,246,0.30)` | Logo glow, hero elements |
| `goldGlow` | `0 0 20px rgba(245,158,11,0.25)` | Win celebrations |
| `cardShadow` | `0 4px 24px rgba(0,0,0,0.40)` | Elevated cards |
| `buttonShadow` | `0 8px 16px rgba(139,92,246,0.25)` | Primary buttons |

---

## 4. Typography

### 4.1 Font Families

| Purpose | Font | Source |
|---------|------|--------|
| Arabic text | **Cairo** | Google Fonts |
| English/numbers | **Inter** | Google Fonts |
| Fallback stack | Cairo, Inter, -apple-system, BlinkMacSystemFont, sans-serif | System |

### 4.2 Type Scale

| Role | Size (px) | Weight | Line Height | Usage |
|------|----------|--------|-------------|-------|
| Splash brand | 28 | 800 | 1.2 | Logo display name only |
| Screen headline | 24 | 700 | 1.3 | Screen titles, hero headlines |
| Section header | 18 | 700 | 1.3 | Section headers, modal titles |
| Card title | 15 | 600 | 1.4 | Player names, stream titles, card titles |
| Body | 14 | 400 | 1.5 | Descriptions, body text |
| Body medium | 14 | 500 | 1.5 | Emphasized body text |
| Button | 15 | 600 | 1.2 | Primary/secondary button labels |
| Caption | 12 | 400 | 1.4 | Timestamps, viewer counts, helper text |
| Micro | 10 | 700 | 1.0 | LIVE badge, micro labels |
| Score | 24 | 700 | 1.1 | Game score displays |

### 4.3 Arabic Typography Adjustments

When rendering Arabic text, apply these overrides:

- **Size increase:** +2px over the English equivalent (e.g., `text-[14px]` becomes `text-[16px]`)
- **Line-height increase:** +0.3 over English (e.g., `1.5` becomes `1.8`)
- **Letter-spacing:** Never apply `letter-spacing` to Arabic text — it breaks connected letter forms
- **Font weight:** Cairo at weight 600 reads heavier than Inter at 600; consider using weight 500 for Arabic where 600 is specified for English
- **Alignment:** Always use `text-align: start` (logical start), never `left` or `right`
- **Direction:** Set `dir="rtl"` on the root element, not on every child

---

## 5. Spacing & Layout

### 5.1 Spacing Scale

Base unit: **4px**

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Tight gaps, icon padding |
| `sm` | 8px | Video grid gaps, inner chip padding |
| `md` | 12px | Card external margins, list gaps |
| `lg` | 16px | Screen horizontal padding, card internal padding |
| `xl` | 20px | Section gaps |
| `xxl` | 24px | Between major sections |
| `xxxl` | 32px | Large section spacing |
| `section` | 48px | Full-height section breaks |

### 5.2 Layout Padding

| Context | Value |
|---------|-------|
| Screen horizontal | 16px (use logical `padding-inline`) |
| Screen vertical | 16px |
| Card internal | 16px |
| Card external | 12px |
| Input internal | 16px horizontal, 0 vertical |
| Button internal | 24px horizontal, 14px vertical |

### 5.3 Grid Layouts

| Grid | Gap | Usage |
|------|-----|-------|
| Video 2x2 | 8px | Player video squares in lobby |
| Stream cards 2-col | 12px | Discovery stream grid |
| List items | 12px | Vertical list spacing |

---

## 6. Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 8px | Small badges, chips |
| `md` | 12px | Inputs, video squares |
| `lg` | 16px | Cards, containers |
| `xl` | 20px | Large cards, modals |
| `xxl` | 24px | Hero cards |
| `full` | 9999px | Avatars, circular indicators |
| `pill` | 9999px | Buttons, pills |
| `card` | 16px | Default card radius |
| `input` | 12px | Text input radius |
| `button` | 9999px | Button radius (full/pill) |
| `badge` | 6px | Small badge radius |
| `avatar` | 9999px | Circles only |
| `gameTable` | 16px | Game table surface |

---

## 7. Shadows

| Name | Value | Usage |
|------|-------|-------|
| Purple glow | `0 0 20px rgba(139,92,246,0.30)` | Logo, hero elements, focus rings |
| Gold glow | `0 0 20px rgba(245,158,11,0.25)` | Win celebrations, achievement highlights |
| Card shadow | `0 4px 24px rgba(0,0,0,0.40)` | Elevated cards on dark backgrounds |
| Button shadow | `0 8px 16px rgba(139,92,246,0.25)` | Primary button elevation |

---

## 8. Components

### 8.1 Primary Button

The main action button. Used for "Continue", "Start Game", "Join Room", etc.

| Property | Value |
|----------|-------|
| Background | `linear-gradient(135deg, #8B5CF6, #7C3AED)` |
| Text color | `#FFFFFF` |
| Border radius | 9999px (pill) |
| Height | 52px |
| Padding | 0 32px |
| Font size | 15px |
| Font weight | 600 |
| Shadow | `0 8px 16px rgba(139,92,246,0.25)` |
| Pressed | `scale(0.97)`, background darkens to `#6D28D9` |
| Disabled | `opacity 0.50` |
| Loading | Spinner replaces text, button becomes non-interactive |

**Flutter:** `ElevatedButton` with custom `ButtonStyle` referencing `ColorManager.purple`.

### 8.2 Gold Button

Used for exciting CTAs — "Start Playing", "Join Tournament", room invitations.

| Property | Value |
|----------|-------|
| Background | `linear-gradient(135deg, #F59E0B, #FBBF24)` |
| Text color | `#0A0A0F` (dark text on gold) |
| Border radius | 9999px |
| Height | 48px |
| Padding | 0 24px |
| Font size | 14px |
| Font weight | 600 |
| Shadow | `0 8px 16px rgba(245,158,11,0.25)` |
| Pressed | `scale(0.97)` |
| Disabled | `opacity 0.50` |

### 8.3 Ghost Button

Secondary/outlined action. Used for "Cancel", "Leave Room", "Skip".

| Property | Value |
|----------|-------|
| Background | transparent |
| Text color | `#FFFFFF` |
| Border | `1px solid rgba(139,92,246,0.25)` |
| Border radius | 9999px |
| Height | 48px |
| Padding | 0 24px |
| Font size | 14px |
| Font weight | 500 |
| Hover | Background becomes `#1E1E2E` |
| Pressed | Background becomes `#252538` |

### 8.4 Stream Card

Used in discovery, home feed, and search results for live streams.

| Property | Value |
|----------|-------|
| Background | `#161622` |
| Border radius | 16px |
| Border | `1px solid rgba(139,92,246,0.15)` |
| Overflow | hidden |
| Hover | Border becomes `rgba(139,92,246,0.25)` |
| Thumbnail | 16:9 aspect ratio, background `#1E1E2E` |
| LIVE badge | Absolute top-left, red `#FF1A1A`, pulsing |
| Viewer count | Absolute top-right with eye icon |
| Stream info | Padding 12px below thumbnail |

**Children layout (stack):**
```
┌─────────────────────────────┐
│ [LIVE]          [👁 142]    │  ← Thumbnail (16:9)
│                              │
│    Player/Room visual       │
│                              │
├─────────────────────────────┤
│ 🔴 Stream Title Here        │
│ @host_name • Baloot         │
│ 👥 2/4 players              │
└─────────────────────────────┘
```

### 8.5 Player Video Square

The core social component. Appears in room lobbies, game play, and stream viewing.

| Property | Value |
|----------|-------|
| Background | `#1E1E2E` |
| Border radius | 12px |
| Aspect ratio | 1:1 |
| Border | `1px solid rgba(139,92,246,0.15)` |
| Overflow | hidden |
| Team A border | `#8B5CF6` (purple), 2px |
| Team B border | `#F59E0B` (gold), 2px |
| Turn indicator | Glowing border animation when it's player's turn |

**Overlays:**
```
┌────────────────────┐
│              [📷]   │  ← Camera indicator (top-right)
│                    │
│   Player Video     │
│   or Avatar        │
│                    │
│         [🎤]       │  ← Mic indicator (bottom-right)
│  Player Name  Lv.5 │
└────────────────────┘
```

**Mic indicator variants:**
- Active: Green circle (`rgba(34,197,94,0.80)`), mic icon
- Muted: Red circle (`rgba(239,68,68,0.80)`), mic-off icon
- Size: 20x20px, positioned absolute bottom-right

**Empty seat variant:**
- Dashed border circle (purple, 50% opacity)
- "Waiting..." text in `#6B7280`
- Pulsing border animation
- "Invite" ghost button below

### 8.6 Game Table Surface

The central playing area during Baloot.

| Property | Value |
|----------|-------|
| Background | `linear-gradient(180deg, rgba(13,40,24,0.20), rgba(9,26,16,0.30))` |
| Border radius | 16px |
| Border | `1px solid rgba(34,197,94,0.25)` |
| Padding | 16px |
| Usage | Center area of landscape game view |

**Contains:** Played cards, trick count, trump suit indicator, current game type, score summary.

### 8.7 Text Input

| Property | Value |
|----------|-------|
| Background | `#1E1E2E` |
| Height | 56px |
| Padding | 0 16px |
| Border radius | 12px |
| Border (default) | `1px solid rgba(139,92,246,0.20)` |
| Border (focus) | `1px solid #8B5CF6` |
| Focus ring | `0 0 0 3px rgba(139,92,246,0.15)` |
| Text color | `#FFFFFF` |
| Placeholder | `#6B7280` |
| Error border | `1px solid #EF4444` |
| Disabled | `opacity 0.50` |

### 8.8 LIVE Badge

| Property | Value |
|----------|-------|
| Background | `#FF1A1A` |
| Text | "LIVE" |
| Text color | `#FFFFFF` |
| Font size | 10px |
| Font weight | 700 |
| Padding | 2px 8px |
| Border radius | 4px |
| Animation | Pulse (opacity 0.8→1, 2s infinite) |
| Position | Absolute, top-left of parent |
| Letter-spacing | 1px |

**Critical rule:** The LIVE badge must ALWAYS be visible and animated on any live stream card or stream viewer screen. There is no acceptable state where a live stream does not show a LIVE badge.

### 8.9 Gold Badge / VIP Indicator

| Property | Value |
|----------|-------|
| Background | `rgba(245,158,11,0.20)` |
| Text color | `#F59E0B` |
| Font size | 11px |
| Font weight | 600 |
| Padding | 2px 8px |
| Border radius | 9999px |
| Border | `1px solid rgba(245,158,11,0.30)` |

**Used for:** VIP status, achievement badges, premium indicators, tournament prizes.

### 8.10 Mic/Camera Indicator

| Variant | Background | Icon | Size |
|---------|-----------|------|------|
| Mic on | `rgba(34,197,94,0.80)` | `mic` | 20x20 |
| Mic off | `rgba(239,68,68,0.80)` | `mic_off` | 20x20 |
| Camera on | transparent | `videocam` | 14x14 icon |
| Camera off | transparent | `videocam_off` | 14x14 icon |

**Position:** Mic indicator absolute bottom-right of video square. Camera indicator absolute top-right.

**Shape:** Circle for mic, icon overlay for camera.

### 8.11 Bottom Navigation

| Property | Value |
|----------|-------|
| Height | 64px |
| Background | `#0A0A0F` |
| Border top | `1px solid rgba(139,92,246,0.10)` |
| Active color | `#8B5CF6` |
| Inactive color | `#6B7280` |
| Center button | Play icon, gold outline, slightly raised |

**Items:** Home → Discover → Play (center, gold) → Chat → Profile

**Hidden during:** Game play (landscape), stream viewer (optional)

---

## 9. Dark Mode

**MVP Status: Dark-only.** There is no light theme in the MVP.

All values in this design system assume a dark background. If a light theme is added in the future:

1. Background becomes `#FFFFFF`, surfaces become light grays
2. Text hierarchy reverses (dark text on light surfaces)
3. Brand colors (purple, gold) remain identical
4. Game table surface adjusts to a lighter green felt
5. Shadows become darker and more prominent

For MVP, all `ThemeData` configuration must set `brightness: Brightness.dark`.

---

## 10. Animations

### 10.1 Duration Scale

| Name | Duration | Usage |
|------|----------|-------|
| Micro | 150ms | Button press, toggle, hover |
| Standard | 250ms | Page transitions, reveals |
| Emphasis | 400ms | Hero animations, modal entry |
| Slow | 600ms | Splash, onboarding |

### 10.2 Easing Curves

| Name | Bezier | Usage |
|------|--------|-------|
| Standard | `cubic-bezier(0.4, 0.0, 0.2, 1)` | Default transitions |
| Decelerate | `cubic-bezier(0.0, 0.0, 0.2, 1.0)` | Entering elements |
| Accelerate | `cubic-bezier(0.4, 0.0, 1.0, 1.0)` | Exiting elements |
| Spring | `cubic-bezier(0.175, 0.885, 0.32, 1.275)` | Bouncy, playful |

### 10.3 Animation Presets

| Preset | Description |
|--------|-------------|
| **Button press** | Scale 0.97 → 0.95, 150ms, standard curve |
| **Card hover** | Border color transition, 250ms, standard |
| **Fade in** | Opacity 0 → 1, 250ms, decelerate |
| **Slide up** | TranslateY(20) → 0, 400ms, decelerate |
| **Pulse live** | Opacity pulse 0.8 → 1, 2000ms, infinite |
| **Card deal** | Scale 0.5 → 1, rotate 10deg → 0, 400ms, spring |
| **Trick win** | Gold glow flash on winning player, 600ms |
| **Score update** | Number scale up 1.1x → 1.0, 300ms, spring |

---

## 11. Game-Specific Components

### 11.1 Card Design

Baloot uses a standard 52-card deck. Card visuals must be:

- **Card back:** Dark purple gradient (`#7C3AED` → `#8B5CF6`) with subtle gold diamond pattern overlay
- **Card face:** Clean, high-contrast suit symbols on cream/white background
- **Card dimensions:** Standard playing card ratio (~2.5:3.5), corner radius 8px
- **Card shadow:** `0 2px 8px rgba(0,0,0,0.50)`
- **Selected state:** Card lifts 8px with purple glow shadow
- **Invalid state:** Card opacity reduced to 0.4, not interactive
- **Valid state:** Card opacity 1.0, tappable
- **Fan layout:** Cards overlap by -20px horizontally, selectable on tap
- **Played animation:** Card animates from hand to center of table, 400ms spring curve

### 11.2 Score Display

Score is always visible during game play. Format:

```
Team A (Us): 8 — Team B (Them): 12
```

- Leading team's score rendered in **gold** (`#F59E0B`)
- Trailing team's score in **white** (`#FFFFFF`)
- Round target shown as `/120` for Sun, varies for Hokm with bonuses
- Current round: `Round 3/8`
- Score update animates with spring scale (1.1x → 1.0)

### 11.3 Player Positioning (Landscape)

```
┌──────────────────────────────────────────────┐
│ [Back]    Room: "Friday Night"    Score [⚙]   │
├──────────────────────────────────────────────┤
│              [Partner Video]                  │
│              [Name] [Mic] [Score]             │
│                                               │
│ [Opp1]  ┌──────────────────────┐  [Opp2]     │
│ [Video] │   GAME TABLE          │  [Video]   │
│ [Name]  │   [Played Cards]      │  [Name]    │
│ [Mic]   │   [Trump indicator]   │  [Mic]     │
│          └──────────────────────┘             │
│              [Your Video]                     │
│              [Name] [Mic] [Cam]               │
│                                               │
│     ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐ ┌─┐           │
│     └─┘ └─┘ └─┘ └─┘ └─┘ └─┘ └─┘             │
│     [Your Cards — Fan]                        │
│                                               │
│  [Chat] [Mic] [Cam] [Voice] [Settings] [Exit] │
└──────────────────────────────────────────────┘
```

**RTL note:** Opponent 1 and Opponent 2 swap positions in RTL layout.

**Auto-hide behavior:** After 3 seconds of inactivity, the top bar and controls bar auto-hide. Tap anywhere to reveal.

---

## 12. Do's and Don'ts

### Do

- Use purple (`#8B5CF6`) as the primary action color
- Use gold (`#F59E0B`) sparingly for wins, achievements, VIP
- Use Cairo for Arabic text, Inter for English/numbers
- Increase Arabic text size by +2px and line-height by +0.3
- Use logical properties (`padding-inline`, `text-align: start`)
- Show LIVE badge on every live stream card, always animated
- Show mic/camera indicators on every player video square
- Use `#0A0A0F` for screen backgrounds
- Use the surface hierarchy for depth (0A0A0F → 161622 → 1E1E2E → 252538)
- Design for landscape orientation when building game/stream screens
- Make touch targets minimum 48px (44px for game controls)
- Use spring animations for playful interactions (card dealing, scoring)
- Hide bottom navigation during game play

### Don't

- Don't use gold as the primary accent — purple is primary, gold is accent
- Don't create a light theme for MVP
- Don't use `letter-spacing` on Arabic text
- Don't use `left`/`right` — use logical direction properties
- Don't hide mic/camera indicators
- Don't create generic game UI (no cartoonish cards, no childish colors)
- Don't show bottom navigation during game play
- Don't clutter the game screen during active play
- Don't use green for success — use gold for positive game outcomes
- Don't use red for decorative elements — red is reserved for LIVE, error, and destructive
- Don't make cards unreadable at small sizes — test on 320px width
- Don't use `margin-left` or `margin-right` — use `margin-inline-start`/`end`
- Don't use generic white cards — Bloot cards have themed backs

---

## 13. Responsive Behavior

### Portrait (all screens except game)

| Viewport | Width | Notes |
|----------|-------|-------|
| iPhone SE | 375px | Design baseline |
| iPhone 15 | 393px | Slightly wider, same scale |
| iPhone 15 Pro Max | 430px | Comfortable spacing |
| Small Android | 360px | Minimum target viewport |

- Bottom navigation is always visible
- Vertical scrolling for content
- 2-column grids for stream cards on wider phones
- Touch targets minimum 48px

### Landscape (game play, stream viewer)

| Viewport | Width x Height | Notes |
|----------|----------------|-------|
| iPhone landscape | 812 x 375 | Design baseline |
| iPhone Pro Max landscape | 932 x 430 | More table space |
| Android landscape | 800+ x 360 | Varies |

- Status bar and system navigation hidden (immersive mode)
- Bottom navigation hidden
- Controls overlay and auto-hide after 3s
- Video squares adapt to landscape width
- Game table fills center area
- Cards fanned at bottom

---

## 14. Platform Notes

### Flutter-Specific

- Use `ThemeData` with `brightness: Brightness.dark` and custom `ColorScheme`
- Define `ColorManager` static class for all color tokens — never hardcode hex values in widgets
- Use `flutter_screenutil` for responsive sizing (or manual `MediaQuery`)
- Use `EdgeInsetsDirectional` instead of `EdgeInsets` for all padding/margin
- Use `AlignmentDirectional` for alignment
- Use `TextDirection.rtl` as the default text direction
- Lock orientation with `SystemChrome.setPreferredOrientations` for game screens
- Use `go_router` for navigation with named routes
- Agora SDK for voice/video channels — never implement custom RTC

### iOS-Specific

- Status bar style: `UIStatusBarStyleLightContent`
- Navigation bar: Hidden, custom app bar
- Safe area: Respect top and bottom safe areas
- Orientation: Portrait for all screens except game play

### Android-Specific

- Status bar: Dark icons on dark background (or light icons)
- Navigation bar: Dark, immersive during game play
- System bars: Hidden during landscape game mode
- Edge-to-edge: Enabled for all screens

### Cross-Platform

- Both platforms use identical UI — no platform-specific design variations in MVP
- System font size overrides are respected but capped at reasonable limits
- Respect dynamic type / font scaling up to 1.3x