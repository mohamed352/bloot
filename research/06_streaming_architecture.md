# Streaming Architecture Research

## Overview

Bloot's streaming feature allows players to broadcast their Baloot games to a live audience. This document covers the architecture for real-time video streaming, chat, gifting, and viewer management.

---

## Viewer-to-Player Ratio Considerations

### Expected Ratios

| Phase | Concurrent Players | Concurrent Viewers | Ratio |
|---|---|---|---|
| Launch (0-3 months) | 100-500 | 200-1,000 | 2:1 |
| Growth (3-6 months) | 1,000-5,000 | 5,000-25,000 | 5:1 |
| Scale (6-12 months) | 5,000-20,000 | 25,000-200,000 | 10:1 |
| Mature (12+ months) | 20,000+ | 200,000+ | 10-20:1 |

### Architecture Implications

- **1:1 to 5:1:** Simple peer-to-peer Agora channels work fine
- **5:1 to 20:1:** Need SFU with selective forwarding
- **20:1+:** Need CDN-based distribution with Agora Live or custom RTMP

### Recommended Architecture by Scale

| Scale | Architecture | Max Viewers/Stream |
|---|---|---|
| Small (< 50 viewers) | Agora Communication mode | ~17 |
| Medium (50-500 viewers) | Agora Live mode (broadcaster + audience) | ~1,000 |
| Large (500+ viewers) | Agora Live + CDN (RTMP push) | Unlimited |

---

## Stream Latency Requirements

### Latency Targets

| Component | Target Latency | Max Acceptable | Rationale |
|---|---|---|---|
| Game state sync | < 500ms | 2 seconds | Viewers must see same card plays |
| Voice/Audio | < 1 second | 3 seconds | Lip sync with video |
| Video stream | < 2 seconds | 5 seconds | Close-to-real-time viewing |
| Chat messages | < 500ms | 2 seconds | Real-time conversation feel |
| Gift animations | < 1 second | 3 seconds | Immediate visual feedback |
| Viewer count | < 5 seconds | 15 seconds | Approximate is acceptable |

### Latency Comparison by Technology

| Technology | Typical Latency | Use Case |
|---|---|---|
| WebRTC (Agora) | 200-500ms | Player voice/video in game |
| Agora Live (Low Latency) | 1-3 seconds | Stream to viewers |
| HLS | 15-30 seconds | Unacceptable for live interaction |
| DASH (Low Latency) | 3-8 seconds | Viable alternative |
| RTMP + CDN | 2-5 seconds | Scale to millions |

### Recommended Approach

Use **Agora Live** with low-latency mode for streams up to 1,000 concurrent viewers per stream. For larger audiences, push RTMP to CDN.

---

## Agora Streaming vs Custom RTMP

### Agora Live (Recommended for MVP)

**Architecture:**

```
Streamer (Broadcaster)
    │
    ▼
Agora SFU (Low-Latency Mode)
    │
    ├──▶ Viewer 1 (Audience, ~2s latency)
    ├──▶ Viewer 2 (Audience, ~2s latency)
    └──▶ Viewer N (Audience, ~2s latency)
```

**Implementation:**

```dart
// Streamer joins as broadcaster
await _engine!.joinChannel(
  token: token,
  channelId: streamId,
  uid: streamerUid,
  options: const ChannelMediaOptions(
    channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    clientRoleType: ClientRoleType.clientRoleBroadcaster,
    publishCameraVideo: true,
    publishMicrophoneAudio: true,
  ),
);

// Viewer joins as audience (no publishing)
await _engine!.joinChannel(
  token: token,
  channelId: streamId,
  uid: viewerUid,
  options: const ChannelMediaOptions(
    channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    clientRoleType: ClientRoleType.clientRoleAudience,
    publishCameraVideo: false,
    publishMicrophoneAudio: false,
  ),
);
```

