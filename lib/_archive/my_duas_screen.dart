import 'package:flutter/material.dart';
import 'package:hearth_prayer/models/dua.dart';
import 'dua_folder.dart';
import 'package:hearth_prayer/theme/tokens.dart';
import 'package:hearth_prayer/widgets/dua_card.dart';
import 'package:hearth_prayer/widgets/copper_chip.dart';

enum SortOption { recent, oldest, az, za, favorites }

class MyDuasScreen extends StatefulWidget {
  const MyDuasScreen({super.key});

  @override
  State<MyDuasScreen> createState() => _MyDuasScreenState();
}

class _MyDuasScreenState extends State<MyDuasScreen> {
  late List<Dua> all;
  late List<DuaFolder> folders;
  String? _selectedFolderId;
  final Set<String> _selectedCats = {};
  late TextEditingController _search;
  SortOption _sort = SortOption.recent;

  static const _categoryLabel = {
    'health': 'Health',
    'rizq': 'Rizq',
    'family': 'Family',
    'guidance': 'Guidance',
    'gratitude': 'Gratitude',
    'strength': 'Strength',
  };

  static const _categoryOrder = ['health', 'rizq', 'family', 'guidance', 'gratitude', 'strength'];

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    
    folders = List.of([
      DuaFolder(id: 'gratitude', name: 'Gratitude', icon: '🎃', count: 0),
    ]);

    all = List.of([
      Dua(
        id: '1',
        title: 'For Family\'s Health and Wellness',
        preview: 'Al-hamdu lilláhi rabbil-álamin. O Allah, the Most Merciful, grant my...',
        body: 'Al-hamdu lilláhi rabbil-álamin. O Allah, the Most Merciful, grant my...',
        englishText: 'Al-hamdu lilláhi rabbil-álamin. O Allah, the Most Merciful, grant my family health and strength.',
        tags: ['Health', 'Family'],
        createdAt: DateTime(2025, 10, 29),
        updatedAt: DateTime(2025, 10, 29),
        userId: 'user1',
      ),
      Dua(
        id: '2',
        title: 'Seeking Divine Guidance',
        preview: 'O Most Merciful, guide me toward Your straight path. Illuminate my...',
        body: 'O Most Merciful, guide me toward Your straight path. Illuminate my...',
        englishText: 'O Most Merciful, guide me toward Your straight path. Illuminate my steps with Your wisdom and light.',
        tags: ['Guidance'],
        createdAt: DateTime(2025, 10, 28),
        updatedAt: DateTime(2025, 10, 28),
        userId: 'user1',
      ),
      Dua(
        id: '3',
        title: 'Blessings O Allah, You have given m...',
        preview: 'Blessings O Allah, You have given me so much. Grant me gratitude for all Your mercies.',
        body: 'Blessings O Allah, You have given me so much...',
        englishText: 'Blessings O Allah, You have given me so much. Grant me gratitude for all Your mercies.',
        tags: ['Gratitude'],
        isBookmarked: true,
        folderId: 'gratitude',
        createdAt: DateTime(2025, 10, 27),
        updatedAt: DateTime(2025, 10, 27),
        userId: 'user1',
      ),
    ]);

    _recalcFolderCounts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _recalcFolderCounts() {
    for (var f in folders) {
      f.count = all.where((d) => d.folderId == f.id).length;
    }
  }

  List<Dua> _filtered() {
    List<Dua> result = List.of(all);

    final q = _search.text.toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((d) =>
        d.title.toLowerCase().contains(q) ||
        d.englishText.toLowerCase().contains(q) ||
        d.body.toLowerCase().contains(q)
      ).toList();
    }

    if (_selectedCats.isNotEmpty) {
      result = result.where((d) =>
        d.tags.any((tag) => _selectedCats.contains(tag.toLowerCase()))
      ).toList();
    }

    if (_selectedFolderId != null) {
      result = result.where((d) => d.folderId == _selectedFolderId).toList();
    }

    result = List.of(result);
    switch (_sort) {
      case SortOption.recent:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case SortOption.oldest:
        result.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      case SortOption.az:
        result.sort((a, b) => a.title.compareTo(b.title));
      case SortOption.za:
        result.sort((a, b) => b.title.compareTo(a.title));
      case SortOption.favorites:
        result.sort((a, b) => (b.isBookmarked ? 1 : 0).compareTo(a.isBookmarked ? 1 : 0));
    }

