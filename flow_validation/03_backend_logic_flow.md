# Bloot — Backend Logic Flow

Backend logic flows for every core system in the Bloot platform. Each section includes decision trees, error handling, and edge cases.

---

## 1. Authentication — Phone + OTP

### Flow Diagram

```
User Opens App
  │
  ├─► Check Firebase Auth Current User
  │     ├─► User exists ──► Fetch Firestore /users/{uid}
  │     │     ├─► Profile complete ──► HOME
  │     │     └─► Profile incomplete ──► PROFILE SETUP
  │     └─► No user ──► WELCOME SCREEN
  │
  ▼
User Enters Phone Number (+966xxxxxxxxx)
  │
  ├─► Validate Format
  │     ├─► Invalid ──► Show error "رقم الهاتف غير صالح"
  │     └─► Valid ──► Call Firebase Auth signInWithPhoneNumber
  │           │
  │           ├─► Success ──► Send OTP SMS
  │           │     ├─► SMS Sent ──► Show OTP entry screen, start 60s countdown
  │           │     └─► SMS Failed (quota exceeded, invalid number)
  │           │           └─► Show error, suggest retry in 5 minutes
  │           │
  │           └─► Failure ──► NETWORK_ERROR / SERVER_ERROR
  │                 └─► Show retry with exponential backoff
  │
  ▼
User Enters OTP
  │
  ├─► Call Firebase Auth confirm verificationResult
  │     ├─► Correct OTP ──► Authenticated
  │     │     │
  │     │     ├─► Check if user document exists
  │     │     │     ├─► Exists ──► Check profile_complete flag
  │     │     │     │     ├─► True ──► HOME
  │     │     │     │     └─► False ──► PROFILE SETUP
  │     │     │     └─► New user ──► Create Firestore document
  │     │     │           /users/{uid} = {
  │     │     │             uid, phone, nickname: null, avatar: null,
  │     │     │             coins: 0, level: 1, xp: 0,
  │     │     │             createdAt, profileComplete: false
  │     │     │           }
  │     │     │           └─► PROFILE SETUP
  │     │     │
  │     ├─► Wrong OTP ──► Show "الكود غير صحيح", decrement attempt counter
  │     │     ├─► Attempts < 5 ──► Allow retry
  │     │     └─► Attempts >= 5 ──► Lock for 15 minutes
  │     │
  │     └─► OTP Expired ──► Show "انتهت صلاحية الكود", offer resend
  │
  ▼
Resend OTP (max 3 resends per session)
  │
  ├─► Resend count < 3 ──► Call resend, reset timer
  └─► Resend count >= 3 ──► Show "تم تجاوز الحد، حاول لاحقاً"
```

### Error Handling

| Error Code | Trigger | User Message (Arabic) | Recovery |
|---|---|---|---|
| `auth/invalid-phone` | Bad format | رقم الهاتف غير صالح | Re-enter phone |
| `auth/quota-exceeded` | SMS limit | تم تجاوز حد الإرسال، حاول بعد 5 دقائق | Countdown timer |
| `auth/invalid-verification` | Wrong OTP | الكود غير صحيح | Re-enter OTP |
| `auth/session-expired` | OTP timeout | انتهت صلاحية الكود | Resend OTP |
| `auth/too-many-requests` | Rate limit | محاولات كثيرة، حاول لاحقاً | 15-min lockout |
| `auth/network-request-failed` | No internet | لا يوجد اتصال بالإنترنت | Retry button |
| `auth/internal-error` | Server 5xx | خطأ في الخادم، حاول لاحقاً | Retry with backoff |

### Edge Cases

- **Same phone on new device**: Firebase creates new refresh token; invalidate old tokens via `revokeRefreshTokens()`.
- **User uninstalls & reinstalls**: Auth state persisted; silent sign-in via `FirebaseAuth.instance.currentUser`.
- **SIM swap attack**: OTP is single-use; Firebase enforces one active session per phone.
- **Arabic nickname sanitization**: Server-side regex `^[\u0600-\u06FFa-zA-Z0-9_ ]{2,20}$` + profanity filter.
- **Avatar upload**: Resized to 256x256, uploaded to Cloud Storage under `/avatars/{uid}.webp`, max 2 MB.