**Pros:**
- Same SDK for game rooms and streaming
- Low latency (1-3 seconds)
- Simple implementation
- Built-in quality adaptation
- No additional infrastructure needed

**Cons:**
- Viewer limit per channel (~1,000 with low-latency)
- Cost scales per viewer-minute
- No DVR/replay out of the box
- Limited CDN customization

### Custom RTMP to CDN

**Architecture:**

```
Streamer (Broadcaster)
    │
    ▼
RTMP Ingest Server (e.g., nginx-rtmp)
    │
    ├──▶ Agora (for interactive viewers, < 1,000)
    ├──▶ CDN HLS/DASH (for passive viewers, unlimited)
    └──▶ Recording Server (for replay)
```

**Pros:**
- Unlimited viewers via CDN
- Lower cost at scale (CDN is cheaper than Agora per viewer)
- Full control over recording and replay
- Can add DVR/pause feature

**Cons:**
- Higher latency (5-10 seconds with LL-HLS, 15-30 seconds with regular HLS)
- Additional infrastructure to build and maintain
- More complex implementation
- Need custom video player for HLS/DASH

### Hybrid Approach (Recommended for Scale)

```
Streamer
    │
    ├──▶ Agora Live Channel (interactive viewers, chat, gifts)
    │       └── Up to 1,000 concurrent viewers (low latency)
    │
    └──▶ RTMP Push → CDN (passive viewers, unlimited scale)
            └── HLS/DASH playback for 1,000+ viewers
```

- Viewers who chat/send gifts → Agora (low latency)
- Passive viewers → CDN (higher latency, lower cost)
- Switch automatically based on viewer count

---

## Chat System Architecture

### Technology: Cloud Firestore (Real-time)

**Why Firestore:**
- Real-time updates via snapshots
- Offline support for unreliable networks
- Automatic scaling
- Simple Flutter integration
- Already part of Firebase ecosystem (auth, FCM, etc.)

### Data Model

```
streams/{streamId}/
  ├── metadata: { title, streamerId, viewerCount, startTime, status }
  └── chat/
        └── messages/{messageId}/
              ├── senderId: String
              ├── senderName: String
              ├── senderAvatar: String
              ├── text: String
              ├── type: 'text' | 'gift' | 'system'
              ├── giftData: { giftId, giftName, coinValue } (if type=gift)
              ├── createdAt: Timestamp
              └── isDeleted: Boolean
```

### Chat Implementation

```dart
class StreamChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> watchMessages(String streamId) {
    return _db
        .collection('streams')
        .doc(streamId)
        .collection('chat')
        .orderBy('createdAt', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  Future<void> sendMessage({
    required String streamId,
    required String senderId,
    required String text,
  }) async {
    await _db.collection('streams').doc(streamId).collection('chat').add({
      'senderId': senderId,
      'text': text,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
      'isDeleted': false,
    });
  }
}
```

### Chat Moderation

- **Rate limiting:** Max 5 messages per 10 seconds per user
- **Profanity filter:** Basic Arabic + English word filter
- **Reporting:** Users can report messages; auto-hide after 3 reports
- **Moderator actions:** Streamer can ban users from chat
- **Spam detection:** Duplicate message detection within 5 seconds

### Chat Scaling Considerations

| Concurrent Viewers | Firestore Reads/sec | Estimated Cost/Month |
|---|---|---|
| 100 | ~50 | Free tier |
| 1,000 | ~500 | ~$50 |
| 10,000 | ~5,000 | ~$500 |
| 100,000 | ~50,000 | ~$5,000 |

**Optimization:** For large streams, batch chat messages (show last 50, load more on scroll) and use Firestore bundle snapshots for read reduction.

---

## Gift/Like System Design

### Gift Flow