    return result;
  }

  // Archived methods - no longer in use
  void _openPreview(Dua d) {}
  void _edit(Dua d) {}

  void _duplicate(Dua d) {
    final copy = d.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isBookmarked: false,
    );
    setState(() {
      all.add(copy);
      _recalcFolderCounts();
    });
  }

  void _delete(Dua d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Duʿā?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        all.removeWhere((x) => x.id == d.id);
        _recalcFolderCounts();
      });
    }
  }

  void _moveToFolder(Dua d) async {
    final choice = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppTok.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTok.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Move to Folder', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              ListTile(
                onTap: () => Navigator.pop(context, null),
                leading: const Text('📂', style: TextStyle(fontSize: 22)),
                title: const Text('Unfiled'),
              ),
              ...folders.map((f) => ListTile(
                onTap: () => Navigator.pop(context, f.id),
                leading: Text(f.icon, style: const TextStyle(fontSize: 22)),
                title: Text(f.name),
                trailing: Text('${f.count}',
                    style: const TextStyle(color: AppTok.textMuted)),
              )),
            ],
          ),
        );
      },
    );

    if (choice != null || choice == null) {
      setState(() {
        final i = all.indexWhere((x) => x.id == d.id);
        all[i] = d.copyWith(folderId: choice);
        _recalcFolderCounts();
      });
    }
  }

  void _createFolder() async {
    final controller = TextEditingController();
    String icon = '🗂';
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create New Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Folder name'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['🗂', '📁', '🌙', '❤️', '🤲', '⭐', '🕌', '📖']
                  .map((e) {
                final sel = e == icon;
                return ChoiceChip(
                  label: Text(e, style: const TextStyle(fontSize: 18)),
                  selected: sel,
                  onSelected: (_) {
                    icon = e;
                    (context as Element).markNeedsBuild();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final fid = name.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
              setState(() {
                folders.add(DuaFolder(id: fid, name: name, icon: icon, count: 0));
              });
              Navigator.pop(context, fid);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTok.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppTok.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Sort By', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...SortOption.values.map((opt) => ListTile(
                title: Text(opt.name[0].toUpperCase() + opt.name.substring(1)),
                trailing: _sort == opt ? const Icon(Icons.check, color: AppTok.copperSolid) : null,
                onTap: () {
                  setState(() => _sort = opt);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
              const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categoryOrder.map((id) {
                  final sel = _selectedCats.contains(id);
                  return CopperChip(
                    label: _categoryLabel[id]!,
                    selected: sel,
                    onTap: () {
                      setState(() => sel
                          ? _selectedCats.remove(id)
                          : _selectedCats.add(id));
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Folders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('All Duʿās'),
                trailing: _selectedFolderId == null ? const Icon(Icons.check, color: AppTok.copperSolid) : null,
                onTap: () {
                  setState(() => _selectedFolderId = null);
                  Navigator.pop(context);
                },
              ),
              ...folders.map((f) => ListTile(
                leading: Text(f.icon, style: const TextStyle(fontSize: 18)),
                title: Text(f.name),
                trailing: _selectedFolderId == f.id ? const Icon(Icons.check, color: AppTok.copperSolid) : null,
                onTap: () {
                  setState(() => _selectedFolderId = f.id);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCats.clear();
                          _selectedFolderId = null;
                          _sort = SortOption.recent;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

   @override
   Widget build(BuildContext context) {
     final list = _filtered();

     return Scaffold(
       backgroundColor: AppTok.bg,
       body: CustomScrollView(
         slivers: [
           SliverAppBar(
             backgroundColor: Colors.transparent,
             elevation: 0,
             floating: false,
             pinned: false,
             toolbarHeight: 0,
             collapsedHeight: 0,
           ),
           SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.only(top: 44, left: 16, right: 16, bottom: 24),
               child: const Text(
                 'My Duʿās',
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: AppTok.copperSolid,
                   fontSize: 32,
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ),
           ),
           SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16),
               child: Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: _search,
                       onChanged: (_) => setState(() {}),
                       decoration: InputDecoration(
                         hintText: 'Search your duʿās…',
                         hintStyle: const TextStyle(color: AppTok.textMuted),
                         filled: true,
                         fillColor: AppTok.surface,
                         prefixIcon: const Icon(Icons.search, color: AppTok.textMuted),
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(20),
                           borderSide: BorderSide.none,
                         ),
                         enabledBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(20),
                           borderSide: BorderSide.none,
                         ),
                         focusedBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(20),
                           borderSide: BorderSide.none,
                         ),
                         isDense: true,
                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   SizedBox(
                     width: 48,
                     height: 48,
                     child: Material(
                       color: AppTok.surface,
                       borderRadius: BorderRadius.circular(16),
                       child: InkWell(
                         borderRadius: BorderRadius.circular(16),
                         onTap: _openFilters,
                         child: const Icon(Icons.filter_alt, color: AppTok.copperSolid),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ),
           SliverToBoxAdapter(child: const SizedBox(height: 16)),
           SliverToBoxAdapter(
             child: SingleChildScrollView(
               scrollDirection: Axis.horizontal,
               padding: const EdgeInsets.symmetric(horizontal: 16),
               child: Row(
                 children: _categoryOrder
                                          .map((id) {
                       final sel = _selectedCats.contains(id);
                       return Padding(
                         padding: const EdgeInsets.only(right: 12),
                         child: SizedBox(
                           height: 36,
                           child: CopperChip(
                             label: _categoryLabel[id]!,
                             selected: sel,
                             onTap: () {
                               setState(() => sel
                                   ? _selectedCats.remove(id)
                                   : _selectedCats.add(id));
                             },
                           ),
                         ),
                       );
                     })
                     .toList(),
               ),
             ),
           ),
           if (folders.isNotEmpty) ...[
             SliverToBoxAdapter(child: const SizedBox(height: 16)),
             SliverToBoxAdapter(
               child: SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 padding: const EdgeInsets.symmetric(horizontal: 16),
                 child: Row(
                   children: [
                     ...folders.map((f) {
                       final sel = _selectedFolderId == f.id;
                       return Padding(
                         padding: const EdgeInsets.only(right: 12),
                         child: GestureDetector(
                           onTap: () => setState(
                               () => _selectedFolderId = sel ? null : f.id),
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             decoration: BoxDecoration(
                               color: sel ? AppTok.copperSolid : AppTok.surface,
                               borderRadius: BorderRadius.circular(24),
                               border: sel ? null : Border.all(color: AppTok.border),
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Text(f.icon, style: const TextStyle(fontSize: 18)),
                                 const SizedBox(width: 6),
                                 Text(
                                   '${f.name} ${f.count}',
                                   style: TextStyle(
                                     color: sel ? Colors.white : AppTok.textSecondary,
                                     fontSize: 13,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ),
                       );
                     }),
                     Padding(
                       padding: const EdgeInsets.only(right: 12),
                       child: GestureDetector(
                         onTap: _createFolder,
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                           decoration: BoxDecoration(
                             color: AppTok.surface,
                             borderRadius: BorderRadius.circular(24),
                             border: Border.all(color: AppTok.border),
                           ),
                           child: const Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(Icons.add, size: 18, color: AppTok.copperSolid),
                               SizedBox(width: 6),
                               Text(
                                 'New Folder',
                                 style: TextStyle(
                                   color: AppTok.textSecondary,
                                   fontSize: 13,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ],
           SliverToBoxAdapter(child: const SizedBox(height: 16)),
           if (list.isEmpty)
             SliverFillRemaining(
               hasScrollBody: false,
               child: Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Text(
                       'Your heart\'s canvas is waiting.',
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         color: AppTok.textMuted,
                         fontSize: 16,
                       ),
                     ),
                     const SizedBox(height: 24),
                     FilledButton(
                       onPressed: () {},
                       child: const Text('Create a Duʿā'),
                     ),
                   ],
                 ),
               ),
             )
           else
             SliverList(
               delegate: SliverChildBuilderDelegate(
                 (_, i) {
                   final d = list[i];
                   return Padding(
                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                     child: DuaCard(
                       dua: d,
                       onTap: (_) => _openPreview(d),
                       onMenu: () {
                         showMenu(
                           context: context,
                           color: AppTok.card,
                           position: const RelativeRect.fromLTRB(1000, 0, 16, 0),
                           items: [
                             _mi('Edit', Icons.edit, () => _edit(d)),
                             _mi('Duplicate', Icons.copy, () => _duplicate(d)),
                             _mi('Share', Icons.share, () {}),
                             _mi('Rename', Icons.edit_note, () {}),
                             _mi('Move to Folder', Icons.folder_open, () => _moveToFolder(d)),
                             _mi('Add to Collection', Icons.collections, () {}),
                             _mi('Export as PDF', Icons.download, () {}),
                             _mi('Delete', Icons.delete, () => _delete(d), danger: true),
                           ],
                         );
                       },
                     ),
                   );
                 },
                 childCount: list.length,
               ),
             ),
           SliverToBoxAdapter(child: const SizedBox(height: 24)),
         ],
       ),
       floatingActionButton: SizedBox(
         width: 56,
         height: 56,
         child: FloatingActionButton(
           backgroundColor: AppTok.copperSolid,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
           onPressed: () {},
           child: const Icon(Icons.add, color: Colors.white, size: 24),
         ),
       ),
       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
     );
   }

  PopupMenuItem _mi(String label, IconData icon, VoidCallback onTap, {bool danger = false}) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: danger ? Colors.redAccent : AppTok.textPrimary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: danger ? Colors.redAccent : AppTok.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
