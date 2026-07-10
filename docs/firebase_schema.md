# Bloot — Firestore Schema

> **Purpose:** Complete Firebase Firestore database schema. Every collection, document, field, subcollection, and index. This is the single source of truth for the data model.

---

## 1. Collections Overview

| Collection | Purpose | Document ID |
|------------|---------|-------------|
| `users` | User profiles, stats, settings | `uid` (Firebase Auth UID) |
| `rooms` | Game rooms, players, settings | Auto-generated ID |
| `games` | Active and completed games | Auto-generated ID |
| `streams` | Stream metadata and viewer info | Same as room ID |
| `messages` | Direct messages and room chat | Auto-generated ID |
| `reports` | User/player reports | Auto-generated ID |
| `coin_transactions` | Coin/virtual currency transactions | Auto-generated ID |
| `achievements` | Player achievements/badges | Achievement ID (e.g., "first_win") |
| `leaderboards` | Weekly/monthly/overall rankings | Composite ID (e.g., "weekly_2025_W20") |
| `notifications` | Notification history | Auto-generated ID |

---

## 2. Realtime Database (RTDB) Mirror

Active game state is mirrored to Firebase Realtime Database for low-latency delivery to the WebView game renderer. Firestore remains the authoritative source of truth.

### Path: `/games/{gameId}`

| Field | Type | Description |
|-------|------|-------------|
| `engineState` | map | Serialized `BalootMatch` from `BalootSerializer.serializeMatch()` — same shape previously sent through the Flutter bridge. |
| `playerUids` | map | `{ uid1: true, uid2: true, ... }` used by RTDB rules to restrict reads to game participants. |
| `status` | string | Mirrors `games/{gameId}.status` (`bidding`, `playing`, `trickEnd`, `roundEnd`, `gameEnd`). |
| `updatedAt` | number | Server-side millisecond timestamp of the last mirror write. |

### Lifecycle
- **Created** by `startGame` Cloud Function immediately after the Firestore game document is created.
- **Updated** by the `mirrorGameToRtdbTrigger` Firestore trigger whenever the game document changes.
- **Removed** by `rematch` (old game discarded) or when the game document is deleted.

### Security Rules
- `.read`: authenticated players only (`playerUids/{uid}` must exist).
- `.write`: client writes are denied; Cloud Functions use the Admin SDK which bypasses rules.

---

## 3. `users` Collection

**Document ID:** Firebase Auth UID (`uid`)

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `uid` | string | yes | Firebase Auth UID |
| `phoneNumber` | string | yes | Verified phone number (e.g., "+966501234567") |
| `displayName` | string | yes | Display name (max 20 chars) |
| `username` | string | yes | Unique username (e.g., "ahmed_baloot"), lowercase |
| `avatarUrl` | string | no | Firebase Storage URL for profile photo |
| `bio` | string | no | Short bio (max 150 chars) |
| `region` | string | no | Region code (e.g., "SA", "AE", "KW") |
| `favoriteMode` | string | no | "sun", "hokm", or "both" |
| `level` | int | yes | Player level (default: 1) |
| `xp` | int | yes | Current XP points (default: 0) |
| `xpToNextLevel` | int | yes | XP threshold for next level |
| `coins` | int | yes | Virtual currency balance (default: 0) |
| `gamesPlayed` | int | yes | Total games played (default: 0) |
| `gamesWon` | int | yes | Total games won (default: 0) |
| `sunGamesPlayed` | int | yes | Sun games played (default: 0) |
| `sunGamesWon` | int | yes | Sun games won (default: 0) |
| `hokmGamesPlayed` | int | yes | Hokm games played (default: 0) |
| `hokmGamesWon` | int | yes | Hokm games won (default: 0) |
| `followersCount` | int | yes | Number of followers (default: 0) |
| `followingCount` | int | yes | Number following (default: 0) |
| `isOnline` | bool | yes | Online status (default: false) |
| `lastSeen` | timestamp | yes | Last online timestamp |
| `fcmToken` | string | no | Firebase Cloud Messaging token |
| `achievements` | map | no | Map of achievement IDs to unlock timestamps |
| `settings` | map | yes | User settings (see below) |
| `createdAt` | timestamp | yes | Account creation timestamp |
| `updatedAt` | timestamp | yes | Last profile update timestamp |