```
Viewer taps gift
    │
    ▼
Gift tray UI opens
    │
    ▼
Viewer selects gift + quantity
    │
    ▼
System checks coin balance
    │
    ├──▶ Insufficient: Show purchase prompt
    │
    └──▶ Sufficient: Deduct coins from viewer
              │
              ▼
        Write gift to Firestore (chat message with type=gift)
              │
              ▼
        Streamer client receives gift via Firestore snapshot
              │
              ▼
        Gift animation plays on streamer's view
              │
              ▼
        Streamer's coin balance increases (after platform cut)
```

### Data Model

```
gifts/{giftId}/
  ├── name: String (e.g., "Rose", "Coffee", "Crown")
  ├── nameAr: String (e.g., "وردة", "قهوة", "تاج")
  ├── iconAsset: String (asset path)
  ├── animationAsset: String (Lottie/asset path)
  ├── coinCost: Number
  ├── category: 'popular' | 'premium' | 'seasonal'
  └── isActive: Boolean

transactions/{transactionId}/
  ├── fromUserId: String
  ├── toUserId: String
  ├── giftId: String
  ├── giftName: String
  ├── coinValue: Number
  ├── streamId: String (optional)
  ├── createdAt: Timestamp
  └── status: 'pending' | 'completed' | 'refunded'
```

### Revenue Split

| Recipient | Percentage | Notes |
|---|---|---|
| Streamer | 60% | Converted to coins in their wallet |
| Platform (Bloot) | 30% | Revenue |
| Payment processing | 10% | Stripe/in-app purchase fees |

### Like System (Free Interaction)

- Viewers can "like" a stream (free, no coins)
- Likes accumulate and show as heart animations on stream
- Like count visible to streamer
- Rate limited: 1 like per second per viewer

---

## Viewer Count Management

### Real-time Viewer Count

**Problem:** Firestore document reads become expensive if every viewer continuously reads viewer count.

**Solution:** Use a combination of Firestore and Agora callbacks:

```dart
// Track join/leave events in Firestore
Future<void> viewerJoined(String streamId, String viewerId) async {
  await _db.collection('streams').doc(streamId).update({
    'viewerIds': FieldValue.arrayUnion([viewerId]),
    'viewerCount': FieldValue.increment(1),
  });
}

Future<void> viewerLeft(String streamId, String viewerId) async {
  await _db.collection('streams').doc(streamId).update({
    'viewerIds': FieldValue.arrayRemove([viewerId]),
    'viewerCount': FieldValue.increment(-1),
  });
}
```

### Optimization Strategies

1. **Batch updates:** Don't write to Firestore on every join/leave; batch every 5 seconds
2. **Approximate counts:** For > 100 viewers, show approximate count (e.g., "1.2K watching")
3. **Cache viewer count:** Client caches count; refreshes every 10 seconds
4. **Agora user count:** Use Agora's built-in user count for accurate real-time count in small streams

### Viewer Count Display

| Actual Count | Display |
|---|---|
| 1-999 | Exact number (e.g., "42 watching") |
| 1,000-9,999 | "1.2K watching" |
| 10,000+ | "12K watching" |

---

## Stream Recording and Replay (Future - Phase 3)

### Recording Options

| Option | Pros | Cons |
|---|---|---|
| Agora Cloud Recording | Simple, integrated, reliable | $0.0095/min (recording) + storage |
| Custom FFmpeg recording | Full control, no per-minute cost | Complex, need server infrastructure |
| Client-side recording | No server cost | Unreliable, quality varies, storage on device |

### Recommended: Agora Cloud Recording

```dart
// Server-side: Start recording when stream goes live
POST https://api.agora.io/v1/apps/{appId}/cloud_recording/resourceid/{resourceId}/mode/mix/start
{
  "cname": "stream_12345",
  "uid": "streamer_uid",
  "clientRequest": {
    "recordingConfig": {
      "maxIdleTime": 30,
      "streamTypes": 2, // both audio and video
      "channelType": 1 // live broadcasting
    },
    "storageConfig": {
      "vendor": 1, // Google Cloud Storage
      "region": 0,
      "bucket": "bloot-recordings",
      "accessKey": "...",
      "secretKey": "..."
    }
  }
}
```

