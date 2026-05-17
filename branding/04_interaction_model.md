# Bloot — Interaction Model

## Strategy: "Immersion First, Speed Second"

In a card game, the experience matters more than the speed. Players come to Bloot to **feel** like they're sitting at the table — not to tap through menus as fast as possible. Our interaction model prioritizes immersion (being present, feeling the game, seeing and hearing other players) over raw speed.

That said, joining a game should be fast. Living in the game should be immersive.

---

## Core Principles

### 1. Quick to Play

A player should be able to join a Balout room in **3 taps maximum**:

| Tap | Action | Screen |
|-----|--------|--------|
| 1 | Tap "العب" (Play) button | Home |
| 2 | Tap a room from the list | Room List |
| 3 | Tap "ادخل" (Join) | Room Preview |

Power users can reduce this to 2 taps with "Quick Join" (rejoin last room or auto-match).

The game lobby and menus should be fast and efficient. But once in the game, speed gives way to immersion.

---

### 2. Immersive Game

During gameplay, the interface should **disappear** and let the experience take over:

- **Landscape mode** is mandatory during gameplay
- **Video squares** of all 4 players visible at all times
- **Voice is always on** — no tap-to-talk
- **Controls auto-hide** after 3 seconds of inactivity, tap to reveal
- **Card interactions** are direct — tap to select, subtle lift on hover/press
- **No modal interruptions** during active play

The goal: players forget they're using an app. They're just in the game.

---

### 3. Social by Default

Social features are not hidden behind tabs. They are ambient:

- **Voice is always on** in a room — you opt out, not in
- **Camera is optional** but one tap to enable
- **Chat is always accessible** — swipe up from bottom to reveal
- **Emoji reactions** are available during gameplay (non-disruptive)
- **Viewer chat** for streams — always visible, never blocking the game

---

### 4. Progressive Disclosure

Show only what's needed, when it's needed:

| Context | Visible | Hidden |
|---------|---------|--------|
| Home screen | Room list, Quick Play, Streams | Settings, Profile deep links |
| In Room (waiting) | Players, voice controls, chat | Game controls |
| In Game (playing) | Cards, score, opponent status, voice | Chat (swipe), settings, room info |
| In Game (between hands) | Score summary, chat peek | Full settings |
| Stream (watching) | Video, chat, streamer info | Player private controls |

---

## Touch Targets

| Element | Minimum Size | Recommended | Notes |
|---------|-------------|-------------|-------|
| Primary button | 56 × 56 dp | 56 × 56 dp | "العب", "ادخل", "ابدأ" |
| Secondary button | 48 × 48 dp | 48 × 48 dp | "مشاركة", "تقديم" |
| Game card | 36 × 52 dp | 44 × 64 dp | Slightly larger for comfort |
| Game controls (bet, pass) | 44 × 44 dp | 48 × 48 dp | |
| Voice/Video toggle | 44 × 44 dp | 44 × 44 dp | |
| Chat trigger | 44 × 44 dp | 44 × 44 dp | |
| Small icon button | 36 × 36 dp | 40 × 40 dp | Settings, info |
| List item (room) | Full width × 72 dp | Full width × 80 dp | |
| Slider (volume) | 28 dp height | 32 dp height | Wider track for game context |

---

## Gestures

### Standard Gestures

| Gesture | Action | Context |
|---------|--------|---------|
| Tap | Select, activate | Buttons, cards, list items |
| Long press (500ms) | Card peek/preview | During gameplay, reveal full card |
| Swipe down | Scroll, refresh | Lists |
| Swipe up (from bottom) | Reveal chat | During gameplay |
| Swipe left/right | Dismiss card, switch tabs | Lobby, notifications |

### Game-Specific Gestures

| Gesture | Action | Context |
|---------|--------|---------|
| Tap card | Select/play card | During turn |
| Long press card | Preview card detail | Any time during hand |
| Flick card upward | Play card quickly (power move) | During turn |
| Pinch (two-finger) | Zoom in on game table | During gameplay |
| Tap teammate avatar | Quick voice focus on teammate | During gameplay |
| Double-tap score | View detailed score breakdown | Between hands |

