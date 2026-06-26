# Social Features Research

## Overview

Bloot's social features are critical for retention and monetization. Unlike pure game apps, Bloot combines Baloot gameplay with social streaming culture, making social features a core differentiator. This document covers the design of following, gifting, leaderboards, achievements, friends, notifications, and moderation.

---

## Following System Design

### Data Model

```
users/{userId}/
  ├── followers/ (subcollection)
  │     └── {followerId}/
  │           ├── followerName: String
  │           ├── followerAvatar: String
  │           └── followedAt: Timestamp
  └── following/ (subcollection)
        └── {followingId}/
              ├── followingName: String
              ├── followingAvatar: String
              └── followedAt: Timestamp
```

### Denormalized Counters (for performance)

```
users/{userId}/
  ├── followerCount: Number (denormalized, incremented atomically)
  ├── followingCount: Number (denormalized, incremented atomically)
  └── ...
```

### Follow/Unfollow Flow

```dart
class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _db.batch();

    // Add to current user's following
    batch.set(
      _db.collection('users').doc(currentUserId)
          .collection('following').doc(targetUserId),
      {
        'followingName': targetUserName,
        'followingAvatar': targetUserAvatar,
        'followedAt': FieldValue.serverTimestamp(),
      },
    );

    // Add to target user's followers
    batch.set(
      _db.collection('users').doc(targetUserId)
          .collection('followers').doc(currentUserId),
      {
        'followerName': currentUserName,
        'followerAvatar': currentUserAvatar,
        'followedAt': FieldValue.serverTimestamp(),
      },
    );

    // Increment denormalized counts
    batch.update(_db.collection('users').doc(currentUserId), {
      'followingCount': FieldValue.increment(1),
    });
    batch.update(_db.collection('users').doc(targetUserId), {
      'followerCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _db.batch();

    batch.delete(_db.collection('users').doc(currentUserId)
        .collection('following').doc(targetUserId));
    batch.delete(_db.collection('users').doc(targetUserId)
        .collection('followers').doc(currentUserId));
    batch.update(_db.collection('users').doc(currentUserId), {
      'followingCount': FieldValue.increment(-1),
    });
    batch.update(_db.collection('users').doc(targetUserId), {
      'followerCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  Stream<bool> isFollowing(String currentUserId, String targetUserId) {
    return _db
        .collection('users').doc(currentUserId)
        .collection('following').doc(targetUserId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
```

### Follow Notifications

When a user is followed, send a push notification via FCM:
- "أحبك [UserName] بدأ بمتابعتك!" (Arabic)
- "[UserName] started following you!" (English)
- Rate limit: Max 10 follow notifications per hour to the same user (prevent spam)

---

## Gifting and Monetization

### Virtual Coin Economy

```
coins_economy/
  ├── Coin Packages (purchase):
  │     ├── 100 coins → $0.99
  │     ├── 500 coins → $4.49
  │     ├── 1,000 coins → $7.99
  │     ├── 5,000 coins → $34.99
  │     └── 10,000 coins → $64.99
  │
  ├── Coin Earning (free):
  │     ├── Daily login: 10 coins
  │     ├── First game of the day: 5 coins
  │     ├── Win a game: 3 coins
  │     ├── Level up: 20 coins
  │     └── Watch stream for 5 min: 2 coins
  │
  └── Coin Spending:
        ├── Gifts to streamers (5-200 coins each)
        └── Avatar/frame purchases (future)
```

### Gift Catalog

| Gift | Name (AR) | Cost (Coins) | Animation |
|---|---|---|---|
| Rose | وردة | 5 | Floating roses |
| Coffee | قهوة | 10 | Coffee cup steam |
| Crown | تاج | 50 | Golden crown sparkle |
| Golden Card | كرت ذهبي | 100 | Card flip animation |
| Baloot King | ملك البلوت | 200 | Throne animation |
| Diamond | ألماسة | 500 | Diamond rain |

### Transaction Flow

```
1. Viewer selects gift → confirms
2. System checks coin balance
3. Transaction created (status: pending)
4. Coins deducted from viewer (atomic)
5. Gift sent to streamer (Firestore write)
6. Streamer's coin balance increased by 60% of gift value
7. Transaction status → completed
8. Gift animation plays on stream
9. Gift notification in chat
10. Platform retains 30%, payment processing 10%
```

### Data Model

