import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hearth_prayer/services/journal_service.dart';
import 'package:hearth_prayer/screens/journal_entry_detail_screen.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brandTokens = context.brandTokens;
    final entries = JournalService.entries;

    return Scaffold(
      backgroundColor: t.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row: back button | centered title | spacer
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 22,
                            color: t.colorScheme.secondary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          tooltip: 'Back',
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => brandTokens.copperGradient.createShader(bounds),
                            child: Text(
                              'My Journal Log',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                height: 1.3,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Entry list
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (entries.isEmpty)
                      _buildEmptyState(context, t)
                    else ...[
                      Column(
                        children: List.generate(
                          entries.length,
                          (index) => _buildEntryCard(context, t, entries[index]),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData t) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.note_outlined,
          size: 64,
          color: t.colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'No entries yet.',
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your reflections will appear here after you save your first journal entry.',
          style: t.textTheme.bodyMedium?.copyWith(
            color: t.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: t.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Write today\'s journal',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildEntryCard(BuildContext context, ThemeData t, dynamic entry) {
    final dateStr = DateFormat('d MMM y • EEE').format(entry.createdAt);
    final moods = entry.moods.take(3).toList();
    
    // Get snapshot line
    final snapshot = entry.blessings.isNotEmpty
        ? 'Blessing: ${entry.blessings.first}'
        : entry.weights.isNotEmpty
            ? 'Weight: ${entry.weights.first}'
            : entry.challenges.isNotEmpty
                ? 'Challenge: ${entry.challenges.first}'
                : entry.dua.isNotEmpty
                    ? 'Duʿā: ${entry.dua}'
                    : '';

    // Build metrics
    final metrics = [
      if (entry.blessings.isNotEmpty) '${entry.blessings.length} blessing${entry.blessings.length > 1 ? 's' : ''}',
      if (entry.weights.isNotEmpty) '${entry.weights.length} weight${entry.weights.length > 1 ? 's' : ''}',
      if (entry.challenges.isNotEmpty) '${entry.challenges.length} challenge${entry.challenges.length > 1 ? 's' : ''}',
    ].join(' • ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => JournalEntryDetailScreen(entry: entry),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: t.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: t.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Text(
                dateStr,
                style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              
              // Moods if any
              if (moods.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: moods.map<Widget>((mood) => Container(
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
                const SizedBox(height: 12),
              ],

              // Snapshot
              if (snapshot.isNotEmpty)
                Text(
                  snapshot,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodyMedium,
                ),
              
              // Metrics
              if (metrics.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  metrics,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: t.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],

              // Chevron
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  color: t.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
