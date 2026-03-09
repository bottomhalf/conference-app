import 'package:flutter/material.dart';
import '../../services/meeting_service.dart';
import '../../theme/app_theme.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MeetingService.instance;

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
              service.errorMessage.value ?? 'Unknown error',
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
                  onPressed: service.leaveMeeting,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.divider(context)),
                  ),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: () =>
                      service.retry("694f949da08d8877589cbdda", "Vivek Kumar"),
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
}