### `settings` Map (nested inside user document)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `voiceChat` | bool | true | Voice chat enabled |
| `camera` | bool | false | Camera enabled |
| `speakerMode` | string | "speaker" | "speaker" or "earpiece" |
| `autoRotateGame` | bool | true | Auto-rotate to landscape for game |
| `gameSpeedDefault` | string | "normal" | "normal", "fast", or "relaxed" |
| `soundEffects` | bool | true | Sound effects enabled |
| `backgroundMusic` | bool | false | Background music enabled |
| `showOnlineStatus` | bool | true | Show online status to others |
| `profileVisibility` | string | "everyone" | "everyone", "followers", "private" |
| `notifyRoomInvitations` | bool | true | Push notifications for room invites |
| `notifyNewFollowers` | bool | true | Push notifications for followers |
| `notifyGameResults` | bool | true | Push notifications for game results |

### Subcollections

#### `users/{uid}/followers`

| Field | Type | Description |
|-------|------|-------------|
| `followerUid` | string | UID of the follower |
| `followedAt` | timestamp | When the follow happened |

#### `users/{uid}/following`

| Field | Type | Description |
|-------|------|-------------|
| `followingUid` | string | UID being followed |
| `followedAt` | timestamp | When the follow happened |

#### `users/{uid}/gameHistory`

| Field | Type | Description |
|-------|------|-------------|
| `gameId` | string | Reference to games collection |
| `result` | string | "won" or "lost" |
| `scoreTeamA` | int | Team A final score |
| `scoreTeamB` | int | Team B final score |
| `gameType` | string | "sun", "hokm", or "ashkal" |
| `duration` | int | Game duration in seconds |
| `playedAt` | timestamp | When the game occurred |

### Indexes

- `users` collection: `username` (unique), `displayName`, `level` (desc), `gamesWon` (desc), `isOnline`
- `users/{uid}/followers`: `followerUid`, `followedAt` (desc)
- `users/{uid}/following`: `followingUid`, `followedAt` (desc)
- `users/{uid}/gameHistory`: `playedAt` (desc), `result`, `gameType`

---

## 3. `rooms` Collection

**Document ID:** Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID (auto) |
| `name` | string | yes | Room display name (max 30 chars) |
| `type` | string | yes | "private", "public", or "stream" |
| `creatorUid` | string | yes | UID of room creator |
| `status` | string | yes | "waiting", "playing", "finished" |
| `password` | string | no | Hashed password for private rooms |
| `voiceEnabled` | bool | yes | Voice chat enabled (default: true) |
| `cameraEnabled` | bool | yes | Camera enabled (default: false) |
| `allowSpectators` | bool | yes | Allow spectators (default: false) |
| `minLevel` | int | yes | Minimum player level (default: 0) |
| `gameSpeed` | string | yes | "normal" (30s), "fast" (15s), "relaxed" (60s) |
| `players` | array | yes | Array of player objects (max 4) |
| `playerUids` | array | yes | Array of UIDs for querying (max 4) |
| `teamA` | array | yes | Array of 2 UIDs on team A |
| `teamB` | array | yes | Array of 2 UIDs on team B |
| `readyPlayers` | array | yes | Array of UIDs who marked ready |
| `currentPlayerCount` | int | yes | Number of players currently in room |
| `maxPlayers` | int | yes | Always 4 for Baloot |
| `agoraChannelName` | string | yes | Agora channel name for voice/video |
| `agoraToken` | string | yes | Agora RTC token (refreshed periodically) |
| `inviteCode` | string | yes | Short shareable code (e.g., "ABC123") |
| `createdAt` | timestamp | yes | Room creation timestamp |
| `updatedAt` | timestamp | yes | Last update timestamp |

### `players` Array Item Structure

```
{
  uid: string,
  displayName: string,
  avatarUrl: string,
  team: "A" | "B",
  seatIndex: 0-3,
  isReady: bool,
  isMicOn: bool,
  isCameraOn: bool,
  joinedAt: timestamp
}
```

### Subcollections

#### `rooms/{roomId}/chat`

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated message ID |
| `senderUid` | string | UID of message sender |
| `senderName` | string | Display name of sender |
| `senderAvatar` | string | Avatar URL |
| `text` | string | Message text |
| `type` | string | "text", "system", "quickMessage" |
| `createdAt` | timestamp | Message timestamp |

### Indexes