```
wallets/{userId}/
  ├── balance: Number (current coin balance)
  ├── totalEarned: Number
  ├── totalSpent: Number
  └── transactions/ (subcollection)
        └── {transactionId}/
              ├── type: 'purchase' | 'gift_sent' | 'gift_received' |
              │        'daily_bonus' | 'game_reward'              ├── amount: Number
              ├── fromUserId: String (optional)
              ├── toUserId: String (optional)
              ├── giftId: String (optional)
              ├── streamId: String (optional)
              ├── createdAt: Timestamp
              └── status: 'pending' | 'completed' | 'failed'
```

### In-App Purchase Integration

```dart
// Use in_app_purchase package for iOS/Android
class CoinPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;

  Future<void> purchaseCoins(String productId) async {
    final ProductDetailsResponse response = await _iap.queryProductDetails({productId});
    final product = response.productDetails.first;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: product,
    );

    _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: true,
    );
  }

  // Verify purchase server-side to prevent fraud
  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    await FirebaseFirestore.instance
        .collection('purchase_verifications')
        .add({
          'userId': currentUserId,
          'productId': purchase.productID,
          'purchaseToken': purchase.verificationData.serverVerificationData,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'status': 'pending_verification',
        });
  }
}
```

---

## Leaderboards and Rankings

### Leaderboard Types

| Leaderboard | Metric | Reset Frequency |
|---|---|---|
| Weekly Champions | Games won this week | Weekly (Sunday midnight AST) |
| Monthly Masters | ELO rating | Monthly |
| Season Legends | Cumulative season score | Seasonal (3 months) |
| Top Streamers | Total viewer hours | Weekly |
| Top Gifters | Coins gifted | Weekly |
| All-Time Greats | Lifetime games won | Never |

### Data Model

```
leaderboards/{leaderboardId}/
  ├── name: String
  ├── nameAr: String
  ├── metric: 'games_won' | 'elo' | 'viewer_hours' | 'coins_gifted'
  ├── resetFrequency: 'weekly' | 'monthly' | 'seasonal' | 'never'
  ├── season: String (e.g., "2026-Q2")
  ├── entries/ (subcollection)
  │     └── {userId}/
  │           ├── rank: Number
  │           ├── score: Number
  │           ├── username: String
  │           ├── avatar: String
  │           └── updatedAt: Timestamp
  └── lastReset: Timestamp
```

### Ranking Algorithm (ELO-based)

```dart
class EloCalculator {
  static const int kFactor = 32;

  static Map<int, int> calculateNewRatings({
    required Map<int, int> currentRatings,
    required List<int> winningTeam,
    required List<int> losingTeam,
  }) {
    final avgWinners = winningTeam.map((id) => currentRatings[id]!).reduce((a, b) => a + b) / 2;
    final avgLosers = losingTeam.map((id) => currentRatings[id]!).reduce((a, b) => a + b) / 2;

    final expectedWin = 1 / (1 + pow(10, (avgLosers - avgWinners) / 400));
    final actualWin = 1.0;

    final change = (kFactor * (actualWin - expectedWin)).round();

    return {
      for (final id in winningTeam) id: currentRatings[id]! + change,
      for (final id in losingTeam) id: currentRatings[id]! - change,
    };
  }
}
```

### Leaderboard UI

- Top 3 shown with medals (gold, silver, bronze)
- Current user's rank always visible (sticky footer)
- Tap on player to view profile
- Leaderboard resets shown with animation

---

## Achievement System

### Achievement Categories

| Category | Examples | Rarity |
|---|---|---|
| Gameplay | First Win, 10 Wins, 100 Wins, Sun Master, Hokm Expert | Common → Legendary |
| Social | First Follower, 100 Followers, 1K Followers | Common → Epic |
| Streaming | First Stream, 100 Viewers Peak, 1K Total Viewers | Common → Epic |
| Gifting | First Gift Sent, Generous (1K coins gifted), Philanthropist | Common → Rare |
| Streak | 3-Day Streak, 7-Day Streak, 30-Day Streak | Common → Legendary |

### Achievement Data Model

```
achievements/{achievementId}/
  ├── name: String
  ├── nameAr: String
  ├── description: String
  ├── descriptionAr: String
  ├── iconAsset: String
  ├── category: 'gameplay' | 'social' | 'streaming' | 'gifting' | 'streak'  ├── rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  ├── condition: { type: String, value: Number }
  ├── coinReward: Number
  └── isActive: Boolean

user_achievements/{userId}_achievements/
  └── unlocked/ (subcollection)
        └── {achievementId}/
              ├── unlockedAt: Timestamp
              └── isDisplayed: Boolean
```

### Achievement Unlock Flow

