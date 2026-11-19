import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:hearth_prayer/services/share_service.dart';
import 'dart:ui';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/services/dua_service.dart';
import 'package:hearth_prayer/services/folder_service.dart';
import 'package:hearth_prayer/screens/mission_message_gate.dart';
import 'package:hearth_prayer/models/folder.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:hearth_prayer/components/copper_button.dart';
import 'package:hearth_prayer/screens/sign_up_screen.dart';

class PreviewScreen extends StatefulWidget {
  final Map<String, String> duaData;

  const PreviewScreen({super.key, required this.duaData});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  // English-only MVP: no language switching state

  @override
  Widget build(BuildContext context) {
    final english = widget.duaData['english'] ?? '';
    final outputLanguage = widget.duaData['output_language'] ?? 'english';
    final isRtl = outputLanguage == 'arabic' || outputLanguage == 'urdu';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Top bar
                SizedBox(height: 24),
                _buildTopBar(colorScheme),
                const SizedBox(height: 24),

                // Heading block (adds its own bottom spacing when present)
                _buildHeadingBlock(colorScheme),

                // Content card (extended to reclaim space from removed guidelines card)
                _buildContentCard(
                  english,
                  colorScheme,
                  isArabic: isRtl,
                  // Extend height to create a more immersive card now that
                  // the Sunnah Guidelines card is removed. This keeps the
                  // duʿā text top-aligned inside while the card grows.
                  minHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(colorScheme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme) {
    final brandTokens = context.brandTokens;
    return Row(
      children: [
        // Back arrow — unchanged
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.chevron_left,
            size: 28,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),

        // Centered header title — matches existing screens (copper gradient, Poppins, w300)
        Expanded(
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => brandTokens.copperGradient.createShader(bounds),
              child: const Text(
                'Preview',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.3,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),

        // Right spacer to balance layout; does not affect back arrow position
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildHeadingBlock(ColorScheme colorScheme) {
    final brandTokens = context.brandTokens;
    final title = (widget.duaData['title'] ?? '').trim();
    if (title.isEmpty) {
      // No explicit title: render nothing, no placeholder, no extra spacing.
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (_) => brandTokens.copperGradient.createShader(const Rect.fromLTWH(0, 0, 300, 50)),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Generated just now',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: brandTokens.textMuted,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildContentCard(String content, ColorScheme colorScheme, {bool isArabic = false, double? minHeight}) {
    final brandTokens = context.brandTokens;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: brandTokens.border),
        borderRadius: BorderRadius.circular(20),
      ),
      constraints: BoxConstraints(
        // Ensure the card grows to fill the space left by the removed
        // guidelines card, while remaining flexible for longer content.
        minHeight: (minHeight ?? 0).clamp(0, double.infinity),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Text(
        content,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isArabic ? TextAlign.right : TextAlign.center,
        style: TextStyle(
          fontSize: isArabic ? 18 : 16,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w300,
          height: 1.8,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              final appState = Provider.of<AppState>(context, listen: false);
              if (appState.isAnonymous) {
                _showAnonymousSaveGate();
              } else {
                _showSaveModal();
              }
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_alt,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _showShareSheet,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: colorScheme.primary),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveDuaModal extends StatefulWidget {
  final Map<String, String> duaData;
  final VoidCallback? onSaveSuccess;
  const _SaveDuaModal({required this.duaData, this.onSaveSuccess});

  @override
  State<_SaveDuaModal> createState() => _SaveDuaModalState();
}

class _SaveDuaModalState extends State<_SaveDuaModal> {
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _selectedFolderId; // none by default
  late List<Folder> _folders;

  @override
  void initState() {
    super.initState();
    _folders = FolderService.getOrderedFolders();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _createFolderFlow() async {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final emojiController = TextEditingController();
    final emojis = ['🤲', '🌙', '❤️', '😊', '📿'];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
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
                        await FolderService.createFolder(name: name, emoji: emoji.isEmpty ? null : emoji);
                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {
                            _folders = FolderService.getOrderedFolders();
                            _selectedFolderId = _folders.last.id;
                          });
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Save', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandTokens = context.brandTokens;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.08)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (context, setInner) {
              final canSave = _titleController.text.trim().isNotEmpty;
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Center(
                      child: ShaderMask(
                        shaderCallback: (r) => brandTokens.copperGradient.createShader(r),
                        child: const Text(
                          'Save Duʿā',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Duʿā Title (required)
                    Text('Duʿā Title', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleController,
                      onChanged: (_) => setInner(() {}),
                      decoration: InputDecoration(
                        hintText: 'Give your duʿā a meaningful title…',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Folder selection row (optional)
                    Text('Save to Folder', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final folder in _folders)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedFolderId = folder.id == _selectedFolderId ? null : folder.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: _selectedFolderId == folder.id ? theme.colorScheme.primary : theme.colorScheme.surface,
                                    border: Border.all(
                                      color: _selectedFolderId == folder.id
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(folder.emoji ?? '🤲', style: const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 6),
                                      Text(
                                        folder.name,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: _selectedFolderId == folder.id ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // + New Folder pill
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: _createFolderFlow,
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
                                    Text('New Folder', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: theme.colorScheme.onSurface)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tags (optional)
                    Text('Tags (optional)', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Health, Family, Gratitude',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Buttons
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: canSave ? _handleSave : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: theme.colorScheme.outline.withValues(alpha: 0.4),
                        ),
                        child: Text('Save Duʿā', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    // DEBUG: Save Duʿā button tapped (handler entered)
    // ignore: avoid_print
    print('DEBUG: Save Duʿā button tapped');
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final english = widget.duaData['english'] ?? '';
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final nowId = 'dua_${DateTime.now().millisecondsSinceEpoch}';
    // Create Dua using service (the service generates an id internally, so we capture after create by reading first item)
    try {
      await DuaService.createDua(
        title: title,
        englishText: english,
        // English-only MVP: body is always the English text
        body: english,
        tags: tags,
        folderId: _selectedFolderId,
        outputLanguage: widget.duaData['output_language'] ?? 'english',
      );
      // ignore: avoid_print
      print('DEBUG: DuaService.createDua completed successfully');
    } catch (e, st) {
      // ignore: avoid_print
      print('DEBUG: Error in DuaService.createDua -> $e');
      // ignore: avoid_print
      print('DEBUG: Stacktrace -> $st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save Duʿā. Please try again.')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pop(context); // close modal
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Duʿā saved!')));
    // Notify parent after close so it can trigger MissionMessageGate with a brief delay
    try {
      widget.onSaveSuccess?.call();
    } catch (e) {
      debugPrint('PreviewScreen: onSaveSuccess callback error -> $e');
    }
  }
}

extension on _PreviewScreenState {
  void _showAnonymousSaveGate() {
    // Store the du'a text in AppState before showing modal
    final appState = Provider.of<AppState>(context, listen: false);
    final english = widget.duaData['english'] ?? '';
    final language = widget.duaData['output_language'] ?? 'english';
    appState.setPendingDua(english, language);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        final theme = Theme.of(modalContext);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Heading
              Text(
                'Save this du\u2019\u0101?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create a free account to keep your du\u2019\u0101s, organise them into folders, and revisit them whenever you need them.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              // Create Account button (primary)
              SizedBox(
                width: double.infinity,
                child: CopperButton(
                  text: 'Create Account',
                  onPressed: () {
                    Navigator.pop(modalContext);
                    final pendingText = appState.pendingDuaText;
                    final pendingLang = appState.pendingDuaLanguage;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SignUpScreen(
                          isConvertingAnonymous: true,
                          pendingDuaText: pendingText,
                          pendingDuaLanguage: pendingLang,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Maybe later button (secondary)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(modalContext),
                  child: Text(
                    'Maybe later',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSaveModal() {
    // Dismiss keyboard before opening modal
    FocusScope.of(context).unfocus();
    // Present a blurred, dark-tinted overlay with centered modal
    // Capture a safe navigator context from the parent screen (not the dialog)
    final rootContext = context;
    // DEBUG: opening Save Duʿā modal
    // ignore: avoid_print
    print('DEBUG: Opening Save Duʿā modal');
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Save Duʿā',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(color: Colors.transparent),
            ),
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
              child: _SaveDuaModal(
                duaData: widget.duaData,
                onSaveSuccess: () async {
                  // Preserve the brief delay previously used to avoid visual stacking
                  // with modal dismissal, but intentionally do not navigate.
                  await Future.delayed(const Duration(milliseconds: 400));
                  if (!mounted) return;
                },
              ),
            ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(curved), child: child),
        );
      },
    );
  }

  void _showShareSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandTokens = context.brandTokens;

    // English-only MVP: always use English
    final currentText = widget.duaData['english'] ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ShaderMask(
                    shaderCallback: (r) => brandTokens.copperGradient.createShader(r),
                    child: const Text(
                      'Share Duʿāʾ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Option 1: Copy text
                InkWell(
                  onTap: () async {
                    try {
                      await Clipboard.setData(ClipboardData(text: currentText));
                      debugPrint('PreviewScreen: Copied duʿāʾ text (len=${currentText.length})');
                    } catch (e) {
                      debugPrint('PreviewScreen: Clipboard error -> $e');
                    } finally {
                      if (mounted) Navigator.pop(sheetContext);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Duʿāʾ copied')),
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Copy text',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),

                Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),

                // Option 2: Send via message (native share sheet)
                InkWell(
                  onTap: () async {
                    try {
                      await ShareService.shareText(currentText);
                      debugPrint('PreviewScreen: Invoked native share sheet');
                    } catch (e) {
                      debugPrint('PreviewScreen: Share error -> $e');
                    } finally {
                      if (mounted) Navigator.pop(sheetContext);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Send via message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}