---

## Micro-Interactions

### Button Interactions

```
State: Default
  Background: Purple #8B5CF6
  Scale: 1.0
  Shadow: 0 2px 8px rgba(139, 92, 246, 0.3)

State: Pressed
  Scale: 0.96
  Duration: 100ms ease-out
  Shadow: 0 1px 4px rgba(139, 92, 246, 0.2)

State: Released → Default
  Scale: 0.96 → 1.0
  Duration: 200ms spring(0.34, 1.56, 0.64, 1)
  Shadow: returns to default

State: Disabled
  Background: rgba(139, 92, 246, 0.3)
  Scale: 1.0
  Text: Gray 400
```

### Card Interactions

```
State: In Hand (default)
  Rotation: 0deg
  Y offset: 0
  Shadow: elevation 1
  Scale: 1.0

State: Playable (hover/focus)
  Y offset: -4px (lifts slightly)
  Shadow: elevation 2
  Scale: 1.02
  Border: 1px solid rgba(139, 92, 246, 0.5)

State: Selected
  Y offset: -12px (lifts clearly)
  Shadow: elevation 3
  Scale: 1.05
  Border: 1px solid #8B5CF6
  Duration: 200ms ease-out

State: Not Playable
  Opacity: 0.4
  Scale: 1.0
  No interaction

State: Dealt (animation)
  From: center of table, scale 0.5, opacity 0
  To: position in hand, scale 1.0, opacity 1.0
  Duration: 400ms stagger (100ms per card)
  Easing: cubic-bezier(0.2, 0, 0, 1)

State: Played (to table)
  From: position in hand
  To: center of table
  Duration: 300ms
  Easing: cubic-bezier(0.22, 1, 0.36, 1)
```

### LIVE Badge Interaction

```
State: Live (default)
  Dot: 8px circle, #EF4444
  Pulse animation:
    0%: scale(1.0), opacity(1.0)
    50%: scale(1.4), opacity(0.6)
    100%: scale(1.0), opacity(1.0)
  Duration: 1500ms, infinite, ease-in-out

State: Viewer hover/tap
  Badge expands to show viewer count
  Duration: 200ms
```

### Voice/Video Toggle

```
State: Mic On
  Icon: microphone
  Background: rgba(139, 92, 246, 0.2)
  Border: 1px solid rgba(139, 92, 246, 0.4)
  Animated: audio wave bars pulsing with volume

State: Mic Off / Muted
  Icon: microphone-off
  Background: rgba(239, 68, 68, 0.2)
  Border: 1px solid rgba(239, 68, 68, 0.4)
  Red slash through icon
  NO animation (silent = static)

State: Camera On
  Icon: video
  Background: rgba(139, 92, 246, 0.2)
  Border: 1px solid rgba(139, 92, 246, 0.4)

State: Camera Off
  Icon: video-off
  Background: rgba(255, 255, 255, 0.06)
  Border: 1px solid rgba(255, 255, 255, 0.1)
  Avatar shown instead of video feed
```

---

## Voice & Video Controls

Voice and video controls are **always accessible, never hidden** during gameplay.

### Control Placement

| Screen | Voice Control Position | Video Control Position |
|--------|----------------------|----------------------|
| Home | N/A | N/A |
| Room List | N/A | N/A |
| Waiting Room | Bottom-right corner, persistent | Bottom-right corner, next to mic |
| Active Game (landscape) | Top-left, 44dp button | Top-left, next to mic |
| Between Hands | Same as active game | Same as active game |
| Stream (viewer) | N/A (viewer only) | N/A (viewer only) |

### Voice Feedback

- When mic is ON: 3-bar audio wave indicator appears next to avatar
- When mic is OFF: static icon with red slash
- When another player is speaking: their avatar gets a subtle purple glow
- Volume level visible in 3 bars (low/medium/high) — never precise metering

