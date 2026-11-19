import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

enum MainTab { inspire, myDuas, create, journal, me }

class BottomNavRefined extends StatelessWidget {
  final MainTab active;
  final ValueChanged<MainTab> onChanged;

  const BottomNavRefined({
    super.key,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brandTokens = context.brandTokens;
    final border = brandTokens.border;
    final bg = t.colorScheme.surface.withValues(alpha: 0.95);

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home (index 0)
                  _NavButton(
                    label: 'Home',
                    icon: Icons.home_outlined,
                    selected: active == MainTab.inspire,
                    onTap: () => onChanged(MainTab.inspire),
                  ),
                  // My Duʿās (index 1)
                  _NavButton(
                    label: 'My Duʿās',
                    icon: Icons.bookmark_border,
                    selected: active == MainTab.myDuas,
                    onTap: () => onChanged(MainTab.myDuas),
                  ),
                  // Create Dua (index 2)
                  _NavButton(
                    label: 'Create Dua',
                    icon: Icons.edit_outlined,
                    selected: active == MainTab.create,
                    onTap: () => onChanged(MainTab.create),
                  ),
                  // Journal (index 3)
                  _NavButton(
                    label: 'Journal',
                    icon: Icons.book_outlined,
                    selected: active == MainTab.journal,
                    onTap: () => onChanged(MainTab.journal),
                  ),
                  // Me (index 4)
                  _NavButton(
                    label: 'Me',
                    icon: Icons.person_outline,
                    selected: active == MainTab.me,
                    onTap: () => onChanged(MainTab.me),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brandTokens = context.brandTokens;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              constraints: const BoxConstraints(minWidth: 70, minHeight: 44),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: selected
                        ? ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (r) => brandTokens.copperGradient
                                .createShader(Rect.fromLTWH(0, 0, r.width, r.height)),
                            child: Icon(icon, size: 24, color: Colors.white),
                          )
                        : Icon(icon, size: 24, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: t.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w400 : FontWeight.w300,
                      color: selected
                          ? t.colorScheme.primary
                          : brandTokens.textMuted.withValues(alpha: 0.7),
                      letterSpacing: 0.01,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: -4,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: brandTokens.copperGradient,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
