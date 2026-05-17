# Bloot User Use Cases

## Overview

This document defines detailed use cases for primary Bloot user flows. Each use case includes actor, goal, steps, expected outcome, alternative flows, and pain points.

---

## UC-P01: Player Joins a Private Room with Friends

**Actor:** Registered player (authenticated)

**Goal:** Join an existing private Baloot room created by a friend to play a game together

**Preconditions:**
- Player has an active account
- Player has the room code or a direct invite link
- Room has available seats (fewer than 4 players)

**Steps:**
1. Player opens Bloot app to Home screen
2. Player taps "Join Room" button
3. Player enters room code OR taps invite link from external app (WhatsApp, etc.)
4. System validates room code and checks availability
5. System checks if player meets room requirements (level, etc.)
6. Player is placed in the room lobby
7. Room creator sees player joined notification
8. Player sees other players already in room, their avatars, and voice status
9. Player's mic is muted by default; camera is off by default
10. Player unmutes mic to greet other players
11. When 4 players are present, room creator starts the game

**Expected Outcome:** Player successfully joins the room, can voice chat with others, and is ready to play when game starts.

**Alternative Flows:**
- **Room full:** System shows "Room is full" message with option to spectate or go back
- **Room not found:** System shows "Room not found" with option to re-enter code
- **Room in progress (game already started):** System offers spectate mode or waiting queue for next game
- **Kicked by host:** Player receives notification and returns to Home
- **Network disconnected during join:** System shows reconnect dialog; if room still available, auto-reconnects
- **Invite link expired:** System shows "This link has expired" with option to request new invite

**Pain Points:**
- Entering room codes manually is error-prone (6-digit codes)
- No way to know if friends are online before joining
- Awkward social moment of joining mid-conversation with muted mic
- No indication of room's current state (lobby vs. mid-game) before joining

---

## UC-P02: Player Creates a Voice-Only Room

**Actor:** Registered player (authenticated)

**Goal:** Create a private Baloot room with voice chat enabled but no video/camera requirement

**Preconditions:**
- Player has an active account
- Player grants microphone permission

**Steps:**
1. Player taps "Create Room" on Home screen
2. System presents room creation form:
   - Room name (optional, default: "Player's Room")
   - Room type: Private (code required) or Public (discoverable)
   - Voice: On (default) / Off
   - Camera: Off (default for voice-only room)
   - Game mode: Standard Baloot (only option in MVP)
3. Player sets room name to "Wednesday Night Baloot"
4. Player selects Private room
5. Player confirms Voice: On, Camera: Off
6. Player taps "Create"
7. System generates 6-digit room code (e.g., 739281)
8. System creates room and places player in lobby
9. Player's mic is active; camera is off
10. Player sees share button with options:
    - Copy room code
    - Share via WhatsApp
    - Share link (deep link to app)
11. Player shares code with 3 friends
12. Friends join one by one (see UC-P01)
13. When 4 players present, "Start Game" button activates
14. Player (as creator) taps "Start Game"

**Expected Outcome:** Private voice-only room is created, friends join via shared code, game begins with voice chat active.

**Alternative Flows:**
- **Mic permission denied:** System shows explanation dialog with link to device settings
- **Only 3 players after waiting:** Creator can invite AI bot (Phase 3) or continue waiting
- **Player wants to switch to camera mid-game:** Player toggles camera on; other players see video tile appear
- **Room code already in use (collision):** System generates a different code automatically
- **Creator leaves room:** Room transfers host to longest-remaining player; if < 2 players, room closes

**Pain Points:**
- Waiting for 4 players with no activity is boring — need mini-games or chat prompts
- No way to set room rules (e.g., "no trash talk," "beginners welcome")
- Sharing code requires switching to another app — friction
- No scheduled room feature for planned sessions

---

## UC-P03: Streamer Starts a Live Stream

**Actor:** Registered player with streaming privileges (authenticated, level 5+)

**Goal:** Start a live stream of a Baloot game so viewers can watch and interact

**Preconditions:**
- Player has streaming privileges (unlocked at level 5 or verified)
- Player has granted camera and microphone permissions
- Player is in a room with at least 2 other players (or will create room)
- Player has stable network connection (quality check passed)

**Steps:**
1. Player taps "Go Live" button on Home screen (prominent CTA)
2. System shows stream setup screen:
   - Stream title (required): e.g., "Late Night Baloot - Come Watch!"
   - Stream category: Auto-tagged as "Baloot"
   - Camera preview: Shows selfie camera feed
   - Mic test: Quick audio level check
   - Visibility: Public (default) or Friends-only