---

## 2. Room Creation & Joining

### Flow Diagram

```
CREATE ROOM
  │
  ├─► Host taps "Create Room"
  │     │
  │     ├─► Validate: Is user in another room?
  │     │     ├─► Yes ──► Show "أنت في غرفة بالفعل" toast
  │     │     └─► No ──► Continue
  │     │
  │     ├─► Create Firestore document: /rooms/{roomId}
  │     │     {
  │     │       roomId: auto-generated 6-char,
  │     │       hostUid: currentUser.uid,
  │     │       name: "غرفة أحمد",          // max 30 chars
  │     │       privacy: "public" | "private",
  │     │       speedMode: false,             // fast game option
  │     │       maxPlayers: 4,
  │     │       players: [{ uid, nickname, avatar, ready: false, seat: 0 }],
  │     │       status: "waiting",           // waiting | playing | finished
  │     │       isStreaming: false,
  │     │       streamId: null,
  │     │       createdAt: FieldValue.serverTimestamp(),
  │     │       gameConfig: { ... }
  │     │     }
  │     │
  │     ├─► Firestore Security Rule: only host can set privacy, maxPlayers
  │     │
  │     └─► Host auto-joins seat 0, navigates to ROOM LOBBY

JOIN ROOM
  │
  ├─► Player enters 6-char room code
  │     │
  │     ├─► Validate format: regex /^[A-Z0-9]{6}$/
  │     │     ├─► Invalid ──► Show error toast
  │     │     └─► Valid ──► Firestore get /rooms/{code}
  │     │           │
  │     │           ├─► Room not found ──► "الغرفة غير موجودة"
  │     │           ├─► Room status == "playing" ──► "اللعبة بدأت بالفعل"
  │     │           ├─► Room status == "finished" ──► "الغرفة منتهية"
  │     │           ├─► players.length >= 4 ──► "الغرفة ممتلئة"
  │     │           ├─► Privacy == "private" & not invited ──► "هذه الغرفة خاصة"
  │     │           └─► Valid ──► Add player to players array
  │     │                 │
  │     │                 ├─► Firestore transaction:
  │     │                 │     1. Read room doc
  │     │                 │     2. Verify players.length < 4
  │     │                 │     3. Append { uid, nickname, avatar, ready: false, seat: nextSeat }
  │     │                 │     4. Write room doc
  │     │                 │
  │     │                 ├─► Success ──► Navigate to ROOM LOBBY
  │     │                 └─► Transaction fail (concurrent join) ──► "الغرفة ممتلئة"
  │     │
  │     └─► Invite link flow:
  │           Deep link: bloot://room/{roomId}
  │           ├─► App installed ──► Open room directly
  │           └─► App not installed ──► App Store / Play Store link

READY STATE
  │
  ├─► Player taps "Ready" toggle
  │     ├─► Update /rooms/{roomId}/players/{index}.ready = true
  │     ├─► All clients listen via Firestore snapshot
  │     └─► When players.filter(p => p.ready).length == 4:
  │           ├─► Host triggers game start
  │           └─► Update room status to "playing"
```

### Decision Tree — Room Join

```
Can user join room?
  ├─► Is user already in another room?
  │     ├─► Yes ──► BLOCK: "أنت في غرفة بالفعل"
  │     └─► No ──► Continue
  ├─► Does room exist?
  │     ├─► No ──► BLOCK: "الغرفة غير موجودة"
  │     └─► Yes ──► Continue
  ├─► Is room full (4 players)?
  │     ├─► Yes ──► BLOCK: "الغرفة ممتلئة"
  │     └─► No ──► Continue
  ├─► Is room private and user not invited?
  │     ├─► Yes ──► BLOCK: "هذه الغرفة خاصة"
  │     └─► No ──► Continue
  ├─► Has game already started?
  │     ├─► Yes ──► BLOCK: "اللعبة بدأت بالفعل"
  │     └─► No ──► ALLOW JOIN
```

### Edge Cases

