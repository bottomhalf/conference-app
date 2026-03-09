import 'package:conference/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/meeting_model.dart';
import '../../models/chat_message_model.dart';
import '../../theme/app_theme.dart';
import 'chat_detail_controller.dart';

class ChatDetailPage extends GetView<ChatDetailController> {
  const ChatDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.messages.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.accentPurple,
                  ),
                );
              }

              if (controller.messages.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Text(
                    'No messages yet',
                    style: TextStyle(color: AppTheme.textSecondary(context)),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount:
                    controller.messages.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.accentPurple,
                          ),
                        ),
                      ),
                    );
                  }

                  // Since messages are ordered latest-first, index 0 is the newest message at the bottom.
                  final message = controller.messages[index];
                  // If 'currentUser' was actually returned we could compare properly; otherwise fallback checking your ID
                  final isMe = message.senderId != UserModel.instance.userId;
                  return _buildMessageBubble(context, message, isMe);
                },
              );
            }),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final convo = controller.conversation;
    return AppBar(
      backgroundColor: AppTheme.card(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppTheme.textPrimary(context),
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _buildAvatar(convo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  convo.conversationName.isNotEmpty
                      ? convo.conversationName
                      : 'Chat',
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${convo.participantCount} participants',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_rounded, color: AppTheme.accentPurple),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.info_outline_rounded,
            color: AppTheme.textSecondary(context),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: AppTheme.divider(context).withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildAvatar(MeetingModel convo) {
    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    ];
    final colorPair = gradients[convo.id.hashCode.abs() % gradients.length];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colorPair),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          convo.conversationName.isNotEmpty
              ? convo.conversationName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    bool isMe,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
              child: Text(
                message.senderId.isNotEmpty
                    ? message.senderId[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.accentPurple : AppTheme.card(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentPurple,
                        ),
                      ),
                    ),
                  Text(
                    message.body,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : AppTheme.textPrimary(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white70
                          : AppTheme.textSecondary(context),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe)
            const SizedBox(width: 32), // Spacer on right for my messages
          if (!isMe)
            const SizedBox(width: 32), // Spacer on left for others' messages
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: AppTheme.textSecondary(context),
            ),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.divider(context).withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.accentPurple,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: controller.sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
