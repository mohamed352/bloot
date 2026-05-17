# Realtime Voice & Video Technical Research

## Overview

Bloot requires real-time voice and video communication for up to 4 players simultaneously during Baloot gameplay, plus streaming capability for broader audiences. This document evaluates technical options and provides implementation guidance.

---

## Agora SDK vs WebRTC Comparison

### Agora.io (Recommended)

| Attribute | Details |
|---|---|
| **Type** | Managed real-time communication platform |
| **SDK** | Native + Flutter (agora_rtc_engine) |
| **Architecture** | SFU (Selective Forwarding Unit) with global CDN |
| **Latency** | 200-400ms (ultra-low latency mode) |
| **Max participants** | 17 (video), 48 (audio) per channel |
| **Flutter package** | `agora_rtc_engine` (official, maintained by Agora) |
| **Pricing** | Free: 10,000 min/month; $3.99/1,000 min after |

**Pros:**
- Official Flutter SDK with excellent documentation
- Built-in echo cancellation, noise suppression, AGC
- Global edge network (low latency worldwide)
- Adaptive bitrate and resolution based on network
- Fallback mechanisms built-in
- Screen sharing support
- Token-based security
- Analytics dashboard for monitoring call quality
- Well-tested at scale (used by Clubhouse, Bumble)

**Cons:**
- Proprietary / vendor lock-in
- Cost scales with usage (can be expensive at scale)
- Less control over infrastructure
- Data routed through Agora servers
- Limited customization of audio processing pipeline

### WebRTC (Open Standard)

| Attribute | Details |
|---|---|
| **Type** | Open standard for real-time communication |
| **SDK** | flutter_webrtc (community package) |
| **Architecture** | P2P or custom SFU (Janus, Mediasoup, LiveKit) |
| **Latency** | 50-200ms (P2P), 200-500ms (SFU) |
| **Max participants** | Unlimited (depends on SFU) |
| **Flutter package** | `flutter_webrtc` (community-maintained) |
| **Pricing** | Free (self-hosted); server costs vary |

**Pros:**
- Open source, no vendor lock-in
- Full control over infrastructure and data
- Lower latency potential (P2P)
- No per-minute costs (only server costs)
- Customizable audio/video processing
- Can self-host for data sovereignty

**Cons:**
- Requires building and maintaining SFU infrastructure
- Flutter package is community-maintained (risk of abandonment)
- No built-in echo cancellation (must implement separately)
- NAT traversal complexity (STUN/TURN servers needed)
- More development time for equivalent features
- Monitoring and debugging is harder
- No built-in analytics

### Decision: Agora SDK

**Rationale:**
- MVP speed: Agora provides working voice/video in days, not weeks
- Flutter integration is mature and officially supported
- Echo cancellation and noise suppression are critical for card game (quiet environment expectations)
- 4-player rooms fit well within Agora's limits
- 10,000 free minutes/month covers early development and soft launch
- Streaming support (Agora Live) provides future expansion path
- Gulf/MENA region has Agora edge servers for low latency

**Migration path:** If costs become prohibitive at scale, migrate to self-hosted LiveKit (open-source, WebRTC-based, Agora-compatible API).

---

## Flutter Integration

### Package Setup

```yaml
# pubspec.yaml
dependencies:
  agora_rtc_engine: ^6.3.2
  permission_handler: ^11.3.1
```

### Core Implementation Pattern

```dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VoiceVideoService {
  static const String appId = 'YOUR_AGORA_APP_ID';
  RtcEngine? _engine;
  String? _currentChannel;

  Future<void> initialize() async {
    _engine = createAgoraRtcEngine();

    await _engine!.initialize(const RtcEngineContext(
      appId: appId,
    ));

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        // Player joined channel
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        // Another player's stream received
      },
      onUserOffline: (connection, remoteUid, reason) {
        // Player disconnected
      },
      onNetworkQuality: (connection, remoteUid, txQuality, rxQuality) {
        // Update network quality indicator
      },
    ));

    // Enable audio
    await _engine!.enableAudio();
    await _engine!.setDefaultAudioRouteToSpeakerphone(true);

    // Audio configuration
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGaming,
    );

    // Enable video (optional, per-room setting)
    await _engine!.enableVideo();
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 320, height: 240),
        frameRate: 15,
        bitrate: 200,
      ),
    );
  }

  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    _currentChannel = channelName;
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraVideo: true,
        publishMicrophoneAudio: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _engine!.leaveChannel();
    _currentChannel = null;
  }

  Future<void> toggleMute(bool muted) async {
    await _engine!.muteLocalAudioStream(muted);
  }

  Future<void> toggleCamera(bool enabled) async {
    if (enabled) {
      await _engine!.enableLocalVideo(true);
      await _engine!.startPreview();
    } else {
      await _engine!.enableLocalVideo(false);
      await _engine!.stopPreview();
    }
  }

  Future<void> dispose() async {
    _engine?.release();
  }
}
```