- `rooms`: `status` (asc), `type` (asc), `createdAt` (desc), `currentPlayerCount`, `inviteCode` (unique)
- `rooms`: `status` == "waiting" AND `type` == "public" AND `currentPlayerCount` < 4 ORDER BY `createdAt`
- `rooms/{roomId}/chat`: `createdAt` (asc)

---

## 4. `games` Collection

**Document ID:** Auto-generated (usually matches room ID for the associated room)

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID |
| `roomId` | string | yes | Reference to rooms collection |
| `gameType` | string | yes | "sun", "hokm", or "ashkal" |
| `status` | string | yes | "dealing", "bidding", "playing", "trickEnd", "roundEnd", "gameEnd" |
| `players` | map | yes | Map of seatIndex (0-3) to player info |
| `teamAScore` | int | yes | Team A total score |
| `teamBScore` | int | yes | Team B total score |
| `currentRound` | int | yes | Current round number |
| `totalRounds` | int | yes | Total rounds in game |
| `currentTrick` | map | yes | Current trick state (see below) |
| `tricksPlayed` | int | yes | Number of tricks played in current round |
| `trumpSuit` | string | no | Trump suit for Hokm as a symbol ("♠", "♥", "♦", "♣") |
| `hokmBidder` | int | no | Seat index of Hokm bidder |
| `sunBidder` | int | no | Seat index of Sun/Ashkal bidder |
| `biddingTeam` | string | no | "A" or "B" — team that won the bid |
| `faceUpCard` | string | no | Face-up card from the deal (e.g., "A♠") |
| `targetScore` | int | yes | Score to win (152 for Saudi Baloot) |
| `turnIndex` | int | yes | Current turn seat index (0-3) |
| `turnTimerStart` | timestamp | no | When current turn started |
| `turnTimeLimit` | int | yes | Seconds per turn (default 90) |
| `fellTeam` | string | no | "A" or "B" — team that fell in the last completed round |
| `playerBids` | map | no | Per-seat bid strings for the UI (e.g., `{"0":"hokm"}`) |
| `engineState` | map | no | Authoritative 32-card engine state (server-side source of truth) |
| `gameLog` | array | no | Array of game events for replay |
| `startedAt` | timestamp | yes | Game start timestamp |
| `endedAt` | timestamp | no | Game end timestamp |
| `updatedAt` | timestamp | yes | Last update timestamp |

### `players` Map Structure

```
{
  "0": {
    uid: string,
    displayName: string,
    avatarUrl: string,
    team: "A" | "B",
    hand: array,      // Array of 32-card keys (e.g., ["A♠", "10♦", "K♥", ...])
    takenCards: array,
    tricksWon: int,
    bid: string | null,
    isConnected: bool,
    isMuted: bool,
    hasCamera: bool,
    agoraUid: int
  },
  "1": { ... },
  "2": { ... },
  "3": { ... }
}
```

**Card notation:** Rank + suit symbol (e.g., "A♠" = Ace of Spades, "10♦" = 10 of Diamonds). 32-card deck: ranks 7-8-9-10-J-Q-K-A; 8 cards per player; 8 tricks per round.

### `currentTrick` Map Structure

```
{
  leadingSuit: string,        // The suit of the first card played
  cards: {                    // Map of seatIndex to card played
    "0": "AH",               // e.g., Player 0 played Ace of Hearts
    "1": null,               // Player 1 hasn't played yet
    "2": "KH",               // Player 2 played King of Hearts
    "3": null
  },
  trickLeaderIndex: int,      // Seat index of who led the trick
  trickNumber: int            // Current trick number in the round
}
```

### Subcollections

#### `games/{gameId}/rounds`

| Field | Type | Description |
|-------|------|-------------|
| `roundNumber` | int | Round number (1-based) |
| `gameType` | string | "sun" or "hokm" for this round |
| `trumpSuit` | string | Trump suit (null for Sun) |
| `teamAScore` | int | Team A score at end of round |
| `teamBScore` | int | Team B score at end of round |
| `tricks` | array | Array of trick results |
| `startedAt` | timestamp | Round start |
| `endedAt` | timestamp | Round end |

#### `games/{gameId}/events`

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | "deal", "bid", "playCard", "trickWin", "roundEnd", "gameEnd" |
| `seatIndex` | int | Player who triggered the event |
| `data` | map | Event-specific data |
| `timestamp` | timestamp | When event occurred |

### Indexes

