import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/tokens.dart' as tokens;

class MunajatBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const MunajatBottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _Item(Icons.home_outlined, 'Home'),
      _Item(Icons.edit_outlined, 'Create'),
      _Item(Icons.bookmark_border, 'My Duʿās'),
      _Item(Icons.person_outline, 'Me'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF2191919),
          border: Border(
            top: BorderSide(color: tokens.AppTok.border),
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final active = i == index;
            return _NavButton(
              item: items[i],
              active: active,
              onTap: () => onTap(i),
            );
          }),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  const _Item(this.icon, this.label);
}

class _NavButton extends StatelessWidget {
  final _Item item;
  final bool active;
  final VoidCallback onTap;
  const _NavButton({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topGlow = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 4,
      width: active ? 32 : 0,
      decoration: BoxDecoration(
        gradient: active ? tokens.AppTok.copperGradient : null,
        borderRadius: BorderRadius.circular(999),
      ),
    );

    return InkResponse(
      onTap: onTap,
      highlightShape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            topGlow,
            const SizedBox(height: 6),
            Icon(
              item.icon,
              size: 24,
              color: active
                  ? tokens.AppTok.copperSolid
                  : tokens.AppTok.textMuted.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w400 : FontWeight.w300,
                color: active
                    ? tokens.AppTok.copperEnd
                    : tokens.AppTok.textMuted.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
