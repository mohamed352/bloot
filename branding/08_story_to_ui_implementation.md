# Bloot — Story to UI Implementation

## Overview

This document maps Bloot's brand values and story directly to concrete UI decisions. Every screen, component, color, and animation in Bloot exists because of a story-driven reason — not because it looks cool or follows a trend.

If you can't trace a UI decision back to a brand value or user need documented here, it doesn't belong.

---

## Brand Values → UI Mapping

### 1. Social Connection → Always-Visible Voice/Video

**Brand value:** "Balout is never played alone. It's 4 players, 2 teams, 1 shared experience."

**UI Implementation:**

| UI Element | Decision | Why |
|------------|----------|-----|
| Voice controls | Always visible in game, top position | Voice IS the social layer — hiding it breaks the promise |
| Video squares | 4 visible at all times during game | You should always see your teammates and opponents |
| Mic status indicator | 3-bar wave next to each player avatar | You need to know who's talking and who's muted |
| Chat access | Swipe up from bottom, always 1 gesture away | Chat should never be more than 1 swipe away |
| Emoji reactions | Available during gameplay, non-blocking | React without disrupting the game |
| Player status | Always visible: connected, disconnected, speaking | Social connection requires awareness |

**Component specs:**
```
Voice Control Button:
  Size: 44 × 44dp
  Position: top-right (portrait), top-left (landscape)
  State ON:  Purple bg, wave animation
  State OFF: Red bg, slash icon, no animation

Video Square:
  Size: Minimum 120 × 90dp (portrait), 160 × 100dp (landscape)
  Border: 2px solid transparent default
  Speaking: 2px solid #8B5CF6 with pulse glow
  Disconnected: Grayscale overlay + reconnect text
```

---

### 2. Competitive Spirit → Rankings, Scores, Gold Accents

**Brand value:** "Every hand has a strategy. Every game has a winner. Every player wants to be the best."

**UI Implementation:**

