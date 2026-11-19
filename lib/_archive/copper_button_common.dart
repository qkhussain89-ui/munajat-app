import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/tokens.dart' as tokens;

enum CopperButtonVariant { primary, outline, ghost }
enum CopperButtonSize { sm, md, lg }

class CopperButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final CopperButtonVariant variant;
  final CopperButtonSize size;

  const CopperButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = CopperButtonVariant.primary,
    this.size = CopperButtonSize.md,
  });

  EdgeInsets get _pad {
    switch (size) {
      case CopperButtonSize.sm: return const EdgeInsets.symmetric(horizontal:16,vertical:10);
      case CopperButtonSize.md: return const EdgeInsets.symmetric(horizontal:20,vertical:12);
      case CopperButtonSize.lg: return const EdgeInsets.symmetric(horizontal:24,vertical:14);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    BoxDecoration deco;
    Color fg;
    switch (variant) {
      case CopperButtonVariant.primary:
        deco = BoxDecoration(gradient: tokens.AppTok.copperGradient, borderRadius: radius);
        fg = Colors.white;
        break;
      case CopperButtonVariant.outline:
        deco = BoxDecoration(
          border: const Border.fromBorderSide(BorderSide(color: tokens.AppTok.copperSolid,width:2)),
          borderRadius: radius,
        );
        fg = tokens.AppTok.copperSolid;
        break;
      case CopperButtonVariant.ghost:
        deco = BoxDecoration(borderRadius: radius);
        fg = tokens.AppTok.copperSolid;
        break;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds:150),
      opacity: onPressed==null?0.6:1,
      child: InkWell(
        borderRadius: radius,
        onTap: onPressed,
        child: Ink(
          decoration: deco,
          child: Padding(
            padding: _pad,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: fg,fontWeight: FontWeight.w500),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
