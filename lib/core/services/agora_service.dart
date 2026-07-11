import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/config/agora_config.dart';
import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/network/cache_helper.dart';
import 'package:bloot/core/network/cache_keys.dart';
import 'package:bloot/core/services/remote_config_service.dart';

/// Event fired when a remote user joins the channel.
class AgoraUserJoinedEvent {
  const AgoraUserJoinedEvent({required this.uid, required this.elapsed});
  final int uid;
  final int elapsed;
}

/// Event fired when a remote user leaves the channel.
class AgoraUserOfflineEvent {
  const AgoraUserOfflineEvent({required this.uid, required this.reason});
  final int uid;
  final UserOfflineReasonType reason;
}

/// Event fired when the connection state changes.
class AgoraConnectionStateChangedEvent {
  const AgoraConnectionStateChangedEvent({
    required this.channelId,
    required this.state,
    required this.reason,
  });
  final String channelId;
  final ConnectionStateType state;
  final ConnectionChangedReasonType reason;
}

/// Event fired when audio volume is indicated.
class AgoraAudioVolumeIndicationEvent {
  const AgoraAudioVolumeIndicationEvent({required this.speakers});
  final List<AudioVolumeInfo> speakers;
}

/// Manages Agora voice/video engine lifecycle for a single channel.
///
/// Follows the singleton pattern via DI and provides:
/// - Video rendering widgets (`getLocalVideoView`, `getRemoteVideoView`)
/// - Reference-counted remote video subscription
/// - Background audio mode
/// - Crash recovery via [CacheHelper]
/// - Connection state and volume indication event streams
@lazySingleton
class AgoraService {
  AgoraService({
    required FirebaseFunctions functions,
    required CacheHelper cacheHelper,
    required FirebaseAuth firebaseAuth,
    required RemoteConfigService remoteConfig,
  })  : _functions = functions,
        _cacheHelper = cacheHelper,
        _firebaseAuth = firebaseAuth,
        _remoteConfig = remoteConfig;

  final FirebaseFunctions _functions;
  final CacheHelper _cacheHelper;
  final FirebaseAuth _firebaseAuth;
  final RemoteConfigService _remoteConfig;

  RtcEngine? _engine;
  String? _currentChannelId;
  int? _currentUid;
  bool _isMicOn = true;
  bool _isCameraOn = false;
  int _remoteVideoSubscriberCount = 0;
  bool _leaveRequested = false;

  // Event controllers
  final _userJoinedController = StreamController<AgoraUserJoinedEvent>.broadcast();
  final _userOfflineController = StreamController<AgoraUserOfflineEvent>.broadcast();
  final _connectionStateController =
      StreamController<AgoraConnectionStateChangedEvent>.broadcast();
  final _audioVolumeController =
      StreamController<AgoraAudioVolumeIndicationEvent>.broadcast();

  /// Whether the local mic is currently unmuted.
  bool get isMicOn => _isMicOn;

  /// Whether the local camera is currently on.
  bool get isCameraOn => _isCameraOn;

  /// The current Agora channel ID, or null if not in a channel.
  String? get currentChannelId => _currentChannelId;

  /// The current Agora UID, or null if not in a channel.
  int? get currentUid => _currentUid;

  /// Stream of remote user join events.
  Stream<AgoraUserJoinedEvent> get onUserJoined => _userJoinedController.stream;

  /// Stream of remote user offline events.
  Stream<AgoraUserOfflineEvent> get onUserOffline =>
      _userOfflineController.stream;

  /// Stream of connection state changes.
  Stream<AgoraConnectionStateChangedEvent> get onConnectionStateChanged =>
      _connectionStateController.stream;

  /// Stream of audio volume indication events.
  Stream<AgoraAudioVolumeIndicationEvent> get onAudioVolumeIndication =>
      _audioVolumeController.stream;

