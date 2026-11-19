import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

/// Etiquettes of Duʿāʾ — accordion presentation matching Mission styling
class EtiquettesOfDuaCanonicalScreen extends StatefulWidget {
  const EtiquettesOfDuaCanonicalScreen({super.key});

  @override
  State<EtiquettesOfDuaCanonicalScreen> createState() => _EtiquettesOfDuaCanonicalScreenState();
}

class _EtiquettesOfDuaCanonicalScreenState extends State<EtiquettesOfDuaCanonicalScreen> {
  int? _openIndex; // null => all collapsed

  @override
  Widget build(BuildContext context) {
    debugPrint('ETIQUETTES_CANONICAL_SCREEN_RENDERED_ACCORDION');
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brand = context.brandTokens;

    TextStyle? body([double? opacity]) => theme.textTheme.bodyLarge?.copyWith(
          height: 1.45,
          color: colors.onSurface.withValues(alpha: opacity ?? 0.92),
        );

    TextStyle? header() => theme.textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        );

    Widget gradientText(String text, TextStyle? base, {TextAlign align = TextAlign.start}) {
      if (base == null) return Text(text, textAlign: align, maxLines: 2, softWrap: true, overflow: TextOverflow.visible);
      return ShaderMask(
        shaderCallback: (bounds) => brand.copperGradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Text(
          text,
          textAlign: align,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.visible,
          style: base.copyWith(color: Colors.white),
        ),
      );
    }

