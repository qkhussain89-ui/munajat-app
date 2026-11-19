import 'package:flutter/material.dart';
import 'package:hearth_prayer/models/dua.dart';
import 'package:hearth_prayer/theme/tokens.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/services/dua_service.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:provider/provider.dart';

class EditDuaScreen extends StatefulWidget {
  final Dua dua;

  const EditDuaScreen({
    super.key,
    required this.dua,
  });

  @override
  State<EditDuaScreen> createState() => _EditDuaScreenState();
}

class _EditDuaScreenState extends State<EditDuaScreen> {
  late TextEditingController _titleController;
  late TextEditingController _englishController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.dua.title);
    _englishController = TextEditingController(text: widget.dua.englishText);
    _tagsController = TextEditingController(text: widget.dua.tags.join(', '));
    // Hide bottom nav on this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().setShowTabBar(false);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _englishController.dispose();
    _tagsController.dispose();
    // Restore bottom nav visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().setShowTabBar(true);
    });
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();

    final updated = widget.dua.copyWith(
      title: _titleController.text.trim(),
      englishText: _englishController.text,
      tags: tags,
      updatedAt: DateTime.now(),
    );

    DuaService.updateDua(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duʿā updated')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandTokens = context.brandTokens;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header — matches other stack screens
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
                            color: colorScheme.secondary,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                          padding: EdgeInsets.zero,
                          tooltip: 'Back',
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ShaderMask(
                            shaderCallback: (_) => brandTokens.copperGradient
                                .createShader(const Rect.fromLTWH(0, 0, 400, 50)),
                            child: const Text(
                              'Edit Duʿā',
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
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Title field
                Text(
                  'Title',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Enter title…',
                    hintStyle: TextStyle(color: brandTokens.textMuted),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: brandTokens.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: brandTokens.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 24),

                // Language label — English-only (non-interactive)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.primary),
                    ),
                    child: Text(
                      'English',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Text area — English only
                SizedBox(
                  height: 200,
                  child: _buildTextArea(
                    _englishController,
                    'Enter English translation…',
                    colorScheme,
                    brandTokens,
                  ),
                ),

                const SizedBox(height: 24),

                // Tags field
                Text(
                  'Tags (comma-separated)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _tagsController,
                  maxLines: 2,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'health, family, peace…',
                    hintStyle: TextStyle(color: brandTokens.textMuted),
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: brandTokens.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: brandTokens.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),

                const SizedBox(height: 32),

                // Save Changes — primary CTA
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextArea(
    TextEditingController controller,
    String hint,
    ColorScheme colorScheme,
    BrandTokens brandTokens, {
    bool isArabic = false,
    bool isItalic = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: TextField(
        controller: controller,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        minLines: 8,
        maxLines: null,
        style: TextStyle(
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: colorScheme.onSurface,
          fontFamily: 'Poppins',
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: brandTokens.textMuted),
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: brandTokens.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: brandTokens.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// Matches the Optimised Duʿā language pill control visually and structurally.
// (Language pill controls removed for English-only MVP)

