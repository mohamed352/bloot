# Bloot — Missing Screens Report

Identifies all screens referenced in the master flow map that need to be designed and built, organized by priority.

---

## Priority Definitions

| Priority | Label | Meaning |
|---|---|---|
| **P0** | Must Have for MVP | App cannot launch without these screens |
| **P1** | Should Have | Core value prop screens; app feels broken without them |
| **P2** | Nice to Have | Polish and completeness features for post-MVP |

---

## P0 — Must Have for MVP

These screens are required for the minimum viable product: a player can authenticate, find a room, and play a complete game of Baloot.

| # | Screen | Flow | Description | Key Components |
|---|---|---|---|---|
| 1 | Splash | Launch | Brand animation, version check, auth state resolution | Bloot logo animation, loading spinner, version check logic |
| 2 | Welcome Onboarding | Launch | 3-card value prop for new users | Swipeable cards (Play, Watch, Compete), Arabic text, CTA button, skip option |
| 3 | Phone Number Entry | Auth | Saudi phone input with +966 prefix | Phone input field, country code selector, validation error states, "إرسال الكود" CTA |
| 4 | OTP Verification | Auth | 6-digit code entry with countdown timer | 6 OTP digit boxes, 60s countdown, resend link, error states (wrong code, expired) |
| 5 | Profile Setup | Auth | Avatar picker + nickname entry | Grid of default avatars, nickname text field (Arabic supported), username validation, CTA |
| 6 | Home Screen | Home | Main hub with quick actions | Hero banner, "إنشاء غرفة" / "انضمام" CTAs, live streams carousel, bottom nav (Home, Discover, Play, Chat, Profile) |
| 7 | Create Room | Room | Room configuration before creating | Room name input, privacy toggle (public/private), game speed toggle, "إنشاء" CTA |
| 8 | Join Room | Room | Enter 6-char code to join existing room | 6-char code input, "انضمام" CTA, error states (invalid, full, started), paste-from-clipboard |
| 9 | Room Lobby | Room | Wait for 4 players, ready up | 4 player slots with avatars, ready/unready toggle, room code display + share, pre-game chat area, "جاهز" button |
| 10 | Game Play — Main | Room | Active game view with cards and actions | Player hands (own cards visible), 4 trick piles in center, teammate indicators, trump suit badge, score strip |
| 11 | Game Play — Bidding | Room | Bidding phase overlay | Current bidder highlight, bid options (Pass, Sun, Hokm + suit selector), bid timer (30s), bid history sidebar |
| 12 | Game Play — Trick | Room | Playing a card for current trick | Highlighted playable cards, turn indicator, trick animation area, trick point counter |
| 13 | Game — Round Score | Room | Between-round score summary | Team scores, round points breakdown, "الجولة القادمة" CTA, running total |
| 14 | Game — Final Score | Room | End-of-game results | Winner banner with confetti, final scores table, player stats (MVP, best trick), "إعادة المباراة" / "العودة" CTAs |
| 15 | Error — Network | Error | Offline / no connection fallback | Illustration, "لا يوجد اتصال بالإنترنت" message, retry button |
| 16 | Error — General | Error | Catch-all error screen | Illustration, error message, "حاول مرة أخرى" button, "العودة للرئيسية" link |
| 17 | Loading / Skeleton | Error | Placeholder during data fetch | Skeleton cards matching home layout, shimmer animation |

**P0 Screen Count: 17**

---

## P1 — Should Have

These screens complete the social and viewing experience. Without them, users can play Baloot but cannot watch streams or chat.

| # | Screen | Flow | Description | Key Components |
|---|---|---|---|---|

| 1 | Discover / Stream List | Stream | Browse live streams with thumbnails | Grid of stream cards (thumbnail, viewer count, streamer name), category filters, RTL scroll |
| 2 | Stream Viewer | Stream | Watch live stream with integrated game view | Video player, game card overlay, viewer count, streamer info bar |
| 3 | Stream Chat Panel | Stream | Real-time chat alongside stream | Chat message list (RTL), text input, emote picker, scroll-to-bottom button |
| 4 | Stream Gift Overlay | Stream | Send virtual gifts to streamer | Gift tray (grid of gifts with coin prices), coin balance, send animation, coin purchase inline link |
| 5 | Stream Host Controls | Stream | Streamer controls during broadcast | Go Live / End Stream toggle, camera flip, mic toggle, viewer count, chat access |
| 6 | Stream Ended | Stream | Post-stream screen with follow CTA | Streamer card, "متابعة" follow button, "العودة" CTA, duration & viewer stats |
| 7 | Messages List | Chat | List of DM conversations | Conversation list (avatar, name, last message, timestamp, unread badge), "رسالة جديدة" FAB |
| 8 | Chat Conversation | Chat | 1-on-1 DM thread | Message bubbles (RTL alignment), text input, room invite action, timestamp, read receipts |
| 9 | New Message Compose | Chat | Start new conversation | Friend search, friend list with "إرسال" CTA |
| 10 | Notifications | Chat | Bell icon notification feed | Notification items (icon, title, time, read/unread), clear all, type filters |
| 11 | Room Invite Modal | Chat | Accept/decline room invite | Inviter avatar & name, room code, "قبول" / "رفض" CTAs, countdown timer |
| 12 | Profile View | Profile | See own or others' profile | Avatar, nickname, level & XP bar, stats grid (games, wins, win rate), tabs (Stats / Achievements / History / Followers) |
| 13 | Profile Edit | Profile | Edit nickname & avatar | Avatar picker, nickname field, "حفظ" CTA, change photo from gallery/camera |
| 14 | Player Statistics | Profile | Detailed gameplay stats | Win/loss chart, average score, favorite partner, ELO rating, game duration stats, time-series graphs |
| 15 | Force Update | Error | Mandatory app update | Bloot branding, "تحديث مطلوب" message, "تحديث الآن" button (deep link to store) |
| 16 | Maintenance | Error | Server maintenance window | Illustration, "صيانة" message, estimated return time, social links |
**P1 Screen Count: 16**

