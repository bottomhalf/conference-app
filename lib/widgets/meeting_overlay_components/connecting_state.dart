import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ConnectingState extends StatelessWidget {
  const ConnectingState({super.key});

  @override
  Widget build(BuildContext context) {
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
}
