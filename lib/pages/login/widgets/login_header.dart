import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Logo ──
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.videocam_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Conference',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 30),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to start your meeting',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
