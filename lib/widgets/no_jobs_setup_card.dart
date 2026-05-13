import 'package:flutter/material.dart';

class NoJobsSetupCard extends StatelessWidget {
  final VoidCallback onSetupPressed;
  final Color accentColor;
  final Color accentEndColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color mutedTextColor;
  final Color buttonTextColor;

  const NoJobsSetupCard({
    super.key,
    required this.onSetupPressed,
    this.accentColor = const Color(0xFF7C5FDD),
    this.accentEndColor = const Color(0xFF5E3FBD),
    this.primaryTextColor = Colors.white,
    this.secondaryTextColor = Colors.white70,
    this.mutedTextColor = Colors.white54,
    this.buttonTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated gradient blob background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accentColor, accentEndColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.work_outline,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Set Up Your Jobs',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Add your jobs with their specific work hours. Tasks will automatically appear based on your active work time.',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                height: 1.6,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Call to Action Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSetupPressed,
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.white.withValues(alpha: 0.1),
                highlightColor: Colors.white.withValues(alpha: 0.05),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accentColor, accentEndColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: buttonTextColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Add Your Jobs',
                        style: TextStyle(
                          color: buttonTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Secondary info text
            Text(
              'You can manage your jobs anytime from the menu',
              style: TextStyle(
                color: mutedTextColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
