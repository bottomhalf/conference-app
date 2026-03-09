import 'package:conference/config/app_config.dart';
import 'package:conference/services/http_service.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Singleton service that owns the active meeting lifecycle.
///
/// Lives across all pages — the overlay reads from this service
/// to render the meeting UI in full or mini mode.
class MeetingService extends GetxService {
  static MeetingService get instance => Get.find<MeetingService>();

  final _http = HttpService.instance;
  final _conferenceManager = ConferenceManager();

  // ─── Reactive state ────────────────────────────────────────────
  final isInMeeting = false.obs;
  final isConnecting = false.obs;
  final errorMessage = Rxn<String>();
  final isFullScreen = true.obs;

  final isMicOn = true.obs;
  final isCameraOn = true.obs;
  final isScreenSharing = false.obs;

  // Renderable Tracks
  final activeScreenShareTrack = Rxn<VideoTrack>();
  final activeVideoTrack = Rxn<VideoTrack>();

  EventsListener<RoomEvent>? _roomListener;

  Room? _room;
  Room? get room => _room;

  String _meetingName = '';
  String get meetingName => _meetingName;

  final participantCount = 1.obs;

  // ─── Join / Leave ──────────────────────────────────────────────

  /// Join a meeting — fetches token, connects to LiveKit, shows overlay.
  Future<void> joinMeeting({
    required String roomId,
    required String participantName,
    String meetingTitle = 'Meeting',
  }) async {
    if (isInMeeting.value) return; // already in a meeting

    _meetingName = meetingTitle;
    isInMeeting.value = true;
    isConnecting.value = true;
    isFullScreen.value = true;
    errorMessage.value = null;

    try {
      // 1. Fetch LiveKit token
      final token = await _http.getMeetingToken(roomId, participantName);

      // 2. Connect to room
      final room = await _conferenceManager.joinRoom(
        "wss://${AppConfig.instance.livekitUrl}/conference",
        token,
      );

      _room = room;
      participantCount.value = room.remoteParticipants.length + 1;

      _roomListener = room.createListener();
      _setupRoomListeners();

      // 3. Show meeting UI immediately
      isMicOn.value = false;
      isCameraOn.value = false;
      isScreenSharing.value = false;
      isConnecting.value = false;

      // 4. Enable mic & camera in the background (don't block UI)
      _enableMediaTracks(room);
    } catch (e) {
      debugPrint("Meeting join failed: $e");
      isConnecting.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> _enableMediaTracks(Room currentRoom) async {
    try {
      await currentRoom.localParticipant?.setMicrophoneEnabled(true);
      isMicOn.value = true;
    } catch (e) {
      debugPrint("Mic enable failed: $e");
    }
    try {
      await currentRoom.localParticipant?.setCameraEnabled(true);
      isCameraOn.value = true;
    } catch (e) {
      debugPrint("Camera enable failed: $e");
    }
  }

  Future<void> leaveMeeting() async {
    await _roomListener?.dispose();
    _roomListener = null;

    await _room?.disconnect();
    _room = null;
    isInMeeting.value = false;
    isConnecting.value = false;
    errorMessage.value = null;
    isFullScreen.value = true;
    isMicOn.value = true;
    isCameraOn.value = true;
    isScreenSharing.value = false;
    activeScreenShareTrack.value = null;
    activeVideoTrack.value = null;
    participantCount.value = 1;
    _meetingName = '';
  }

  /// Retry after a connection error.
  void retry(String roomId, String participantName) {
    isInMeeting.value = false;
    joinMeeting(
      roomId: roomId,
      participantName: participantName,
      meetingTitle: _meetingName,
    );
  }

  // ─── Controls ──────────────────────────────────────────────────

  void _setupRoomListeners() {
    _roomListener?.on<TrackSubscribedEvent>((event) {
      if (event.publication.source == TrackSource.screenShareVideo) {
        activeScreenShareTrack.value = event.track as VideoTrack?;
        isScreenSharing.value =
            true; // Refers to the session having a screen share
      } else if (event.track is RemoteVideoTrack &&
          event.publication.source == TrackSource.camera) {
        if (activeVideoTrack.value == null) {
          activeVideoTrack.value = event.track as VideoTrack?;
        }
      }
    });

    _roomListener?.on<TrackUnsubscribedEvent>((event) {
      if (event.publication.source == TrackSource.screenShareVideo) {
        // If the unsubscribed track is our active one, remove it.
        if (activeScreenShareTrack.value == event.track) {
          activeScreenShareTrack.value = null;
          isScreenSharing.value = false;
        }
      } else if (event.track == activeVideoTrack.value) {
        activeVideoTrack.value = null;
      }
    });
  }

  Future<void> toggleMic() async {
    isMicOn.value = !isMicOn.value;
    await _room?.localParticipant?.setMicrophoneEnabled(isMicOn.value);
  }

  Future<void> toggleCamera() async {
    isCameraOn.value = !isCameraOn.value;
    await _room?.localParticipant?.setCameraEnabled(isCameraOn.value);
  }

  Future<void> toggleScreenShare() async {
    final newState = !isScreenSharing.value;
    isScreenSharing.value = newState;
    await _room?.localParticipant?.setScreenShareEnabled(newState);

    // Attempt to quickly grab our local sharing track from our participant object
    if (newState) {
      final pub = _room?.localParticipant?.getTrackPublicationBySource(
        TrackSource.screenShareVideo,
      );
      if (pub?.track is VideoTrack) {
        activeScreenShareTrack.value = pub?.track as VideoTrack;
      }
    } else {
      activeScreenShareTrack.value = null;
    }
  }

  // ─── Display mode ──────────────────────────────────────────────

  /// Switch to mini PiP mode.
  void minimize() => isFullScreen.value = false;

  /// Switch to full-screen mode.
  void maximize() => isFullScreen.value = true;
}
