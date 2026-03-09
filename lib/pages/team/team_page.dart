import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/meeting_model.dart';
import '../../theme/app_theme.dart';
import 'team_controller.dart';

class TeamPage extends GetView<TeamController> {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            // App Header placeholder integration will go here, currently managed by main structure
            _buildTeamHeader(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentPurple,
                      strokeWidth: 3,
                    ),
                  );
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppTheme.errorRed,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: controller.fetchConversations,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPurple,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: AppTheme.textSecondary(
                            context,
                          ).withValues(alpha: 0.5),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet.',
                          style: TextStyle(
                            color: AppTheme.textSecondary(context),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: controller.conversations.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppTheme.divider(context).withValues(alpha: 0.4),
                    height: 1,
                    indent: 64, // To align with text, bypassing avatar
                  ),
                  itemBuilder: (context, index) {
                    final convo = controller.conversations[index];
                    return _buildTeamTile(context, convo);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Team',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: AppTheme.textSecondary(context),
            ),
            onPressed: () {},
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.edit_rounded, color: AppTheme.accentPurple),
            onPressed: () {},
            tooltip: 'New Team',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamTile(BuildContext context, MeetingModel convo) {
    // Basic formatting for avatar — check conversationType
    final isGroup = convo.conversationType == 'group';

    // Display Title
    String title = convo.conversationName;
    if (title.isEmpty) {
      title = isGroup ? 'Group Chat' : 'Direct Message';
    }

    // Attempt to extract initials from title or users
    String initials = '?';
    if (title.isNotEmpty) {
      final parts = title.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = title[0].toUpperCase();
      }
    }

    // Retrieve gradient pair using ID hash map
    final gradients = [
      const [Color(0xFF6C5CE7), Color(0xFF8E7CF3)],
      const [Color(0xFF2D7FF9), Color(0xFF18BFFF)],
      const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      const [Color(0xFF00B894), Color(0xFF55EFC4)],
      const [Color(0xFFE17055), Color(0xFFF8A5C2)],
    ];
    final colorPair = gradients[convo.id.hashCode.abs() % gradients.length];

    return InkWell(
      onTap: () => controller.openTeam(convo),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            // AVATAR
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colorPair),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (isGroup)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.surface(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.card(context),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        size: 12,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // MIDDLE TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        convo.timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          convo.lastMessage?.content ??
                              (isGroup
                                  ? 'You were added to the group'
                                  : 'Start of conversation'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
