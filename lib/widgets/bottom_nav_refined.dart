import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/munajat_theme.dart';

class BottomNavRefined extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavRefined({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copper = theme.extension<CopperGradient>();
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
        color: theme.scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          items: [
            _buildNavItem(Icons.home_outlined, 'Home', 0, copper),
            _buildNavItem(Icons.add_circle_outline, 'Create', 1, copper),
            _buildNavItem(Icons.bookmark_outline, 'My Duʿās', 2, copper),
            _buildNavItem(Icons.person_outline, 'Me', 3, copper),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
    CopperGradient? copper,
  ) =>
    BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          if (currentIndex == index && copper != null)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: copper.copperGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Icon(
            icon,
            size: 24,
            color: currentIndex == index ? _iconColor : Colors.grey,
          ),
        ],
      ),
      label: label,
    );

  Color get _iconColor => Colors.amber[700] ?? Colors.amber;
}
