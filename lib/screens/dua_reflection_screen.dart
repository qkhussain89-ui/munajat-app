import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';

const poppins = 'Poppins';
final h26w300 = TextStyle(fontFamily: poppins, fontSize: 26, fontWeight: FontWeight.w300, height: 1.3, letterSpacing: 0.01);
final h20w500 = TextStyle(fontFamily: poppins, fontSize: 20, fontWeight: FontWeight.w500, height: 1.3);
final h18w500 = TextStyle(fontFamily: poppins, fontSize: 18, fontWeight: FontWeight.w500, height: 1.3);
final body16w400 = TextStyle(fontFamily: poppins, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
final body14w400 = TextStyle(fontFamily: poppins, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
final meta13w400 = TextStyle(fontFamily: poppins, fontSize: 13, fontWeight: FontWeight.w400);
final meta13w300 = TextStyle(fontFamily: poppins, fontSize: 13, fontWeight: FontWeight.w300);
final meta11w300 = TextStyle(fontFamily: poppins, fontSize: 11, fontWeight: FontWeight.w300);

class DuaSummaryMock {
  final int total;
  final int answered;
  final int pending;
  const DuaSummaryMock({required this.total, required this.answered, required this.pending});
}

class DuaAnsweredMock {
  final String title;
  final String answeredOn;
  final String note;
  const DuaAnsweredMock({required this.title, required this.answeredOn, required this.note});
}

enum DuaReflectionRange { day, week, month, year }

const _summary = DuaSummaryMock(total: 126, answered: 18, pending: 108);
const _recentAnswered = [
  DuaAnsweredMock(
    title: 'Provision for my family',
    answeredOn: '12 Shaʿbān 1446',
    note: 'I made this duʿāʾ during a difficult month. Three weeks later, an unexpected opportunity opened…',
  ),
  DuaAnsweredMock(
    title: 'Healing for my mother',
    answeredOn: '3 Rajab 1446',
    note: 'The doctors said the treatment wasn\'t working, but after many asked me to make duʿāʾ. Today she is recovering well.',
  ),
  DuaAnsweredMock(
    title: 'Clarity in my decision',
    answeredOn: '18 Jumada al-Thani 1446',
    note: 'I was confused about a major life choice. A week after making duʿāʾ, the path became clear.',
  ),
];

const _yearData = [3, 5, 7, 2, 9, 6, 4, 8, 5, 7, 6, 4];
const _monthData = [8, 12, 15, 10];
const _weekData = [5, 8, 6, 9, 7, 10, 8];
const _dayData = [2, 3, 4, 2, 1];

const _yearLabels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
const _monthLabels = ['W1', 'W2', 'W3', 'W4'];
const _weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _dayLabels = ['Fajr', 'Dhuhr', 'ʿAsr', 'Maghrib', 'ʿIshāʾ'];

class DuaReflectionScreen extends StatefulWidget {
  const DuaReflectionScreen({super.key});

  @override
  State<DuaReflectionScreen> createState() => _DuaReflectionScreenState();
}

class _DuaReflectionScreenState extends State<DuaReflectionScreen> {
  DuaReflectionRange _selectedRange = DuaReflectionRange.year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandTokens = context.brandTokens;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with back button
              _buildHeader(context, colorScheme, brandTokens),
              const SizedBox(height: 32),

              // Snapshot Card
              _SnapshotCard(summary: _summary, brandTokens: brandTokens, colorScheme: colorScheme),
              const SizedBox(height: 24),

              // Filter Chips + Activity Chart
              _FilterAndChartSection(
                selectedRange: _selectedRange,
                onRangeChanged: (range) {
                  setState(() => _selectedRange = range);
                },
                brandTokens: brandTokens,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 24),

              // Quick Insights Card
              _QuickInsightsCard(brandTokens: brandTokens, colorScheme: colorScheme),
              const SizedBox(height: 24),

              // Recent Answered Duʿās List
              _RecentAnsweredSection(brandTokens: brandTokens, colorScheme: colorScheme),
              const SizedBox(height: 24),

              // Anchor Verse Card
              _AnchorVerseCard(brandTokens: brandTokens, colorScheme: colorScheme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, BrandTokens brandTokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Semantics(
                label: 'Go back to home',
                button: true,
                child: Icon(Icons.arrow_back, color: colorScheme.primary, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Duʿā Reflection',
              style: h20w500.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Your journey of asking and being answered.',
          style: body14w400.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'A calm space to notice patterns in your duʿāʾ and trust in Allah\'s timing.',
          style: meta13w300.copyWith(color: brandTokens.textMuted),
        ),
      ],
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final DuaSummaryMock summary;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _SnapshotCard({
    required this.summary,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandTokens.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Snapshot',
            style: h18w500.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 24),
          // Total Duʿās
          Text(
            summary.total.toString(),
            style: TextStyle(
              fontFamily: poppins,
              fontSize: 40,
              fontWeight: FontWeight.w300,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duʿās you\'ve recorded so far.',
            style: body14w400.copyWith(color: brandTokens.textMuted),
          ),
          const SizedBox(height: 20),
          // Answered vs Pending
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Answered',
                  value: summary.answered.toString(),
                  brandTokens: brandTokens,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatPill(
                  label: 'Awaiting',
                  value: summary.pending.toString(),
                  brandTokens: brandTokens,
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Reassurance line
          Text(
            'Every answered duʿāʾ is a mercy. Every pending duʿāʾ is a trust.',
            style: body14w400.copyWith(
              color: brandTokens.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _StatPill({
    required this.label,
    required this.value,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brandTokens.border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: poppins,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: meta13w300.copyWith(color: brandTokens.textMuted),
          ),
        ],
      ),
    );
  }
}

class _FilterAndChartSection extends StatelessWidget {
  final DuaReflectionRange selectedRange;
  final Function(DuaReflectionRange) onRangeChanged;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _FilterAndChartSection({
    required this.selectedRange,
    required this.onRangeChanged,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _FilterChip(
              label: 'Day',
              isSelected: selectedRange == DuaReflectionRange.day,
              onTap: () => onRangeChanged(DuaReflectionRange.day),
              brandTokens: brandTokens,
              colorScheme: colorScheme,
            ),
            _FilterChip(
              label: 'Week',
              isSelected: selectedRange == DuaReflectionRange.week,
              onTap: () => onRangeChanged(DuaReflectionRange.week),
              brandTokens: brandTokens,
              colorScheme: colorScheme,
            ),
            _FilterChip(
              label: 'Month',
              isSelected: selectedRange == DuaReflectionRange.month,
              onTap: () => onRangeChanged(DuaReflectionRange.month),
              brandTokens: brandTokens,
              colorScheme: colorScheme,
            ),
            _FilterChip(
              label: 'Year',
              isSelected: selectedRange == DuaReflectionRange.year,
              onTap: () => onRangeChanged(DuaReflectionRange.year),
              brandTokens: brandTokens,
              colorScheme: colorScheme,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Chart Card
        _ActivityChartCard(
          selectedRange: selectedRange,
          brandTokens: brandTokens,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filter duʿāʾ activity by $label',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colorScheme.primary : brandTokens.border,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: meta13w400.copyWith(
              color: isSelected ? Colors.white : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityChartCard extends StatelessWidget {
  final DuaReflectionRange selectedRange;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _ActivityChartCard({
    required this.selectedRange,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    late List<int> data;
    late List<String> labels;
    late String rangeLabel;

    switch (selectedRange) {
      case DuaReflectionRange.day:
        data = _dayData;
        labels = _dayLabels;
        rangeLabel = 'Today (by prayer time)';
        break;
      case DuaReflectionRange.week:
        data = _weekData;
        labels = _weekLabels;
        rangeLabel = 'This week';
        break;
      case DuaReflectionRange.month:
        data = _monthData;
        labels = _monthLabels;
        rangeLabel = 'This month';
        break;
      case DuaReflectionRange.year:
        data = _yearData;
        labels = _yearLabels;
        rangeLabel = 'This year';
        break;
    }

    final maxValue = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b).toDouble() : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandTokens.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duʿāʾ Activity Over Time',
            style: h18w500.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on when you created duʿāʾ cards.',
            style: body14w400.copyWith(color: brandTokens.textMuted),
          ),
          const SizedBox(height: 24),
          // Bar Chart
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(data.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                            child: SizedBox(
                              height: (data[index] / maxValue) * 120,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: meta11w300.copyWith(color: brandTokens.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mock data for now – later this will reflect your real duʿāʾ history.',
            style: meta11w300.copyWith(color: brandTokens.textMuted),
          ),
        ],
      ),
    );
  }
}

class _QuickInsightsCard extends StatelessWidget {
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _QuickInsightsCard({
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandTokens.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patterns in Your Duʿāʾ',
            style: h18w500.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          _InsightLine(
            text: 'You\'ve been most active on Friday evenings.',
            brandTokens: brandTokens,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          _InsightLine(
            text: 'Ramadan was your busiest month for duʿāʾ.',
            brandTokens: brandTokens,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 12),
          _InsightLine(
            text: 'Late night remains your quietest window – a place to gently grow.',
            brandTokens: brandTokens,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _InsightLine extends StatelessWidget {
  final String text;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _InsightLine({
    required this.text,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 12),
          child: Icon(Icons.circle, size: 6, color: colorScheme.primary),
        ),
        Expanded(
          child: Text(
            text,
            style: body14w400.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

class _RecentAnsweredSection extends StatelessWidget {
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _RecentAnsweredSection({
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Answered Duʿās',
          style: h18w500.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          'Moments where you saw Allah\'s generosity clearly.',
          style: body14w400.copyWith(color: brandTokens.textMuted),
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(_recentAnswered.length, (index) {
            final item = _recentAnswered[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index < _recentAnswered.length - 1 ? 12 : 0),
              child: _AnsweredDuaCard(
                title: item.title,
                answeredOn: item.answeredOn,
                note: item.note,
                brandTokens: brandTokens,
                colorScheme: colorScheme,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AnsweredDuaCard extends StatelessWidget {
  final String title;
  final String answeredOn;
  final String note;
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _AnsweredDuaCard({
    required this.title,
    required this.answeredOn,
    required this.note,
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brandTokens.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: body14w400.copyWith(color: colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Answered',
                  style: TextStyle(
                    fontFamily: poppins,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Answered on $answeredOn',
            style: meta13w300.copyWith(color: brandTokens.textMuted),
          ),
          const SizedBox(height: 12),
          Text(
            note,
            style: body14w400.copyWith(color: colorScheme.onSurface),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AnchorVerseCard extends StatelessWidget {
  final BrandTokens brandTokens;
  final ColorScheme colorScheme;

  const _AnchorVerseCard({
    required this.brandTokens,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandTokens.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anchor Verse',
            style: h18w500.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          Text(
            '"Call upon Me; I will respond to you."\n— Qurʾān 40:60',
            style: body16w400.copyWith(
              color: colorScheme.onSurface,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Carry this verse with you today whenever you raise your hands.',
            style: body14w400.copyWith(color: brandTokens.textMuted),
          ),
        ],
      ),
    );
  }
}