```dart
class AchievementService {
  Future<void> checkAchievements(String userId, String eventType, int value) async {
    final achievements = await _db.collection('achievements')
        .where('condition.type', isEqualTo: eventType)
        .where('isActive', isEqualTo: true)
        .get();

    for (final achievement in achievements.docs) {
      final conditionValue = achievement['condition']['value'] as int;
      if (value >= conditionValue) {
        await _unlockAchievement(userId, achievement.id, achievement.data());
      }
    }
  }

  Future<void> _unlockAchievement(String userId, String achievementId, Map data) async {
    final doc = _db.collection('users').doc(userId)
        .collection('unlocked_achievements').doc(achievementId);

    final existing = await doc.get();
    if (existing.exists) return; // Already unlocked

    await doc.set({'unlockedAt': FieldValue.serverTimestamp()});

    // Award coin bonus
    if (data['coinReward'] != null && data['coinReward'] > 0) {
      await _walletService.addCoins(userId, data['coinReward']);
    }

    // Show achievement notification
    await _notificationService.showAchievementUnlock(
      userId: userId,
      achievementName: data['nameAr'], // Arabic for Gulf users
      coinReward: data['coinReward'] ?? 0,
    );
  }
}
```

---

## Friend System

### Adding Friends

**Methods:**
1. **Search by username** — type username, find and add
2. **Contacts import** — sync phone contacts who use Bloot
3. **Recent opponents** — after a game, suggest adding opponents as friends
4. **Share profile link** — shareable deep link to profile

### Data Model

```
users/{userId}/
  └── friends/ (subcollection)
        └── {friendId}/
              ├── friendName: String
              ├── friendAvatar: String
              ├── friendLevel: Number
              ├── status: 'online' | 'offline' | 'in_game'
              ├── addedAt: Timestamp
              └── isFavorite: Boolean

friend_requests/{requestId}/
  ├── fromUserId: String
  ├── fromUserName: String
  ├── fromUserAvatar: String
  ├── toUserId: String
  ├── status: 'pending' | 'accepted' | 'declined'
  └── createdAt: Timestamp
```

### Online Presence

```dart
// Update presence on app open/close
class PresenceService {
  Future<void> goOnline(String userId) async {
    await _db.collection('users').doc(userId).update({
      'onlineStatus': 'online',
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<void> goOffline(String userId) async {
    await _db.collection('users').doc(userId).update({
      'onlineStatus': 'offline',
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setInGame(String userId, String roomId) async {
    await _db.collection('users').doc(userId).update({
      'onlineStatus': 'in_game',
      'currentRoomId': roomId,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}
```

### Contacts Import

```dart
// Use flutter_contacts package
Future<List<BlootUser>> findContactsOnBloot() async {
  final contacts = await FastContacts.getAllContacts();
  final phoneNumbers = contacts
      .expand((c) => c.phones)
      .map((p) => normalizePhoneNumber(p.number))
      .toSet();

  final query = await _db.collection('users')
      .where('phoneNumber', whereIn: phoneNumbers.take(30).toList())
      .get();

  return query.docs.map((doc) => BlootUser.fromFirestore(doc)).toList();
}
```

---

## Notification System

### Firebase Cloud Messaging (FCM)

### Notification Types

| Type | Priority | Sound | AR Title Template |
|---|---|---|---|
| Friend goes live | High | Custom chime | "[اسم] بدأ البث المباشر!" |
| Friend request | High | Default | "طلب صداقة جديد من [اسم]" |
| Game invite | High | Custom ring | "دعوة لعبة من [اسم]" |
| Achievement unlock | Medium | Short ding | "فتحت إنجاز جديد! [اسم]" |
| Daily bonus | Low | None | "مكافأتك اليومية بانتظارك!" |
| Gift received | Medium | Coin sound | "أرسل [اسم] لك [هدية]!" |
| Level up | Medium | Level up sound | "ارتقيت إلى المستوى [رقم]!" |

### FCM Implementation

```dart
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    await _saveFcmToken(token);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
  }

  Future<void> _saveFcmToken(String? token) async {
    if (token == null) return;
    await _db.collection('users').doc(currentUserId).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }
}
```

### Server-side Notification (Firebase Cloud Functions)

