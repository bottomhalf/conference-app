import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';

class BottomControls extends StatelessWidget {
  const BottomControls({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MeetingService.instance;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlBtn(
                    context: context,
                    icon: service.isMicOn.value
                        ? Icons.mic_rounded
                        : Icons.mic_off_rounded,
                    isActive: service.isMicOn.value,
                    onTap: service.toggleMic,
                  ),
                  const SizedBox(width: 4),
                  _buildControlBtn(
                    context: context,
                    icon: service.isCameraOn.value
                        ? Icons.videocam_rounded
                        : Icons.videocam_off_rounded,
                    isActive: service.isCameraOn.value,
                    onTap: service.toggleCamera,
                  ),
                  const SizedBox(width: 4),
                  _buildControlBtn(
                    context: context,
                    icon: Icons.screen_share_rounded,
                    isActive: service.isScreenSharing.value,
                    onTap: service.toggleScreenShare,
                    activeColor: AppTheme.accentPurple,
                  ),
                  const SizedBox(width: 4),
                  _buildControlBtn(
                    context: context,
                    icon: Icons.groups_rounded,
                    isActive: false,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildLeaveBtn(context, service),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? (activeColor?.withValues(alpha: 0.2) ?? Colors.transparent)
              : Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? (activeColor ?? Colors.white) : Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildLeaveBtn(BuildContext context, MeetingService service) {
    return GestureDetector(
      onTap: service.leaveMeeting,
      child: Container(
        width: 60,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(
          Icons.call_end_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
