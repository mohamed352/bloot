# MVP Scope and Phasing Research

## Overview

This document defines the phased delivery plan for Bloot, from MVP through full product. Each phase has clear scope, dependencies, and success metrics.

---

## Phase 1: MVP (Months 1-4)

**Goal:** Launch a playable Baloot app with voice chat and basic social features. Users can sign up, create/join rooms, play Baloot with correct rules, and communicate via voice.

### Features

#### Authentication & Onboarding

| Feature | Description | Priority |
|---|---|---|
| Phone sign-up | SMS OTP verification (Saudi numbers first) | P0 |
| Apple Sign-In | iOS authentication | P0 |
| Google Sign-In | Android authentication | P0 |
| Username selection | Unique username, 3-20 chars, Arabic or Latin | P0 |
| Avatar selection | Choose from preset avatar gallery (10-15 options) | P0 |
| Onboarding flow | 3-step: Sign up → Choose avatar → Ready | P0 |

#### Home Screen

| Feature | Description | Priority |
|---|---|---|
| Create Room CTA | Prominent "Create Room" button | P0 |
| Join Room CTA | "Join Room" with code entry | P0 |
| Live Now section | Horizontal scroll of active streams (thumbnails) | P0 |
| Quick Play | Auto-matchmaking for public rooms | P1 |
| Navigation bar | Bottom tabs: Home, Live, Chat, Profile | P0 |

#### Room & Game

| Feature | Description | Priority |
|---|---|---|
| Create room | Set name, privacy, voice/camera defaults | P0 |
| Join room | Enter 6-digit code or tap invite link | P0 |
| Room lobby | Wait for 4 players, voice chat active | P0 |
| Share room code | Copy code, share via WhatsApp/system share | P0 |
| Deal cards | Automated dealing with animation | P0 |
| Bidding phase | Sun/Hokm/Pass with timer | P0 |
| Trick play | Tap card to play, suit-following enforced | P0 |
| Score display | Running score visible during game | P0 |
| Game end | Winner declared, score summary | P0 |
| Rematch | Option to play again with same players | P0 |
| Voice chat | Agora SDK, mute/unmute, speaker default | P0 |
| Camera toggle | Enable/disable camera during game | P0 |
| Video tiles | Small video overlays at player positions | P0 |
| Turn timer | 30-second timer, auto-play on expiry | P0 |
| Kick player | Host can remove players from room | P1 |
| Spectate mode | Watch ongoing game (no hand visibility) | P1 |

#### Streaming (Basic)

| Feature | Description | Priority |
|---|---|---|
| Watch stream | View live stream with game state + camera | P0 |
| Stream chat | Read and send messages during stream | P0 |
| Stream discovery | "Live Now" section on Home screen | P0 |
| Follow from stream | Follow streamer while watching | P1 |

#### Profile

| Feature | Description | Priority |
|---|---|---|
| View profile | Avatar, username, level, basic stats | P0 |
| Edit profile | Change avatar, bio | P0 |
| Game stats | Games played, win rate | P1 |

### Technical Infrastructure (Phase 1)

| Component | Technology | Purpose |
|---|---|---|
| Frontend | Flutter 3.x | Cross-platform mobile app |
| Backend | Firebase (Firestore, Auth, FCM, Functions) | Serverless backend |
| Voice/Video | Agora RTC SDK | Real-time communication |
| State management | Riverpod | App state and dependency injection |
| Navigation | GoRouter | Declarative routing |
| Analytics | Firebase Analytics + Crashlytics | Usage tracking and crash reporting |
| CI/CD | GitHub Actions + Codemagic | Automated builds and deployment |

### MVP Success Metrics

| Metric | Target (Month 4) |
|---|---|
| App downloads | 5,000 |
| Monthly active users | 2,000 |
| Daily active users | 500 |
| Games played per user/week | 5 |
| Average session duration | 20 minutes |
| Voice chat activation rate | 60% |
| 7-day retention | 25% |
| App store rating | 4.0+ |
| Crash-free rate | 99%+ |

---

## Phase 2: Social & Streaming (Months 5-8)