### Token Generation

Tokens should be generated server-side for security:

```dart
// Server-side (Firebase Functions or custom backend)
// Use agora-token package
import 'package:agora_token/agora_token.dart';

String generateToken(String channelName, int uid) {
  return RtcTokenBuilder.build(
    appId: appId,
    appCertificate: appCertificate,
    channelName: channelName,
    uid: uid,
    role: RtcRole.publisher,
    expireTimestamp: DateTime.now().millisecondsSinceEpoch + 3600,
  );
}
```

---

## Audio Routing

### Speaker vs Earpiece

For a social card game, **speakerphone** is the default and preferred audio route:

| Scenario | Audio Route | Rationale |
|---|---|---|
| Default gameplay | Speakerphone | Social experience, multiple people can hear |
| Player alone | Earpiece | Privacy, battery saving |
| Player with speaker | Speakerphone | Everyone in room can participate |
| Streaming | Speakerphone | Audience engagement |

```dart
// Set default to speakerphone
await _engine!.setDefaultAudioRouteToSpeakerphone(true);

// Switch to earpiece (if player toggles)
await _engine!.setDefaultAudioRouteToSpeakerphone(false);

// Force speaker on (regardless of earphone connection)
await _engine!.setEnableSpeakerphone(true);
```

### Bluetooth Headset Handling

- If Bluetooth headset is connected, audio routes to headset automatically
- Player can toggle between Bluetooth and speakerphone
- Microphone on Bluetooth headset is used automatically
- Need to handle Bluetooth disconnection gracefully (switch to speaker)

---

## Video Rendering

### Flutter Widget Setup

```dart
// Local (self) video preview
AgoraVideoView(
  controller: VideoViewController(
    rtcEngine: _engine!,
    canvas: const VideoCanvas(uid: 0), // 0 = local
  ),
)

// Remote video view
AgoraVideoView(
  controller: VideoViewController.remote(
    rtcEngine: _engine!,
    canvas: VideoCanvas(uid: remoteUid),
    connection: RtcConnection(channelId: channelName),
  ),
)
```

### Video Layout in Game View

```
┌────────────────────────────────────┐
│         Game Table Area            │
│                                    │
│   [Player 2 Video]                 │
│                                    │
│ [P1 Video]  [CARDS]  [P3 Video]   │
│                                    │
│   [Player 4 Video]  [My Cards]     │
│                                    │
└────────────────────────────────────┘
```

- Video tiles: 120×90px (small overlays at each player position)
- Tap to expand video to larger view
- Camera-off state shows avatar with voice activity indicator

### Video Resolution Tiers

| Network Quality | Resolution | FPS | Bitrate |
|---|---|---|---|
| Excellent | 320×240 | 15 | 200 kbps |
| Good | 240×180 | 15 | 150 kbps |
| Poor | 160×120 | 10 | 80 kbps |
| Very Poor | Audio only | — | — |

---

## Permission Handling

### Required Permissions

**Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
```

**iOS (Info.plist):**
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Bloot needs microphone access for voice chat during games</string>
<key>NSCameraUsageDescription</key>
<string>Bloot needs camera access so other players can see you</string>
```

### Permission Request Flow

```dart
Future<bool> requestAudioPermission() async {
  var status = await Permission.microphone.status;
  if (status.isGranted) return true;

  status = await Permission.microphone.request();
  if (status.isGranted) return true;

  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }

  return false;
}

Future<bool> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (status.isGranted) return true;

  status = await Permission.camera.request();
  if (status.isGranted) return true;

  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }

  return false;
}
```

### Graceful Degradation

- If mic permission denied: Player can still play, text chat only
- If camera permission denied: Voice-only mode, avatar displayed
- Permission can be granted later from settings

---

## Network Quality Indicators

### Agora Network Quality Callback

```dart
_engine!.registerEventHandler(RtcEngineEventHandler(
  onNetworkQuality: (connection, remoteUid, txQuality, rxQuality) {
    // txQuality: sending quality
    // rxQuality: receiving quality
    // QualityType: excellent, good, poor, bad, veryBad, down
  },
));
```

### UI Indicators

| Quality | Icon | Color | Action |
|---|---|---|---|
| Excellent | 📶 | Green | None |
| Good | 📶 | Green | None |
| Poor | 📶 | Yellow | Reduce video quality |
| Bad | 📶 | Orange | Disable video, audio only |
| Very Bad | 📶 | Red | Alert user, may disconnect |
| Down | ❌ | Red | Reconnecting... |

---

## Echo Cancellation and Noise Suppression

### Agora Built-in Features

Agora provides hardware and software AEC (Acoustic Echo Cancellation) and ANS (Active Noise Suppression) out of the box:

