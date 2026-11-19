import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CopperButtonVariant { primary, outline, ghost }
enum CopperButtonSize { sm, md, lg }

class CopperButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final CopperButtonVariant variant;
  final CopperButtonSize size;
  final IconData? leadingIcon;
  final bool isLoading;
  final double? width;

  const CopperButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = CopperButtonVariant.primary,
    this.size = CopperButtonSize.md,
    this.leadingIcon,
    this.isLoading = false,
    this.width,
  });

  @override
  State<CopperButton> createState() => _CopperButtonState();
}

class _CopperButtonState extends State<CopperButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    late EdgeInsetsGeometry padding;
    late double fontSize;

    switch (widget.size) {
      case CopperButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        fontSize = 12;
        break;
      case CopperButtonSize.md:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        fontSize = 14;
        break;
      case CopperButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
        fontSize = 16;
        break;
    }

    late Color backgroundColor;
    late Color textColor;
    Color? borderColor;
    double borderWidth = 1.0;

    switch (widget.variant) {
      case CopperButtonVariant.primary:
        if (!isEnabled) {
          backgroundColor = isDark 
              ? const Color(0xFFB87333).withValues(alpha: 0.08)
              : const Color(0xFFB87333).withValues(alpha: 0.05);
          textColor = isDark 
              ? const Color(0xFFD4A574).withValues(alpha: 0.4)
              : const Color(0xFF8B5E3C).withValues(alpha: 0.4);
          borderColor = isDark 
              ? const Color(0xFFD4A574).withValues(alpha: 0.2)
              : const Color(0xFFB87333).withValues(alpha: 0.2);
        } else if (isDark) {
          backgroundColor = _isPressed
              ? const Color(0xFFB87333).withValues(alpha: 0.25)
              : const Color(0xFFB87333).withValues(alpha: 0.15);
          textColor = const Color(0xFFD4A574);
          borderColor = _isPressed
              ? const Color(0xFFD4A574).withValues(alpha: 0.8)
              : const Color(0xFFD4A574).withValues(alpha: 0.5);
        } else {
          backgroundColor = _isPressed
              ? const Color(0xFFB87333).withValues(alpha: 0.18)
              : const Color(0xFFB87333).withValues(alpha: 0.10);
          textColor = const Color(0xFF8B5E3C);
          borderColor = _isPressed
              ? const Color(0xFF8B5E3C).withValues(alpha: 0.7)
              : const Color(0xFFB87333).withValues(alpha: 0.4);
        }
        borderWidth = 1.5;
        break;

      case CopperButtonVariant.outline:
        if (!isEnabled) {
          backgroundColor = Colors.transparent;
          textColor = isDark 
              ? const Color(0xFFE8E0D6).withValues(alpha: 0.3)
              : const Color(0xFF5A4A3A).withValues(alpha: 0.3);
          borderColor = isDark 
              ? const Color(0xFFE8E0D6).withValues(alpha: 0.1)
              : const Color(0xFF64503C).withValues(alpha: 0.1);
        } else if (isDark) {
          backgroundColor = _isPressed
              ? const Color(0xFFE8E0D6).withValues(alpha: 0.05)
              : Colors.transparent;
          textColor = const Color(0xFFE8E0D6).withValues(alpha: 0.7);
          borderColor = _isPressed
              ? const Color(0xFFE8E0D6).withValues(alpha: 0.4)
              : const Color(0xFFE8E0D6).withValues(alpha: 0.2);
        } else {
          backgroundColor = _isPressed
              ? const Color(0xFF64503C).withValues(alpha: 0.05)
              : Colors.transparent;
          textColor = const Color(0xFF5A4A3A);
          borderColor = _isPressed
              ? const Color(0xFF64503C).withValues(alpha: 0.4)
              : const Color(0xFF64503C).withValues(alpha: 0.2);
        }
        borderWidth = 1.0;
        break;

      case CopperButtonVariant.ghost:
        if (!isEnabled) {
          backgroundColor = Colors.transparent;
          textColor = isDark 
              ? const Color(0xFFD4A574).withValues(alpha: 0.4)
              : const Color(0xFF8B5E3C).withValues(alpha: 0.4);
          borderColor = null;
        } else if (isDark) {
          backgroundColor = _isPressed
              ? const Color(0xFFB87333).withValues(alpha: 0.08)
              : Colors.transparent;
          textColor = const Color(0xFFD4A574);
          borderColor = null;
        } else {
          backgroundColor = _isPressed
              ? const Color(0xFF8B5E3C).withValues(alpha: 0.06)
              : Colors.transparent;
          textColor = const Color(0xFF8B5E3C);
          borderColor = null;
        }
        break;
    }

    return GestureDetector(
      onTapDown: isEnabled ? _onTapDown : null,
      onTapUp: isEnabled ? _onTapUp : null,
      onTapCancel: isEnabled ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: widget.width,
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: borderColor != null 
                    ? Border.all(color: borderColor, width: borderWidth)
                    : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(textColor),
                          ),
                        )
                      else if (widget.leadingIcon != null) ...[
                        Icon(
                          widget.leadingIcon,
                          color: textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: GoogleFonts.poppins(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
