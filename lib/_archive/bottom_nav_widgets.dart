import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItem(Icons.home_outlined, 'Home'),
      _NavItem(Icons.edit_outlined, 'Create'),
      _NavItem(Icons.bookmark_border, 'My Duʿās'),
      _NavItem(Icons.person_outline, 'Me'),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xF2191919),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: T.border, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  final active = i == currentIndex;
                  final item = items[i];
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTap(i),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (active)
                              Container(
                                width: 32,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: T.copperGradient,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            if (active) const SizedBox(height: 4),
                            Icon(item.icon,
                              size: 24,
                              color: active ? T.copperSolid : T.textMuted.withValues(alpha: 0.7)),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: active ? FontWeight.w400 : FontWeight.w300,
                                color: active ? T.copperEnd : T.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