**Goal:** Add full streaming, gifting, and social features to increase retention and monetization.

### Features

#### Streaming (Full)

| Feature | Description | Priority |
|---|---|---|
| Start stream | "Go Live" with title, camera preview | P1 |
| Stream notifications | Push to followers when streamer goes live | P1 |
| Viewer count | Real-time viewer count display | P1 |
| Stream end summary | Duration, peak viewers, gifts received | P1 |
| Gift system | Virtual coins, gift tray, animations | P2 |
| Like button | Free likes with heart animation | P2 |
| Stream search | Find streams by streamer name | P2 |

#### Social

| Feature | Description | Priority |
|---|---|---|
| Follow/unfollow | Follow system with counts | P1 |
| Online status | See which friends are online/in-game | P1 |
| Friend list | View and manage friends | P1 |
| Add friend by username | Search and send friend request | P1 |
| Recent opponents | Suggest adding opponents after game | P1 |
| Direct messages | Private chat with friends | P2 |
| Game invite via chat | Send room invite in DM | P2 |
| Contacts import | Find friends from phone contacts | P2 |

#### Leaderboards

| Feature | Description | Priority |
|---|---|---|
| Weekly leaderboard | Games won this week | P1 |
| Monthly leaderboard | ELO rating ranking | P1 |
| Top streamers | Viewer hours ranking | P2 |

#### Achievements

| Feature | Description | Priority |
|---|---|---|
| Achievement system | Unlock badges for milestones | P1 |
| Achievement display | Badges shown on profile | P1 |
| Achievement notifications | Alert when new badge earned | P2 |

### Phase 2 Technical Dependencies

| Dependency | Blocker | Resolution |
|---|---|---|
| Gift/coin economy | In-app purchase setup (Apple/Google) | Register merchant accounts early |
| Leaderboards | High Firestore read volume | Cache with Firestore bundles |
| DM system | Real-time message delivery | Firestore snapshots + FCM |

### Phase 2 Success Metrics

| Metric | Target (Month 8) |
|---|---|
| Monthly active users | 10,000 |
| Daily active users | 3,000 |
| Active streamers | 50 |
| Average concurrent viewers per stream | 20 |
| Gifts sent per day | 500 |
| 30-day retention | 20% |
| Revenue (coins) | $2,000/month |

---

## Phase 3: Advanced & Scale (Months 9-14)

**Goal:** Add advanced features for long-term retention, replay, AI moderation, and full monetization.

### Features

#### Advanced Stats & Replay

| Feature | Description | Priority |
|---|---|---|
| Detailed match history | Per-game score breakdown | P2 |
| Game replay | Watch past games move-by-move | P2 |
| Stream recording | Auto-record streams for replay | P2 |
| Stream replay | Watch past streams on profile | P2 |
| Advanced statistics | ELO trend, partner performance, mode preference | P2 |
| Export stats | Share stats as image | P2 |

#### AI & Moderation

| Feature | Description | Priority |
|---|---|---|
| AI moderation | Auto-flag inappropriate content | P2 |
| Profanity filter v2 | ML-based Arabic profanity detection | P2 |
| Cheat detection | Anomaly detection for collusion | P2 |
| AI opponents | Bots for solo play and filling seats | P2 |
| Smart matchmaking | ELO-based room pairing | P2 |

#### Monetization (Full)

| Feature | Description | Priority |
|---|---|---|
| Premium subscription | Ad-free, exclusive avatars, priority support | P2 |
| Avatar marketplace | Purchase premium avatars and frames | P2 |
| Table themes | Custom card backs and table skins | P2 |
| Seasonal pass | Battle pass with exclusive rewards | P2 |

#### Platform Expansion

| Feature | Description | Priority |
|---|---|---|
| iPad/tablet support | Optimized layouts for larger screens | P2 |
| Web app | Flutter Web for browser-based play | P2 |
| Smart TV (casting) | Cast stream to TV | P2 |

### Phase 3 Technical Dependencies