```javascript
// Triggered when a user goes live
exports.notifyFollowersOnLive = functions.firestore
  .document('streams/{streamId}')
  .onCreate(async (snap, context) => {
    const stream = snap.data();
    const streamerId = stream.streamerId;

    const followers = await admin.firestore()
      .collection('users').doc(streamerId)
      .collection('followers').get();

    const tokens = [];
    for (const doc of followers.docs) {
      const userDoc = await admin.firestore()
        .collection('users').doc(doc.id).get();
      if (userDoc.exists) {
        tokens.push(...(userDoc.data().fcmTokens || []));
      }
    }

    if (tokens.length === 0) return;

    await admin.messaging().sendMulticast({
      tokens: tokens,
      notification: {
        title: `${stream.streamerName} بدأ البث المباشر!`,
        body: stream.title,
      },
      data: {
        type: 'stream_live',
        streamId: context.params.streamId,
        streamerId: streamerId,
      },
      android: {
        priority: 'high',
      },
    });
  });
```

---

## Report and Moderation System

### Report Types

| Type | Description | Auto-Action |
|---|---|---|
| Harassment | Verbal abuse, threats | Warning, then mute |
| Spam | Repeated messages, ads | Auto-mute after 5 reports |
| Inappropriate content | Nudity, violence on camera | Auto-blur, review within 1 hour |
| Cheating | Game manipulation, collusion | Flag for review, temp ban |
| Hate speech | Discrimination, racism | Auto-mute, review within 4 hours |
| Impersonation | Fake identity | Review within 24 hours |

### Report Flow

```
User reports content/player
    │
    ▼
Report created in Firestore
    │
    ├──▶ Auto-moderation checks
    │     ├── Profanity filter: auto-delete message
    │     ├── 3+ reports on same user in 1 hour: auto-mute
    │     └── Camera content flagged: auto-blur
    │
    └──▶ Human moderation queue
          ├── Moderator reviews report
          ├── Actions: dismiss, warn, mute, ban
          └── Notify reporter of action taken
```

### Data Model

```
reports/{reportId}/
  ├── reporterId: String
  ├── reportedUserId: String
  ├── type: 'harassment' | 'spam' | 'inappropriate' | 'cheating' | 'hate_speech' | 'impersonation'
  ├── description: String
  ├── evidence: { messageId, streamId, screenshotUrl }
  ├── status: 'pending' | 'reviewing' | 'resolved' | 'dismissed'
  ├── moderatorId: String (assigned)
  ├── resolution: 'warn' | 'mute' | 'ban' | 'dismiss'
  ├── createdAt: Timestamp
  └── resolvedAt: Timestamp

moderation_actions/{actionId}/
  ├── userId: String
  ├── action: 'warn' | 'mute' | 'temp_ban' | 'permanent_ban'
  ├── reason: String
  ├── duration: Number (hours, if temporary)
  ├── moderatorId: String
  └── createdAt: Timestamp
```

### Auto-Moderation: Profanity Filter

```dart
class ProfanityFilter {
  static const List<String> _arabicWords = [
    // Arabic profanity list (populated during implementation)
  ];

  static const List<String> _englishWords = [
    // English profanity list
  ];

  static bool containsProfanity(String text) {
    final normalized = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final words = normalized.split(RegExp(r'\s+'));

    return words.any((word) =>
      _arabicWords.contains(word) || _englishWords.contains(word));
  }

  static String censor(String text) {
    var result = text;
    for (final word in [..._arabicWords, ..._englishWords]) {
      result = result.replaceAll(
        RegExp(word, caseSensitive: false),
        '*' * word.length,
      );
    }
    return result;
  }
}
```

---

## Content Guidelines for Streams

### Prohibited Content

1. **Nudity or sexual content** — Zero tolerance, immediate ban
2. **Violence or threats** — Zero tolerance, immediate ban
3. **Hate speech** — Discrimination based on race, religion, gender, nationality
4. **Gambling promotion** — No real-money gambling (use "coins" language, not "money")
5. **Spam or advertising** — No unauthorized promotions
6. **Cheating or exploitation** — No game manipulation exploits
7. **Underage users on camera** — If user appears under 13, remove stream immediately
8. **Impersonation** — No pretending to be another person

### Cultural Sensitivity (Gulf/MENA)

- Avoid imagery offensive to Islamic values
- Respect prayer times (consider auto-muting notifications during prayer)
- Gender-segregated options for those who prefer it
- No alcohol or substance imagery on stream
- Conservative dress code expectations for camera (no enforcement, but community guidelines)
- Respect for regional politics — no political content on streams

### Stream Rating System

| Rating | Description | Content Rules |
|---|---|---|
| General | Family-friendly | No profanity, appropriate dress |
| Mature | Adults only | Some language leniency, still no explicit content |

Default: General. Streamers can set rating when going live.