3. Player enters stream title
4. Player positions camera, checks mic levels (green indicator)
5. Player taps "Start Streaming"
6. System performs quality check (bandwidth, latency)
7. Stream goes live:
   - Player's video feed appears as picture-in-picture in their game view
   - Stream appears in "Live Now" feed for viewers
   - Push notification sent to followers: "[Player] is live!"
8. Player plays Baloot normally; game state and voice are broadcast
9. Viewer chat messages appear in stream overlay (semi-transparent)
10. Viewer gifts appear as animations in player's view
11. Player can see viewer count
12. Player can pin chat messages or highlight gifted viewers
13. When game ends, stream continues in lobby (post-game talk)
14. Player taps "End Stream" to stop
15. System shows stream summary: duration, peak viewers, gifts received

**Expected Outcome:** Stream is live, viewers discover it, streamer plays while engaging with chat, stream ends with summary stats.

**Alternative Flows:**
- **Quality check fails:** System suggests switching to audio-only stream or shows troubleshooting tips
- **Network drops mid-stream:** System attempts reconnect; viewers see "Reconnecting" overlay; if restored, stream continues
- **Streamer wants camera off:** Camera can be toggled off; stream continues with avatar + voice + game state
- **No other players in room:** Streamer can invite viewers to play (if room has open seats)
- **Report from viewer:** Stream gets flagged for review; moderator may intervene
- **Streamer accidentally ends stream:** 10-second undo window before stream truly ends

**Pain Points:**
- Balancing gameplay focus with chat engagement is difficult
- No moderation tools during live stream (need trust system)
- Camera angle setup is awkward while holding phone and playing cards
- Gift notifications can be distracting during critical game moments
- No co-host feature for dual commentary

---

## UC-V01: Viewer Discovers and Watches a Stream

**Actor:** Registered or guest viewer

**Goal:** Find and watch an interesting Baloot live stream

**Preconditions:**
- Viewer has the app installed (account optional for viewing)
- At least one stream is live

**Steps:**
1. Viewer opens Bloot app
2. Home screen shows "Live Now" section with stream thumbnails:
   - Streamer avatar, username
   - Stream title (truncated)
   - Viewer count badge
   - Live indicator (pulsing red dot)
3. Viewer scrolls through available streams
4. Viewer taps on a stream thumbnail
5. Stream view opens:
   - Full-screen game view (cards, table, players)
   - Streamer's camera feed (corner overlay or bottom strip)
   - Chat panel (collapsible from bottom)
   - Viewer count
   - Gift button
   - Follow button (if not following)
6. Viewer watches gameplay in real-time
7. Viewer reads chat messages from other viewers
8. Viewer types a chat message and sends it
9. Viewer taps gift button and sends a small gift (if has coins)
10. Viewer continues watching, can switch to another stream by swiping

**Expected Outcome:** Viewer finds and watches a stream, optionally participates in chat and sends gifts.

**Alternative Flows:**
- **No streams live:** Home shows "No live streams right now" with option to browse recorded clips (Phase 3) or popular players
- **Stream ends while watching:** System shows "Stream ended" with option to follow streamer for next live notification
- **Guest viewer wants to chat:** System prompts to create account (quick signup)
- **Viewer wants full-screen camera:** Tap on camera overlay to expand; tap again to minimize
- **Viewer swipes to next stream:** Vertical swipe gesture loads next live stream (TikTok-style)

