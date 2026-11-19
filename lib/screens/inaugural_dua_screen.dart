import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math';
import 'package:hearth_prayer/services/dua_service.dart';
import 'package:hearth_prayer/services/folder_service.dart';
import 'package:hearth_prayer/services/user_service.dart';
import 'package:hearth_prayer/models/user.dart';

class InauguralDuaScreen extends StatefulWidget {
  final User user;
  const InauguralDuaScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<InauguralDuaScreen> createState() => _InauguralDuaScreenState();
}

class _InauguralDuaScreenState extends State<InauguralDuaScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = false;
  String _selectedLanguage = 'English';
  bool _showLanguageMenu = false;
  bool _isSaving = false;

  final Map<String, String> _duaTexts = {
    'English': '''All praise is due to Allah, Lord of all creation, the Most Merciful, the Ever-Merciful, Master of the Day of Judgement. All praise belongs to Him who hears every whispered plea, who knows what lies hidden in every heart, and who responds to the desperate one when they call upon Him. He is the One who guides the lost, strengthens the weak, and opens doors that no force in creation can close. He is perfect in His knowledge, absolute in His wisdom, and boundless in His generosity.

O Allah, send Your peace and blessings upon the Prophet Muhammad, upon his family and his companions.

Y\u0101 Ra\u1e25m\u0101n, You whose mercy encompasses all things and reaches every soul that turns to You in need, we come before You with this tool \u2014 Mun\u0101j\u0101t \u2014 a humble means by which Your servants may learn to call upon You as You deserve to be called upon. Y\u0101 Mu\u02bballim, You who teach hearts what they did not know, make this app a teacher for those who struggle to find words when they stand before You, for those who yearn to know You through Your Beautiful Names but do not know where to begin.

Y\u0101 Muj\u012bb, You who respond to the one who calls upon You, make this app a bridge between Your servants and Your mercy. When someone opens it in the stillness of the night, weighed down by worry they cannot voice, grant that it helps them pour out their heart to You in a way that is pleasing to You. When someone turns to it in a moment of desperation, not knowing how to ask for what they need, let it guide them to invoke You by the Names that unlock Your treasuries of provision, healing, forgiveness, and peace.

Y\u0101 Fatt\u0101\u1e25, You who open what no one can close, open the hearts of millions through this app. Let it be a means by which Muslims across the world \u2014 from every language, every land, every circumstance \u2014 grow closer to You. Make it a tool that reminds the forgetful, comforts the grieving, empowers the anxious, and lifts the broken. Let every du\u2019a created through it be rooted in Your Book and the Sunnah of Your Messenger \uFDFA, free from innovation, free from error, and filled with the reverence You alone deserve.

Y\u0101 \u02bbAl\u012bm, You who know all things, You know the intention behind this work. It was not built for fame, nor for pride, nor for any purpose except to serve Your servants and to help them turn their faces to You. Accept this effort, imperfect as it is, and make it a means of continuous reward for all who contributed to it \u2014 those who wrote its code, those who refined its words, those who tested it, and those who will one day use it to call upon You. Let every du\u2019a made through Mun\u0101j\u0101t be recorded as a good deed for all of us, and let those good deeds weigh heavy on the scales on the Day we meet You.

Y\u0101 Mann\u0101n, You who bestow without being asked and give without measure, place barakah in this app. Let its reach be vast, its impact deep, and its life long. Let it spread across continents and languages, into the hands of the elderly who have prayed all their lives but never knew Your Names, into the hearts of the young who are searching for You but do not know how to speak to You, into the lives of the broken who think You have turned away from them, and into the souls of the sinners who believe they are beyond Your mercy.

Make this app a means by which people learn that You are al-Taww\u0101b \u2014 that You love to forgive more than they love to be forgiven. Let them learn that You are al-La\u1e6d\u012bf \u2014 that You are aware of every hidden pain and every unspoken need. Let them memorize Your Names not as mere words, but as windows into who You are, so that when calamity strikes, they know to call upon al-Mu\u02bb\u012bn, and when they are lost, they know to seek al-H\u0101d\u012b, and when they are afraid, they know to take refuge in al-\u1e24af\u012b\u1e93.

L\u0101 il\u0101ha ill\u0101 Anta, Sub\u1e25\u0101naka, inn\u012b kuntu min al-\u1e93\u0101lim\u012bn. There is no deity worthy of worship except You, Glorified are You, truly I have been among the wrongdoers.

O Allah, forgive us for every shortcoming in this work. Forgive us for the moments we relied on our own ability instead of turning to You. Forgive us for any word written in haste, any feature built with arrogance, any decision made without seeking Your guidance. Cover our faults, pardon our mistakes, and let this app be judged not by its imperfections, but by the sincerity of the intention behind it.

Y\u0101 Kar\u012bm, You who are generous beyond measure, make this app a source of provision for those who built it, but let that provision never distract them from why it was built. Let the wealth it generates be \u1e25al\u0101l, blessed, and a means of drawing closer to You. And as You provide through it, let 10% of every penny earned be a charity that reaches orphans, widows, the hungry, and the displaced. Let that charity be a purification, a protection, and a means of multiplying reward.

Y\u0101 Wak\u012bl, You upon whom we rely, we place our trust in You alone. If this app is good for the d\u012bn of those who use it, and good for their hearts, and good for their \u0101khirah, then spread it far and wide and make it a tool of Your mercy. But if there is any harm in it \u2014 any hidden fault, any theological error we could not see, any way it might lead people astray \u2014 then stop it from spreading, and guide us to correct it or to let it go. We want only what You want, and we seek refuge in You from building something that earns Your displeasure.

Y\u0101 Shak\u016br, You who multiplies the reward of the smallest deed, let every person who makes a du\u2019a through this app have their supplication answered. Let the one who asks for forgiveness be forgiven. Let the one who seeks provision be provided for. Let the one who cries out in pain be healed. Let the one who is lost be guided. And when their du\u2019as are answered, let them know it was You \u2014 not the app, not the code, not the words \u2014 but You alone who heard them and responded.

Make this app a means by which people fall in love with calling upon You. Let them return to it again and again, not out of habit, but out of longing \u2014 because they have tasted the sweetness of speaking to You, and they want more of it. Let it become a companion in their loneliest nights, a teacher in their most desperate moments, and a reminder that no matter how far they have strayed, Your door is always open.

Y\u0101 Ra\u1e25\u012bm, You who are especially merciful to those who turn to You, let this app be a mercy upon the ummah of Mu\u1e25ammad \uFDFA. Let it unite us in calling upon You, across every border, every language, every difference that divides us. Let it remind us that we are all beggars at Your door, and that in our shared neediness, we are one.

This is my du\u2019\u0101 and upon You is the response. This is my effort and upon You is the reliance. There is no might nor power except with You.

O Allah, send Your peace and blessings upon the Prophet Muhammad, upon his family and his companions.

Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.

\u0100m\u012bn.''',

    'Arabic': '[PLACEHOLDER \u2014 Will be translated post-launch]',
    'Urdu': '[PLACEHOLDER \u2014 Will be translated post-launch]',
    'Turkish': '[PLACEHOLDER \u2014 Will be translated post-launch]',
    'Bahasa': '[PLACEHOLDER \u2014 Will be translated post-launch]',
    'Chinese': '[PLACEHOLDER \u2014 Will be translated post-launch]',
    'French': '[PLACEHOLDER \u2014 Will be translated post-launch]',
    'Spanish': '[PLACEHOLDER \u2014 Will be translated post-launch]',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScroll);
  }

  void _checkScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final threshold = maxScroll - 50;

      if (currentScroll >= threshold && !_isScrolledToBottom) {
        setState(() => _isScrolledToBottom = true);
      }
    }
  }

  Future<void> _onAmeenPressed() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Navigate back to Me screen (no database operations needed)
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFFFDF9),
      body: Stack(
        children: [
          // Animated copper gradient background
          _buildAnimatedBackground(isDark),

          // Glassmorphism modal
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.85)
                    : const Color(0xFFFFFDF9).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFD4A574).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    children: [
                      _buildHeader(context, isDark),
                      Expanded(child: _buildDuaText(context, isDark)),
                      _buildFooter(context, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Language menu overlay
          if (_showLanguageMenu) _buildLanguageMenu(context, isDark),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 3),
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFFB87333),
                  Color(0xFFFFD9A0),
                  Color(0xFFB87333),
                ],
                stops: [0.0, value, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        children: [
          const Text('\uD83D\uDD4C', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),

          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFB87333), Color(0xFFFFD9A0)],
            ).createShader(bounds),
            child: Text(
              'The Founding Du\u02bb\u0101 of Mun\u0101j\u0101t',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Language selector button
          GestureDetector(
            onTap: () => setState(() => _showLanguageMenu = !_showLanguageMenu),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD4A574).withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\uD83C\uDF10', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    _selectedLanguage,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDuaText(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Text(
        _duaTexts[_selectedLanguage]!,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w300,
          height: 1.8,
          color: isDark
              ? const Color(0xFFFFFDF9).withOpacity(0.95)
              : Colors.black.withOpacity(0.9),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          const Text('\uD83E\uDD32', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_isScrolledToBottom && !_isSaving) ? _onAmeenPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScrolledToBottom
                    ? const Color(0xFFB87333)
                    : const Color(0xFFD4A574).withOpacity(0.3),
                disabledBackgroundColor: const Color(0xFFD4A574).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: _isScrolledToBottom ? 4 : 0,
                shadowColor: _isScrolledToBottom
                    ? const Color(0xFFB87333).withOpacity(0.4)
                    : Colors.transparent,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isScrolledToBottom ? '\u0100m\u012bn' : 'Scroll to continue',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageMenu(BuildContext context, bool isDark) {
    final languages = {
      'English': '\uD83C\uDDEC\uD83C\uDDE7',
      'Arabic': '\uD83C\uDDF8\uD83C\uDDE6',
      'Urdu': '\uD83C\uDDF5\uD83C\uDDF0',
      'Turkish': '\uD83C\uDDF9\uD83C\uDDF7',
      'Bahasa': '\uD83C\uDDEE\uD83C\uDDE9',
      'Chinese': '\uD83C\uDDE8\uD83C\uDDF3',
      'French': '\uD83C\uDDEB\uD83C\uDDF7',
      'Spanish': '\uD83C\uDDEA\uD83C\uDDF8',
    };

    return GestureDetector(
      onTap: () => setState(() => _showLanguageMenu = false),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(150),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Center globe icon
                const Center(
                  child: Text('\uD83C\uDF10', style: TextStyle(fontSize: 48)),
                ),

                // Radial language buttons
                ...languages.entries.map((entry) {
                  final index = languages.keys.toList().indexOf(entry.key);
                  final angle = (index * 2 * pi) / languages.length - pi / 2;
                  const radius = 110.0;
                  final x = 150 + radius * cos(angle);
                  final y = 150 + radius * sin(angle);

                  return Positioned(
                    left: x - 30,
                    top: y - 30,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = entry.key;
                          _showLanguageMenu = false;
                        });
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _selectedLanguage == entry.key
                              ? const Color(0xFFB87333)
                              : (isDark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF5F5F5)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