| Case | Handling |
|---|---|
| Two players join same seat simultaneously | Firestore transaction ensures seat atomicity; max 4 check re-read |
| Host leaves lobby | Ownership transfers to seat 1; if only 1 player, room auto-deletes after 30s |
| Player disconnects in lobby | Presence indicator turns grey; after 60s idle, auto-removed |
| Room code collision | 6-char alphanumeric = 36^6 = 2.1B combos; collision check on creation |
| Private room invite | Share link with token param; Firestore security rule validates token |

---

## 3. Game Lifecycle

### Baloot Game State Machine

```
GAME_START
  │
  ├─► Initialize game document: /games/{gameId}
  │     {
  │       gameId, roomId, players[4],
  │       currentRound: 0, maxRounds: depends on variant,
  │       scores: { team1: 0, team2: 0 },
  │       phase: "dealing",           // dealing | bidding | playing | scoring
  │       dealerSeat: random(0-3),
  │       trumpSuit: null,
  │       announcement: null,
  │       deck: [], hands: [[], [], [], []],
  │       tricks: [], currentTrick: [],
  │       turnSeat: null,
  │       createdAt, updatedAt
  │     }
  │
  ▼
DEALING PHASE
  │
  ├─► Shuffle deck (Fisher-Yates server-side via Cloud Function)
  ├─► Deal 5 cards to each player (first deal of 5+4+4 pattern)
  ├─► Broadcast hands to each player via Firestore (security rule: player can only read own hand)
  ├─► Set phase = "bidding"
  │
  ▼
BIDDING PHASE
  │
  ├─► Each player in turn order decides:
  │     ├─► Pass (no bid)
  │     ├─► Bid: "صن" (Sun) or "حكم" (Hokm)
  │     │     ├─► All pass ──► Re-deal (no penalty, increment dealCount)
  │     │     ├─► Hokm declared ──► Declarer chooses trump suit
  │     │     │     ├─► Deal remaining 4 cards to each player
  │     │     │     └─► Set trumpSuit, set phase = "playing"
  │     │     └─► Shadda declared ──► Deal remaining, double scoring
  │     │
  │     └─► Timer: 30 seconds per bid decision
  │           ├─► Timeout ──► Auto-pass
  │           └─► Disconnect ──► Auto-pass, flag player as "disconnected"
  │
  ▼
PLAYING PHASE
  │
  ├─► Turn order follows standard Baloot rules
  ├─► Leader plays first card of trick
  ├─► Each player follows suit if possible, else any card
  ├─► Trick winner determined by Baloot scoring rules:
  │     ├─► Trump suit beats all non-trump
  │     ├─► Higher trump wins if multiple trumps played
  │     ├─► Higher card of led suit wins if no trump
  │     └─► Trick points calculated and accumulated
  │
  ├─► Per-trick flow:
  │     Player plays card
  │       ├─► Validate move (must follow suit if possible)
  │       │     ├─► Invalid ──► Reject, show error, retry
  │       │     └─► Valid ──► Add to currentTrick array
  │       ├─► When 4 cards played ──► Evaluate trick
  │       ├─► Award trick to winning player's team
  │       ├─► Winning player leads next trick
  │       └─► After 13 tricks ──► Set phase = "scoring"
  │
  ├─► Timer: 15 seconds per card play
  │     ├─► Timeout ──► Auto-play lowest valid card
  │     └─► Disconnect ──► AI takes over (simple heuristic)
  │
  ▼
SCORING PHASE
  │
  ├─► Calculate round score:
  │     ├─► Sum trick points for each team
  │     ├─► Apply announcement bonus (if applicable)
  │     ├─► Double score if Shadda round
  │     └─► Bonus: 26-0 = "بلك" (belote), extra points
  │
  ├─► Update game document:
  │     ├─► scores.team1 += roundScore1
  │     ├─► scores.team2 += roundScore2
  │     ├─► currentRound++
  │     └─► If cumulative score >= 151 (or variant threshold):
  │           ├─► Yes ──► Set phase = "finished", announce winner
  │           └─► No ──► Set phase = "dealing", rotate dealer
  │
  ▼
GAME_END
  │
  ├─► Calculate final stats:
  │     { gameId, winner: team1 | team2,
  │       finalScores: { team1, team2 },
  │       roundsPlayed, duration,
  │       mvpUid, achievements[] }
  │
  ├─► Write to /users/{uid}/gameHistory as subcollection
  ├─► Update /users/{uid}/stats: totalGames, winRate, eloRating
  ├─► Update room status to "finished"
  ├─► Trigger Cloud Function for leaderboard updates
  │
  └─► Clients show GAME_SCORE_FINAL screen
        ├─► Rematch (create new room, same players, invite sent)
        └─► Return to Home
```

