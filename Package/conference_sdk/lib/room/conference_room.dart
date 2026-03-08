import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class ConferenceRoom extends StatefulWidget {
  final Room room;

  const ConferenceRoom({super.key, required this.room});

  @override
  State<ConferenceRoom> createState() => _ConferenceRoomState();
}

class _ConferenceRoomState extends State<ConferenceRoom> {
  late final EventsListener<RoomEvent> _listener = widget.room.createListener();

  @override
  void initState() {
    super.initState();
    // used for generic change updates
    widget.room.addListener(_onChange);

    // used for specific events
    _listener
      ..on<RoomDisconnectedEvent>((_) {
        // handle disconnect
      })
      ..on<ParticipantConnectedEvent>((e) {
        debugPrint("participant joined: ${e.participant.identity}");
      });
  }

  @override
  void dispose() {
    // be sure to dispose listener to stop listening to further updates
    _listener.dispose();
    widget.room.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    // perform computations and then call setState
    // setState will trigger a build
    setState(() {
      // your updates here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