---

## P2 — Nice to Have

These screens add polish, community features, and advanced functionality for post-MVP releases.

| # | Screen | Flow | Description | Key Components |
|---|---|---|---|---|

| 1 | Profile — Achievements | Profile | Badges & achievement gallery | Achievement grid (locked/unlocked, icon, name, description), progress bar for incomplete achievements, rare/legendary badges |
| 2 | Profile — Game History | Profile | List of past games with results | Scrollable game list (date, opponents, score, result badge), filter by win/loss, tap to see game detail |
| 3 | Profile — Followers / Following | Profile | Social connections list | Tabs (متابِعون / متابَعون), user cards with follow/unfollow button, search/filter |
| 4 | Stream — Coin Purchase | Stream | Buy coins via IAP | Coin package cards (price SAR, coin amount, bonus badge), "شراء" CTA, Apple/Google Pay integration, terms link |
| 5 | Stream — Offline / Not Found | Stream | Stream is no longer live | Illustration, "البث انتهى أو غير متوفر" message, "متابعة" follow CTA, related streams |
| 6 | Stream — VOD Player | Stream | Watch past stream recording | Video player with scrubber, game card replay overlay, like count, "متابعة" CTA |
| 7 | Pre-game Chat | Room | Chat in lobby before game starts | Simple chat interface within room lobby, emotes, room code share |
| 8 | Disconnect Overlay | Room | Shown when player loses connection | "إعادة الاتصال" spinner, countdown timer (60s), "الخروج" abandon option |
| 9 | Game — Learn to Play | Room | Tutorial / rules overlay for new players | Baloot rules cards, practice mode hint, "تخطي" skip button |
| 10 | Chat — Room Invite via DM | Chat | Send/accept room invite in conversation | "دعوة للغرفة" button, room code preview, accept/decline inline |
| 11 | Settings | Settings | App settings hub | Settings groups (Account, Audio, Notifications, Privacy, Language, About),RTL toggle |
| 12 | Settings — Language | Settings | Arabic / English toggle | Language picker, "العربية" / "English" radio buttons, live preview, "حفظ" CTA |
| 13 | Settings — Notifications | Settings | Push notification preferences | Toggle per notification type (Room invites, Game starts, Messages, Streams), quiet hours |
| 14 | Settings — Privacy | Settings | Privacy controls & blocking | Profile visibility toggle, blocked users list, "حظر مستخدم" search, data download request |
| 15 | Settings — Audio | Settings | Mic, speaker, and voice chat settings | Mic sensitivity slider, speaker volume, voice chat toggle, echo cancellation toggle |
| 16 | Settings — Account | Settings | Account management | Phone number display, "تسجيل الخروج" button, "حذف الحساب" danger button with confirmation |
| 17 | Settings — About | Settings | App info & links | App version, terms of service link, privacy policy link, contact support, social links |
| 18 | Auth — Resend OTP | Auth | Resend verification code | "إعادة إرسال الكود" button, cooldown timer (60s), max 3 resends warning |
| 19 | Auth — Error | Auth | Authentication failure screen | Error icon, specific error message (Arabic), "حاول مرة أخرى" CTA, "الاتصال بالدعم" link |
| 20 | Home — Online Friends Bar | Home | Horizontal scroll of online friends | Avatar circles with online indicator, tap to view profile / invite to room |
| 21 | TOS Consent | Auth | Terms of Service acceptance | Scrollable terms text (Arabic), "أوافق" / "رفض" buttons, required to proceed |
**P2 Screen Count: 21**

---

## Screen Count Summary

