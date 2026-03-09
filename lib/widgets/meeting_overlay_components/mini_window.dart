import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';

class MiniWindow extends StatelessWidget {
  final Size screenSize;
  final double miniX;
  final double miniY;
  final double miniWidth;
  final double miniHeight;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;

  const MiniWindow({
    super.key,
    required this.screenSize,
    required this.miniX,
    required this.miniY,
    required this.miniWidth,
    required this.miniHeight,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    final service = MeetingService.instance;

    return Positioned(
      left: 0,
      top: 0,
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: miniX,
              top: miniY,
              child: GestureDetector(
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
                onTap: service.maximize,
                child: _buildMiniCard(context, service),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(BuildContext context, MeetingService service) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: miniWidth,
          height: miniHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.card(context).withValues(alpha: 0.95),
                AppTheme.cardAlt(context).withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentPurple.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Obx(
            () => Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row — meeting name + close
                  Row(
                    children: [
                      Icon(
                        Icons.fiber_manual_record_rounded,
                        color: AppTheme.successGreen,
                        size: 8,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          service.meetingName.isNotEmpty
                              ? service.meetingName
                              : 'Meeting',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: service.leaveMeeting,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.call_end_rounded,
                            size: 11,
                            color: AppTheme.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Bottom row — status icons
                  Row(
                    children: [
                      Icon(
                        service.isMicOn.value
                            ? Icons.mic_rounded
                            : Icons.mic_off_rounded,
                        size: 14,
                        color: service.isMicOn.value
                            ? AppTheme.textSecondary(context)
                            : AppTheme.errorRed,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        service.isCameraOn.value
                            ? Icons.videocam_rounded
                            : Icons.videocam_off_rounded,
                        size: 14,
                        color: service.isCameraOn.value
                            ? AppTheme.textSecondary(context)
                            : AppTheme.errorRed,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.people_rounded,
                        size: 13,
                        color: AppTheme.textSecondary(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.participantCount.value}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.open_in_full_rounded,
                        size: 12,
                        color: AppTheme.accentPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