- `games`: `roomId` (asc), `status` (asc), `startedAt` (desc)
- `games`: `players.0.uid` OR `players.1.uid` OR `players.2.uid` OR `players.3.uid` (for finding games by player)
- `games/{gameId}/rounds`: `roundNumber` (asc)
- `games/{gameId}/events`: `timestamp` (asc)

---

## 5. `streams` Collection

**Document ID:** Same as associated room ID

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID (same as room ID) |
| `roomId` | string | yes | Reference to rooms collection |
| `hostUid` | string | yes | UID of stream host |
| `hostName` | string | yes | Display name of stream host |
| `hostAvatar` | string | no | Avatar URL of stream host |
| `title` | string | yes | Stream title (max 100 chars) |
| `description` | string | no | Stream description (max 500 chars) |
| `type` | string | yes | "baloot" (game stream), "casual" (social) |
| `status` | string | yes | "live", "paused", "ended" |
| `viewerCount` | int | yes | Current viewer count (default: 0) |
| `peakViewerCount` | int | yes | Peak viewer count (default: 0) |
| `totalLikes` | int | yes | Total likes received (default: 0) |
| `totalGifts` | int | yes | Total gifts received (default: 0) |
| `tags` | array | no | Array of tag strings (e.g., ["baloot", "competitive", "arabic"]) |
| `language` | string | yes | "ar", "en", or "mixed" |
| `agoraChannelName` | string | yes | Agora channel for viewers (may differ from room channel) |
| `agoraToken` | string | yes | Agora viewer token |
| `thumbnailUrl` | string | no | Stream thumbnail image URL |
| `startedAt` | timestamp | yes | Stream start timestamp |
| `endedAt` | timestamp | no | Stream end timestamp |
| `updatedAt` | timestamp | yes | Last update timestamp |

### Subcollections

#### `streams/{streamId}/viewers`

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string | Viewer UID |
| `displayName` | string | Viewer display name |
| `avatarUrl` | string | Viewer avatar URL |
| `joinedAt` | timestamp | When viewer joined |
| `isFollowing` | bool | Whether viewer follows the host |

#### `streams/{streamId}/chat`

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated message ID |
| `senderUid` | string | UID of message sender |
| `senderName` | string | Display name |
| `senderAvatar` | string | Avatar URL |
| `text` | string | Message text (max 200 chars) |
| `type` | string | "text", "system", "like", "gift" |
| `giftType` | string | no | Gift type if type is "gift" |
| `giftValue` | int | no | Coin value of gift |
| `createdAt` | timestamp | Message timestamp |

### Indexes

- `streams`: `status` (asc), `hostUid` (asc), `viewerCount` (desc), `startedAt` (desc), `type` (asc)
- `streams`: `status` == "live" ORDER BY `viewerCount` DESC
- `streams/{streamId}/viewers`: `joinedAt` (desc)
- `streams/{streamId}/chat`: `createdAt` (asc)

## 6. `messages` Collection

**Document ID:** Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID |
| `conversationId` | string | yes | Conversation/thread ID (computed from participants) |
| `senderUid` | string | yes | UID of sender |
| `senderName` | string | yes | Display name of sender |
| `senderAvatar` | string | no | Avatar URL of sender |
| `receiverUid` | string | yes | UID of receiver (for DMs) |
| `text` | string | no | Message text (max 500 chars) |
| `type` | string | yes | "text", "image", "roomInvite", "system", "quickMessage" |
| `imageUrl` | string | no | Image URL if type is "image" |
| `roomInvite` | map | no | Room invitation data (see below) |
| `quickMessage` | string | no | Quick message key (e.g., "ready", "gg", "letsPlay") |
| `isRead` | bool | yes | Whether receiver has read it (default: false) |
| `createdAt` | timestamp | yes | Message timestamp |

### `roomInvite` Map Structure (when type is "roomInvite")

```
{
  roomId: string,
  roomName: string,
  roomType: string,
  hostName: string,
  currentPlayers: int,
  maxPlayers: int,
  expiresAt: timestamp
}
```

### Indexes

- `messages`: `conversationId` (asc), `createdAt` (desc)
- `messages`: `senderUid` (asc), `receiverUid` (asc), `createdAt` (desc)
- `messages`: `receiverUid` (asc), `isRead` (asc) — for unread count queries

---

## 7. `reports` Collection