| Dependency | Blocker | Resolution |
|---|---|---|
| Stream recording | Agora Cloud Recording or custom FFmpeg | Evaluate cost vs. build |
| AI moderation | ML model for Arabic content | Use Google Cloud Vision + custom models |
| Cheat detection | Game state anomaly detection | Build statistical model from game data |
| Premium subscriptions | App Store / Play Store subscriptions | Register and configure subscription products |
| Web app | Flutter Web stability | Monitor Flutter Web readiness |

### Phase 3 Success Metrics

| Metric | Target (Month 14) |
|---|---|
| Monthly active users | 50,000 |
| Daily active users | 15,000 |
| Active streamers | 500 |
| Premium subscribers | 2% of MAU |
| Revenue | $15,000/month |
| 90-day retention | 10% |
| App store rating | 4.5+ |

---

## Detailed Feature Matrix

| Feature | Phase 1 (MVP) | Phase 2 | Phase 3 |
|---|---|---|---|
| **Auth** | | | |
| Phone sign-up | ✅ | — | — |
| Apple/Google sign-in | ✅ | — | — |
| Username + avatar | ✅ | — | — |
| **Home** | | | |
| Create/Join room | ✅ | — | — |
| Live Now section | ✅ | — | — |
| Quick Play matchmaking | — | ✅ | — |
| **Room & Game** | | | |
| Full Baloot (Sun + Hokm) | ✅ | — | — |
| Voice chat | ✅ | — | — |
| Camera toggle | ✅ | — | — |
| Turn timer | ✅ | — | — |
| Spectate | — | ✅ | — |
| AI opponents | — | — | ✅ |
| **Streaming** | | | |
| Watch stream | ✅ | — | — |
| Start stream | — | ✅ | — |
| Stream chat | ✅ | — | — |
| Gifts/likes | — | ✅ | — |
| Stream recording/replay | — | — | ✅ |
| **Social** | | | |
| Follow/unfollow | — | ✅ | — |
| Friend system | — | ✅ | — |
| Direct messages | — | ✅ | — |
| Online status | — | ✅ | — |
| **Leaderboards** | | | |
| Weekly/monthly | — | ✅ | — |
| Seasonal | — | — | ✅ |
| **Achievements** | | | |
| Basic badges | — | ✅ | — |
| Advanced milestones | — | — | ✅ |
| **Profile** | | | |
| Create/edit profile | ✅ | — | — |
| Game stats | — | ✅ | — |
| Advanced stats | — | — | ✅ |
| **Monetization** | | | |
| Virtual coins | — | ✅ | — |
| In-app purchases | — | ✅ | — |
| Premium subscription | — | — | ✅ |
| Avatar marketplace | — | — | ✅ |
| Seasonal pass | — | — | ✅ |

---

## Risk Assessment

### High Risks

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Baloot rules implementation bugs | Critical — game is unplayable | High | Extensive unit tests, hire Balout expert for QA, beta test with real players |
| Agora voice quality issues in Gulf | High — core feature broken | Medium | Test with real Gulf networks, have WebRTC fallback ready |
| Low initial player count (empty rooms) | High — no one to play with | High | Seed with AI bots, host scheduled events, invite-only beta |
| App Store rejection (gifting = gambling?) | High — launch blocked | Medium | Frame as "social gifting," not gambling; use coins not money; legal review |
| Arabic RTL layout bugs | Medium — looks unprofessional | High | Dedicated RTL QA pass, native Arabic tester, automated RTL tests |

### Medium Risks

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Firestore costs scale faster than revenue | Medium | Medium | Monitor usage daily, optimize queries, implement caching early |
| Agora costs exceed budget | Medium | Medium | Default to voice-only, optimize video quality, evaluate LiveKit migration |
| Streaming feature sees low adoption | Medium | Medium | Incentivize streaming with coin rewards, feature top streamers |
| Cheating/collusion | Medium | Medium | Anti-cheat detection, report system, fair play policy |
| Competition from Jawaker adding features | Low-Medium | Medium | First-mover on video/streaming, build social lock-in |