| UI Element | Decision | Why |
|------------|----------|-----|
| Score display | Large, always visible during game | Win/loss is the core loop — always know the score |
| Ranking badge | On profile and on player cards | Competitive players need visible proof of skill |
| Gold accents on achievements | Gold (#F59E0B) for wins, streaks, milestones | Gold = earned, not given — visual reward |
| Tournament banner | Prominent on home screen | Tournaments are the competitive outlet |
| Post-game stats | Detailed breakdown after each hand | Competitive players love data |
| Win/rank animation | Confetti + gold shimmer on victories | Winning should FEEL like winning |

**Component specs:**
```
Score Display:
  Font: --text-score (24px, Bold)
  Color: #FFFFFF
  Winning team: Gold (#F59E0B) highlight
  Animation: Count-up on score change, 400ms

Ranking Badge:
  Size: 24px circle
  Bronze: rgba(180, 83, 9, 1) (#B45309)
  Silver: rgba(148, 163, 184, 1) (#94A3B8)
  Gold: rgba(245, 158, 11, 1) (#F59E0B)
  Diamond: purple-to-gold gradient

Achievement Shimmer:
  Background: linear-gradient(110deg, transparent 33%, rgba(245,158,11,0.3) 50%, transparent 67%)
  Animation: shimmer 2s linear infinite
```

---

### 3. Premium Experience → Dark Theme, Gold Accents, Smooth Animations

**Brand value:** "No ads clutter. No childish graphics. No outdated UI. Every pixel is intentional."

**UI Implementation:**

| UI Element | Decision | Why |
|------------|----------|-----|
| Dark theme only (MVP) | #0A0A0F background | Premium feels dark, focused, cinematic |
| Gold on achievements | #F59E0B only for earned things | Gold = premium. Overuse = cheap |
| Purple for interactive | #8B5CF6 for buttons, links | Purple = digital action. Consistent. |
| Glass morphism panels | Blur + subtle purple border | Depth without clutter — premium feeling |
| Smooth micro-interactions | 200-300ms spring physics | Cheap apps jerk. Premium apps flow. |
| No ads, ever | Clean, uncluttered layouts | Ads destroy premium feel |
| Custom card designs | Bespoke Balout card art | Generic cards feel like every other app |

**Component specs:**
```
Glass Panel:
  background: rgba(22, 22, 34, 0.7)
  backdrop-filter: blur(16px)
  border: 1px solid rgba(139, 92, 246, 0.15)
  border-radius: 16px

Premium Button:
  background: #8B5CF6
  color: #FFFFFF
  border-radius: 12px
  padding: 14px 32px
  press: scale(0.96), 100ms
  shadow: 0 2px 8px rgba(139, 92, 246, 0.3)

Gold Accent Element:
  color: #F59E0B
  text-shadow: 0 0 20px rgba(245, 158, 11, 0.3)
  ONLY on: achievements, wins, premium, VIP
  NEVER on: standard buttons, links, nav
```

---

### 4. Gulf Heritage → Arabic-First, RTL-First

**Brand value:** "Bloot is Arabic-first. RTL-first. Built with Khaleeji culture at its core."

**UI Implementation:**

| UI Element | Decision | Why |
|------------|----------|-----|
| Default language: Arabic | All primary UI in Arabic | Arabic is the primary audience |
| Default direction: RTL | `dir="rtl"` as default | RTL is not an adaptation — it's the default |
| Font: Cairo (Arabic) | Primary typeface for all Arabic text | Modern, legible, culturally appropriate |
| Slang in UI | "يا هلا" not "مرحبا", "شباب" not "لاعبين" | Authentic Gulf voice, not formal MSA |
| Card terminology | "مكّة" "سنة" "بن" using Arabic terms | Balout terms in Arabic, not translated |
| Number system | Arabic-Indic numerals in pure Arabic contexts | Culturally correct |
| Diwaniya references | UI language evokes gathering culture | "غرفة" (room) evokes diwaniya |
| Ramadan mode | Special theme during Ramadan | Cultural awareness embedded in product |

**RTL Implementation Rules:**
```
1. ALL layout uses logical CSS properties (inline-start, inline-end)
2. Text alignment: text-align: start (NEVER left/right)
3. Icons mirror in RTL: arrows, chevrons, flow indicators
4. Card dealing order: right-to-left
5. Swipe gestures: swipe left = back (in RTL)
6. Progress fills: right-to-left
7. Time display: stays LTR even in RTL layout
8. Numbers in game UI: LTR directionality within RTL container
```

**UI Copy — Authentic vs. Generic:**

| Context | Generic (NO) | Authentic (YES) |
|---------|-------------|-----------------|
| Welcome | مرحباً بك | يا هلا والله |
| Play button | ابدأ اللعب | العب |
| Room | غرفة لعب | غرفة |
| Good game | لعبة جيدة | الله يعطيك العافية |
| Ready | مستعد | جاهز |
| Waiting | جاري الانتظار | ننتظر اللاعب الرابع |
| Nice move | حركة جيدة | ما شاء الله |

---

### 5. Fair Play → Anti-Cheat Indicators, Transparent Rules

**Brand value:** "The best game is a fair game. Everyone plays by the same rules."

**UI Implementation:**

| UI Element | Decision | Why |
|------------|----------|-----|
| Anti-cheat badge | Green shield icon on room cards | Players need to trust the platform |
| Connection quality indicator | 4-level signal icon per player | If someone's lagging, others should know |
| Move timer | Visible countdown on each turn | Prevents stalling, keeps game moving |
| Score transparency | Full breakdown always accessible | No hidden scoring, no ambiguity |
| Rules accessible | "?" icon with complete Balout rules | Everyone should know the rules |
| Player reputation | Star rating visible on profile | Community-policing against quitters |
| Disconnection handling | Auto-pause, clear reconnect UI | Don't penalize for bad connection |

**Component specs:**
```
Anti-Cheat Badge:
  Icon: Shield check
  Color: #22C55E (Success Green)
  Size: 16px
  Position: Inline with room name
  Tooltip: "هذه الغرفة محمية" (This room is protected)

Connection Quality:
  4 bars: Excellent (green #22C55E)
  3 bars: Good (yellow #F59E0B)
  2 bars: Fair (orange #F97316)
  1 bar: Poor (red #EF4444)
  Position: Next to player avatar

Move Timer:
  Circular countdown: 30 seconds default
  Color: Purple #8B5CF6 → switches to Red #EF4444 at 10s
  Position: On each player's video square
  Warning: Haptic at 10s remaining
```

---

## Emotional Design Map

Different moments in the Bloot experience require different emotional responses. The UI should match the emotion.

### Moment → Emotion → Design Response

| Moment | Emotion | UI Response |
|--------|---------|-------------|
| Opening the app | Welcoming, social | Warm greeting, purple glow, "يا هلا" |
| Browsing rooms | Casual, curious | Clean list, clear room info, easy to browse |
| Joining a room | Anticipation, social | Voice connects immediately, "اهلاً فلان" chime |
| Waiting for players | Relaxed, social | Chat encouraged, "ننتظر اللاعب الرابع" with a smile |
| Game starting | Excited, focused | Card dealing animation, background dims slightly |
| Your turn | Focused, confident | Purple glow on your cards, "دورك" prompt |
| Playing a winning card | Thrilled, proud | Card animation to center, subtle gold flash |
| Winning a hand | Celebratory | Score animation, gold shimmer on winning team |
| Losing a hand | Graceful | Subtle fade, encouraging text "اليد الجاية احسن" |
| Winning the game | Triumphant | Confetti, gold border, celebration animation |
| Losing the game | Accepting, motivated | "خيرها بغيرها" message, quick rematch option |
| Going live (streamer) | Excited, confident | Red LIVE badge pulse, viewer count, chat opens |
| Receiving a gift (streamer) | Grateful, happy | Gift animation, gold accent, thank you prompt |
| Earning a badge | Proud | Achievement card, gold shimmer, share option |
| Someone disconnects | Frustrated | Clear "Player left" indicator, auto-pause, reconnect countdown |
| Scoring dispute | Confused | Full score breakdown, rules link, clear explanation |

### Emotional Color Mapping

| Emotion | Primary Color | Accent | Animation Speed |
|---------|-------------|--------|-----------------|
| Calm / Relaxed | #8B5CF6 (Purple) | — | Slow (400ms) |
| Focused / Active | #8B5CF6 (Purple) | Glow effect | Medium (200-300ms) |
| Excited / Winning | #F59E0B (Gold) | Shimmer | Fast (100-200ms) |
| Alert / Warning | #F59E0B (Gold) | Pulse | Medium (300ms) |
| Error / Disconnected | #EF4444 (Red) | Pulse | Urgent (100ms) |
| Success / Connected | #22C55E (Green) | Fade | Quick (200ms) |
| Social / Chatting | #8B5CF6 (Purple) | Message slide | Snappy (150ms) |

---

## Screen-by-Screen Value Trace

### Home Screen

| UI Element | Brand Value | Reason |
|------------|-------------|--------|
| "العب" (Play) button | Social Connection | Entry point to playing together |
| "تفرج" (Watch) tab | Social Connection | Viewers are first-class users |
| Live rooms section | Social Connection + Live | Show what's happening now |
| Streamer thumbnails | Social Connection | Faces = social, not just room cards |
| Purple accent on active tab | Premium | Consistent, branded |
| Gold badge on featured streams | Competitive + Premium | Highlighted = earned attention |

### Game Room (Lobby)

| UI Element | Brand Value | Reason |
|------------|-------------|--------|
| Voice chat auto-on | Social Connection | Voice = social, must be default |
| Video toggle easily accessible | Social Connection | Video is one tap, not buried |
| Anti-cheat badge visible | Fair Play | Trust before you play |
| Room rules displayed | Fair Play | Transparency |
| "جاهز" (Ready) button | Competitive | Clear commitment to play |

### Active Gameplay

| UI Element | Brand Value | Reason |
|------------|-------------|--------|
| 4 video squares | Social Connection | Always see the people |
| Voice indicators | Social Connection | Know who's talking |
| Score prominently displayed | Competitive | Always know the score |
| Your turn indicator | Competitive + Fair | Clear whose turn it is |
| Cards with playable state | Competitive + Fair | Can't miss which cards are valid |
| Gold on winning score | Competitive | Gold = earned |

### Stream View

| UI Element | Brand Value | Reason |
|------------|-------------|--------|
| LIVE badge | Live | Pulsing, unmissable |
| Viewer count | Social + Competitive | Social proof + streamer motivation |
| Chat overlay | Social | Interactive viewing |
| Gift button | Premium + Social | Monetization + expressiveness |
| Follow button | Social Connection | Build community |

---

## Animation Philosophy

Animations in Bloot are not decoration — they're **emotional communication**.

| Principle | Implementation |
|-----------|---------------|
| Meaningful motion | Every animation communicates: state change, success, error, transition |
| Not slow, not fast | 200-300ms for most, 400ms for emphasis, 100ms for micro |
| Spring physics | Cards and interactive elements use spring easing, not linear |
| No animation for decoration | If it doesn't communicate, it doesn't animate |
| Respect reduce motion | When reduce-motion is on, cut to 200ms linear max |
| Game animations prioritize flow | Card dealing is staggered but fast — don't slow the game |
| Celebration animations are earned | Gold shimmer only on achievements, not every interaction |

---

*Every pixel in Bloot exists for a reason. The reason is always a story, a value, or a need — never just "because it looks cool."*