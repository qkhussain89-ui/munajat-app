// Journal screen: fully aligned with brand theme and main tabs UI pattern
// - Header matches My Duʿās/Create using inline copper gradient
// - TextFields inherit theme (no explicit style override)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/services/journal_service.dart';
import 'package:hearth_prayer/screens/journal_history_screen.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';
import 'package:hearth_prayer/screens/me/subscription_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _isSubscribed = false;
  bool _subscriptionChecked = false;

  int _selectedTab = 0; // 0 = Today, 1 = History
  // Mood tracking
  final Set<String> _selectedMoods = {};
  late Set<String> _tempSelectedMoods;
  
  // Mood options
  final List<String> _allMoods = const [
    // Keep exact order and deduplicated per spec
    'Calm',
    'Grateful',
    'Hopeful',
    'Content',
    'Anxious',
    'Heavy-hearted',
    'Overwhelmed',
    'Tired',
    'Angry',
    'Urge to Sin',
    'Confident',
    'Confused',
    'Depressed',
    'Doubtful',
    'Greedy',
    'Guilty',
    'Happy',
    'Hurt',
    'Indecisive',
    'Hypocritical',
    'Jealous',
    'Lazy',
    'Lonely',
    'Lost',
    'Nervous',
    'Regret',
    'Sad',
    'Scared',
    'Suicidal',
    'Unloved',
    'Weak',
    'Bored',
    'Impatient',
  ];
  
  // Journal entries
  final List<TextEditingController> _blessingsControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _weightsControllers = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _challengesControllers = List.generate(5, (_) => TextEditingController());
  
  // Large text fields
  final TextEditingController _duaController = TextEditingController();
  final TextEditingController _reminderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelectedMoods = Set.from(_selectedMoods);
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final isPro = await RevenueCatService().isProUser();
    final isTrial = isPro ? true : await RevenueCatService().isInTrial();
    if (mounted) {
      setState(() {
        _isSubscribed = isPro || isTrial;
        _subscriptionChecked = true;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _blessingsControllers) controller.dispose();
    for (final controller in _weightsControllers) controller.dispose();
    for (final controller in _challengesControllers) controller.dispose();
    _duaController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveEntry() async {
    final blessings = _blessingsControllers.map((c) => c.text).toList();
    final weights = _weightsControllers.map((c) => c.text).toList();
    final challenges = _challengesControllers.map((c) => c.text).toList();
    final dua = _duaController.text;
    final reminder = _reminderController.text;

    await JournalService.addEntry(
      moods: _selectedMoods.toList(),
      blessings: blessings,
      weights: weights,
      challenges: challenges,
      dua: dua,
      reminder: reminder,
    );

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Journal saved. May Allah ease your heart.'),
        duration: Duration(seconds: 2),
      ),
    );

    // Clear all fields
    setState(() {
      _selectedMoods.clear();
      for (final controller in _blessingsControllers) controller.clear();
      for (final controller in _weightsControllers) controller.clear();
      for (final controller in _challengesControllers) controller.clear();
      _duaController.clear();
      _reminderController.clear();
    });
  }

   @override
   Widget build(BuildContext context) {
     final t = Theme.of(context);
     final brandTokens = context.brandTokens;
     
     final today = DateTime.now();
     final formattedDate = DateFormat('EEE, d MMM y').format(today);

     // Subscription gate: show paywall message while checking or if expired
     if (!_subscriptionChecked) {
       return Scaffold(
         backgroundColor: t.colorScheme.background,
         body: const SafeArea(child: Center(child: CircularProgressIndicator())),
       );
     }

     if (!_isSubscribed) {
       return Scaffold(
         backgroundColor: t.colorScheme.background,
         body: SafeArea(
           child: Center(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 32),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.lock_outline, size: 48, color: t.colorScheme.primary.withOpacity(0.6)),
                   const SizedBox(height: 16),
                   Text(
                     'Subscribe to unlock your journal.',
                     textAlign: TextAlign.center,
                     style: t.textTheme.titleMedium?.copyWith(
                       color: t.colorScheme.onSurface,
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     'Start a free trial to begin journaling.',
                     textAlign: TextAlign.center,
                     style: t.textTheme.bodyMedium?.copyWith(
                       color: t.colorScheme.onSurface.withOpacity(0.6),
                     ),
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
                       onPressed: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                         );
                       },
                       child: Text(
                         'View Plans',
                         style: t.textTheme.labelLarge?.copyWith(
                           color: t.colorScheme.onPrimary,
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

     return Scaffold(
       backgroundColor: t.colorScheme.background,
       body: SafeArea(
         child: GestureDetector(
           onTap: () => FocusScope.of(context).unfocus(),
           child: SingleChildScrollView(
           physics: const BouncingScrollPhysics(),
           child: Padding(
             padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                  // Header: Journal (copper gradient)
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => brandTokens.copperGradient.createShader(bounds),
                      child: Text(
                        'Journal',
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
                  const SizedBox(height: 16),

                  // Segmented tabs: Today | History
                  Container(
                    decoration: BoxDecoration(
                      color: t.colorScheme.surface,
                      border: Border.all(
                        color: t.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTab == 0 ? t.colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              child: Text(
                                'Today',
                                style: t.textTheme.labelMedium?.copyWith(
                                  color: _selectedTab == 0 ? t.colorScheme.onPrimary : t.colorScheme.onSurface.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Visually mark Library as active before navigating
                              setState(() => _selectedTab = 1);
                              // Navigate to Library, then restore Today as active when returning
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => const JournalHistoryScreen(),
                                    ),
                                  )
                                  .then((_) {
                                if (!mounted) return;
                                setState(() => _selectedTab = 0);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedTab == 1 ? t.colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              alignment: Alignment.center,
                              child: Text(
                                'Library',
                                style: t.textTheme.labelMedium?.copyWith(
                                  color: _selectedTab == 1 ? t.colorScheme.onPrimary : t.colorScheme.onSurface.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Today • $formattedDate',
                      style: t.textTheme.labelMedium?.copyWith(
                        color: t.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),

            // Section 1: Mood inline summary
            _buildMoodSummaryRow(context, t),
            const SizedBox(height: 24),

            // Section 2: Blessings
            _buildFieldsSection(
              context,
              t,
              title: 'Blessings I Noticed Today',
              subtitle: 'Write up to 5 things Allah blessed you with today.',
              controllers: _blessingsControllers,
              placeholders: [
                'A small blessing I noticed…',
                'Time with someone I love…',
                'A moment of peace…',
                'Strength I found today…',
                'Guidance I received…',
              ],
            ),
            const SizedBox(height: 24),

            // Section 3: Weights
            _buildFieldsSection(
              context,
              t,
              title: 'What Weighed On My Heart Today',
              subtitle: 'Write up to 5 things that made your heart feel heavy.',
              controllers: _weightsControllers,
              placeholders: [
                'A worry that stayed with me today…',
                'A loss I felt…',
                'A conflict that troubled me…',
                'Sadness that visited me…',
                'A struggle I faced…',
              ],
            ),
            const SizedBox(height: 24),

            // Section 4: Challenges
            _buildFieldsSection(
              context,
              t,
              title: 'Challenges I Faced Today',
              subtitle: 'List up to 5 difficulties or tests you experienced.',
              controllers: _challengesControllers,
              placeholders: [
                'A test I encountered…',
                'A difficulty I overcame…',
                'A moment of doubt…',
                'A challenge to my patience…',
                'A trial I endured…',
              ],
            ),
            const SizedBox(height: 24),

            // Section 5: Duʿā for today
            _buildTitleSubtitle(
              t,
              title: 'My Duʿā For Today',
              subtitle: 'Based on what you wrote above, what would you like to ask Allah for?',
            ),
            const SizedBox(height: 12),
            _buildLargeTextField(
              t,
              controller: _duaController,
              placeholder: 'O Allah, help me with…',
              minLines: 4,
            ),
            const SizedBox(height: 24),

            // Section 6: Reminder
            _buildTitleSubtitle(
              t,
              title: 'A Reminder To Myself',
              subtitle: 'One gentle sentence you want to remember.',
            ),
            const SizedBox(height: 12),
            _buildLargeTextField(
              t,
              controller: _reminderController,
              placeholder: 'Allah has not forgotten me.',
              minLines: 2,
            ),
            const SizedBox(height: 32),

            // Save button
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
                onPressed: _handleSaveEntry,
                child: Text(
                   'Save journal entry',
                   style: t.textTheme.labelLarge?.copyWith(
                     color: t.colorScheme.onPrimary,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
              ),
            ),
            const SizedBox(height: 24),
              ],
            ),
          ),
        ),
         ),
      ),
    );
  }

  Widget _buildMoodSummaryRow(BuildContext context, ThemeData t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleSubtitle(t, title: 'How Are You Feeling Today?'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _showMoodPickerSheet,
          child: Container(
            decoration: BoxDecoration(
              color: t.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: t.colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedMoods.isEmpty)
                  Text(
                    'Tap to choose up to 3 moods.',
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: t.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  )
                else
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: _selectedMoods.take(3).map((mood) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: t.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            mood,
                            style: t.textTheme.labelSmall?.copyWith(
                              color: t.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (_selectedMoods.isNotEmpty)
                  Text(
                    'Edit',
                    style: t.textTheme.labelSmall?.copyWith(
                      color: t.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMoodPickerSheet() {
    _tempSelectedMoods = Set.from(_selectedMoods);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final t = Theme.of(context);
            final showError = _tempSelectedMoods.length > 3;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'How are you feeling today?',
                    style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle
                  Text(
                    'Choose up to 3 moods that fit you best.',
                    style: t.textTheme.labelSmall?.copyWith(
                      color: t.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mood chips (scrollable area with fixed max height; layout otherwise unchanged)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allMoods.map((mood) {
                          final isSelected = _tempSelectedMoods.contains(mood);
                          final canSelect = !showError || isSelected;

                          return GestureDetector(
                            onTap: canSelect
                                ? () {
                                    setModalState(() {
                                      if (isSelected) {
                                        _tempSelectedMoods.remove(mood);
                                      } else {
                                        _tempSelectedMoods.add(mood);
                                      }
                                    });
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? t.colorScheme.primary : t.colorScheme.surface,
                                border: Border.all(
                                  color: isSelected
                                      ? t.colorScheme.primary
                                      : t.colorScheme.outline.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                mood,
                                style: t.textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? t.colorScheme.onPrimary
                                      : t.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Error message
                  if (showError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'You can choose up to 3 moods.',
                        style: t.textTheme.labelSmall?.copyWith(
                          color: t.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Clear selection button
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _tempSelectedMoods.clear();
                      });
                    },
                    child: Text(
                      'Clear selection',
                      style: t.textTheme.labelLarge?.copyWith(
                        color: t.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Save button
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
                      onPressed: () {
                        setState(() {
                          _selectedMoods.clear();
                          _selectedMoods.addAll(_tempSelectedMoods);
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Save moods',
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
          },
        );
      },
    );
  }

  Widget _buildFieldsSection(
    BuildContext context,
    ThemeData t, {
    required String title,
    required String subtitle,
    required List<TextEditingController> controllers,
    required List<String> placeholders,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleSubtitle(t, title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        Container(
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
        ),
      ],
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

  Widget _buildTitleSubtitle(
    ThemeData t, {
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.textTheme.titleMedium?.copyWith(
            color: t.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: t.textTheme.labelSmall?.copyWith(
              color: t.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