### Low Risks

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Flutter performance issues | Low | Low | Profile early, optimize rendering, use isolates for game logic |
| FCM delivery issues in Gulf | Low | Low | Test with real devices, have in-app polling fallback |
| Cultural insensitivity backlash | Low | Low | Hire Gulf cultural consultant, Arabic-native team member review |
| Server downtime (Firebase) | Low | Very Low | Firebase SLA 99.95%, have maintenance page ready |

---

## Timeline Estimates

### Phase 1: MVP (16 weeks)

| Sprint | Weeks | Focus | Deliverables |
|---|---|---|---|
| Sprint 1 | 1-2 | Project setup | Flutter project, Firebase config, CI/CD, design system |
| Sprint 2 | 3-4 | Auth + Home | Sign-up flow, username/avatar, Home screen layout |
| Sprint 3 | 5-6 | Room system | Create room, join room, room lobby, invite sharing |
| Sprint 4 | 7-8 | Game engine core | Dealing, bidding, trick play (Sun mode) |
| Sprint 5 | 9-10 | Game engine advanced | Hokm mode, scoring, bonuses, game end |
| Sprint 6 | 11-12 | Voice/Video | Agora integration, mute/unmute, camera toggle, video tiles |
| Sprint 7 | 13-14 | Streaming (basic) | Watch stream, stream chat, Live Now section |
| Sprint 8 | 15-16 | Polish + QA | Bug fixes, RTL QA, performance optimization, beta launch |

### Phase 2: Social & Streaming (16 weeks)

| Sprint | Weeks | Focus | Deliverables |
|---|---|---|---|
| Sprint 9 | 17-18 | Go Live | Streamer setup, start stream, viewer count |
| Sprint 10 | 19-20 | Social graph | Follow system, friend requests, online status |
| Sprint 11 | 21-22 | Gifting | Coin economy, gift tray, gift animations, transactions |
| Sprint 12 | 23-24 | Chat & DM | Direct messages, game invites via chat |
| Sprint 13 | 25-26 | Leaderboards & Achievements | Weekly/monthly rankings, badge system |
| Sprint 14 | 27-28 | Contacts & Discovery | Import contacts, friend suggestions, advanced stream search |
| Sprint 15 | 29-30 | Polish + Launch | Full QA, performance, public launch marketing |

### Phase 3: Advanced & Scale (24 weeks)

| Sprint | Weeks | Focus | Deliverables |
|---|---|---|---|
| Sprint 17-18 | 33-36 | Recording & Replay | Stream recording, game replay, stream replay |
| Sprint 19-20 | 37-40 | AI & Moderation | Auto-mod, cheat detection, AI opponents |
| Sprint 21-22 | 41-44 | Advanced Stats | Detailed history, ELO trends, partner stats |
| Sprint 23-24 | 45-48 | Full Monetization | Premium subscription, avatar marketplace, seasonal pass |
| Sprint 25-26 | 49-52 | Platform Expansion | iPad support, Flutter Web, smart TV casting |
| Sprint 27-28 | 53-56 | Scale & Optimize | Performance at 50K MAU, cost optimization, LiveKit migration eval |

---

## Team Recommendations

### Phase 1 Team (MVP)

| Role | Count | Focus |
|---|---|---|
| Flutter Developer | 2 | App development, game engine |
| Backend/DevOps | 1 | Firebase, Agora integration, CI/CD |
| UI/UX Designer | 1 | Design system, screens, RTL layouts |
| QA Tester (Arabic-native) | 1 | Game logic QA, RTL testing, cultural review |
| Product Manager | 1 | Prioritization, stakeholder management |

### Phase 2 Team (Growth)

| Role | Count | Focus |
|---|---|---|
| Flutter Developer | 2-3 | Social features, streaming |
| Backend Developer | 1 | Coin economy, matchmaking, cron jobs |
| UI/UX Designer | 1 | New feature designs |
| QA Tester | 1 | Feature testing |
| Product Manager | 1 | Feature prioritization |

### Phase 3 Team (Scale)

Add: ML Engineer (AI moderation), DevOps/SRE (infrastructure scaling), Marketing/Growth (user acquisition)