```dart
// These are enabled by default in Agora, but can be configured:
await _engine!.setParameters('{"che.audio.keep.aec": true}');
await _engine!.setParameters('{"che.audio.ans": true}');
await _engine!.setParameters('{"che.audio.agc": true}');
```

### Additional Recommendations

- Encourage players to use earphones (UI prompt on first join)
- Implement "push-to-talk" option as alternative to always-on mic
- Visual indicator when mic is picking up audio (level meter)
- Auto-mute when not in active game (between deals)

---

## Bandwidth Considerations

### 4-Player Video Call

| Component | Per Player | Total (4 players) |
|---|---|---|
| Video upload | 200 kbps | 200 kbps (1 stream up) |
| Video download | 200 kbps × 3 | 600 kbps (3 streams down) |
| Audio upload | 32 kbps | 32 kbps |
| Audio download | 32 kbps × 3 | 96 kbps |
| **Total per player** | | **~928 kbps** |

### 4-Player Voice-Only Call

| Component | Per Player | Total (4 players) |
|---|---|---|
| Audio upload | 32 kbps | 32 kbps |
| Audio download | 32 kbps × 3 | 96 kbps |
| **Total per player** | | **~128 kbps** |

### Recommendations

- **Minimum required bandwidth:** 500 kbps (audio-only), 1.5 Mbps (video)
- **Recommended bandwidth:** 2 Mbps+ for full video experience
- Default to voice-only in rooms; camera is opt-in
- Auto-detect network quality and suggest disabling video if slow

---

## Fallback Strategy

### Three-Tier Fallback

```
Video + Audio (default)
    │
    │ Network quality drops to "Poor"
    ▼
Audio Only (camera disabled, avatar shown)
    │
    │ Network quality drops to "Very Bad"
    ▼
Text Only (audio disabled, text chat only)
    │
    │ Connection lost
    ▼
Reconnecting (auto-retry for 60 seconds)
    │
    │ Timeout
    ▼
Disconnected (game paused, AI takes over temporarily)
```

### Implementation

```dart
void handleNetworkQuality(QualityType txQuality, QualityType rxQuality) {
  final worstQuality = txQuality.index > rxQuality.index ? txQuality : rxQuality;

  switch (worstQuality) {
    case QualityType.qualityExcellent:
    case QualityType.qualityGood:
      // Full video + audio
      break;
    case QualityType.qualityPoor:
      // Reduce video quality
      _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 160, height: 120),
          frameRate: 10,
          bitrate: 80,
        ),
      );
      break;
    case QualityType.qualityBad:
    case QualityType.qualityVeryBad:
      // Disable video, keep audio
      _engine!.muteAllRemoteVideoStreams(true);
      _engine!.enableLocalVideo(false);
      break;
    case QualityType.qualityDown:
      // Connection lost - trigger reconnect
      _reconnect();
      break;
  }
}
```

---

## Pricing and Limits

### Agora Pricing (as of 2024)

| Tier | Audio | Video (HD) | Video (SD) |
|---|---|---|---|
| Free tier | 10,000 min/month | 10,000 min/month | 10,000 min/month |
| Paid | $0.99/1,000 min | $3.99/1,000 min | $1.99/1,000 min |

### Estimated Monthly Costs

**Scenario: 1,000 MAU, avg 2 hours voice + 30 min video per month**

| Usage Type | Minutes/Month | Cost |
|---|---|---|
| Voice | 120,000 min | $118.80 |
| Video (SD) | 30,000 min | $59.70 |
| **Total** | | **$178.50/month** |

**Scenario: 10,000 MAU, avg 3 hours voice + 1 hour video per month**

| Usage Type | Minutes/Month | Cost |
|---|---|---|
| Voice | 1,800,000 min | $1,782.00 |
| Video (SD) | 600,000 min | $1,194.00 |
| **Total** | | **$2,976.00/month** |

### Cost Optimization

1. Default to voice-only; video is opt-in per player
2. Use SD video (320×240) instead of HD
3. Reduce video bitrate aggressively based on network quality
4. Consider LiveKit migration at scale (>100K MAU)
5. Implement idle detection (mute when not speaking, disable video when in background)

---

## Security Considerations

- **Token-based authentication:** All Agora channels require server-generated tokens
- **Channel encryption:** Enable Agora's built-in encryption
- **UID validation:** Verify user IDs match authenticated users
- **Token expiry:** 1-hour tokens, refresh before expiry
- **Room isolation:** Each game room gets a unique Agora channel
- **No recording by default:** Audio/video is not recorded unless streaming is active

```dart
// Enable encryption
await _engine!.enableEncryption(
  enabled: true,
  config: const EncryptionConfig(
    encryptionMode: EncryptionModeType.encryptionModeAes128Gcm2,
    encryptionKey: 'SERVER_PROVIDED_KEY',
  ),
);
```