**Pain Points:**
- Discoverability is hard with few streamers initially — need curated "featured" section
- Chat can be toxic without moderation — need auto-mod or reporting
- No way to follow a specific game state as a spectator (who's winning?)
- Latency between game action and viewer seeing it can feel delayed
- No picture-in-picture mode for viewing while using other apps

---

## UC-T01: Player Joins a Tournament

**Actor:** Registered player (authenticated, meets level requirement)

**Goal:** Join a Baloot tournament to compete for ranking and prizes

**Preconditions:**
- Player meets tournament entry requirements (level, entry fee if applicable)
- Tournament has available slots
- Tournament has not yet started

**Steps:**
1. Player taps "Tournaments" tab on Home screen
2. System shows tournament list:
   - Upcoming tournaments with date/time, entry requirements, prize
   - Active tournaments (spectate only if not joined)
   - Past tournaments (results)
3. Player selects an upcoming tournament: "Friday Night Championship"
4. Tournament detail screen shows:
   - Description and rules
   - Entry requirement: Level 10+, 50 coins entry fee
   - Prize pool: 5,000 coins + "Champion" badge
   - Start time: Friday 9:00 PM AST
   - Registered players: 28/32
   - Bracket format: Single elimination
5. Player taps "Join Tournament"
6. System deducts 50 coins from player's balance
7. Player receives confirmation with tournament details
8. Player gets push notification 30 minutes before start
9. At tournament start time, player taps notification or opens app
10. System places player in first-round match
11. Player enters game room (same as UC-P01 but with tournament overlay)
12. Game plays with tournament rules enforced (strict timing, no re-entry)
13. Winner advances; loser is eliminated
14. Player continues through bracket until eliminated or wins final

**Expected Outcome:** Player joins tournament, competes through bracket, receives prize if victorious.

**Alternative Flows:**
- **Tournament full:** System shows waitlist option; if player drops, next in waitlist is added
- **Player doesn't show up at start time:** 5-minute grace period; then auto-forfeit
- **Player disconnects mid-tournament game:** 60-second reconnect window; if fails, opponent wins by default
- **Entry fee insufficient:** System shows coin purchase prompt
- **Tournament cancelled:** Entry fee refunded; players notified via push

**Pain Points:**
- Waiting between tournament rounds with nothing to do
- No way to practice with tournament rules before joining
- Scheduling conflicts for international players across time zones
- Unclear what happens if opponent disconnects
- No team tournament option for partnered players

---

## UC-S01: Player Sends a Gift/Like During Stream

**Actor:** Registered viewer (authenticated, has coins)

**Goal:** Send a virtual gift to a streamer to show appreciation and support

**Preconditions:**
- Viewer is watching a live stream
- Viewer has sufficient coin balance for the selected gift
- Gifting feature is enabled for the stream

**Steps:**
1. Viewer taps gift icon (🎁) in stream view
2. Gift tray slides up from bottom:
   - Gift categories: Popular, New, Premium
   - Each gift shows: icon, name, coin cost
   - Example gifts: Rose (5 coins), Coffee (10 coins), Crown (50 coins), Golden Card (200 coins)
3. Viewer selects "Coffee" gift (10 coins)
4. System shows confirmation: "Send Coffee to [Streamer] for 10 coins?"
5. Viewer confirms
6. System deducts 10 coins from viewer's balance
7. Gift animation plays on streamer's view (coffee cup animation)
8. Gift notification appears in chat: "[Viewer] sent Coffee ☕ to [Streamer]"
9. Streamer sees and acknowledges gift (verbally or with reaction)
10. Streamer's coin balance increases (after platform commission)
11. Viewer's gift is recorded in stream summary

**Expected Flows:**
- **Insufficient coins:** System shows "Not enough coins" with purchase prompt
- **Quick gift (double-tap):** Double-tap on stream sends default gift (Rose, 5 coins) without confirmation
- **Gift during critical game moment:** Gift animation is non-blocking; streamer can dismiss quickly
- **Viewer wants to send multiple:** Long-press gift for quantity selector (1x, 5x, 10x)
- **Gift refund request:** No refunds on virtual gifts (stated in TOS)

**Pain Points:**
- Accidental gift sending (fat-finger on mobile)
- No way to know if streamer noticed the gift
- Gift animations can be distracting for other viewers
- No gifting leaderboard to incentivize top gifters
- Coin purchase flow interrupts the viewing experience

---

## UC-C01: Player Chats with Friend

**Actor:** Registered player (authenticated)

**Goal:** Send a direct message to a friend on Bloot

**Preconditions:**
- Both players have active accounts
- Players are mutual friends (or DMs are open)
- Recipient has not blocked the sender

**Steps:**
1. Player taps "Chat" icon in navigation bar
2. System shows chat list: recent conversations sorted by latest message
3. Player taps on friend's name in list
4. Chat screen opens showing message history
5. Player types message in Arabic text field (RTL input)
6. Player taps send button
7. Message is delivered via real-time connection (Firestore)
8. Recipient sees message in their chat list with notification badge
9. If recipient is online and in app: message appears immediately
10. If recipient is offline: push notification sent via FCM
11. Recipient reads message and optionally replies

**Expected Outcome:** Message is delivered and received; conversation continues in real-time.

**Alternative Flows:**
- **First message to new friend:** System opens chat with empty history; no icebreaker prompts
- **Recipient has DMs restricted:** System shows "This user isn't accepting messages right now"
- **Sending image:** Player taps attachment icon; selects from gallery; image compressed and uploaded
- **Sending game invite:** Player taps game invite button in chat; friend receives playable invite card
- **Block/report:** Player can block from chat; no further messages delivered

**Pain Points:**
- No online/offline status indicator for friends
- No typing indicator to show when friend is responding
- RTL text mixing with LTR content (numbers, English words) causes layout issues
- No read receipts (by design for privacy, but can feel unresponsive)
- No group chat for coordinating game sessions with multiple friends
- Switching between chat and game is cumbersome