  /// Initialize the Agora engine (idempotent).
  Future<void> initialize() async {
    if (_engine != null) return;

    final appId = _remoteConfig.agoraAppId.isNotEmpty
        ? _remoteConfig.agoraAppId
        : AgoraConfig.appId;
    if (appId.isEmpty) {
      throw StateError('Agora App ID is not configured.');
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    await _engine!.enableAudio();
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileMusicStandard,
      // Game-streaming scenario mixes with other app audio instead of taking
      // exclusive focus, so WebView sound effects keep playing.
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
    await _engine!.enableAudioVolumeIndication(
      interval: 200,
      smooth: 3,
      reportVad: true,
    );
    await _engine!.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    _registerEventHandlers();

    AppLogger.info('Agora engine initialized', tag: 'Agora');
  }

  void _registerEventHandlers() {
    if (_engine == null) return;

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          AppLogger.info(
            'Joined channel: ${connection.channelId}, uid: ${connection.localUid}',
            tag: 'Agora',
          );
        },
        onLeaveChannel: (connection, stats) {
          AppLogger.info('Left channel: ${connection.channelId}', tag: 'Agora');
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          AppLogger.info('User joined: $remoteUid', tag: 'Agora');
          _userJoinedController.add(
            AgoraUserJoinedEvent(uid: remoteUid, elapsed: elapsed),
          );
        },
        onUserOffline: (connection, remoteUid, reason) {
          AppLogger.info(
            'User offline: $remoteUid, reason: $reason',
            tag: 'Agora',
          );
          _userOfflineController.add(
            AgoraUserOfflineEvent(uid: remoteUid, reason: reason),
          );
        },
        onConnectionStateChanged: (connection, state, reason) {
          AppLogger.info(
            'Connection state: $state, reason: $reason',
            tag: 'Agora',
          );
          _connectionStateController.add(
            AgoraConnectionStateChangedEvent(
              channelId: connection.channelId ?? '',
              state: state,
              reason: reason,
            ),
          );
        },
        onAudioVolumeIndication: (connection, speakers, totalVolume, vad) {
          if (speakers.isNotEmpty) {
            _audioVolumeController.add(
              AgoraAudioVolumeIndicationEvent(speakers: speakers),
            );
          }
        },
        onTokenPrivilegeWillExpire: (connection, token) {
          AppLogger.warning(
            'Token will expire for ${connection.channelId}',
            tag: 'Agora',
          );
          _renewToken(connection.channelId ?? '');
        },
      ),
    );
  }

  /// Request an Agora token from Cloud Functions.
  Future<String> _fetchToken({
    required String channelName,
    required int uid,
    required String role,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('generateAgoraToken')
          .call<Map<String, dynamic>>({
        'channelName': channelName,
        'uid': uid,
        'role': role,
      }).timeout(const Duration(seconds: 10));
      final token = result.data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Token generation returned empty token');
      }
      AppLogger.info('Agora token obtained', tag: 'Agora');
      return token;
    } catch (e) {
      AppLogger.error('Failed to fetch Agora token', error: e, tag: 'Agora');
      rethrow;
    }
  }

  Future<void> _renewToken(String channelName) async {
    if (_currentUid == null || _currentChannelId == null) return;
    try {
      final token = await _fetchToken(
        channelName: channelName,
        uid: _currentUid!,
        role: 'publisher',
      );
      await _engine?.renewToken(token);
      AppLogger.info('Token renewed', tag: 'Agora');
    } catch (e) {
      AppLogger.error('Failed to renew token', error: e, tag: 'Agora');
    }
  }

  /// Join an Agora channel as a broadcaster (player).
  ///
  /// Uses the current Firebase Auth UID hash as the Agora UID.
  Future<void> joinChannel({required String channelName}) async {
    await _joinChannelInternal(
      channelName: channelName,
      isAudience: false,
    );
  }

  /// Join an Agora channel as an audience member (spectator).
  ///
  /// Subscribes to audio and video but does not publish.
  Future<void> joinAsAudience({required String channelName}) async {
    await _joinChannelInternal(
      channelName: channelName,
      isAudience: true,
    );
  }

  Future<void> _joinChannelInternal({
    required String channelName,
    required bool isAudience,
  }) async {
    await initialize();

    if (_currentChannelId == channelName) return;
    if (_currentChannelId != null) {
      await leaveChannel();
    }

    _leaveRequested = false;

    final firebaseUid = _firebaseAuth.currentUser?.uid;
    if (firebaseUid == null) {
      throw Exception('Cannot join Agora channel: user not authenticated');
    }

    final agoraUid = firebaseUid.hashCode.abs();
    final token = await _fetchToken(
      channelName: channelName,
      uid: agoraUid,
      role: isAudience ? 'subscriber' : 'publisher',
    );

    try {
      // Audience needs video enabled to decode remote video streams
      if (isAudience) {
        await _engine!.enableVideo();
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(autoSubscribeVideo: true),
        );
      }

      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: agoraUid,
        options: ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishMicrophoneTrack: !isAudience,
          publishCameraTrack: !isAudience && _isCameraOn,
          clientRoleType: isAudience
              ? ClientRoleType.clientRoleAudience
              : ClientRoleType.clientRoleBroadcaster,
        ),
      );

      // If the user requested leave while we were joining, leave immediately.
      if (_leaveRequested) {
        await leaveChannel();
        return;
      }

      _currentChannelId = channelName;
      _currentUid = agoraUid;

      // Crash recovery: save active room/channel
      await _cacheHelper.saveData(key: CacheKeys.activeChannelId, value: channelName);

      AppLogger.info(
        'Joined Agora channel: $channelName, uid: $agoraUid',
        tag: 'Agora',
      );
    } catch (e) {
      AppLogger.error('Failed to join Agora channel', error: e, tag: 'Agora');
      rethrow;
    }
  }

  /// Leave the current Agora channel.
  Future<void> leaveChannel() async {
    if (_engine == null) return;
    _leaveRequested = true;
    if (_currentChannelId == null) return;

    try {
      await _engine!.leaveChannel();
      AppLogger.info('Left Agora channel: $_currentChannelId', tag: 'Agora');
    } catch (e) {
      AppLogger.error('Failed to leave Agora channel', error: e, tag: 'Agora');
    } finally {
      _currentChannelId = null;
      _currentUid = null;
      _isMicOn = true;
      _isCameraOn = false;
      // video disabled
      _remoteVideoSubscriberCount = 0;

      // Clear crash recovery
      await _cacheHelper.removeData(key: CacheKeys.activeChannelId);
    }
  }

  /// Toggle local microphone mute state.
  Future<bool> toggleMic() async {
    if (_engine == null) return _isMicOn;
    _isMicOn = !_isMicOn;
    await _engine!.muteLocalAudioStream(!_isMicOn);
    AppLogger.info('Mic ${_isMicOn ? 'on' : 'muted'}', tag: 'Agora');
    return _isMicOn;
  }

  /// Toggle local camera on/off state.
  Future<bool> toggleCamera() async {
    if (_engine == null) return _isCameraOn;
    _isCameraOn = !_isCameraOn;

    if (_isCameraOn) {
      await _engine!.enableVideo();
      // video enabled
      await _engine!.muteLocalVideoStream(false);
    } else {
      await _engine!.muteLocalVideoStream(true);
    }

    if (_currentChannelId != null) {
      await _engine!.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishCameraTrack: _isCameraOn,
        ),
      );
    }

    AppLogger.info('Camera ${_isCameraOn ? 'on' : 'off'}', tag: 'Agora');
    return _isCameraOn;
  }

  /// Set mic and camera state from external source (e.g., room settings).
  Future<void> setMediaState({
    required bool micOn,
    required bool cameraOn,
  }) async {
    if (_engine == null) return;

    if (_isMicOn != micOn) {
      _isMicOn = micOn;
      await _engine!.muteLocalAudioStream(!_isMicOn);
    }

    if (_isCameraOn != cameraOn) {
      _isCameraOn = cameraOn;
      if (_isCameraOn) {
        await _engine!.enableVideo();
        // video enabled
        await _engine!.muteLocalVideoStream(false);
      } else {
        await _engine!.muteLocalVideoStream(true);
      }

      if (_currentChannelId != null) {
        await _engine!.updateChannelMediaOptions(
          ChannelMediaOptions(publishCameraTrack: _isCameraOn),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Video rendering
  // ---------------------------------------------------------------------------

  /// Returns a widget that renders the local video feed.
  Widget getLocalVideoView({VideoSourceType? sourceType}) {
    if (_engine == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: VideoCanvas(
          uid: 0,
          sourceType: sourceType ?? VideoSourceType.videoSourceCamera,
        ),
      ),
    );
  }

  /// Returns a widget that renders a remote user's video feed.
  Widget getRemoteVideoView(int remoteUid) {
    if (_engine == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: remoteUid),
        connection: RtcConnection(
          channelId: _currentChannelId ?? '',
          localUid: _currentUid ?? 0,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reference-counted remote video subscription
  // ---------------------------------------------------------------------------

  /// Increment the remote video subscriber count and enable video if needed.
  Future<void> subscribeToRemoteVideo() async {
    if (_engine == null || _currentChannelId == null) return;
    _remoteVideoSubscriberCount++;
    if (_remoteVideoSubscriberCount == 1) {
      try {
        await _engine!.enableVideo();
        // video enabled
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(autoSubscribeVideo: true),
        );
        AppLogger.debug('Remote video subscribed', tag: 'Agora');
      } catch (e) {
        AppLogger.error('Failed to subscribe to remote video', error: e, tag: 'Agora');
      }
    }
  }

  /// Decrement the remote video subscriber count and disable video if no
  /// subscribers remain.
  Future<void> unsubscribeFromRemoteVideo() async {
    if (_engine == null || _currentChannelId == null) return;
    _remoteVideoSubscriberCount--;
    if (_remoteVideoSubscriberCount <= 0) {
      _remoteVideoSubscriberCount = 0;
      try {
        await _engine!.updateChannelMediaOptions(
          const ChannelMediaOptions(autoSubscribeVideo: false),
        );
        AppLogger.debug('Remote video unsubscribed', tag: 'Agora');
      } catch (e) {
        AppLogger.error('Failed to unsubscribe from remote video', error: e, tag: 'Agora');
      }
    }
    if (_remoteVideoSubscriberCount < 0) _remoteVideoSubscriberCount = 0;
  }

  // ---------------------------------------------------------------------------
  // Background / foreground
  // ---------------------------------------------------------------------------

  /// Enter background mode — keep audio session active.
  Future<void> enterBackgroundMode() async {
    if (_engine == null) return;
    await _engine!.updateChannelMediaOptions(
      const ChannelMediaOptions(publishMicrophoneTrack: true),
    );
    AppLogger.debug('Entered background mode', tag: 'Agora');
  }

  /// Leave background mode — restore normal media options.
  Future<void> leaveBackgroundMode() async {
    if (_engine == null) return;
    AppLogger.debug('Left background mode', tag: 'Agora');
  }

  // ---------------------------------------------------------------------------
  // Crash recovery
  // ---------------------------------------------------------------------------

  /// Returns the cached active channel ID from a previous session, or null.
  String? getCachedActiveChannelId() {
    return _cacheHelper.getData(key: CacheKeys.activeChannelId);
  }

  /// Clears any cached active channel ID.
  Future<void> clearCachedActiveChannel() async {
    await _cacheHelper.removeData(key: CacheKeys.activeChannelId);
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  /// Release the Agora engine and free resources.
  Future<void> dispose() async {
    await leaveChannel();

    await _userJoinedController.close();
    await _userOfflineController.close();
    await _connectionStateController.close();
    await _audioVolumeController.close();

    await _engine?.release(sync: true);
    _engine = null;
    AppLogger.info('Agora engine released', tag: 'Agora');
  }
}
