import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hearth_prayer/models/journal_entry.dart';
import 'package:hearth_prayer/services/journal_service.dart';
import 'package:hearth_prayer/components/top_nav_bar.dart';
import 'package:hearth_prayer/screens/edit_journal_entry_screen.dart';

class JournalEntryDetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const JournalEntryDetailScreen({super.key, required this.entry});

  @override
  State<JournalEntryDetailScreen> createState() => _JournalEntryDetailScreenState();
}

class _JournalEntryDetailScreenState extends State<JournalEntryDetailScreen> {
  late JournalEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final dateStr = DateFormat('EEE • d MMM y').format(_entry.createdAt);

    return Scaffold(
      backgroundColor: t.colorScheme.background,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            TopNavBar(
              title: dateStr,
              showBack: true,
              inBody: false,
              onBack: () => Navigator.of(context).maybePop(),
              rightAction: Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<_JournalMenuAction>(
                  icon: Icon(Icons.more_vert, color: t.colorScheme.secondary),
                  onSelected: (value) async {
                    switch (value) {
                      case _JournalMenuAction.edit:
                        await _handleEdit();
                        break;
                      case _JournalMenuAction.delete:
                        _showDeleteConfirmation();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _JournalMenuAction.edit,
                      child: Text('Edit entry'),
                    ),
                    PopupMenuItem(
                      value: _JournalMenuAction.delete,
                      child: Text(
                        'Delete entry',
                        style: TextStyle(color: t.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Moods if any
              if (_entry.moods.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: _entry.moods.take(3).map((mood) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: t.colorScheme.surface,
                      border: Border.all(
                        color: t.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mood,
                      style: t.textTheme.labelSmall?.copyWith(
                        color: t.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Blessings
              if (_entry.blessings.isNotEmpty)
                _buildSection(t, 'Blessings I noticed today', _entry.blessings),
              
              // Weights
              if (_entry.weights.isNotEmpty)
                _buildSection(t, 'What weighed on my heart today', _entry.weights),
              
              // Challenges
              if (_entry.challenges.isNotEmpty)
                _buildSection(t, 'Challenges I faced today', _entry.challenges),
              
              // Duʿā
              if (_entry.dua.isNotEmpty) ...[
                Text(
                  'My duʿā for today',
                  style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: t.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: t.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _entry.dua,
                    style: t.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Reminder
              if (_entry.reminder.isNotEmpty) ...[
                Text(
                  'A reminder to myself',
                  style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  _entry.reminder,
                  style: t.textTheme.titleSmall,
                ),
                const SizedBox(height: 24),
              ],

              // Bottom action buttons removed in favor of top-right overflow menu
            ],
          ),
        ),
      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData t, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: t.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: t.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12, top: 4),
                      child: Text(
                        '•',
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: t.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: t.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showDeleteConfirmation() {
    final t = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Delete this entry?',
              style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'This will permanently remove this journal entry.',
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: t.colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await JournalService.deleteEntry(_entry.id);
                  if (!mounted) return;
                  Navigator.of(context).pop(); // Close bottom sheet
                  Navigator.of(context).pop(); // Close detail screen
                  Navigator.of(context).pop(); // Go back to history
                },
                child: Text(
                  'Delete',
                  style: t.textTheme.labelLarge?.copyWith(
                    color: t.colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: t.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleEdit() async {
    // Navigate to edit screen; refresh on return if updated (same logic as original button)
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditJournalEntryScreen(entryId: _entry.id),
      ),
    );
    if (updated == true) {
      final latest = JournalService.getEntry(_entry.id);
      if (latest != null && mounted) {
        setState(() {
          _entry = latest;
        });
      }
    }
  }
}

enum _JournalMenuAction { edit, delete }