### Error Handling

| Error | Trigger | Handling |
|---|---|---|
| Invalid card play | Player plays wrong suit | Reject move, show "يجب أن تلعب نفس النوع", auto-retry |
| Mid-game disconnect | Player loses connection | AI takes over; player can reconnect within 60s |
| All players disconnect | Network outage | Game paused; resume when 2+ reconnect; auto-cancel after 5 min |
| Score desync | Client/server score mismatch | Server score is source of truth; force sync to clients |
| Database write failure | Firestore rate limit hit | Queue locally, retry with exponential backoff |

### Edge Cases

| Case | Handling |
|---|---|
| Player goes AFK | 30s inactivity per action → auto-play; 60s total → AI full takeover |
| Host device crashes mid-game | Re-election: player with lowest seat becomes host |
| Shay / Sun with all passes | Re-deal; after 3 consecutive re-deals, force random Hokm |
| Scoring dispute | Server-side calculation only; clients never compute scores |
| Game timer disagreement | Server timestamp is authoritative; NTP sync on connection |

---

## 4. Voice / Video — Agora Integration

### Flow Diagram

```
VOICE/VIDEO SETUP
  │
  ├─► User enables mic/camera in lobby
  │     │
  │     ├─► Check OS permissions
  │     │     ├─► Not granted ──► Show permission dialog with Arabic explanation
  │     │     │     ├─► User grants ──► Continue
  │     │     │     ├─► User denies ──► Continue with voice-only or silent mode
  │     │     │     └─► "Don't ask again" ──► Deep link to Settings
  │     │     └─► Granted ──► Continue
  │     │
  │     ├─► Call Agora Cloud Function: generateToken(uid, roomId, role)
  │     │     ├─► role = "publisher" (streamer/host)
  │     │     │     or role = "subscriber" (viewer)
  │     │     ├─► Token expires in 6 hours (max game duration)
  │     │     └─► Return { token, appId, channelId }
  │     │
  │     ├─► Initialize RtcEngine
  │     │     ├─► Set audio profile: GAME scenario (low latency)
  │     │     ├─► Set channel profile: COMMUNICATION (for room)
  │     │     │     or LIVE_BROADCASTING (for stream viewers)
  │     │     ├─► Enable echo cancellation & noise suppression
  │     │     └─► Set client role based on publisher/subscriber
  │     │
  │     ├─► Join channel
  │     │     ├─► Success ──► Audio/video streams active
  │     │     └─► Failure ──► Fallback flow:
  │     │           ├─► Retest network (Agora network test)
  │     │           ├─► Retry with audio-only
  │     │           └─► Show "مشكل في الاتصال، جرب الصوت فقط"
  │     │
  │     └─► In-game audio management:
  │           ├─► Mute self mic ──► Set local audio muted
  │           ├─► Mute other player ──► Adjust remote volume (not supported by Agora, use UI hint)
  │           ├─► Speaker toggle ──► Set audio output to earpiece/speaker
  │           └─► Push-to-talk ──► Toggle mute on button press

STREAMING MODE (for viewers)
  │
  ├─► Viewer joins stream channel
  │     ├─► role = "subscriber"
  │     ├─► Receive remote video/audio
  │     ├─► Low-latency mode (default 500ms)
  │     └─► Adaptive bitrate based on network quality

  ├─► Viewer interacts
  │     ├─► Chat: Firestore /streams/{streamId}/messages subcollection
  │     ├─► Gift: Firestore transaction updating streamer coins
  │     │     └─► Validate: sufficient viewer coins, coin deduction + streamer credit in same transaction
  │     └─► Like/Heart: Agora SEI data + Firestore counter

  └─► Streamer controls
        ├─► Pin viewer comment ──► Highlight in chat UI
        ├─► Mute viewer voice (if subscriber joins with mic) ──► Agora muteRemoteAudio
        ├─► Kick disruptive viewer ──► Remove from Firestore viewer list, Agotra revoke token
        └─► End stream ──► Destroy Agora channel, update Firestore status
```

