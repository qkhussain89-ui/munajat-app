import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearth_prayer/models/dua.dart';
import 'package:hearth_prayer/widgets/badge_chip.dart';
import 'package:hearth_prayer/state/app_state.dart';

class DuaCard extends StatefulWidget {
  final Dua dua;
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(Dua)? onTap;
  final VoidCallback? onMenu;

  const DuaCard({
    required this.dua,
    this.onOpen,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.onMenu,
  });

  @override
  State<DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends State<DuaCard>
  with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final muted = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Consumer<AppState>(
      builder: (context, appState, _) {
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero)
              .animate(_animation),
            child: GestureDetector(
              onTap: widget.onTap != null ? () => widget.onTap!(widget.dua) : widget.onOpen,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.dua.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: primary,
                            ),
                          ),
                        ),
                        // Status icon indicator (awaiting ⏳ vs answered ✓)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 4),
                          child: Icon(
                            widget.dua.isAnswered ? Icons.check_circle : Icons.hourglass_empty,
                            size: 18,
                            color: widget.dua.isAnswered
                                ? primary
                                : onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        if (widget.onMenu != null)
                          IconButton(
                            icon: Icon(Icons.more_vert, color: onSurfaceVariant),
                            onPressed: () => widget.onMenu!(),
                            tooltip: 'More',
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.dua.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * appState.fontSizeMultiplier,
                        fontFamily: 'Poppins',
                        color: onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.dua.tags.map((tag) {
                        return BadgeChip(
                          label: tag,
                          variant: BadgeChipVariant.secondary,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(widget.dua.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            color: muted,
                          ),
                        ),
                        if (widget.dua.isNew())
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Duʿā?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          if (widget.onDelete != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete!();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
