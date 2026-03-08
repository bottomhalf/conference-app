import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

/// A Calculator.
class ConferenceManager {
  Room? _room;

  Future<Room> joinRoom(String url, String token) async {
    final room = Room();

    final listener = room.createListener();

    /// Track subscribed
    listener.on<TrackSubscribedEvent>((event) {
      final track = event.track;
      final participant = event.participant;
      final publication = event.publication;

      if (publication.source == TrackSource.screenShareVideo) {
        debugPrint("${participant.identity} is sharing screen");
      }

      if (track is RemoteAudioTrack) {
        debugPrint("Audio track received from ${participant.identity}");
      }

      if (track is RemoteVideoTrack) {
        debugPrint("Video track received from ${participant.identity}");
      }
    });

    /// Track unsubscribed
    listener.on<TrackUnsubscribedEvent>((event) {
      debugPrint("Track removed from ${event.participant.identity}");
    });

    /// Track muted
    listener.on<TrackMutedEvent>((event) {
      debugPrint("${event.participant.identity} muted track");
    });

    /// Track unmuted
    listener.on<TrackUnmutedEvent>((event) {
      debugPrint("${event.participant.identity} unmuted track");
    });

    /// Participant connected
    listener.on<ParticipantConnectedEvent>((event) {
      debugPrint("${event.participant.identity} joined meeting");
    });

    /// Participant disconnected
    listener.on<ParticipantDisconnectedEvent>((event) {
      debugPrint("${event.participant.identity} left meeting");
    });

    /// Data received (chat / reactions / hand raise)
    listener.on<DataReceivedEvent>((event) {
      final participant = event.participant;
      final message = utf8.decode(event.data);

      final json = jsonDecode(message);

      if (json["type"] == "hand_raise") {
        debugPrint("${participant?.identity} raised hand");
      }

      if (json["type"] == "reaction") {
        debugPrint("${participant?.identity} reaction ${json["emoji"]}");
      }

      if (json["type"] == "chat") {
        debugPrint("${participant?.identity}: ${json["message"]}");
      }
    });

    /// Connected
    listener.on<RoomConnectedEvent>((event) {
      debugPrint("Connected to room");

      for (final participant in room.remoteParticipants.values) {
        debugPrint("Existing participant ${participant.identity}");
      }
    });

    await room.connect(
      url,
      token,
      // roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
    );

    _room = room;
    return room;
  }

  Future<void> shareScreen() async {
    _room!.localParticipant?.setScreenShareEnabled(true);
  }

  Future<void> leaveRoom() async {
    await _room?.disconnect();
    debugPrint("Disconnected from room");
  }
}
