class ChatMessage {
  final String id;
  final String messageId;
  final String conversationId;
  final String senderId;
  final String type;
  final String body;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.body,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      messageId: json['messageId'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      body: json['body'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class ChatMessageResponse {
  final List<ChatMessage> messages;
  final int page;
  final int totalPages;
  final bool hasMore;

  ChatMessageResponse({
    required this.messages,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