### Replay Architecture

```
Recording (Agora Cloud)
    │
    ▼
Google Cloud Storage (raw files)
    │
    ▼
Post-processing (FFmpeg: transcode, add chat overlay)
    │
    ▼
CDN (HLS/DASH segments)
    │
    ▼
Player (Flutter video_player or chewie)
```

---

## CDN Considerations

### CDN Selection

| Provider | MENA PoPs | Pricing (per GB) | Notes |
|---|---|---|---|
| Cloudflare | UAE, Saudi, Qatar | $0.05-0.10 | Best MENA coverage |
| Google Cloud CDN | Limited | $0.08-0.14 | Good if on GCP |
| AWS CloudFront | UAE, Bahrain | $0.085-0.12 | Most features |
| Akamai | Extensive MENA | $0.04-0.08 (negotiated) | Premium, enterprise |

### Recommended: Cloudflare

- Best Middle East PoP coverage
- Competitive pricing
- Easy integration with Google Cloud (where Firestore runs)
- DDoS protection included
- Free tier for small scale

### CDN Cost Estimates

| Monthly Viewers | Avg Stream Duration | Bandwidth | Monthly Cost |
|---|---|---|---|
| 1,000 | 30 min | ~2 TB | ~$100-200 |
| 10,000 | 45 min | ~20 TB | ~$1,000-2,000 |
| 100,000 | 60 min | ~200 TB | ~$10,000-20,000 |

---

## Load Testing Strategy

### Test Scenarios

| Test | Target | Metrics |
|---|---|---|
| Single stream, 100 viewers | Baseline | Latency, chat throughput |
| Single stream, 1,000 viewers | Agora limit | Latency, chat throughput, cost |
| 50 concurrent streams, 20 viewers each | Multi-stream | Agora channel management, Firestore reads |
| Chat spam (100 msg/sec) | Chat resilience | Firestore write throughput, client render |
| Gift flood (10 gifts/sec) | Gift system | Animation rendering, transaction speed |
| Network degradation | Fallback | Video→Audio→Text fallback timing |

### Load Testing Tools

| Tool | Use Case |
|---|---|
| Agora Load Test SDK | Simulate concurrent viewers |
| Firestore emulator | Test chat at scale without cost |
| Locust / k6 | HTTP/API load testing |
| Flutter integration tests | Client-side performance |

### Key Metrics to Monitor

- **P95 stream latency:** Must be < 5 seconds
- **Chat delivery time:** Must be < 2 seconds
- **Gift animation latency:** Must be < 3 seconds
- **Viewer count accuracy:** Within 5% of actual
- **Agora connection success rate:** > 99%
- **Firestore read/write quota:** Stay within free tier during testing

---

## Monitoring and Observability

### Metrics Dashboard (Firebase + Custom)

| Metric | Source | Alert Threshold |
|---|---|---|
| Active streams | Firestore | - |
| Total concurrent viewers | Agora + Firestore | > 80% of capacity |
| Average stream latency | Agora Analytics | > 5 seconds |
| Chat message rate | Firestore | > 100 msg/sec per stream |
| Gift transaction rate | Firestore | > 10 gifts/sec per stream |
| Error rate | Firebase Crashlytics | > 1% |
| Agora connection failures | Agora Analytics | > 5% |

### Logging Strategy

```dart
// Structured logging for streaming events
void logStreamEvent(String event, Map<String, dynamic> data) {
  FirebaseAnalytics.instance.logEvent(
    name: 'stream_$event',
    parameters: data.map((k, v) => MapEntry(k, v.toString())),
  );
}

// Examples:
// stream_started: { streamId, streamerId, hasCamera, hasAudio }
// stream_viewer_joined: { streamId, viewerId, totalViewers }
// stream_gift_sent: { streamId, giftId, coinValue }
// stream_ended: { streamId, duration, peakViewers, totalGifts }
```
