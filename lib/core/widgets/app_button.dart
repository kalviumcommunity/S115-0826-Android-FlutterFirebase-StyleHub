import 'package:flutter/material.dart';
import '../theme/app_constants.dart';

enum AppButtonType { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled = isDisabled || isLoading || onPressed == null;
    final VoidCallback? handlePress = effectivelyDisabled ? null : onPressed;

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.s),
        ],
        Text(text),
      ],
    );

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: handlePress,
          child: buttonChild,
        );
      case AppButtonType.secondary:
        return OutlinedButton(
          onPressed: handlePress,
          child: buttonChild,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: handlePress,
          child: buttonChild,
        );
    }
  }
}
