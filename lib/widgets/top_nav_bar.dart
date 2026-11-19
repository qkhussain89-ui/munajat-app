import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/tokens.dart';

class TopNavBar extends StatelessWidget {
  final String title;
  final Widget? rightAction;
  final VoidCallback? onBack;
  final bool inBody;

  const TopNavBar({
    required this.title,
    this.rightAction,
    this.onBack,
    this.inBody = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (inBody) {
      return SafeArea(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildContent(theme),
        ),
      );
    } else {
      return PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          child: _buildContent(theme),
        ),
      );
    }
  }

  Widget _buildContent(ThemeData theme) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppTok.copperSolid),
            onPressed: onBack,
          )
        else
          SizedBox(width: 8),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        if (rightAction != null)
          rightAction!
        else
          SizedBox(width: 8),
      ],
    );
  }
}