**Document ID:** Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID |
| `reporterUid` | string | yes | UID of person reporting |
| `reportedUid` | string | yes | UID of person being reported |
| `type` | string | yes | "user", "room", "stream", "message" |
| `reason` | string | yes | "harassment", "cheating", "spam", "inappropriate", "other" |
| `description` | string | no | Description of the report (max 1000 chars) |
| `referenceId` | string | no | ID of the reported entity (room, stream, message) |
| `status` | string | yes | "pending", "reviewed", "resolved", "dismissed" |
| `resolution` | string | no | Admin resolution notes |
| `resolvedBy` | string | no | Admin UID who resolved |
| `createdAt` | timestamp | yes | Report creation timestamp |
| `resolvedAt` | timestamp | no | Resolution timestamp |

### Indexes

- `reports`: `reportedUid` (asc), `status` (asc), `createdAt` (desc)
- `reports`: `reporterUid` (asc), `createdAt` (desc)
- `reports`: `status` (asc), `type` (asc)

---

## 8. `coin_transactions` Collection

**Document ID:** Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID |
| `uid` | string | yes | UID of the user involved in transaction |
| `type` | string | yes | "earn", "spend", "gift_send", "gift_receive", "purchase", "daily_bonus", "achievement_reward" |
| `amount` | int | yes | Amount of coins (positive for credit, negative for debit) |
| `balanceAfter` | int | yes | User's coin balance after this transaction |
| `description` | string | no | Human-readable description (max 200 chars) |
| `descriptionAr` | string | no | Arabic description (max 200 chars) |
| `referenceType` | string | no | "game", "gift", "purchase", "daily_bonus", "achievement", "stream_gift" |
| `referenceId` | string | no | ID of the referenced entity (game ID, purchase ID, etc.) |
| `counterpartyUid` | string | no | UID of the other user in gift/send transactions |
| `metadata` | map | no | Additional transaction-specific data |
| `createdAt` | timestamp | yes | Transaction timestamp |

### `metadata` Map Structure (optional, varies by type)

```
{
  "gameType": "sun",            // For game earnings
  "giftType": "rose",           // For stream gifts
  "productId": "coins_500",     // For purchases
}
```

### Indexes

- `coin_transactions`: `uid` (asc), `createdAt` (desc)
- `coin_transactions`: `uid` (asc), `type` (asc), `createdAt` (desc)
- `coin_transactions`: `referenceType` (asc), `referenceId` (asc)
- `coin_transactions`: `uid` (asc), `type` == "earn" ORDER BY `createdAt` DESC

---

## 9. `achievements` Collection

**Document ID:** Achievement ID (e.g., "first_win", "streak_10", "streamer_100")

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID (kebab-case identifier) |
| `name` | string | yes | Achievement name in English (max 50 chars) |
| `nameAr` | string | yes | Achievement name in Arabic (max 50 chars) |
| `description` | string | yes | Achievement description in English (max 150 chars) |
| `descriptionAr` | string | yes | Achievement description in Arabic (max 150 chars) |
| `iconUrl` | string | yes | Firebase Storage URL for achievement badge icon |
| `iconInactiveUrl` | string | yes | Greyed-out version for locked achievements |
| `category` | string | yes | "gameplay", "social", "streaming", "special" |
| `rarity` | string | yes | "common", "rare", "epic", "legendary" |
| `xpReward` | int | yes | XP awarded on unlock (default: 0) |
| `coinReward` | int | yes | Coins awarded on unlock (default: 0) |
| `conditionType` | string | yes | "games_won", "games_played", "streak", "followers", "hours_streamed", "custom" |
| `conditionThreshold` | int | yes | Numeric threshold to unlock (e.g., 10 for 10 wins) |
| `isSecret` | bool | yes | Hidden until unlocked (default: false) |
| `displayOrder` | int | yes | Sort order in achievement list |
| `isActive` | bool | yes | Whether achievement can currently be earned (default: true) |
| `createdAt` | timestamp | yes | Achievement creation timestamp |
| `updatedAt` | timestamp | yes | Last update timestamp |

### Subcollections

#### `achievements/{achievementId}/unlockedBy`

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string | UID of user who unlocked |
| `displayName` | string | Display name at time of unlock |
| `avatarUrl` | string | Avatar URL at time of unlock |
| `unlockedAt` | timestamp | When the achievement was unlocked |

### Indexes

