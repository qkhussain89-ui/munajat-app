import 'package:flutter/material.dart';

enum CopperButtonVariant { primary, outline, ghost }
enum CopperButtonSize { sm, md, lg }

class CopperButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final CopperButtonVariant variant;
  final CopperButtonSize size;
  final Widget? icon;
  final bool isLoading;

  const CopperButton({
    required this.label,
    required this.onPressed,
    this.variant = CopperButtonVariant.primary,
    this.size = CopperButtonSize.md,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final textPrimary = theme.colorScheme.onSurface;

    final (padding, fontSize) = _getSizeValues();

    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(padding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    );

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[icon!, SizedBox(width: 8)],
        if (isLoading)
          SizedBox(
            width: fontSize,
            height: fontSize,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Text(label, style: textStyle),
      ],
    );

    switch (variant) {
      case CopperButtonVariant.primary:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(primary),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          child: child,
        );
      case CopperButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            side: WidgetStateProperty.all(BorderSide(color: primary, width: 2)),
            foregroundColor: WidgetStateProperty.all(primary),
          ),
          child: child,
        );
      case CopperButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle.copyWith(
            foregroundColor: WidgetStateProperty.all(primary),
          ),
          child: child,
        );
    }
  }

  (EdgeInsets, double) _getSizeValues() {
    switch (size) {
      case CopperButtonSize.sm:
        return (EdgeInsets.symmetric(horizontal: 12, vertical: 8), 12);
      case CopperButtonSize.md:
        return (EdgeInsets.symmetric(horizontal: 16, vertical: 12), 14);
      case CopperButtonSize.lg:
        return (EdgeInsets.symmetric(horizontal: 24, vertical: 16), 16);
    }
  }
}