| Priority | Category | Count |
|---|---|---:|
| **P0** | Auth | 4 |
| **P0** | Home | 1 |
| **P0** | Room / Game | 7 |
| **P0** | Launch | 2 |
| **P0** | Error | 3 |
| | **P0 Total** | **17** |
| **P1** | Discover / Stream List | 1 |
| **P1** | Stream Viewer | 1 |
| **P1** | Stream Chat Panel | 1 |
| **P1** | Stream Gift Overlay | 1 |
| **P1** | Stream Host Controls | 1 |
| **P1** | Stream Ended | 1 |
| **P1** | Messages List | 1 |
| **P1** | Chat Conversation | 1 |
| **P1** | New Message Compose | 1 |
| **P1** | Notifications | 1 |
| **P1** | Room Invite Modal | 1 |
| **P1** | Profile View | 1 |
| **P1** | Profile Edit | 1 |
| **P1** | Player Statistics | 1 |
| **P1** | Force Update | 1 |
| **P1** | Maintenance | 1 |
| | **P1 Total** | **16** |
| **P2** | Profile — Achievements | 1 |
| **P2** | Profile — Game History | 1 |
| **P2** | Profile — Followers / Following | 1 |
| **P2** | Stream — Coin Purchase | 1 |
| **P2** | Stream — Offline / Not Found | 1 |
| **P2** | Stream — VOD Player | 1 |
| **P2** | Pre-game Chat | 1 |
| **P2** | Disconnect Overlay | 1 |
| **P2** | Game — Learn to Play | 1 |
| **P2** | Chat — Room Invite via DM | 1 |
| **P2** | Settings | 1 |
| **P2** | Settings — Language | 1 |
| **P2** | Settings — Notifications | 1 |
| **P2** | Settings — Privacy | 1 |
| **P2** | Settings — Audio | 1 |
| **P2** | Settings — Account | 1 |
| **P2** | Settings — About | 1 |
| **P2** | Auth — Resend OTP | 1 |
| **P2** | Auth — Error | 1 |
| **P2** | Home — Online Friends Bar | 1 |
| **P2** | TOS Consent | 1 |
| | **P2 Total** | **21** |
| | **Grand Total** | **54** |

---

## Development Phase Estimate

| Phase | Priority | Screens | Estimated Effort |
|---|---|---|---|
| **Alpha** | P0 | 17 | 8–10 weeks |
| **Beta** | P0 + P1 | 33 | 14–18 weeks |
| **1.0 Release** | P0 + P1 + P2 | 54 | 22–28 weeks |

---

## Critical Screen Dependencies

```
AUTH FLOW
  Splash ──► Welcome ──► Phone Entry ──► OTP ──► Profile Setup ──► Home
                                                                              │
  All other screens depend on ───────────────────────────────────────► HOME ◄──┘
                                                                              │
  HOME ──► Create Room ──► Room Lobby ──► Game Play ──► Round Score ──► Final Score
  HOME ──► Join Room ──► Room Lobby ──► ...                                  
  HOME ──► Discover ──► Stream Viewer ──► Stream Chat / Gifts
  HOME ──► Messages ──► Conversation                                       
  HOME ──► Profile ──► Edit / Stats 
  HOME ──► Settings ──► Language / Notifications / Privacy / Audio / Account / About
```

---

## Screens-at-Risk (Potential Blockers)

| Screen | Risk | Mitigation |
|---|---|---|
| Game Play — Main | Most complex screen; card rendering, real-time sync, voice chat | Start early; use Flutter CustomPainter for cards; test on low-end devices |
| Stream Viewer | Agora SDK integration, audio sync, PiP mode | Prototype Agora integration in Week 2; fallback to audio-only |
| Auth — OTP | SMS delivery reliability in KSA, auto-fill issues | Test with multiple carriers; implement resend flow; add backup verification |
| Room Lobby | Real-time sync for 4 players, presence detection | Test Firestore listener performance; add connection quality indicator |
| Chat — Stream | High message rate, Arabic RTL, moderation | Implement rate limiting server-side; pre-build profanity filter for Arabic |

---

## Recommendations

1. **Start with P0 screens**: Build the core loop (auth → home → room → game → score) before any social or streaming features.
2. **Prototype Game Play early**: The Baloot card game engine is the highest risk item. Validate game state sync across 4 devices before building surrounding UI.
3. **RTL-first design**: All screens must be designed RTL-first. Arabic text overflow, mirrored icons, and right-aligned layouts should be validated in Figma before implementation.
4. **Firebase emulator**: Use Firebase Local Emulator Suite for all Firestore and Cloud Function development to avoid billing and rate limit issues during development.
5. **Agora sandbox**: Test all voice/video flows in Agora's test environment before production. Confirm echo cancellation works in Baloot's noisy game context.
6. **Design system components**: Build shared Flutter widgets for cards, buttons, modals, and error states first. All 61 screens reuse ~15 core components.