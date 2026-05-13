import 'package:flutter/material.dart';

class UserInitialsLogoButton extends StatelessWidget {
  final String? displayName;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? borderColor;
  final Color textColor;

  const UserInitialsLogoButton({
    super.key,
    required this.onPressed,
    this.displayName,
    this.gradient,
    this.borderColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getUserInitials(displayName);

    return IconButton(
      icon: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.25),
          ),
          gradient: gradient ??
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C5FDD), Color(0xFF4B2FA4)],
              ),
        ),
        child: Text(
          initials,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      onPressed: onPressed,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }

  String _getUserInitials(String? value) {
    final trimmedName = value?.trim();
    if (trimmedName == null || trimmedName.isEmpty) return 'U';

    final nameParts = trimmedName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (nameParts.isEmpty) return 'U';

    final firstInitial = nameParts.first[0];
    final lastInitial = nameParts.length > 1 ? nameParts.last[0] : '';
    return '$firstInitial$lastInitial'.toUpperCase();
  }
}
