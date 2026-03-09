import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';
import 'bottom_controls.dart';

class VideoArea extends StatefulWidget {
  const VideoArea({super.key});

  @override
  State<VideoArea> createState() => _VideoAreaState();
}

class _VideoAreaState extends State<VideoArea> {
  bool _isScreenRotated = false;

  void _toggleRotation() {
    setState(() {
      _isScreenRotated = !_isScreenRotated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = MeetingService.instance;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Background/Player
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.divider(context).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Obx(() {
                      final screenTrack = service.activeScreenShareTrack.value;
                      final videoTrack = service.activeVideoTrack.value;

                      if (screenTrack != null) {
                        Widget player = VideoTrackRenderer(
                          screenTrack,
                          fit: VideoViewFit.contain,
                        );

                        if (_isScreenRotated) {
                          player = RotatedBox(
                            quarterTurns: 1, // 90 degree rotation
                            child: player,
                          );
                        }

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: _toggleRotation,
                              child: player,
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: GestureDetector(
                                onTap: _toggleRotation,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.screen_rotation_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (videoTrack != null) {
                        return VideoTrackRenderer(
                          videoTrack,
                          fit: VideoViewFit.cover,
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppTheme.accentGradient,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Text(
                                'U',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            service.isCameraOn.value
                                ? 'Camera is on'
                                : 'Camera is off',
                            style: TextStyle(
                              color: AppTheme.textSecondary(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Floating Bottom Controls
            Obx(() {
              // We only want the bottom controls to rotate if the screen share
              // is active AND the user has toggled the rotation button.
              final hasScreenShare =
                  service.activeScreenShareTrack.value != null;
              final shouldRotateControls = hasScreenShare && _isScreenRotated;

              Widget controls = const BottomControls();

              if (shouldRotateControls) {
                controls = RotatedBox(quarterTurns: 1, child: controls);
              }

              return Positioned(
                bottom: shouldRotateControls
                    ? null
                    : 24, // Reset bottom if rotated
                left: shouldRotateControls ? 24 : 0, // Snap left if rotated
                right: shouldRotateControls ? null : 0,
                child: controls,
              );
            }),
          ],
        ),
      ),
    );
  }
}
