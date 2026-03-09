import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/meeting_service.dart';
import '../theme/app_theme.dart';

/// In-app meeting overlay that supports two modes:
///
/// **Full mode** — covers entire screen with meeting controls, video area, etc.
/// **Mini mode** — small draggable card at a screen corner showing status.
///
/// Rendered via [MeetingOverlayManager] as an Overlay entry.
class MeetingOverlay extends StatefulWidget {
  const MeetingOverlay({super.key});

  @override
  State<MeetingOverlay> createState() => _MeetingOverlayState();
}

class _MeetingOverlayState extends State<MeetingOverlay>
    with SingleTickerProviderStateMixin {
  final _service = MeetingService.instance;

  // Mini-window drag position
  double _miniX = double.infinity; // will be set on first build
  double _miniY = double.infinity;
  bool _positioned = false;

  // Animation
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;

  static const double _miniWidth = 160;
  static const double _miniHeight = 100;
  static const double _miniPadding = 16;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _snapToNearestCorner(Size screenSize) {
    final centerX = _miniX + _miniWidth / 2;
    final centerY = _miniY + _miniHeight / 2;
    final midX = screenSize.width / 2;
    final midY = screenSize.height / 2;

    setState(() {
      _miniX = centerX < midX
          ? _miniPadding
          : screenSize.width - _miniWidth - _miniPadding;
      _miniY = centerY < midY
          ? _miniPadding + MediaQuery.of(context).padding.top
          : screenSize.height -
                _miniHeight -
                _miniPadding -
                MediaQuery.of(context).padding.bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Initialize position on first build
    if (!_positioned) {
      _miniX = screenSize.width - _miniWidth - _miniPadding;
      _miniY = screenSize.height - _miniHeight - _miniPadding - 80;
      _positioned = true;
    }

    return Obx(() {
      if (!_service.isInMeeting.value) {
        return const SizedBox.shrink();
      }

      if (_service.isFullScreen.value) {
        return _buildFullScreen(context, screenSize);
      } else {
        return _buildMiniWindow(context, screenSize);
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════
  //  FULL-SCREEN MODE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFullScreen(BuildContext context, Size screenSize) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _service.minimize();
      },
      child: Material(
        color: AppTheme.surface(context),
        child: SafeArea(
          child: Obx(() {
            if (_service.isConnecting.value) {
              return _buildConnecting();
            }
            if (_service.errorMessage.value != null) {
              return _buildError();
            }
            return _buildMeetingUI(context);
          }),
        ),
      ),
    );
  }

  Widget _buildConnecting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.accentPurple,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Joining meeting…',
            style: TextStyle(
              color: AppTheme.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connecting to the conference server',
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 20),
            Text(
              'Connection Failed',
              style: TextStyle(
                color: AppTheme.textPrimary(context),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _service.errorMessage.value ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _service.leaveMeeting,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.divider(context)),
                  ),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: () =>
                      _service.retry("694f949da08d8877589cbdda", "Vivek Kumar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingUI(BuildContext context) {
    return Column(
      children: [
        // ─── Top Bar ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.fiber_manual_record_rounded,
                  color: AppTheme.successGreen,
                  size: 12,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _service.meetingName.isNotEmpty
                      ? _service.meetingName
                      : 'In Meeting',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
              ),
              // Minimize button
              GestureDetector(
                onTap: _service.minimize,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.divider(context).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Icon(
                    Icons.picture_in_picture_alt_rounded,
                    size: 20,
                    color: AppTheme.accentPurple,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.divider(context).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: AppTheme.accentPurple,
                    ),
                    const SizedBox(width: 6),
                    Obx(
                      () => Text(
                        '${_service.participantCount.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ─── Video Area ──────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                  child: Column(
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
                      Obx(
                        () => Text(
                          _service.isCameraOn.value
                              ? 'Camera is on'
                              : 'Camera is off',
                          style: TextStyle(
                            color: AppTheme.textSecondary(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ─── Bottom Controls ─────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: AppTheme.card(context).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: AppTheme.divider(context).withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlBtn(
                  icon: _service.isMicOn.value
                      ? Icons.mic_rounded
                      : Icons.mic_off_rounded,
                  label: _service.isMicOn.value ? 'Mute' : 'Unmute',
                  isActive: _service.isMicOn.value,
                  onTap: _service.toggleMic,
                ),
                _buildControlBtn(
                  icon: _service.isCameraOn.value
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  label: 'Camera',
                  isActive: _service.isCameraOn.value,
                  onTap: _service.toggleCamera,
                ),
                _buildControlBtn(
                  icon: Icons.screen_share_rounded,
                  label: 'Share',
                  isActive: _service.isScreenSharing.value,
                  onTap: _service.toggleScreenShare,
                  activeColor: AppTheme.accentPurple,
                ),
                _buildControlBtn(
                  icon: Icons.groups_rounded,
                  label: 'Team',
                  isActive: false,
                  onTap: () {},
                ),
                _buildLeaveBtn(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  MINI-WINDOW MODE
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMiniWindow(BuildContext context, Size screenSize) {
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
              left: _miniX,
              top: _miniY,
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    _miniX = (_miniX + d.delta.dx).clamp(
                      0.0,
                      screenSize.width - _miniWidth,
                    );
                    _miniY = (_miniY + d.delta.dy).clamp(
                      0.0,
                      screenSize.height - _miniHeight,
                    );
                  });
                },
                onPanEnd: (_) => _snapToNearestCorner(screenSize),
                onTap: _service.maximize,
                child: _buildMiniCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: _miniWidth,
          height: _miniHeight,
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
                          _service.meetingName.isNotEmpty
                              ? _service.meetingName
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
                        onTap: _service.leaveMeeting,
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
                        _service.isMicOn.value
                            ? Icons.mic_rounded
                            : Icons.mic_off_rounded,
                        size: 14,
                        color: _service.isMicOn.value
                            ? AppTheme.textSecondary(context)
                            : AppTheme.errorRed,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _service.isCameraOn.value
                            ? Icons.videocam_rounded
                            : Icons.videocam_off_rounded,
                        size: 14,
                        color: _service.isCameraOn.value
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
                        '${_service.participantCount.value}',
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

  // ═══════════════════════════════════════════════════════════════
  //  SHARED BUTTON BUILDERS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppTheme.textPrimary(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive
                  ? (activeColor ?? AppTheme.cardAlt(context)).withValues(
                      alpha: 0.25,
                    )
                  : AppTheme.cardAlt(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? color.withValues(alpha: 0.4)
                    : AppTheme.divider(context).withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? color : AppTheme.textSecondary(context),
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBtn() {
    return GestureDetector(
      onTap: _service.leaveMeeting,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.errorRed,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorRed.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Leave',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}