- `achievements`: `category` (asc), `rarity` (asc), `displayOrder` (asc), `isActive` (asc)
- `achievements`: `conditionType` (asc), `conditionThreshold` (asc)
- `achievements/{id}/unlockedBy`: `unlockedAt` (desc), `uid` (asc)

---

## 10. `leaderboards` Collection

**Document ID:** Composite ID (e.g., "weekly_2025_W20", "monthly_2025_05", "all_time_sun", "all_time_hokm")

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID |
| `type` | string | yes | "weekly", "monthly", "allTime" |
| `period` | string | yes | Period identifier (e.g., "2025-W20", "2025-05", "all_time") |
| `gameType` | string | yes | "sun", "hokm", or "overall" |
| `metric` | string | yes | "gamesWon", "winRate", "xp", "coinsEarned" |
| `startDate` | timestamp | yes | Leaderboard period start |
| `endDate` | timestamp | no | Leaderboard period end (null for allTime) |
| `status` | string | yes | "active", "finalized", "archived" |
| `entries` | array | yes | Top entries (see below, max 100 stored) |
| `totalParticipants` | int | yes | Total number of ranked players |
| `prizes` | map | no | Prize distribution for this leaderboard period |
| `updatedAt` | timestamp | yes | Last recalculation timestamp |
| `finalizedAt` | timestamp | no | When leaderboard was finalized |

### `entries` Array Item Structure

```
{
  rank: int,               // 1-based position
  uid: string,             // User UID
  displayName: string,     // Display name
  avatarUrl: string,       // Avatar URL
  level: int,              // Player level
  value: int,              // The metric value (e.g., games won count)
  previousRank: int,       // Rank in previous period (for trend arrows)
  change: string           // "up", "down", "same", "new"
}
```

### `prizes` Map Structure (optional)

```
{
  "1": { "coins": 5000, "xp": 1000 },
  "2": { "coins": 3000, "xp": 750 },
  "3": { "coins": 1500, "xp": 500 },
  "4-10": { "coins": 500, "xp": 250 },
  "11-50": { "coins": 100, "xp": 100 }
}
```

### Indexes

- `leaderboards`: `type` (asc), `gameType` (asc), `metric` (asc), `status` (asc)
- `leaderboards`: `type` == "weekly" AND `status` == "active" ORDER BY `startDate` DESC
- `leaderboards`: `type` (asc), `period` (asc), `gameType` (asc)

---

## 11. `notifications` Collection

**Document ID:** Auto-generated

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Document ID |
| `uid` | string | yes | Recipient user UID |
| `type` | string | yes | "roomInvite", "newFollower", "gameResult", "achievement", "gift", "friendRequest", "levelUp", "system", "promo" |
| `title` | string | yes | Notification title in English (max 100 chars) |
| `titleAr` | string | yes | Notification title in Arabic (max 100 chars) |
| `body` | string | yes | Notification body in English (max 500 chars) |
| `bodyAr` | string | yes | Notification body in Arabic (max 500 chars) |
| `imageUrl` | string | no | Optional notification image URL |
| `data` | map | no | Deep link and action data (see below) |
| `isRead` | bool | yes | Whether user has read it (default: false) |
| `isPushed` | bool | yes | Whether push notification was sent (default: false) |
| `pushStatus` | string | no | "pending", "sent", "failed" |
| `priority` | string | yes | "high", "normal", "low" (default: "normal") |
| `expiresAt` | timestamp | no | When notification becomes stale (e.g., room invite expiry) |
| `createdAt` | timestamp | yes | Notification creation timestamp |
| `readAt` | timestamp | no | When user read the notification |
| `pushedAt` | timestamp | no | When push was sent |

### `data` Map Structure (varies by type)

```
// Room invite
{ "roomId": "abc123", "roomName": "...", "action": "open_room" }

// Game result
{ "gameId": "game123", "result": "won", "action": "open_game_summary" }

// Achievement
{ "achievementId": "first_win", "action": "open_achievement" }

// New follower
{ "followerUid": "uid456", "action": "open_profile" }

// Gift received
{ "giftType": "rose", "fromUid": "uid789", "action": "open_stream" }
```

### Indexes

- `notifications`: `uid` (asc), `createdAt` (desc)
- `notifications`: `uid` (asc), `isRead` (asc), `createdAt` (desc)
- `notifications`: `uid` (asc), `type` (asc), `createdAt` (desc)
- `notifications`: `expiresAt` (asc) — for TTL cleanup of expired notifications

---

## 12. Cloud Functions

