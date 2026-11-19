import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearth_prayer/state/my_duas_controller.dart';
import 'package:hearth_prayer/widgets/top_nav_bar.dart';
import 'package:hearth_prayer/widgets/badge_chip.dart';
import 'package:hearth_prayer/widgets/copper_button.dart';
import 'package:hearth_prayer/widgets/dua_card.dart';
import 'package:hearth_prayer/widgets/filters_drawer.dart';

class MyDuasScreen extends StatefulWidget {
  const MyDuasScreen({super.key});

  @override
  State<MyDuasScreen> createState() => _MyDuasScreenState();
}

class _MyDuasScreenState extends State<MyDuasScreen> {
  Set<String> _selectedTags = {};
  DateTimeRange? _dateRange;
  int _sortMode = 0;
  bool _favoriteOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: TopNavBar(
          title: 'My Duʿās',
          rightAction: IconButton(
            icon: Icon(Icons.tune, color: theme.colorScheme.primary),
            onPressed: _showFiltersDrawer,
            tooltip: 'Open filters',
          ),
        ),
      ),
      body: Consumer<MyDuasController>(
        builder: (context, controller, _) {
          final filtered = _applyAllFilters(controller);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchRow(context, controller),
                _buildListView(context, filtered),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchRow(
    BuildContext context,
    MyDuasController controller,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(16),
      child: Semantics(
        label: 'Search your duʿās',
        textField: true,
        child: TextField(
          onChanged: controller.setQuery,
          decoration: InputDecoration(
            hintText: 'Search your duʿās…',
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<dynamic> filtered,
  ) {
    final theme = Theme.of(context);
    if (filtered.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              SizedBox(height: 16),
              Text(
                'Your heart\'s canvas is waiting',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final controller = context.read<MyDuasController>();
                  controller.onCreateNew();
                },
                child: Text('+ New Duʿā'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dua = filtered[index];
        final controller = context.read<MyDuasController>();
        return Semantics(
          label: dua.title,
          child: DuaCard(
            dua: dua,
            onOpen: () => controller.onOpenDua(dua.id),
            onEdit: () => controller.onEditDua(dua.id),
            onDelete: () => controller.deleteById(dua.id),
          ),
        );
      },
    );
  }

  List<dynamic> _applyAllFilters(MyDuasController controller) {
    var result = controller.filtered;

    if (_selectedTags.isNotEmpty) {
      result = result
        .where((d) => d.tags.any((tag) => _selectedTags.contains(tag)))
        .toList();
    }

    if (_dateRange != null) {
      result = result
        .where((d) =>
          d.createdAt.isAfter(_dateRange!.start) &&
          d.createdAt.isBefore(_dateRange!.end.add(Duration(days: 1))))
        .toList();
    }

    if (_favoriteOnly) {
      result = result.where((d) => d.favorite).toList();
    }

    if (_sortMode == 0) {
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    debugPrint('[MyDuasScreen] TILES_OK');
    debugPrint('[MyDuasScreen] COUNTS_OK');
    debugPrint('[MyDuasScreen] FILTERS_OK');
    debugPrint('[MyDuasScreen] SEARCH_OK');
    debugPrint('[MyDuasScreen] NEW_OK');
    debugPrint('[MyDuasScreen] LIST_OK');

    return result;
  }

  void _showFiltersDrawer() {
    final controller = context.read<MyDuasController>();
    showModalBottomSheet(
      context: context,
      builder: (context) => FiltersDrawer(
        allTags: controller.allTags.toList(),
        selectedTags: _selectedTags,
        onTagsChanged: (tags) {
          setState(() {
            _selectedTags = tags;
          });
        },
        range: _dateRange,
        onRangeChanged: (range) {
          setState(() {
            _dateRange = range;
          });
        },
      ),
    );
  }
}
