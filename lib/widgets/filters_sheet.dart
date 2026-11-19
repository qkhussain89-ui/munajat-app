import 'package:flutter/material.dart';

class FiltersSheet extends StatefulWidget {
  final List<String> allTags;
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onTagsChanged;
  final DateTimeRange? range;
  final ValueChanged<DateTimeRange?> onRangeChanged;

  const FiltersSheet({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onTagsChanged,
    required this.range,
    required this.onRangeChanged,
  });

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late Set<String> _tempTags;
  late DateTimeRange? _tempRange;

  @override
  void initState() {
    super.initState();
    _tempTags = {...widget.selectedTags};
    _tempRange = widget.range;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Advanced Filters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.allTags.map((tag) {
                final selected = _tempTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (val) => setState(() {
                    if (val) {
                      _tempTags.add(tag);
                    } else {
                      _tempTags.remove(tag);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDateRange: _tempRange,
                );
                if (range != null) {
                  setState(() => _tempRange = range);
                }
              },
              child: Text(_tempRange == null
                  ? 'Select Date Range'
                  : '${_tempRange!.start.toString().split(' ')[0]} - ${_tempRange!.end.toString().split(' ')[0]}'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTagsChanged(_tempTags);
                      widget.onRangeChanged(_tempRange);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