    Widget panelContainer({required Widget child}) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: brand.border),
            boxShadow: [brand.cardShadowLight],
          ),
          child: child,
        );

    String _stripSectionPrefix(String s) {
      final re = RegExp(r'^section\s*\d+\s*[—\-]\s*', caseSensitive: false);
      return s.replaceFirst(re, '');
    }

    Widget accordionHeader({required String title, required bool expanded, required VoidCallback onTap}) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            // Slightly increased vertical padding for balanced two-line headers
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              // Title area expands and wraps to two lines max.
              Expanded(
                child: Builder(builder: (context) {
                  final base = theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w500);
                  final text = _stripSectionPrefix(title);
                  if (expanded) {
                    return gradientText(
                      text,
                      base,
                      align: TextAlign.center,
                    );
                  }
                  return Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.visible, // prevent clipping of parenthetical text
                    style: base?.copyWith(color: colors.onSurface.withValues(alpha: 0.9)),
                  );
                }),
              ),
              // Fixed-width trailing chevron container prevents overlap and keeps uniform alignment
              SizedBox(
                width: 36,
                child: Center(
                  child: AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.chevron_right,
                      color: expanded ? theme.colorScheme.primary : colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );

    Widget accordionSection({required int index, required String title, required Widget bodyChild}) {
      final isOpen = _openIndex == index;
      return panelContainer(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          accordionHeader(
            title: title,
            expanded: isOpen,
            onTap: () => setState(() => _openIndex = isOpen ? null : index),
          ),
          AnimatedCrossFade(
            crossFadeState: isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
            firstChild: Padding(padding: const EdgeInsets.only(top: 10), child: bodyChild),
            secondChild: const SizedBox.shrink(),
          ),
        ]),
      );
    }

    // Introduction body — plain text per spec (no card, no header)
    const String introCopy = '''Before a request is formed, duʿāʾ is a turning of the heart.
Before words are chosen, it is a decision to face Allah as a servant in need.

Duʿāʾ is not measured by length or eloquence.
It is shaped by sincerity, presence, and the state of the one who calls.

The Messenger of Allah ﷺ taught us that duʿāʾ has an adab —
an outward way that aligns the tongue,
and an inward reality that gives the supplication its weight.

What follows is a guided path through the etiquettes of duʿāʾ —
from preparing the heart,
to opening the request,
to trusting Allah with the outcome.

Move through it slowly.
Open what you need.
Let it shape how you stand before Allah.''';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 44,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: theme.colorScheme.secondary),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          tooltip: 'Back',
        ),
        actions: const [SizedBox(width: 44)],
        shape: Border(bottom: BorderSide(color: brand.border.withValues(alpha: 0.35), width: 1)),
        title: ShaderMask(
          shaderCallback: (bounds) => brand.copperGradient.createShader(bounds),
          child: Text(
            'Etiquettes of Duʿāʾ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: theme.textTheme.titleLarge?.fontSize ?? 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Introduction (plain text on background; editorial hierarchy only)
                // Align intro text with the same horizontal content column as cards (26px)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: _IntroductionRenderer(intro: introCopy),
                ),
                const SizedBox(height: 18),

                // Sections 1–7 (collapsed by default, single-open accordion)
                accordionSection(
                  index: 1,
                  title: 'SECTION 1 — The Foundation (What Duʿāʾ Stands On)',
                  bodyChild: _SectionBodyRenderer(
                    text: 'Before words are spoken, before hands are raised — du\'ā\' begins in the heart.\n\nDu\'ā\' is not merely speech. It is an act of worship, and like all worship, it rests upon sincerity.\n\nAllah ﷻ says:\n\n"So call upon Allah, being sincere to Him in religion."\n(Ghāfir 40:14)\n\nA heart divided between Allah and creation struggles to rise fully in supplication.\n\nThe Messenger of Allah ﷺ said:\n\n"Call upon Allah while you are certain of a response, and know that Allah does not accept a supplication from a heedless, distracted heart."\n(Sunan al-Tirmidhī 3479 — Ḥasan)\n\nDu\'ā\' is received according to the state of presence. The tongue may move, but it is the heart that arrives.\n\nYaqīn (firm conviction) carries du\'ā\' forward. It is a settled certainty that Allah hears, sees, knows, and responds — even when the response has not yet appeared.\n\nAllah ﷻ says:\n\n"And when My servants ask you concerning Me — indeed, I am near."\n(Al-Baqarah 2:186)\n\nNear in knowledge. Near in response. Near in mercy.\n\nTo stand before Allah in du\'ā\' is to recognise a single truth: complete need.\n\nAllah ﷻ says:\n\n"O mankind, you are those in need of Allah — and Allah is the One Free of all need, the Praiseworthy."\n(Fāṭir 35:15)\n\nDu\'ā\' rises from humility, dependence, and a quiet awareness of who stands before whom. Brokenness gives du\'ā\' its strength.\n\nThe early scholars said that the most powerful du\'ā\' is not the most eloquent — but the one spoken by a heart that knows its Lord and knows itself.\n\nThis foundation transforms du\'ā\' from routine into worship.',
                    style: body(),
                  ),
                ),

                accordionSection(
                  index: 2,
                  title: 'SECTION 2 — Preparing the Moment (Before You Speak)',
                  bodyChild: _SectionBodyRenderer(
                    text: 'Du\'ā\' is shaped before it is spoken. The moments that precede supplication prepare the heart to stand properly before Allah.\n\nWhen the heart is settled, du\'ā\' gains weight. When it is scattered, words lose their force.\n\nPresence is the first preparation. A heart awake to Allah is more receptive than a tongue fluent in words.\n\nThe Messenger of Allah ﷺ said:\n\n"Allah does not respond to the supplication of a heedless, distracted heart."\n(Sunan al-Tirmidhī 3479 — Ḥasan)\n\nChoosing the moment carries wisdom. Certain times are marked by greater openness and mercy:\n\n• The last third of the night — Allah descends to the lowest heaven and says: "Is there anyone who calls upon Me so that I may respond?"\n(Ṣaḥīḥ al-Bukhārī 1145, Ṣaḥīḥ Muslim 758)\n\n• While in sujūd — "The closest a servant is to his Lord is when he is in prostration, so increase your supplication therein."\n(Ṣaḥīḥ Muslim 482)\n\n• Between the adhān and iqāmah — "A du\'ā\' made between the adhān and iqāmah is not rejected."\n(Sunan al-Tirmidhī 212 — Ṣaḥīḥ)\n\n• On the day of Jumuʿah — There is an hour on Friday in which no Muslim asks Allah for something except that He gives it to him.\n(Ṣaḥīḥ al-Bukhārī 935, Ṣaḥīḥ Muslim 852)\n\n• During rain\n\n• While fasting — "Three supplications are not rejected: the supplication of a fasting person..."\n(Sunan al-Tirmidhī 3598 — Ḥasan)\n\nDu\'ā\' is always permitted. Seeking moments beloved to Allah is part of reverence.\n\nOutward preparation gently gathers the heart:\n\n• Performing wuḍū\'\n• Facing the qiblah\n• Raising the hands\n• Beginning with praise of Allah and ṣalawāt upon the Prophet ﷺ\n\nThese are not conditions — du\'ā\' is accepted in any state — but they are praiseworthy acts that settle the heart before speaking.',
                    style: body(),
                  ),
                ),

                accordionSection(
                  index: 3,
                  title: 'SECTION 3 — Opening the Door (How Duʿāʾ Begins)',
                  bodyChild: _SectionBodyRenderer(
                    text: 'Every du\'ā\' should begin with three things, in order:\n\n1. Praising Allah ﷻ\n\nThe Prophet ﷺ heard a man making du\'ā\' without praising Allah or sending ṣalawāt. He said: "He was too hasty." Then he called him and said: "When one of you makes du\'ā\', he should start by praising and glorifying his Lord, then send ṣalawāt upon the Prophet, then ask for whatever he wishes."\n(Sunan Abū Dāwūd 1481 — Ṣaḥīḥ)\n\nPraising Allah can be done through:\n— His own words from the Qur\'ān (the greatest form of praise)\n— The words of the Prophet ﷺ\n— The words of the companions and righteous predecessors\n— One\'s own heartfelt words, provided they do not contradict sound belief\n— His Beautiful Names\n\n2. Sending Ṣalawāt upon the Prophet ﷺ\n\nAllah ﷻ says:\n\n"Indeed, Allah and His angels send blessings upon the Prophet. O you who believe, invoke Allah to bless him, and send your salām to him in abundance."\n(Al-Aḥzāb 33:56)\n\n\'Umar ibn al-Khaṭṭāb (raḍiyallāhu \'anhu) said: "Du\'ā\' is suspended between the heaven and the earth, and none of it ascends until you send ṣalawāt upon your Prophet ﷺ."\n\nṢalawāt at the beginning, in the middle, and at the end of du\'ā\' is recommended. It is the wing that lifts du\'ā\' upward.\n\n3. Asking Allah Through His Beautiful Names and His Oneness\n\nAllah ﷻ says:\n\n"To Allah belongs the Most Beautiful Names, so call on Him by them."\n(Al-A\'rāf 7:180)\n\nProphet Yūnus (\'alayhis-salām) called out from the belly of the whale:\n\n"There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers."\n(Al-Anbiyā\' 21:87)\n\nThe Prophet ﷺ said that no one supplicates with this du\'ā\' except that it is answered.\n(Sunan al-Tirmidhī 3505 — Ḥasan)\n\nWhen calling upon Allah with His Names, match the Name to your need: Yā Razzāq for provision, Yā Shāfī for cure, Yā Tawwāb for forgiveness. Remove the "al-" when calling upon Him directly.',
                    style: body(),
                  ),
                ),

                accordionSection(
                  index: 4,
                  title: 'SECTION 4 — Clearing the Path (Removing Barriers)',
                  bodyChild: _SectionBodyRenderer(
                    text: 'Before asking Allah for what you need, ask Him to forgive you for what you have done.\n\nAllah ﷻ says:\n\n"Say: O My slaves who have transgressed against themselves, do not despair of the mercy of Allah. Truly Allah forgives all sins."\n(Al-Zumar 39:53)\n\nThe Prophet ﷺ said that Allah said: "Son of Ādam, as long as you call upon Me and hope in Me, I will forgive you irrespective of what you do, and I do not care. Son of Ādam, even if your sins were to reach the clouds of the sky, then you seek forgiveness from Me, I will forgive you."\n(Sunan al-Tirmidhī 3540 — Ḥasan)\n\nIbn Rajab (raḥimahullāh) identified three means of attaining forgiveness:\n— Calling upon Allah with hope, knowing that only He forgives\n— Seeking forgiveness despite the magnitude of one\'s sins\n— Actualising tawḥīd — the greatest means of forgiveness\n\nThe master supplication for forgiveness (Sayyid al-Istighfār):\n\nاللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ ، خَلَقْتَنِي وَأَنَا عَبْدُكَ ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي ، فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ\n\n"O Allah, You are my Lord. There is no deity except You. You created me and I am Your servant, and I am upon Your covenant and Your promise as much as I am able. I seek refuge in You from the evil of what I have done. I acknowledge Your favour upon me and I acknowledge my sin, so forgive me — for none forgives sins except You."\n(Ṣaḥīḥ al-Bukhārī 6306)\n\nWhen seeking forgiveness, try to feel the remorse in your heart. Cry over your sins and beg Allah to forgive you.\n\nSins create barriers between the servant and his Lord. Istighfār clears the path before you ask.',
                    style: body(),
                  ),
                ),

                accordionSection(
                  index: 5,
                  title: 'SECTION 5 — The Heart of Duʿāʾ (Munājāt)',
                  bodyChild: _SectionBodyRenderer(
                    text: 'This is the essence of what this app is named after. Munājāt is intimate, private conversation with your Lord — not just asking, but pouring out.\n\nAllah ﷻ says about Prophet Zakariyyā (\'alayhis-salām):\n\n"When he called upon his Lord in a secret call. He said: \'My Lord, my bones have weakened, and my head has turned white with age. But never, my Lord, has my prayer to You remained unanswered.\'"\n(Maryam 19:3-4)\n\nThough Allah already knew Zakariyyā\'s condition, he still described it. Allah loves to hear His servants speak to Him intimately and pour out their hearts.\n\nThe secret of du\'ā\' is utter desperation and brokenness before Allah.\n\nAt the height of his victory on the plains of \'Arafah, the Prophet ﷺ raised his hands and said: "O Allah, You hear my speech… I am the desperate and needy one, the one who is seeking Your help and protection, fearful and scared, the one who confesses and acknowledges his sins."\n(al-Ṭabarānī — Ḥasan)\n\nAt his highest point, nothing but humility.\n\nKey inner states for du\'ā\':\n\n• Make du\'ā\' in secret — Al-Ḥasan al-Baṣrī (raḥimahullāh) said: "Du\'ā\' performed privately is 70 times more virtuous than du\'ā\' performed openly." Allah says: "Supplicate to your Lord humbly and secretly." (Al-A\'rāf 7:55)\n\n• Be persistent — The Prophet ﷺ used to repeat his du\'ā\' three times. (Ṣaḥīḥ Muslim) Allah loves those who return to Him again and again.\n\n• Be present and mindful — Know what you are asking for and Who you are asking from. The scholars unanimously agreed that du\'ā\' made with a heedless heart has no effect.\n\n• Converse intimately — This is at-tamalluq: speaking to Allah with soft, loving words. Not merely asking, but praising, pleading, pouring out your brokenness.',
                    style: body(),
                  ),
                ),

                accordionSection(
                  index: 6,
                  title: 'SECTION 6 — Asking Properly (The Manner of Request)',
                  bodyChild: _SectionBodyRenderer(
                    text: 'Be assertive in your du\'ā\'.\n\nThe Prophet ﷺ said: "None of you should say, \'O Allah, forgive me if You will.\' Let him be firm in his request, for no one can compel Allah."\n(Ṣaḥīḥ al-Bukhārī 6339, Ṣaḥīḥ Muslim 2679)\n\nAsk clearly and confidently, with humility in your heart and trust in Allah\'s generosity.\n\nBe ambitious — ask for everything.\n\nThe Prophet ﷺ said: "When one of you asks for something from Allah, then let him be plentiful in what he asks for, for indeed he is asking his Lord."\n(Ṣaḥīḥ Ibn Ḥibbān)\n\nIn another ḥadīth: "When you ask Allah, ask for al-Firdaws" — the highest level of Jannah.\n(Sunan al-Tirmidhī 2530 — Ṣaḥīḥ)\n\nDo not limit your du\'ā\' to only what you perceive as possible. Nothing is too big for the One being asked, and nothing is too small for the one asking Him.\n\nIbn Rajab (raḥimahullāh) said: "Some of the pious predecessors would ask Allah for everything, even when they needed salt for dough and grass for the sheep."\n\nPlace complete hope in Allah alone.\n\nAllah says in a ḥadīth qudsī: "I am as My servant thinks of Me."\n(Ṣaḥīḥ al-Bukhārī 7405, Ṣaḥīḥ Muslim 2675)\n\nIbn Mas\'ūd (raḍiyallāhu \'anhu) said: "No servant ever had good expectations of Allah except that Allah gave him what he hoped for, because all goodness is in His Hands."\n\nBe certain that Allah will answer.\n\nThe Prophet ﷺ said: "No Muslim makes du\'ā\' which does not entail a sin or the severing of ties of kinship without Allah giving him one of three: He fulfils his du\'ā\' immediately, He stores it for him in the hereafter, or He averts from him a similar evil."\n\nThe companions said: "If that is so, we will make du\'ā\' even more." He ﷺ replied: "Allah will respond even more."\n(Musnad Aḥmad — Ṣaḥīḥ according to al-Albānī)',
                    style: body(),
                  ),
                ),

                accordionSection(
                  index: 7,
                  title: 'SECTION 7 — Trust & Outcome (After Āmīn)',
                  bodyChild: _SectionBodyRenderer(
                    text: 'After raising your hands and pouring your heart out — trust Allah with the outcome.\n\nDo not be impatient.\n\nThe Prophet ﷺ said: "The du\'ā\' of every one of you is accepted as long as he does not grow impatient and says: \'I made du\'ā\' but it was not accepted.\'"\n(Ṣaḥīḥ Muslim 2735)\n\nDo not become despondent.\n\nEven after prolonged supplications and patience, never think your du\'ā\' has been rejected. Remain optimistic and ignore the demoralising whispers of Shayṭān.\n\nAllah ﷻ says: "I am just as My slave thinks I am."\n(Ṣaḥīḥ al-Bukhārī 7405)\n\nMake abundant du\'ā\' in times of ease.\n\nThe Prophet ﷺ said: "Remember Allah during times of ease and He will remember you during times of hardship."\n(Musnad Aḥmad — Ṣaḥīḥ)\n\nEnd your du\'ā\' as you began it.\n\nClose with praise of Allah, ṣalawāt upon the Prophet ﷺ, and trust that what you have asked has been heard by the One who never forgets, never sleeps, and never turns away a sincere heart.',
                    style: body(),
                  ),
                ),

                // Final Conclusion/Summary — OMITTED per spec if no explicit conclusion exists in current copy
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionBodyRenderer extends StatelessWidget {
  const _SectionBodyRenderer({required this.text, required this.style});

  final String text;
  final TextStyle? style;

  List<String> _toParagraphs(String input) {
    final lines = input.split('\n');
    final paragraphs = <String>[];
    final buffer = StringBuffer();
    for (final raw in lines) {
      final line = raw.replaceAll('\r', '');
      if (line.trim().isEmpty) {
        if (buffer.isNotEmpty) {
          paragraphs.add(buffer.toString());
          buffer.clear();
        }
      } else {
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(line);
      }
    }
    if (buffer.isNotEmpty) paragraphs.add(buffer.toString());
    return paragraphs;
  }

  bool _isLeadIn(String p) {
    final t = p.trim();
    if (!t.endsWith(':')) return false;
    final l = t.toLowerCase();
    return l.contains('allah') || l.contains('messenger') || l.contains('prophet') || l.endsWith('said:');
  }

  bool _isCitation(String p) {
    final t = p.trim();
    if (t.startsWith('(') && t.endsWith(')')) return true;
    final l = t.toLowerCase();
    final re = RegExp(r"\b(qur['']?an|bukhārī|muslim|tirmidhī|abū dāwūd)\b");
    return re.hasMatch(l);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final paragraphs = _toParagraphs(text);
    const double gap = 12;

    final children = <Widget>[];
    int i = 0;
    while (i < paragraphs.length) {
      final p = paragraphs[i];
      if (_isLeadIn(p)) {
        children.add(Text(p, style: style?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.95))));
        children.add(const SizedBox(height: 8));

        if (i + 1 < paragraphs.length) {
          final quote = paragraphs[i + 1];
          String? citation;
          if (i + 2 < paragraphs.length && _isCitation(paragraphs[i + 2])) {
            citation = paragraphs[i + 2];
          }

          children.add(Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: cs.outline.withValues(alpha: 0.35), width: 3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(quote, style: style),
              if (citation != null) ...[
                const SizedBox(height: 6),
                Text(citation, style: style?.copyWith(color: cs.onSurface.withValues(alpha: 0.8))),
              ],
            ]),
          ));
          children.add(const SizedBox(height: gap));

          i += 1 + (citation == null ? 0 : 1);
        }
      } else {
        children.add(Text(p, style: style));
        if (i < paragraphs.length - 1) children.add(const SizedBox(height: gap));
      }
      i += 1;
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class _IntroductionRenderer extends StatelessWidget {
  const _IntroductionRenderer({required this.intro});

  final String intro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Split into paragraph blocks by blank lines
    final paragraphs = intro.split('\n\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (paragraphs.isEmpty) return const SizedBox.shrink();

    final body = theme.textTheme.bodyLarge?.copyWith(height: 1.62, color: cs.onSurface.withValues(alpha: 0.92));
    final lead = body?.copyWith(fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 14) + 1.5, fontWeight: FontWeight.w500, height: 1.5, color: cs.onSurface.withValues(alpha: 0.95));

    final widgets = <Widget>[];

    // First paragraph block: slightly larger + medium weight
    widgets.add(Text(paragraphs.first, style: lead, softWrap: true));

    // Middle paragraphs: normal body, increased line height
    for (int i = 1; i < paragraphs.length - 1; i++) {
      widgets.add(const SizedBox(height: 10));
      widgets.add(Text(paragraphs[i], style: body, softWrap: true));
    }

    // Final short guidance lines: split into lines with extra spacing
    final last = paragraphs.last.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (last.isNotEmpty) {
      widgets.add(const SizedBox(height: 12));
      for (int i = 0; i < last.length; i++) {
        widgets.add(Text(last[i], style: body, softWrap: true));
        if (i != last.length - 1) widgets.add(const SizedBox(height: 10));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
