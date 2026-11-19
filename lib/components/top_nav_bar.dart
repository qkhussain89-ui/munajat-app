import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/tokens.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? rightAction;
  final bool transparent;
  final bool inBody;

  const TopNavBar({
    super.key,
    this.title,
    this.showBack = false,
    this.onBack,
    this.rightAction,
    this.transparent = false,
    this.inBody = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final bt = context.brandTokens;

    final content = Container(
      height: 56,
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(
          bottom: BorderSide(
            color: bt.border.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: showBack
                ? IconButton(
                    onPressed: () {
                      if (onBack != null) {
                        onBack!.call();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: cs.secondary,
                    ),
                    tooltip: 'Back',
                  )
                : null,
          ),
          Expanded(
            child: title != null
                ? Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => bt.copperGradient.createShader(bounds),
                      child: Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          SizedBox(
            width: 44,
            child: rightAction ?? const SizedBox.shrink(),
          ),
        ],
      ),
    );

    if (inBody) {
      return Padding(
        padding: const EdgeInsets.only(top: 44),
        child: content,
      );
    } else {
      return content;
    }
  }
}
