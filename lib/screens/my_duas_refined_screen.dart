import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/components/dua_card.dart';
import 'package:hearth_prayer/services/dua_service.dart';
import 'package:hearth_prayer/services/share_service.dart';
import 'package:hearth_prayer/services/folder_service.dart';
import 'package:hearth_prayer/services/user_service.dart';
import 'package:hearth_prayer/models/dua.dart';
import 'package:hearth_prayer/models/folder.dart';
import 'package:hearth_prayer/theme/tokens.dart';

class MyDuasRefinedScreen extends StatefulWidget {
  const MyDuasRefinedScreen({Key? key}) : super(key: key);

  // Set this before navigating to auto-scroll and pulse-highlight an item.
  static String? scrollToDuaId;

  @override
  State<MyDuasRefinedScreen> createState() => _MyDuasRefinedScreenState();
}

class _MyDuasRefinedScreenState extends State<MyDuasRefinedScreen> with TickerProviderStateMixin {
  String? _selectedFolderId;
  String? _selectedTagId;
  String _searchQuery = '';
  late AnimationController _shimmerController;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};
  String? _highlightDuaId;
  late AnimationController _highlightController;

  bool _bootstrapped = false; // Fix C: avoid showing "empty" UI before first refresh

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _highlightController = AnimationController(vsync: this, duration: const Duration(milliseconds: 375));

    // Fix C: Refresh from Supabase once screen mounts so folders/duas never rely on stale in-memory state.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshFromSupabaseAndHydrateSelection();

      // Handle pending scroll/highlight request AFTER data is loaded
      final pendingId = MyDuasRefinedScreen.scrollToDuaId;
      if (pendingId != null) {
        MyDuasRefinedScreen.scrollToDuaId = null; // consume
        _highlightDuaId = pendingId;
        _scrollToAndPulse(pendingId);
      }
    });
  }

  /// Fix C:
  /// Always refresh folder + dua caches from Supabase when entering My Duʿās.
  /// Then re-apply Fix B selection restore with a stale-id guard.
  Future<void> _refreshFromSupabaseAndHydrateSelection() async {
    try {
      // Only refresh if we have an authenticated user in memory.
      // If not, skip quietly (screen will show empty).
      final userId = UserService.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _bootstrapped = true);
        return;
      }

      await FolderService.initialize();
      await DuaService.initialize();

      // Fix B (stale saved folder guard) after fresh folder list exists
      await _loadLastSelectedFolder();

      if (mounted) setState(() => _bootstrapped = true);
    } catch (e) {
      debugPrint('[MyDuas] Refresh failed: $e');
      if (mounted) setState(() => _bootstrapped = true);
    }
  }

  /// Fix B:
  /// - If the saved folder id is stale (folder deleted, not loaded yet, or belongs to a different user),
  ///   clear it so the screen falls back to "All Duʿās" (null filter).
  Future<void> _loadLastSelectedFolder() async {
    final lastFolderId = await UserService.getLastSelectedFolder();
    if (!mounted) return;

    if (lastFolderId == null || lastFolderId.trim().isEmpty) {
      return;
    }

    Folder? folder = FolderService.getFolderById(lastFolderId);
    if (folder == null) {
      // Folder list should already be fresh from Fix C, but keep a safe fallback.
      try {
        await FolderService.initialize();
      } catch (_) {}
      folder = FolderService.getFolderById(lastFolderId);
    }

    if (folder == null) {
      await UserService.setLastSelectedFolder(null);
      if (mounted) setState(() => _selectedFolderId = null);
      return;
    }

    if (mounted) setState(() => _selectedFolderId = lastFolderId);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _highlightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandTokens = context.brandTokens;

    // Fix C: until first refresh finishes, avoid misleading “No duʿās found”.
    if (!_bootstrapped) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: SafeArea(
          child: Center(
            child: Text(
              'Loading…',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    final filteredDuas = _getFilteredDuas();
    final allTags = _getAllTags();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => brandTokens.copperGradient.createShader(bounds),
                  child: Text(
                    'My Duʿās',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),

                _SearchBar(onChanged: (value) => setState(() => _searchQuery = value)),
                const SizedBox(height: 12),

                if (allTags.isNotEmpty) _buildTagRow(allTags, theme),
                if (allTags.isNotEmpty) const SizedBox(height: 12),

                _buildFolderRow(theme),
                const SizedBox(height: 16),

                if (filteredDuas.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No duʿās found',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (final dua in filteredDuas)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildHighlightableDuaCard(dua),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightableDuaCard(Dua dua) {
    final key = _itemKeys.putIfAbsent(dua.id, () => GlobalKey());
    final isHighlight = dua.id == _highlightDuaId;
    return Stack(
      key: key,
      children: [
        if (isHighlight)
          FadeTransition(
            opacity: _highlightController.drive(Tween<double>(begin: 0.0, end: 1.0)),
            child: Container(height: 0),
          ),
        if (isHighlight)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _highlightController,
                builder: (context, _) {
                  final t = _highlightController.value;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0.10 * (1 - (t - 0.5).abs() * 2),
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        DuaCard(
          dua: dua,
          onTap: (d) {
            Navigator.pushNamed(context, '/viewer', arguments: d).then((_) {
              if (mounted) setState(() {});
            });
          },
          onMenu: () => _showDuaMenu(context, dua),
        ),
      ],
    );
  }

  Future<void> _scrollToAndPulse(String duaId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final key = _itemKeys[duaId];
    if (key?.currentContext != null) {
      try {
        await Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: 0.2,
          curve: Curves.easeOut,
        );
      } catch (_) {}
    }
    if (!mounted) return;
    try {
      await _highlightController.forward();
      await _highlightController.reverse();
    } catch (_) {}
    if (mounted) setState(() => _highlightDuaId = null);
  }

  Widget _buildTagRow(List<String> allTags, ThemeData theme) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final tag in allTags)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTagId = (_selectedTagId == tag) ? null : tag;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedTagId == tag ? theme.colorScheme.primary : theme.colorScheme.surface,
                    border: Border.all(
                      color: _selectedTagId == tag
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _selectedTagId == tag ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// UI tweak:
  /// Add an explicit "All Duʿās" pill at the start of the folder row.
  /// - Selected when _selectedFolderId == null
  /// - Tapping it clears folder filter (sets _selectedFolderId = null)
  Widget _buildFolderRow(ThemeData theme) {
    final folders = FolderService.getOrderedFolders();
    final allDuasCount = DuaService.duas.length;

    Widget buildPill({
      required VoidCallback onTap,
      required Widget child,
      required bool selected,
      VoidCallback? onLongPress,
    }) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // ✅ NEW: "All Duʿās" pill (explicit)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: buildPill(
              selected: _selectedFolderId == null,
              onTap: () {
                setState(() {
                  _selectedFolderId = null;
                  UserService.setLastSelectedFolder(null);
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text('🤲', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                  const SizedBox(width: 6),
                  Text(
                    'All Duʿās',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: (_selectedFolderId == null)
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      '$allDuasCount',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: (_selectedFolderId == null)
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User folders
          for (final folder in folders)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: folder.name == 'Welcome to Mun\u0101j\u0101t'
                  ? _buildWelcomeFolderPill(folder, theme)
                  : buildPill(
                selected: _selectedFolderId == folder.id,
                onTap: () {
                  setState(() {
                    // ✅ Toggle behaviour: tap again to de-select (back to All)
                    if (_selectedFolderId == folder.id) {
                      _selectedFolderId = null;
                      UserService.setLastSelectedFolder(null);
                    } else {
                      _selectedFolderId = folder.id;
                      UserService.setLastSelectedFolder(folder.id);
                    }
                  });
                },
                onLongPress: () {
                  // All pill is separate, so all real folders can be long-pressed safely
                  _showFolderOptionsSheet(context, folder);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text((folder.emoji ?? '\u{1F932}'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                    const SizedBox(width: 6),
                    Text(
                      folder.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: (_selectedFolderId == folder.id)
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_getFolderCount(folder.id)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: (_selectedFolderId == folder.id)
                            ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // "+ New Folder" pill
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _showCreateFolderSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: theme.colorScheme.surface,
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 4),
                    Text(
                      'New Folder',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeFolderPill(Folder folder, ThemeData theme) {
    final isSelected = _selectedFolderId == folder.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedFolderId == folder.id) {
            _selectedFolderId = null;
            UserService.setLastSelectedFolder(null);
          } else {
            _selectedFolderId = folder.id;
            UserService.setLastSelectedFolder(folder.id);
          }
        });
      },
      onLongPress: () => _showFolderOptionsSheet(context, folder),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : const Color(0xFFB87333).withOpacity(0.3),
            width: isSelected ? 1 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(folder.emoji ?? '\u{1F54C}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            const SizedBox(width: 6),
            Text(
              folder.name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            // "Founding" badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB87333), Color(0xFFFFD9A0)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Founding',
                style: TextStyle(
                  color: Color(0xFF3D2817),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${_getFolderCount(folder.id)}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAllTags() {
    final tags = <String>{};
    for (final dua in DuaService.duas) {
      for (final tag in dua.tags) {
        tags.add(tag.trim().toLowerCase());
      }
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }

  int _getFolderCount(String folderId) {
    return DuaService.duas.where((d) => d.folderId == folderId).length;
  }

  List<Dua> _getFilteredDuas() {
    List<Dua> duas = List.of(DuaService.duas);

    if (_selectedFolderId != null) {
      duas = duas.where((d) => d.folderId == _selectedFolderId).toList();
    }

    if (_selectedTagId != null) {
      duas = duas.where((d) {
        final tags = d.tags.map((t) => t.trim().toLowerCase());
        return tags.contains(_selectedTagId);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      duas = duas.where((d) {
        final t = d.title.toLowerCase();
        final e = d.englishText.toLowerCase();
        return t.contains(q) || e.contains(q);
      }).toList();
    }

    duas.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return duas;
  }

  void _showCreateFolderSheet(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    final emojis = ['🤲', '🌙', '❤️', '😊', '📿'];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Folder', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'Enter folder name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emojiController,
                decoration: InputDecoration(
                  labelText: 'Emoji (optional)',
                  hintText: 'e.g., 🤲',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Quick select:', style: theme.textTheme.labelSmall),
              const SizedBox(height: 8),
              Row(
                spacing: 8,
                children: [
                  for (final emoji in emojis)
                    GestureDetector(
                      onTap: () => setModalState(() => emojiController.text = emoji),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: emojiController.text == emoji
                              ? theme.colorScheme.primary.withValues(alpha: 0.2)
                              : theme.colorScheme.surface,
                          border: Border.all(
                            color: emojiController.text == emoji
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        final emoji = emojiController.text.trim();

                        await FolderService.createFolder(
                          name: name,
                          emoji: emoji.isEmpty ? null : emoji,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);

                          // Fix C: after write, refresh from Supabase so the UI is authoritative.
                          await _refreshFromSupabaseAndHydrateSelection();

                          // Select the newest folder if it exists
                          final ordered = FolderService.getOrderedFolders();
                          if (ordered.isNotEmpty) {
                            final newFolder = ordered.last;
                            setState(() {
                              _selectedFolderId = newFolder.id;
                              UserService.setLastSelectedFolder(newFolder.id);
                            });
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Save',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Existing menu + delete + move folder code remains unchanged below =====

  void _showRenameFolderSheet(BuildContext context, Folder folder) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: folder.name);
    final emojiController = TextEditingController(text: folder.emoji ?? '');
    String? errorText;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rename folder', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'Enter folder name',
                  errorText: errorText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emojiController,
                decoration: InputDecoration(
                  labelText: 'Emoji (optional)',
                  hintText: 'e.g., 🤲',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          setModalState(() => errorText = 'Folder name can\'t be empty');
                          return;
                        }
                        final emoji = emojiController.text.trim();

                        await FolderService.updateFolder(
                          id: folder.id,
                          name: name,
                          emoji: emoji.isEmpty ? null : emoji,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          await _refreshFromSupabaseAndHydrateSelection();
                          setState(() {});
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Save',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDuaSheet(BuildContext context, Dua dua) {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: dua.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rename Du\u02BBA',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter new title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final newTitle = controller.text.trim();
                    if (newTitle.isNotEmpty && newTitle != dua.title) {
                      final updatedDua = dua.copyWith(
                        title: newTitle,
                        updatedAt: DateTime.now(),
                      );
                      await DuaService.updateDua(updatedDua);
                      if (context.mounted) {
                        Navigator.pop(context);
                        await _refreshFromSupabaseAndHydrateSelection();
                        setState(() {});
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Save',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDuaMenu(BuildContext context, Dua dua) {
    final theme = Theme.of(context);
    final rootContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuOption(theme, Icons.edit, 'Edit', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/edit_dua', arguments: dua);
                }),
                _buildMenuOption(theme, Icons.content_copy, 'Duplicate', () {
                  Navigator.pop(context);
                }),
                _buildMenuOption(theme, Icons.share, 'Share', () async {
                  Navigator.pop(context);

                  final english = dua.englishText.trim();
                  String textToShare = '';

                  if (english.isNotEmpty) {
                    textToShare = english;
                  } else if (dua.body.trim().isNotEmpty) {
                    textToShare = dua.body.trim();
                  } else if (dua.preview.trim().isNotEmpty) {
                    textToShare = dua.preview.trim();
                  }

                  if (textToShare.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        const SnackBar(content: Text('Nothing to share yet.')),
                      );
                    }
                    return;
                  }

                  await ShareService.shareDua(
                    title: dua.title.trim().isEmpty ? null : dua.title,
                    body: textToShare,
                  );
                }),
                _buildMenuOption(theme, Icons.drive_file_rename_outline, 'Rename', () {
                  Navigator.pop(context);
                  _showRenameDuaSheet(rootContext, dua);
                }),
                _buildMenuOption(theme, Icons.folder, 'Move to Folder', () {
                  Navigator.pop(context);
                  _showMoveToFolderSheet(rootContext, dua);
                }),
                _buildMenuOption(theme, Icons.picture_as_pdf, 'Export as PDF', () {
                  Navigator.pop(context);
                }),
                _buildMenuOption(
                  theme,
                  Icons.delete,
                  'Delete',
                  () async {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, dua);
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFolderOptionsSheet(BuildContext context, Folder folder) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuOption(theme, Icons.drive_file_rename_outline, 'Rename folder', () {
                  Navigator.pop(context);
                  _showRenameFolderSheet(context, folder);
                }),
                _buildMenuOption(theme, Icons.delete, 'Delete folder', () async {
                  Navigator.pop(context);
                  await _showDeleteFolderConfirmation(context, folder);
                }, isDestructive: true),
                const SizedBox(height: 4),
                _buildMenuOption(theme, Icons.close, 'Cancel', () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteFolderConfirmation(BuildContext context, Folder folder) async {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete this folder?', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        content: const Text('Your duʿās will NOT be deleted. They will remain visible under “All Duʿās.”'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
          ),
          FilledButton(
            onPressed: () async {
              final deletingSelected = _selectedFolderId == folder.id;

              await DuaService.clearFolderForDuas(folder.id);
              await FolderService.deleteFolder(folder.id);

              if (mounted) {
                Navigator.pop(context);
                if (deletingSelected) {
                  setState(() {
                    _selectedFolderId = null;
                    UserService.setLastSelectedFolder(null);
                  });
                }
                await _refreshFromSupabaseAndHydrateSelection();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete folder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMoveToFolderSheet(BuildContext context, Dua dua) {
    final theme = Theme.of(context);
    final folders = FolderService.getOrderedFolders();
    String? tempFolderId = dua.folderId.isEmpty ? null : dua.folderId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Move to Folder', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    RadioListTile<String?>(
                      value: null,
                      groupValue: tempFolderId,
                      onChanged: (val) => setModalState(() => tempFolderId = val),
                      title: const Text('No folder'),
                      activeColor: theme.colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    for (final folder in folders)
                      RadioListTile<String?>(
                        value: folder.id,
                        groupValue: tempFolderId,
                        onChanged: (val) => setModalState(() => tempFolderId = val),
                        title: Row(
                          children: [
                            Text(folder.emoji ?? '🤲', style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(folder.name),
                            const SizedBox(width: 8),
                            Text(
                              '${_getFolderCount(folder.id)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        activeColor: theme.colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showCreateFolderSheet(context);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Folder'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final updatedDua = dua.copyWith(
                            folderId: tempFolderId ?? '',
                            updatedAt: DateTime.now(),
                          );

                          await DuaService.updateDua(updatedDua);

                          if (context.mounted) {
                            Navigator.pop(context);
                            await _refreshFromSupabaseAndHydrateSelection();
                            setState(() {});
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Save',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuOption(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: isDestructive ? Colors.red : theme.colorScheme.onSurface, size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDestructive ? Colors.red : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Dua dua) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Duʿā?', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        content: Text('This action cannot be undone.', style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
          ),
          FilledButton(
            onPressed: () async {
              await DuaService.deleteDua(dua.id);
              if (mounted) {
                Navigator.pop(context);
                await _refreshFromSupabaseAndHydrateSelection();
                setState(() {});
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const _SearchBar({this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search your duʿās…',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}