### Permission Decision Tree

```
App needs mic/camera access
  │
  ├─► First time request
  │     ├─► OS dialog shown with custom Arabic rationale
  │     │     "يحتاج بلوت الوصول إلى الميكروفون للتواصل مع اللاعبين"
  │     ├─► Granted ──► Proceed
  │     └─► Denied ──► Offer voice-only mode
  │
  ├─► Previously denied
  │     ├─► Can ask again ──► Show in-app rationale + system dialog
  │     └─► "Don't ask again" ──► Show "فتح الإعدادات" button → deep link to app settings
  │
  └─► Permission revoked (rare)
        └─► Detect via Agora error callback ──► Show re-permission flow
```

### Edge Cases

| Case | Handling |
|---|---|
| Headphones plugged/unplugged mid-game | Agora auto-switches audio route; notify user |
| Bluetooth headset with latency | Warn user; offer "Reduce Latency" mode |
| Background mode (iOS) | Continue audio; video paused; local notification "اللعبة مستمرة" |
| Bluetooth mic echo | Enable AEC (Acoustic Echo Cancellation) by default |
| Multiple viewers (1000+) | Agora CDN streaming mode; offload to Cloud CDN for >500 viewers |
| Network quality drops (Agora quality callback) | Reduce resolution; disable video; audio-only fallback |

---

## 5. Streaming — Viewer & Host

### Host (Streamer) Flow

```
HOST STARTS STREAM
  │
  ├─► Host toggles "Go Live" in lobby
  │     ├─► Create /streams/{streamId} document
  │     │     {
  │     │       streamId, hostUid, roomId,
  │     │       title: "مباراة بلوت مباشرة",
  │     │       viewerCount: 0,
  │     │       likeCount: 0,
  │     │       giftCoins: 0,
  │     │       status: "live",
  │     │       isAudioOnly: false,
  │     │       startedAt: FieldValue.serverTimestamp(),
  │     │       tags: ["بلوت", "مباشر"],
  │     │       thumbnailUrl: null // auto-generated from first frame
  │     │     }
  │     │
  │     ├─► Generate Agora token (role = broadcaster)
  │     ├─► Start Agora RTC engine with dual-stream mode
  │     └─► Register stream in Discovery feed
  │           └─► Cloud Function: addToDiscovery(streamId)

VIEWER JOINS STREAM
  │
  ├─► Viewer taps stream card in Discover
  │     ├─► Fetch /streams/{streamId}
  │     │     ├─► status != "live" ──► Show "البث انتهى"
  │     │     └─► status == "live" ──► Continue
  │     ├─► Generate Agora token (role = audience)
  │     ├─► Increment viewerCount atomically
  │     ├─► Subscribe to stream video/audio
  │     └─► Subscribe to Firestore /streams/{streamId}/messages for chat

VIEWER CHAT
  │
  ├─► Viewer types message
  │     ├─► Validate: length 1-200 chars, rate limit 5 msgs/10s
  │     ├─► Profanity filter (Arabic + English)
  │     ├─► Write to /streams/{streamId}/messages
  │     │     { text, senderUid, senderNickname, timestamp, type: "chat" }
  │     └─► All subscribers see message in real-time

VIEWER GIFTS
  │
  ├─► Viewer taps gift icon
  │     ├─► Show gift catalog (prices in coins)
  │     ├─► Viewer selects gift
  │     ├─► Check viewer coin balance >= gift price
  │     │     ├─► Insufficient ──► Show "شراء عملات" inline purchase flow
  │     │     └─► Sufficient ──► Firestore transaction:
  │     │           1. Deduct coins from /users/{viewerUid}.coins
  │     │           2. Credit 80% to /users/{hostUid}.coins (20% platform fee)
  │     │           3. Write gift to /streams/{streamId}/gifts
  │     │           4. Increment stream giftCoins
  │     ├─► Animate gift overlay on stream (broadcast via Firestore update)
  │     └─► Host receives coin notification

STREAM ENDS
  │
  ├─► Host taps "End Stream"
  │     ├─► Update /streams/{streamId}.status = "ended"
  │     ├─► Set endedAt timestamp
  │     ├─► Calculate stream duration
  │     ├─► Update host stats: totalStreams, totalViewers, totalGiftCoins
  │     ├─► Destroy Agora channel
  │     ├─► Trigger Cloud Function: saveVOD(streamId) → stores recording in Cloud Storage
  │     └─► Show viewers "البث انتهى" with follow CTA
```

