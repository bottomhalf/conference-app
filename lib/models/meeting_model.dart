/// Participant in a meeting conversation.
class MeetingParticipant {
  final String userId;
  final String firstName;
  final String? lastName;
  final String email;
  final String? avatar;
  final DateTime? joinedAt;
  final String role;

  MeetingParticipant({
    required this.userId,
    required this.firstName,
    this.lastName,
    required this.email,
    this.avatar,
    this.joinedAt,
    required this.role,
  });

  factory MeetingParticipant.fromJson(Map<String, dynamic> json) {
    return MeetingParticipant(
      userId: json['userId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'] as String)
          : null,
      role: json['role'] as String? ?? 'member',
    );
  }

  String get fullName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  }
}

/// Last message in a meeting conversation.
class MeetingLastMessage {
  final String messageId;
  final String content;
  final String senderId;
  final String? senderName;
  final DateTime? sentAt;

  MeetingLastMessage({
    required this.messageId,
    required this.content,
    required this.senderId,
    this.senderName,
    this.sentAt,
  });

  factory MeetingLastMessage.fromJson(Map<String, dynamic> json) {
    return MeetingLastMessage(
      messageId: json['messageId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String?,
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'] as String)
          : null,
    );
  }
}

/// A meeting / conversation returned by the recent-meetings API.
class MeetingModel {
  final String id;
  final String conversationType;
  final List<String> participantIds;
  final List<MeetingParticipant> participants;
  final String conversationName;
  final String? conversationAvatar;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final MeetingLastMessage? lastMessage;
  final DateTime? lastMessageAt;
  final bool active;

  MeetingModel({
    required this.id,
    required this.conversationType,
    required this.participantIds,
    required this.participants,
    required this.conversationName,
    this.conversationAvatar,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.lastMessageAt,
    required this.active,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] as String? ?? '',
      conversationType: json['conversationType'] as String? ?? '',
      participantIds:
          (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map(
                (e) => MeetingParticipant.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      conversationName: json['conversationName'] as String? ?? '',
      conversationAvatar: json['conversationAvatar'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      lastMessage: json['lastMessage'] != null
          ? MeetingLastMessage.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            )
          : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      active: json['active'] as bool? ?? false,
    );
  }

  /// Number of participants.
  int get participantCount => participants.length;

  /// Formatted time-ago string for last activity.
  String get timeAgo {
    final date = lastMessageAt ?? updatedAt ?? createdAt;
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