### Video Feedback

- Active speaker: Purple border glow around their video square
- Camera OFF: Avatar displayed with subtle "camera off" icon
- Connection issues: Pixelation overlay + "اتصال ضعيف" label
- Screen share: Expanded view with minimize button

---

## Game-Specific Interaction Patterns

### Joining a Room

```
Step 1: Player sees room list
  → Tap room card
  → Room preview sheet slides up (200ms)

Step 2: Room preview shows:
  → Room name, player count, stakes
  → Voice ON by default shown
  → Camera OFF by default shown
  → "ادخل الغرفة" primary button

Step 3: Tap "ادخل الغرفة"
  → Connecting animation (purple pulse, 500ms max)
  → Transition into room (landscape rotation if needed)
  → Voice activates immediately
```

### Card Play Flow

```
1. Your turn indicator appears
   → Purple glow on your card area
   → Text: "دورك" (Your turn)
   → Haptic feedback (light)

2. Playable cards lift slightly (Y: -4px)
   → Unplayable cards dim (opacity: 0.4)
   → Animations: 200ms

3. Tap card to select
   → Card lifts further (Y: -12px)
   → Purple border appears
   → Haptic feedback (medium)

4. Tap selected card again (or tap table center) to play
   → Card flies to center (300ms, ease-out)
   → Other players see the card appear
   → Turn indicator moves to next player

5. If long-press instead of tap
   → Card enlarges for preview
   → Release to return to hand
   → Does NOT play the card
```

### Scoring Interaction

```
Between hands:
  → Score summary sheet slides up from bottom
  → Shows team scores with animation (count up)
  → Gold highlight on winning team
  → "التالي" (Next) button to proceed
  → Chat accessible via swipe up
```

---

## Haptic Feedback

| Event | Haptic Pattern | Intensity |
|-------|---------------|-----------|
| Card dealt to you | Single tap | Light |
| Your turn starts | Double tap | Medium |
| Card played (by anyone) | Single tap | Light |
| Winning a hand | Triple tap, 100ms gaps | Medium |
| Losing a hand | Single long vibration (200ms) | Medium |
| Achievement unlocked | Pattern: tap-tap-tap (ascending) | Strong |
| LIVE started | Double tap | Medium |
| Button press | Single tap | Light |
| Error | Single long vibration (300ms) | Strong |

---

## Loading States

### Skeleton Loading

All content areas show skeleton loaders matching their layout:

```css
.bloot-skeleton {
  background: linear-gradient(
    90deg,
    #161622 0%,
    #1E1E2E 40%,
    #161622 80%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s ease-in-out infinite;
  border-radius: 8px;
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

| Component | Skeleton Shape |
|-----------|---------------|
| Room card | Full card width × 72px, rounded |
| Player avatar | Circle, 44px × 44px |
| Video square | Rectangle with 4px radius |
| Chat message | Rounded rectangle, variable height |
| Score display | Number block, 24px × 40px |

---

## Error States

| Error | Visual | Action | Message |
|-------|--------|--------|---------|
| No internet | Full screen, purple illustration | Tap to retry | "لا يوجد اتصال — تحقق من الإنترنت" |
| Room full | Toast notification | Auto-suggest alternatives | "الغرفة مليئة — جرب غرفة ثانية" |
| Mic permission denied | Icon overlay on mic button | Open settings link | "اسمح بالمايكروفون من الإعدادات" |
| Camera permission denied | Icon overlay on camera button | Open settings link | "اسمح بالكاميرا من الإعدادات" |
| Connection lost (in game) | Overlay on video squares | Auto-reconnect | "إعادة الاتصال..." |
| Server error | Toast notification | Auto-retry | "صار خطأ — حاول مرة ثانية" |

---

*The best interface during a game is one you don't notice. Everything should feel like sitting at the table with friends.*