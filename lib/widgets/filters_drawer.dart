import 'package:flutter/material.dart';

class FiltersDrawer extends StatefulWidget {
  final List<String> allTags;
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onTagsChanged;
  final DateTimeRange? range;
  final ValueChanged<DateTimeRange?> onRangeChanged;

  const FiltersDrawer({
    required this.allTags,
    required this.selectedTags,
    required this.onTagsChanged,
    this.range,
    required this.onRangeChanged,
  });

  @override
  State<FiltersDrawer> createState() => _FiltersDrawerState();
}

class _FiltersDrawerState extends State<FiltersDrawer> {
  late Set<String> _localSelectedTags;
  late DateTimeRange? _localRange;

  @override
  void initState() {
    super.initState();
    _localSelectedTags = Set.from(widget.selectedTags);
    _localRange = widget.range;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline),
          ),
        ),
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Filters',
              style: theme.textTheme.headlineLarge,
            ),
            SizedBox(height: 24),
            Text(
              'Tags',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.allTags.map((tag) {
                final isSelected = _localSelectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _localSelectedTags.add(tag);
                      } else {
                        _localSelectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Text(
              'Date Range',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            ListTile(
              title: Text(
                _localRange == null
                  ? 'Select date range'
                  : '${_localRange!.start.toString().split(' ')[0]} - ${_localRange!.end.toString().split(' ')[0]}',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _localRange,
                );
                if (picked != null) {
                  setState(() {
                    _localRange = picked;
                  });
                }
              },
            ),
            if (_localRange != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _localRange = null;
                  });
                },
                child: Text('Clear date range'),
              ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    widget.onTagsChanged(_localSelectedTags);
                    widget.onRangeChanged(_localRange);
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
