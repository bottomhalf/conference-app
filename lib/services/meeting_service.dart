import 'package:conference/config/app_config.dart';
import 'package:conference/services/http_service.dart';
import 'package:conference_sdk/conference_sdk.dart';
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

  /// Disconnect and hide the overlay.
  Future<void> leaveMeeting() async {
    await _room?.disconnect();
    _room = null;
    isInMeeting.value = false;
    isConnecting.value = false;
    errorMessage.value = null;
    isFullScreen.value = true;
    isMicOn.value = true;
    isCameraOn.value = true;
    isScreenSharing.value = false;
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

  Future<void> toggleMic() async {
    isMicOn.value = !isMicOn.value;
    await _room?.localParticipant?.setMicrophoneEnabled(isMicOn.value);
  }

  Future<void> toggleCamera() async {
    isCameraOn.value = !isCameraOn.value;
    await _room?.localParticipant?.setCameraEnabled(isCameraOn.value);
  }

  Future<void> toggleScreenShare() async {
    isScreenSharing.value = !isScreenSharing.value;
    await _room?.localParticipant?.setScreenShareEnabled(isScreenSharing.value);
  }

  // ─── Display mode ──────────────────────────────────────────────

  /// Switch to mini PiP mode.
  void minimize() => isFullScreen.value = false;

  /// Switch to full-screen mode.
  void maximize() => isFullScreen.value = true;
}