### Auth Triggers

| Function | Trigger | Purpose |
|----------|--------|---------|
| `createUserProfile` | `auth.user.onCreate` | Create user document in Firestore |
| `deleteUserData` | `auth.user.onDelete` | Clean up user data on account deletion |

### Firestore Triggers

| Function | Trigger | Purpose |
|----------|--------|---------|
| `updateRoomStatus` | `rooms/{id}.onUpdate` | Update room status when all players ready |
| `updateViewerCount` | `streams/{id}/viewers.onWrite` | Recalculate viewer count |
| `updateFollowerCount` | `users/{id}/followers.onWrite` | Recalculate follower count |
| `processGameEnd` | `games/{id}.onUpdate` | Handle game completion, update stats |
| `cleanExpiredRoom` | Scheduled (every 5 min) | Delete rooms idle > 30 min |
| `checkAchievements` | `users/{uid}.onUpdate` | Check and unlock achievements when stats change |
| `updateLeaderboards` | Scheduled (every hour) | Recalculate active leaderboards |
| `sendNotification` | Firestore `onCreate` (various) | Create notification documents on triggers |
| `cleanExpiredNotifications` | Scheduled (daily) | Delete notifications past `expiresAt` |
| `awardDailyBonus` | Scheduled (daily at midnight) | Award daily login coin bonus |
| `processCoinTransaction` | HTTPS Callable | Atomically deduct/credit coins with transaction record |

### HTTPS Callable Functions

| Function | Purpose |
|----------|---------|
| `generateAgoraToken` | Generate Agora RTC token for voice/video channels |
| `joinRoom` | Atomically add player to room (transaction) |
| `leaveRoom` | Atomically remove player from room (transaction) |
| `startGame` | Validate all players ready, create game document |
| `playCard` | Validate and process card play (with game rules) |
| `reportUser` | Create a report document |
| `markNotificationRead` | Mark a notification as read |
| `getLeaderboard` | Fetch leaderboard entries with user's rank |
| `getUserNotifications` | Fetch paginated notifications for current user |

---

## 13. Security Rules Summary

```
// Users can read any user profile, write only their own
match /users/{uid} {
  allow read: if true;
  allow write: if request.auth != null && request.auth.uid == uid;
}

// Rooms: read any, write only for participants and creator
match /rooms/{roomId} {
  allow read: if true;
  allow create: if request.auth != null;
  allow update: if request.auth != null &&
    (request.auth.uid == resource.data.creatorUid ||
     request.auth.uid in resource.data.playerUids);
}

// Games: read for participants, write only by server (cloud functions)
match /games/{gameId} {
  allow read: if request.auth != null &&
    request.auth.uid in resource.data.playerUids;
  allow write: if false; // Only cloud functions
}

// Streams: read any, write only by host
match /streams/{streamId} {
  allow read: if true;
  allow write: if request.auth != null &&
    request.auth.uid == resource.data.hostUid;
}

// Messages: read/write for conversation participants only
match /messages/{messageId} {
  allow read: if request.auth != null &&
    (request.auth.uid == resource.data.senderUid ||
     request.auth.uid == resource.data.receiverUid);
  allow create: if request.auth != null &&
    request.auth.uid == request.resource.data.senderUid;
}

// Reports: read by admins, create by authenticated users
match /reports/{reportId} {
  allow create: if request.auth != null;
  allow read: if request.auth != null &&
    isAdmin(request.auth.uid);
}

// Coin transactions: read own, write only by server (cloud functions)
match /coin_transactions/{transactionId} {
  allow read: if request.auth != null &&
    request.auth.uid == resource.data.uid;
  allow write: if false; // Only cloud functions
}

// Achievements: read any, write by admin/server only
match /achievements/{achievementId} {
  allow read: if true;
  allow write: if false; // Only cloud functions / admin
}

// Leaderboards: read any, write by server only
match /leaderboards/{leaderboardId} {
  allow read: if true;
  allow write: if false; // Only cloud functions
}

// Notifications: read own, create by server, update own (mark read)
match /notifications/{notificationId} {
  allow read: if request.auth != null &&
    request.auth.uid == resource.data.uid;
  allow create: if false; // Only cloud functions
  allow update: if request.auth != null &&
    request.auth.uid == resource.data.uid &&
    !request.resource.data.diff(resource.data).affectedFields()
      .hasOnly(['isRead', 'readAt']);
}
```