### Error Handling

| Error | Trigger | Handling |
|---|---|---|
| Agora token expired | Stream >6 hours | Pre-emptive refresh at 5.5 hours; interrupt if refresh fails |
| Coin transaction race | Gift + coin purchase same instant | Firestore transaction ensures atomicity |
| Stream drops | Host network loss | Show "المستضيف فقد الاتصال"; auto-retry 30s; end stream after 60s |
| Chat spam | >5 messages / 10s | Rate-limit on client + Cloud Function; shadow-ban repeat offenders |
| Gift animation lag | Low-end device | Skip animation, show static badge; deduct coins regardless |
| VOD processing failure | Cloud Storage error | Retry 3x; mark stream as "processing"; notify host when ready |

---

## 6. Notifications

### Notification Types & Triggers

| Type | Trigger | Channel | Priority | TTL |
|---|---|---|---|---|
| Room Invite | Friend invites player | Push + In-app | High | 5 min |
| Game Starting | All players ready in room | Push + In-app | High | 30s |
| Streamer Live | Followed streamer goes live | Push | Normal | 15 min |
| Chat Message | DM received | In-app (Push if offline) | Normal | No expiry |
| Gift Received | Viewer sends gift | In-app | Normal | No expiry |
| Friend Request | New friend request | Push + In-app | Normal | No expiry |
| Level Up | Player reaches new level | In-app | Low | No expiry |

### Notification Flow

```
EVENT TRIGGER
  │
  ├─► Cloud Function triggered by Firestore write
  │     e.g., onRoomInvite, onGameStart
  │
  ├─► Compose notification payload
  │     {
  │       type: "room_invite",
  │       title: "دعوة لغرفة",
  │       body: "أحمد يدعوك للانضمام إلى غرفته",
  │       data: { roomId: "ABC123", fromUid: "..." },
  │       sound: "default",
  │       badge: increment,
  │       collapseKey: "room_invite_ABC123" // deduplicate
  │     }
  │
  ├─► Route notification
  │     ├─► App in foreground ──► Show in-app snackbar + badge
  │     ├─► App in background ──► FCM push notification
  │     └─► App terminated ──► FCM push + store in Firestore for in-app on next launch
  │
  ├─► User taps notification
  │     ├─► Room invite ──► Deep link opens room lobby (or auth if logged out)
  │     ├─► Game start ──► Deep link opens game play screen
  │     ├─► Stream live ──► Deep link opens stream viewer
  │     └─► DM ──► Deep link opens chat conversation
  │
  └─► Notification preferences
        ├─► Global on/off
        ├─► Per-type toggle (Settings → Notifications)
        ├─► Quiet hours (mute 11pm–7am local time)
        └─► Per-sender mute (mute specific friend invites)
```

### Deep Link Schema

| URI Pattern | Target Screen |
|---|---|
| `bloot://room/{roomId}` | Room Lobby |
| `bloot://game/{gameId}` | Game Play |
| `bloot://stream/{streamId}` | Stream Viewer |
| `bloot://chat/{conversationId}` | Chat Conversation |
| `bloot://profile/{uid}` | Profile View |
| `https://bloot.app/r/{roomId}` | Universal link (room) |

### Edge Cases

| Case | Handling |
|---|---|
| User taps notification while logged out | Deep link stored; auth flow first; then redirect to target |
| Multiple notifications stacked | Collapse by type; show latest only per room |
| iOS notification service extension | Rich notification with game card preview |
| Android notification channel | Separate channels: Game (high), Social (default), Promotional (low) |
| Rate limiting | Max 10 push notifications per user per hour (excluding game-start) |
| Stale notification | If room/game/stream no longer exists, show "انتهت الصلاحية" toast |