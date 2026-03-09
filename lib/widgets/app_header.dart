import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.divider(context).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // ── Profile Avatar ──
              GestureDetector(
                onTap: () {
                  // E.g. open profile or settings drawer
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentPurple.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'MI', // In a real app, this would be the user's initials
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentPurple,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ── Search Bar ──
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.cardAlt(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.divider(context).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppTheme.textSecondary(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search', // Non-functional placeholder for UI purposes
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary(
                              context,
                            ).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // ── Action / Notifications ──
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.textSecondary(context),
                  size: 24,
                ),
                onPressed: () {},
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60); // Standard header height including safe area
}
