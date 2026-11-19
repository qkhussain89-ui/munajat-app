import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hearth_prayer/models/journal_entry.dart';
import 'package:hearth_prayer/services/journal_service.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

class EditJournalEntryScreen extends StatefulWidget {
  final String entryId;

  const EditJournalEntryScreen({super.key, required this.entryId});

  @override
  State<EditJournalEntryScreen> createState() => _EditJournalEntryScreenState();
}

class _EditJournalEntryScreenState extends State<EditJournalEntryScreen> with SingleTickerProviderStateMixin {
  JournalEntry? _entry;

  // moods
  final List<String> _allMoods = const [
    'Calm',
    'Grateful',
    'Hopeful',
    'Content',
    'Anxious',
    'Heavy-hearted',
    'Overwhelmed',
    'Tired',
  ];
  final Set<String> _selectedMoods = {};

  // controllers
  final List<TextEditingController> _blessingsCtrls = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _weightsCtrls = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _challengesCtrls = List.generate(5, (_) => TextEditingController());
  final TextEditingController _duaCtrl = TextEditingController();

  // dirty tracking
  bool _isDirty = false;
  late final List<VoidCallback> _listeners;

  // polish
  late AnimationController _fadeController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _listeners = [];
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _loadEntry();
  }

  @override
  void dispose() {
    for (final c in _blessingsCtrls) c.dispose();
    for (final c in _weightsCtrls) c.dispose();
    for (final c in _challengesCtrls) c.dispose();
    _duaCtrl.dispose();
    for (final l in _listeners) {
      // no-op holder; listeners are anonymous closures attached to controllers
    }
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEntry() async {
    // read the latest entry snapshot
    final entry = JournalService.getEntry(widget.entryId);
    setState(() {
      _entry = entry;
    });
    if (entry == null) return;

    // prefill moods
    _selectedMoods.clear();
    _selectedMoods.addAll(entry.moods.take(3));

    // prefill lists up to 5 each
    void fillList(List<TextEditingController> ctrls, List<String> values) {
      for (int i = 0; i < ctrls.length; i++) {
        ctrls[i].text = i < values.length ? values[i] : '';
        final listener = () => _markDirty();
        ctrls[i].addListener(listener);
        _listeners.add(listener);
      }
    }
    fillList(_blessingsCtrls, entry.blessings);
    fillList(_weightsCtrls, entry.weights);
    fillList(_challengesCtrls, entry.challenges);

    _duaCtrl.text = entry.dua;
    _duaCtrl.addListener(_markDirty);
    _listeners.add(_markDirty);

    // slight fade-in after data bound
    _fadeController.forward();
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  Future<bool> _handleBack() async {
    if (!_isDirty) return true;
    final t = Theme.of(context);
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text("You’ve made changes to this journal entry. Are you sure you want to leave without saving?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Keep Editing', style: t.textTheme.labelLarge),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Discard', style: t.textTheme.labelLarge?.copyWith(color: t.colorScheme.error)),
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
  }

  Future<void> _save() async {
    final t = Theme.of(context);
    final entry = _entry;
    if (entry == null) return;

    // collect values, trim, filter empties
    List<String> _collect(List<TextEditingController> ctrls) => ctrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    final updated = entry.copyWith(
      moods: _selectedMoods.take(3).toList(),
      blessings: _collect(_blessingsCtrls),
      weights: _collect(_weightsCtrls),
      challenges: _collect(_challengesCtrls),
      dua: _duaCtrl.text.trim(),
    );

    try {
      await JournalService.updateEntry(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journal entry updated')),
      );
      Navigator.of(context).pop(true); // indicate updated
    } catch (e) {
      debugPrint('[EditJournalEntry] save error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save changes. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final brandTokens = context.brandTokens;
    final entry = _entry;
    final dateStr = entry != null ? DateFormat('EEE • d MMM y').format(entry.createdAt) : '';

    return WillPopScope(
      onWillPop: () async {
        final ok = await _handleBack();
        return ok;
      },
      child: Scaffold(
        backgroundColor: t.colorScheme.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row with back and title
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
                              onPressed: () async {
                                final ok = await _handleBack();
                                if (ok && mounted) Navigator.of(context).maybePop();
                              },
                              padding: EdgeInsets.zero,
                              tooltip: 'Back',
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (bounds) => brandTokens.copperGradient.createShader(bounds),
                                child: const Text(
                                  'Edit Journal Entry',
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
                    const SizedBox(height: 4),
                    if (entry != null)
                      Text(
                        dateStr,
                        textAlign: TextAlign.center,
                        style: t.textTheme.labelMedium?.copyWith(
                          color: t.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Section 1: Moods
                    _buildTitle(t, 'How are you feeling in this entry?'),
                    const SizedBox(height: 12),
                    _buildMoodChips(t),
                    const SizedBox(height: 24),

                    // Section 2: Blessings
                    _buildTitleSubtitle(
                      t,
                      title: 'Blessings I noticed that day',
                      subtitle: 'Edit up to 5 blessings Allah blessed you with that day.',
                    ),
                    const SizedBox(height: 12),
                    _buildListFields(t, _blessingsCtrls, placeholders: const [
                      'A small blessing I noticed…',
                      'Time with someone I love…',
                      'A moment of peace…',
                      'Strength I found that day…',
                      'Guidance I received…',
                    ]),
                    const SizedBox(height: 24),

                    // Section 3: Weights
                    _buildTitleSubtitle(
                      t,
                      title: 'What weighed on my heart that day',
                      subtitle: 'Edit up to 5 things that made your heart feel heavy.',
                    ),
                    const SizedBox(height: 12),
                    _buildListFields(t, _weightsCtrls, placeholders: const [
                      'A worry that stayed with me…',
                      'A loss I felt…',
                      'A conflict that troubled me…',
                      'Sadness that visited me…',
                      'A struggle I faced…',
                    ]),
                    const SizedBox(height: 24),

                    // Section 4: Challenges (kept for parity with data model)
                    _buildTitleSubtitle(
                      t,
                      title: 'Challenges I faced that day',
                      subtitle: 'List up to 5 difficulties or tests you experienced.',
                    ),
                    const SizedBox(height: 12),
                    _buildListFields(t, _challengesCtrls, placeholders: const [
                      'A test I encountered…',
                      'A difficulty I overcame…',
                      'A moment of doubt…',
                      'A challenge to my patience…',
                      'A trial I endured…',
                    ]),
                    const SizedBox(height: 24),

                    // Section 5: Duʿā
                    _buildTitle(t, 'My duʿā for that day'),
                    const SizedBox(height: 12),
                    _buildLargeTextField(t, controller: _duaCtrl, placeholder: 'O Allah, help me with…', minLines: 4),
                    const SizedBox(height: 32),

                    // Footer actions
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _save,
                        child: Text(
                          'Save Changes',
                          style: t.textTheme.labelLarge?.copyWith(
                            color: t.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final ok = await _handleBack();
                          if (ok && mounted) Navigator.of(context).maybePop();
                        },
                        child: Text(
                          'Cancel',
                          style: t.textTheme.labelLarge?.copyWith(
                            color: t.colorScheme.onSurface.withValues(alpha: 0.7),
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
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData t, String title) => Text(
        title,
        style: t.textTheme.titleMedium?.copyWith(
          color: t.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _buildTitleSubtitle(ThemeData t, {required String title, required String subtitle}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(t, title),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: t.textTheme.labelSmall?.copyWith(
              color: t.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      );

  Widget _buildMoodChips(ThemeData t) {
    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: t.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _allMoods.map((mood) {
          final isSelected = _selectedMoods.contains(mood);
          final atLimit = _selectedMoods.length >= 3;
          final canSelect = isSelected || !atLimit;
          return GestureDetector(
            onTap: canSelect
                ? () {
                    setState(() {
                      if (isSelected) {
                        _selectedMoods.remove(mood);
                      } else {
                        _selectedMoods.add(mood);
                      }
                      _markDirty();
                    });
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? t.colorScheme.primary : t.colorScheme.surface,
                border: Border.all(
                  color: isSelected ? t.colorScheme.primary : t.colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mood,
                style: t.textTheme.labelSmall?.copyWith(
                  color: isSelected ? t.colorScheme.onPrimary : t.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListFields(
    ThemeData t,
    List<TextEditingController> controllers, {
    required List<String> placeholders,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: t.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          controllers.length,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < controllers.length - 1 ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 12),
                  child: Text(
                    '${i + 1}.',
                    style: t.textTheme.labelSmall?.copyWith(
                      color: t.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controllers[i],
                    decoration: InputDecoration(
                      hintText: placeholders[i],
                      hintStyle: t.textTheme.bodyMedium?.copyWith(
                        color: t.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: t.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: t.colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: t.colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeTextField(
    ThemeData t, {
    required TextEditingController controller,
    required String placeholder,
    required int minLines,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: t.textTheme.bodyMedium?.copyWith(
          color: t.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: t.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: t.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      minLines: minLines,
      maxLines: null,
    );
  }
}
