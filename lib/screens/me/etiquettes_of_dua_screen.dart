import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';

/// Etiquettes of Duʿāʾ
/// Structured, scrollable article framework (placeholders only) matching Mission Gate styling.
class EtiquettesOfDuaScreen extends StatelessWidget {
  const EtiquettesOfDuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brand = context.brandTokens;

    TextStyle? bodyStyle([double? size, double? opacity]) => theme.textTheme.bodyLarge?.copyWith(
          fontSize: size ?? 16,
          height: 1.56,
          color: colors.onSurface.withValues(alpha: opacity ?? 0.9),
        );

    TextStyle? smallStyle([double? opacity]) => theme.textTheme.bodyMedium?.copyWith(
          height: 1.5,
          color: colors.onSurface.withValues(alpha: opacity ?? 0.8),
        );

    TextStyle? headerStyle() => theme.textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        );

    Widget gradientText(String text, TextStyle? base, {TextAlign align = TextAlign.start}) {
      if (base == null) return Text(text, textAlign: align);
      return ShaderMask(
        shaderCallback: (bounds) => brand.copperGradient.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Text(text, textAlign: align, style: base.copyWith(color: Colors.white)),
      );
    }

    Widget sectionHeader(String text) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: gradientText(text, headerStyle()),
        );

    Widget goldDivider() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Divider(
            height: 1,
            thickness: 1,
            color: brand.divider.withValues(alpha: 0.2),
          ),
        );

    Widget bullet(String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: smallStyle(0.9))),
            ],
          ),
        );

    Widget numbered(int n, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$n.', style: smallStyle(0.9)?.copyWith(color: colors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: smallStyle(0.9))),
            ],
          ),
        );

    Widget accordionTitle(String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        );

    Widget accordionBlock(String title, {Widget? content}) => _AccordionBlock(title: title, content: content);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etiquettes of Duʿāʾ'),
      ),
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1 — Opening Anchor
                  Center(
                    child: gradientText(
                      'بِسْمِ ٱللَّٰهِ',
                      theme.textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
                      align: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Duʿāʾ is not merely words spoken — it is a meeting of the heart with its Lord.',
                    style: bodyStyle(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acceptance is not unlocked by eloquence, but by sincerity, humility, and truthfulness before Allah.',
                    style: bodyStyle(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This guide walks you through the Sunnah way of calling upon Allah — outwardly and inwardly.',
                    style: bodyStyle(16, 0.8),
                  ),
                  goldDivider(),

                  // SECTION 2 — Overview / Mental Map
                  sectionHeader('An Overview'),
                  Text(
                    'Duʿāʾ has an outward method taught by the Prophet ﷺ, and an inner reality that gives it life.\n\n'
                    'When both align — correct practice and a present, humble heart — duʿāʾ rises with strength and returns with mercy.',
                    style: bodyStyle(),
                  ),
                  const SizedBox(height: 10),
                  bullet('The Outward Method (Sunnah Structure)'),
                  bullet('The Inner State (Heart & Reliance)'),
                  goldDivider(),

                  // SECTION 3 — Sunnah Flow (Expandable)
                  sectionHeader('A Sunnah Flow: From Intention to Āmīn'),
                  const SizedBox(height: 6),
                  // 8 accordions
                  accordionBlock(
                    '1. Prepare the Heart & Moment',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Note: The accordion title already renders this step's title.
                        // We start directly with the specified content body.
                        Text(
                          'Before duʿāʾ begins on the tongue, it must begin in the heart.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Duʿāʾ is not accepted through habit or haste, but through presence. A distracted heart weakens supplication, while a gathered heart gives it weight.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Intention & Presence
                        Text('a) Intention & Presence', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          'Pause before you ask. Quiet the mind. Turn inward.\nKnow Who you are speaking to — the Lord of Majesty and Honour.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 8),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Call upon Allah while you are certain of a response, and know that Allah does not respond to a supplication from a heedless, distracted heart.”\n(Tirmidhī)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // b) Choose a Blessed Time
                        Text('b) Choose a Blessed Time (when possible)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Some moments carry greater openness and mercy:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('The last third of the night (Tahajjud)'),
                        bullet('While in sujūd'),
                        bullet('Between adhān and iqāmah'),
                        bullet('On Jumuʿah'),
                        bullet('During rain'),
                        bullet('While fasting'),
                        const SizedBox(height: 6),
                        Text('Duʿāʾ is always permitted — but wisdom is choosing moments Allah loves most.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Outward Adab
                        Text('c) Outward Adab (Recommended, Not Required)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('These actions prepare the state of the heart:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('Perform wuḍūʾ'),
                        bullet('Face the qiblah'),
                        bullet('Raise the hands'),
                        bullet('Sit or stand with humility'),
                        const SizedBox(height: 6),
                        Text('They are not conditions — but keys.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) A Powerful Opening Key
                        Text('d) A Powerful Opening Key (Optional)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Giving even a small ṣadaqah before duʿāʾ softens the heart and invites mercy.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'Ibn al-Qayyim (raḥimahullāh) noted that charity before supplication was among the causes of acceptance, and Ibn Taymiyyah (raḥimahullāh) would secretly give charity before Jumuʿah for this reason.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Purpose of this step:\nTo arrive at duʿāʾ awake, present, and aware — not rushed, not careless, not absent.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '2. Begin with Praise (Ḥamd)',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Do not rush to ask.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'Begin by praising Allah — for He loves to be praised, and praise opens the door of acceptance.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“There is none who loves praise more than Allah.”\n(Bukhārī)', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text('And he ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“When one of you makes duʿāʾ, let him begin by praising Allah and glorifying Him, then send ṣalawāt upon the Prophet, and then ask for whatever he wishes.”\n(Abū Dāwūd)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text('Praise reminds the heart Who Allah is before reminding Him of what you want.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text('How to Praise Allah', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('You may praise Allah in several sound ways:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('With words Allah used to praise Himself in the Qur’an'),
                        bullet('With phrases taught by the Prophet ﷺ'),
                        bullet('By mentioning Allah’s greatness, mercy, power, wisdom, and generosity'),
                        bullet('By calling upon Him through His Beautiful Names'),
                        const SizedBox(height: 10),
                        Text('Examples include:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('Al-ḥamdu lillāhi Rabbil-ʿālamīn'),
                        bullet('Subḥānaka Allāhumma wa bi-ḥamdik'),
                        bullet('Yā Raḥmān, Yā Raḥīm, Yā Ḥayy, Yā Qayyūm'),
                        const SizedBox(height: 12),
                        Text('Praising Allah is not formality — it is recognition.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'It softens the heart, cultivates humility, and aligns the servant with the reality of standing before the Lord of all creation.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Purpose of this step:\nTo anchor duʿāʾ in reverence, gratitude, and recognition of Allah before asking Him for anything.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '3. Send Ṣalawāt upon the Prophet ﷺ',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Before presenting your needs, honour the one through whom guidance reached you.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sending ṣalawāt upon the Prophet ﷺ is not a formality — it is a cause of acceptance.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Every supplication is suspended between the heaven and the earth until ṣalāh is sent upon the Prophet ﷺ.”\n(Tirmidhī)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'When you send ṣalawāt, your duʿāʾ is elevated, refined, and returned with mercy.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text('Allah Himself commands this honour:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Indeed, Allah and His angels send blessings upon the Prophet. O you who believe, send blessings upon him and salutations of peace.”\n(Qurʾān 33:56)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Why Ṣalawāt Comes Before Asking
                        Text('a) Why Ṣalawāt Comes Before Asking',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        bullet('It is gratitude before request'),
                        bullet('It acknowledges the source of guidance'),
                        bullet('It softens the heart and humbles the soul'),
                        bullet('It opens the door of acceptance'),
                        const SizedBox(height: 6),
                        Text(
                          'Ibn al-Qayyim (raḥimahullāh) explained that beginning duʿāʾ with praise and ṣalawāt is among the strongest means of response.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // b) How to Send Ṣalawāt
                        Text('b) How to Send Ṣalawāt',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('There is no single required wording. Simplicity with presence is sufficient.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Examples:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('“Allāhumma ṣalli ʿalā Muḥammad”'),
                        bullet('“Allāhumma ṣalli wa sallim ʿalā Nabiyyinā Muḥammad”'),
                        bullet('Any sincere form of blessing and peace upon him ﷺ'),
                        const SizedBox(height: 6),
                        Text('Say it with awareness — not speed.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) A Heart Check
                        Text('c) A Heart Check',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('As you send ṣalawāt, remember:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'You are honouring the one who cared for your ummah more than himself.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text('Let gratitude replace entitlement.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'Purpose of this step:\nTo elevate your duʿāʾ, align it with divine command, and approach Allah through love, gratitude, and honour — not demand.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '4. Ask Allah through Tawḥīd & His Names',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Duʿāʾ is strongest when it begins with recognition of Who Allah is — not only what you want.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tawḥīd is the foundation of supplication.\nIt is calling upon Allah while affirming that He alone hears, knows, wills, and responds.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text('Allah says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“And to Allah belong the Most Beautiful Names, so call upon Him by them.”\n(Qurʾān 7:180)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Ask Through Tawḥīd
                        Text('a) Ask Through Tawḥīd',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Before naming your need, affirm His Oneness:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('He alone controls benefit and harm'),
                        bullet('He alone gives and withholds'),
                        bullet('He alone responds to the distressed'),
                        const SizedBox(height: 6),
                        Text(
                          'This removes hidden reliance on means, people, or outcomes — and restores trust where it belongs.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // b) Call Upon Allah by His Names
                        Text('b) Call Upon Allah by His Names',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Align your request with His Names:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('Seeking forgiveness → *Al-Ghafūr*, *Al-ʿAfūw*'),
                        bullet('Seeking provision → *Ar-Razzāq*, *Al-Karīm*'),
                        bullet('Seeking healing → *Ash-Shāfī*'),
                        bullet('Seeking guidance → *Al-Hādī*'),
                        bullet('Seeking relief → *Al-Fattāḥ*, *Ar-Raḥmān*'),
                        const SizedBox(height: 6),
                        Text('This is not poetic technique — it is prophetic precision.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text('The Prophet ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Allah has ninety-nine names; whoever calls upon Him by them will be answered.”\n(Ṣaḥīḥ meaning, reported in Aḥmad and others)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // c) Speak to Allah as One Who Knows You
                        Text('c) Speak to Allah as One Who Knows You',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Mention His attributes before your request:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('His mercy before your weakness'),
                        bullet('His power before your inability'),
                        bullet('His knowledge before your confusion'),
                        const SizedBox(height: 10),
                        Text('Example (conceptual):', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“O Allah, You are the Most Merciful — have mercy on my brokenness.”', style: bodyStyle()),
                        Text('“O Allah, You are the All-Knowing — You know what I cannot say.”', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) A Subtle Correction of the Heart
                        Text('d) A Subtle Correction of the Heart',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Do not treat Allah as a last option.', style: bodyStyle()),
                        Text('Do not speak as though He must be convinced.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'You are asking the One who already knows — and already has power — and already has mercy.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Purpose of this step:\nTo anchor duʿāʾ in Tawḥīd, align requests with divine attributes, and remove hidden reliance on anything besides Allah.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '5. Seek Forgiveness before Asking',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Before you ask Allah for what you need, cleanse what stands between you and acceptance.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sins do not block duʿāʾ because Allah is unwilling —\nthey block duʿāʾ because the heart is weighed down.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Allah is *Al-Ghafūr* and loves to forgive, but forgiveness must be sought.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text('Allah says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Say, ‘O My servants who have transgressed against themselves, do not despair of the mercy of Allah. Indeed, Allah forgives all sins.’”\n(Qurʾān 39:53)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Acknowledge Your Shortcomings
                        Text('a) Acknowledge Your Shortcomings',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Approach Allah with honesty, not excuses.', style: bodyStyle()),
                        Text('Admit negligence, weakness, forgetfulness, and failure.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('This is not humiliation — it is truthfulness.', style: bodyStyle()),
                        Text('And truthfulness is beloved to Allah.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) Seek Forgiveness with Hope, Not Despair
                        Text('b) Seek Forgiveness with Hope, Not Despair',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Prophet ﷺ narrated that Allah said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“O son of Ādam, so long as you call upon Me and hope in Me, I will forgive you for what you have done, and I do not mind…”\n(Tirmidhī)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text('No sin is too great.', style: bodyStyle()),
                        Text('No door is closed.', style: bodyStyle()),
                        Text('What matters is sincerity.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Feel the Weight — Then Release It
                        Text('c) Feel the Weight — Then Release It',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Forgiveness is not only spoken.', style: bodyStyle()),
                        Text('It is felt.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Regret softens the heart.', style: bodyStyle()),
                        Text('Tears polish it.', style: bodyStyle()),
                        Text('Hope lifts it.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Ibn Rajab (raḥimahullāh) said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Your hearts were created pure, but sins have stained them — so wash them with repentance.”',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // d) A Prophetic Anchor (Optional)
                        Text('d) A Prophetic Anchor (Optional)',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          'Among the greatest forms of seeking forgiveness is *Sayyid al-Istighfār* —\nthe master supplication of repentance.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text('You may recite it, or speak in your own words.', style: bodyStyle()),
                        Text('Allah hears both.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo remove spiritual barriers, soften the heart, and approach Allah purified — not demanding, but hopeful.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '6. The Secret of Duʿāʾ (Munājāt)',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This is the heart of duʿāʾ.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text('Not polished words.', style: bodyStyle()),
                        Text('Not performance.', style: bodyStyle()),
                        Text('But *munājāt* — the private, intimate whisper of a servant to his Lord.',
                            style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text(
                          'Here, you speak not as someone who deserves —\nbut as someone who needs.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Lower Yourself Before Allah
                        Text('a) Lower Yourself Before Allah',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Come with humility, fear, hope, and surrender.', style: bodyStyle()),
                        Text('Strip away pride.', style: bodyStyle()),
                        Text('Strip away self-reliance.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Allah says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“And remember your Lord within yourself, humbly and with fear…”\n(Qurʾān 7:205)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('And He says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“They used to call upon Us with hope and fear, and they were humble before Us.”\n(Qurʾān 21:90)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // b) Speak as the Desperate Servant
                        Text('b) Speak as the Desperate Servant',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Confess your weakness.', style: bodyStyle()),
                        Text('Your confusion.', style: bodyStyle()),
                        Text('Your inability to manage even your own affairs.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('The Prophet ﷺ, at the height of victory, raised his hands on ʿArafah and said:',
                            style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“O Allah, I am the desperate and needy one… I beg You with the begging of a destitute…”\n(Ṭabarānī)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text('This is not weakness.', style: bodyStyle()),
                        Text('This is servitude.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Direct Your Complaint Only to Allah
                        Text('c) Direct Your Complaint Only to Allah',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Do not vent to creation what should be poured before the Creator.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Like Ayyūb عليه السلام, say:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Indeed, harm has touched me, and You are the Most Merciful of the merciful.”\n(Qurʾān 21:83)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('This is not complaining *about* Allah —', style: bodyStyle()),
                        Text('it is complaining *to* Allah.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) Whisper — Do Not Perform
                        Text('d) Whisper — Do Not Perform',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Duʿāʾ is not for an audience.', style: bodyStyle()),
                        Text('Allah is near.', style: bodyStyle()),
                        Text('He hears the quietest breath.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Allah says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“Invoke your Lord with humility and in secret…”\n(Qurʾān 7:55)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Speak naturally.', style: bodyStyle()),
                        Text('Pause.', style: bodyStyle()),
                        Text('Cry if tears come.', style: bodyStyle()),
                        Text('If not, ask Allah for a heart that feels.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo shift duʿāʾ from words to surrender — from asking with the tongue to pleading with the heart.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '7. Make Your Requests',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Now ask.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Not vaguely.', style: bodyStyle()),
                        Text('Not timidly.', style: bodyStyle()),
                        Text('Not with hesitation.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Ask with certainty — because you are asking Allah.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // a) Ask with Yaqīn (Certainty)
                        Text('a) Ask with Yaqīn (Certainty)',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Do not say “if You will.”', style: bodyStyle()),
                        Text('Do not speak as though Allah might refuse out of reluctance.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Let none of you say: ‘O Allah, forgive me if You wish.’\nRather, ask Allah with certainty, for no one can compel Him.”\n(Bukhārī, Muslim)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('Certainty is not demanding —', style: bodyStyle()),
                        Text('it is trusting.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) Ask Big — and Ask Small
                        Text('b) Ask Big — and Ask Small',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Nothing is too great for Allah.', style: bodyStyle()),
                        Text('Nothing is too small to ask Him for.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Ask for:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('Guidance'),
                        bullet('Forgiveness'),
                        bullet('Healing'),
                        bullet('Provision with barakah'),
                        bullet('Protection'),
                        bullet('Family rectification'),
                        bullet('Firmness in dīn'),
                        bullet('Jannah — and the highest level of it'),
                        const SizedBox(height: 10),
                        Text('The Prophet ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“When you ask Allah, ask Him for al-Firdaws.”\n(Tirmidhī)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('And he ﷺ taught that even the smallest needs are worthy of duʿāʾ.',
                            style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Be Specific in Your Requests
                        Text('c) Be Specific in Your Requests',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Specificity reflects awareness.', style: bodyStyle()),
                        Text('Clarity reflects trust.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Name what you want.', style: bodyStyle()),
                        Text('Name what hurts.', style: bodyStyle()),
                        Text('Name what you fear losing.', style: bodyStyle()),
                        Text('Name what you hope Allah will fix.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Allah already knows —', style: bodyStyle()),
                        Text('but He loves to hear His servant ask.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) Repeat — Persist — Do Not Tire
                        Text('d) Repeat — Persist — Do Not Tire',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Repeat your duʿāʾ.', style: bodyStyle()),
                        Text('Ask again.', style: bodyStyle()),
                        Text('And again.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('The Prophet ﷺ would repeat supplication three times.', style: bodyStyle()),
                        Text('(Muslim)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('And he ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Allah continues to answer the servant so long as he is not impatient.”\n(Bukhārī, Muslim)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('Persistence is not doubt —', style: bodyStyle()),
                        Text('it is devotion.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo ask Allah with full trust, clear intention, and unwavering certainty — knowing that every sincere duʿāʾ is answered in the best way and time.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '8. Seal with Reliance, Ṣalawāt & Āmīn',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Do not end duʿāʾ abruptly.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Just as you began with reverence,', style: bodyStyle()),
                        Text('you must conclude with surrender.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // a) Close with Salawāt Upon the Prophet ﷺ
                        Text('a) Close with Salawāt Upon the Prophet ﷺ',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          'End your duʿāʾ by sending peace and blessings upon the Messenger of Allah ﷺ.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('ʿUmar ibn al-Khaṭṭāb (raḍiyallāhu ʿanhu) said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Duʿāʾ remains suspended between the heavens and the earth until salawāt are sent upon the Prophet ﷺ.”',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Allah is too Generous to reject a supplication that is wrapped between two acts He loves.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),

                        // b) Say Āmīn with Presence
                        Text('b) Say Āmīn with Presence',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Āmīn means:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“O Allah, answer.”', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Say it with awareness.', style: bodyStyle()),
                        Text('Say it believing it has been heard.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('The angels say Āmīn with you.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // c) Surrender the Outcome to Allah
                        Text('c) Surrender the Outcome to Allah',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Once duʿāʾ is complete, let go.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Do not obsess over how it will happen.', style: bodyStyle()),
                        Text('Do not dictate when it must come.', style: bodyStyle()),
                        Text('Do not measure acceptance by immediacy.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“No Muslim makes a duʿāʾ — without sin or severing family ties —', style: bodyStyle()),
                        Text('except that Allah gives him one of three:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('He grants it immediately,'),
                        bullet('Or He stores it for him in the Hereafter,'),
                        bullet('Or He averts from him an equivalent harm.'),
                        const SizedBox(height: 6),
                        Text('”', style: bodyStyle()),
                        Text('(Aḥmad)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Every sincere duʿāʾ is answered.', style: bodyStyle()),
                        Text('Just not always in the way the servant expects.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // d) Tie Your Camel — Then Trust
                        Text('d) Tie Your Camel — Then Trust',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Duʿāʾ does not replace effort.', style: bodyStyle()),
                        Text('Nor does effort replace duʿāʾ.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Take the permissible means.', style: bodyStyle()),
                        Text('Act with integrity.', style: bodyStyle()),
                        Text('Then place the outcome entirely with Allah.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('This is tawakkul.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        Text(
                          'PURPOSE OF THIS STEP:\nTo leave duʿāʾ with peace — trusting Allah’s wisdom, timing, and mercy more than one’s own understanding.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  goldDivider(),

                  // SECTION 4 — Inner Secrets (Expandable)
                  sectionHeader('The Inner Secrets That Unlock Acceptance'),
                  const SizedBox(height: 6),
                  accordionBlock(
                    '1. Precede Duʿāʾ with a Righteous Deed',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Before you ask Allah, offer something beloved to Him.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'A righteous deed done quietly — even if small — can become the key that opens the door of acceptance.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'This is not “buying” an answer.\nIt is arriving to Allah with humility, sincerity, and a proof that you truly mean what you are about to ask.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Why this works
                        Text('a) Why this works', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          'Good deeds soften the heart, wash away heedlessness, and place barakah in the moment.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sometimes the heart is too hard to ask properly.\nSo you begin by doing something that restores it.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // b) The strongest example: tawassul through sincere deeds
                        Text('b) The strongest example: tawassul through sincere deeds',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Prophet ﷺ mentioned the story of three men trapped in a cave.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'Each one called upon Allah by mentioning a deed they did purely for His sake —\nand Allah removed the hardship from them.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'This teaches a powerful principle:\nWhen the servant brings a truthful deed, Allah may bring an opening.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // c) Examples of deeds you can do before duʿāʾ
                        Text('c) Examples of deeds you can do before duʿāʾ',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Choose what is easy and sincere:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('Give a small ṣadaqah (even the smallest amount)'),
                        bullet('Pray two rakaʿāt (even if brief)'),
                        bullet('Make dhikr with presence (SubḥānAllāh, Alḥamdulillāh, Allāhu Akbar)'),
                        bullet('Make istighfār sincerely'),
                        bullet('Reconcile with someone, or forgive someone'),
                        bullet('Help someone quietly, for Allah alone'),
                        const SizedBox(height: 12),
                        // d) The key condition: sincerity
                        Text('d) The key condition: sincerity',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          'The deed must be for Allah — not for people, not for reputation, not for “results”.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'If your heart says:\n“O Allah, I did this for You, and I need You”\n— then you are standing at the door correctly.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo enter duʿāʾ already warmed by obedience — with a softened heart and a sincere offering placed before Allah.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '2. Make Duʿāʾ in Secret',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duʿāʾ made quietly is often the most sincere.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'When no one hears you, and no one sees you, the heart speaks more truthfully.\nThis is the place where showing off disappears — and servitude remains.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Why secrecy matters
                        Text('a) Why secrecy matters', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Allah loves the duʿāʾ that rises from humility, not performance.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Allah says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Invoke your Lord with humility and in secret. Indeed, He does not love the transgressors.”\n(Qur’ān 7:55)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text('A quiet duʿāʾ protects the heart from pride and keeps the intention pure.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) You are not calling One who is distant
                        Text('b) You are not calling One who is distant', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Prophet ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“You are not calling upon One who is deaf or absent.\nYou are calling upon One who is All-Hearing, Ever Near.”\n(Muslim)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text('Allah hears the whisper.', style: bodyStyle()),
                        Text('He hears what is not even spoken.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Secret duʿāʾ builds intimacy
                        Text('c) Secret duʿāʾ builds intimacy', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          'When you speak softly to Allah — or even without sound —\nit creates closeness.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 6),
                        Text('This is the language of munājāt:', style: bodyStyle()),
                        Text('a private conversation between the servant and His Lord.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('In this space, there is no pressure to sound eloquent.', style: bodyStyle()),
                        Text('Only truth is required.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) How to practice this
                        Text('d) How to practice this', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        bullet('Lower your voice'),
                        bullet('Speak slowly'),
                        bullet('Whisper, or speak within the heart'),
                        bullet('Let the duʿāʾ feel personal — not formal'),
                        bullet('Stay longer than usual, even if the words are few'),
                        const SizedBox(height: 10),
                        Text('Allah knows what you mean — even when you struggle to say it.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo protect sincerity, deepen intimacy, and remove the need to be seen — so the heart can be fully present with Allah alone.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '3. Humility, Brokenness & Need',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duʿāʾ is strongest when the servant is weakest.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          'Allah does not respond to pride, self-sufficiency, or hidden arrogance.\nHe responds to the one who comes broken, needy, and honest about their dependence.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Brokenness is not failure — it is truth
                        Text('a) Brokenness is not failure — it is truth',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Every human is poor before Allah, whether they realise it or not.', style: bodyStyle()),
                        Text('The heart that admits this is closer to acceptance.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Allah says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“O mankind, you are those in need of Allah,\nwhile Allah is the Free of need, the Praiseworthy.”\n(Qur’ān 35:15)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('Duʿāʾ becomes powerful when the heart stops pretending it is strong.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) Display your need before Allah
                        Text('b) Display your need before Allah',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Prophets called upon Allah not with entitlement, but with humility.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Ayyūb (ʿalayhis-salām) said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Indeed, hardship has touched me,\nand You are the Most Merciful of the merciful.”\n(Qur’ān 21:83)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('He did not list his patience.', style: bodyStyle()),
                        Text('He did not demand relief.', style: bodyStyle()),
                        Text('He showed his need.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Broken hearts are welcomed
                        Text('c) Broken hearts are welcomed',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Messenger of Allah ﷺ embodied this servitude.', style: bodyStyle()),
                        Text('At the height of victory, he stood in humility.', style: bodyStyle()),
                        Text('At moments of hardship, he wept and begged.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('In duʿāʾ, allow yourself to be small.', style: bodyStyle()),
                        Text('Allow tears, pauses, and silence.', style: bodyStyle()),
                        Text('Allah is not offended by weakness — He loves it.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) How to enter this state
                        Text('d) How to enter this state',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        bullet('Lower yourself internally'),
                        bullet('Acknowledge your inability and limits'),
                        bullet('Admit fear, confusion, and reliance'),
                        bullet('Speak honestly — even if the words are simple'),
                        bullet('Let the heart lead, not the tongue'),
                        const SizedBox(height: 12),
                        Text('This is the station of true servitude.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo remove pride, soften the heart, and allow duʿāʾ to rise from genuine need — the state Allah loves most.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '4. Persistence without Impatience',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Persistence is beloved to Allah — impatience is what blocks acceptance.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Duʿāʾ is not rejected because it is repeated.', style: bodyStyle()),
                        Text('It is abandoned because the heart grows impatient.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // a) Duʿāʾ is answered — but not always immediately
                        Text('a) Duʿāʾ is answered — but not always immediately',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“The supplication of one of you will be answered\nso long as he is not hasty and says:\n‘I supplicated, but I was not answered.’”\n(Bukhārī, Muslim)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('Impatience is not anger — it is subtle despair.', style: bodyStyle()),
                        Text('It is the assumption that silence means rejection.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) Repetition is not doubt — it is devotion
                        Text('b) Repetition is not doubt — it is devotion',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Prophet ﷺ would repeat supplications three times,\nand he encouraged persistence without frustration.',
                            style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Duʿāʾ is an act of worship.', style: bodyStyle()),
                        Text('Each time you ask, you are rewarded — even before the outcome appears.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Allah delays with wisdom, not neglect
                        Text('c) Allah delays with wisdom, not neglect',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Every duʿāʾ results in one of three outcomes:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('It is answered immediately'),
                        bullet('It is delayed for a better time'),
                        bullet('It is stored for the Hereafter'),
                        bullet('Or harm is removed in its place'),
                        const SizedBox(height: 10),
                        Text('The servant loses nothing by continuing to ask.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) How to remain persistent without impatience
                        Text('d) How to remain persistent without impatience',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        bullet('Continue making duʿāʾ with calm certainty'),
                        bullet('Do not track outcomes obsessively'),
                        bullet('Avoid saying “Why hasn’t Allah answered?”'),
                        bullet('Replace haste with trust in Allah’s timing'),
                        bullet('Remember: silence is not absence'),
                        const SizedBox(height: 10),
                        Text('Allah hears every supplication — even the repeated ones.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo teach the heart patience in duʿāʾ, persistence in worship, and trust in Allah’s timing without frustration or despair.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '5. Placing Hope in Allah Alone',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duʿāʾ is weakened when hope is divided.', style: bodyStyle()),
                        Text('It is strengthened when hope is placed entirely in Allah.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // a) Duʿāʾ is an act of tawḥīd
                        Text('a) Duʿāʾ is an act of tawḥīd',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('When you raise your hands, you are declaring:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Only Allah can give.', style: bodyStyle()),
                        Text('Only Allah can withhold.', style: bodyStyle()),
                        Text('Only Allah controls outcomes.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“When you ask, ask Allah.', style: bodyStyle()),
                        Text('And when you seek help, seek help from Allah.”', style: bodyStyle()),
                        Text('(Tirmidhī)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Placing hope in people, systems, or outcomes alongside Allah', style: bodyStyle()),
                        Text('quietly fractures reliance.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // b) Means are taken — but hearts rely on Allah
                        Text('b) Means are taken — but hearts rely on Allah',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Islam does not reject effort.', style: bodyStyle()),
                        Text('It rejects attachment to effort.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Take the means.', style: bodyStyle()),
                        Text('Consult, work, plan, act.', style: bodyStyle()),
                        Text('But let the heart remain unattached to all except Allah.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('True tawakkul is not passivity —', style: bodyStyle()),
                        Text('it is effort without dependence on the effort itself.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // c) Hope in Allah must outweigh fear of disappointment
                        Text('c) Hope in Allah must outweigh fear of disappointment',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Some hearts stop asking because they fear being let down.', style: bodyStyle()),
                        Text('But Allah is not like His creation.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Allah says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“I am as My servant thinks of Me.”', style: bodyStyle()),
                        Text('(Bukhārī, Muslim)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Expecting goodness from Allah is itself an act of worship.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // d) Signs your hope is placed correctly
                        Text('d) Signs your hope is placed correctly',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        bullet('You continue making duʿāʾ even when outcomes delay'),
                        bullet('You feel peace after supplicating'),
                        bullet('You are not devastated if the answer differs'),
                        bullet('You trust Allah’s choice over your own'),
                        const SizedBox(height: 12),
                        Text('Hope anchored in Allah is never misplaced.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo purify reliance, sever hidden dependence on creation, and anchor the heart’s hope fully and exclusively in Allah.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '6. Certainty (Yaqīn) of Response',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duʿāʾ is not a wish.', style: bodyStyle()),
                        Text('It is a conversation with certainty.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Yaqīn — firm conviction — is one of the greatest causes of acceptance.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // a) Duʿāʾ must be made with certainty, not conditions
                        Text('a) Duʿāʾ must be made with certainty, not conditions',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Let none of you say: ‘O Allah, forgive me if You wish.’\nRather, ask Allah with certainty, for no one can compel Allah.”\n(Bukhārī, Muslim)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('Conditional language reveals doubt.', style: bodyStyle()),
                        Text('Certainty reflects true īmān.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Ask with confidence.', style: bodyStyle()),
                        Text('Ask with firmness.', style: bodyStyle()),
                        Text('Ask knowing Allah hears and responds.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) Every duʿāʾ is answered — but not always as expected
                        Text('b) Every duʿāʾ is answered — but not always as expected',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“No Muslim makes a duʿāʾ — not involving sin or severing family ties —\nexcept that Allah gives him one of three:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('He grants it immediately'),
                        bullet('He delays it for him in the Hereafter'),
                        bullet('He averts from him a harm equal to it.'),
                        const SizedBox(height: 6),
                        Text('”\n(Aḥmad)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Certainty is not demanding a specific outcome.', style: bodyStyle()),
                        Text('It is trusting the divine response.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Delay is not rejection
                        Text('c) Delay is not rejection',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('A delayed response often:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('softens the heart'),
                        bullet('increases humility'),
                        bullet('raises rank'),
                        bullet('protects from harm unseen'),
                        const SizedBox(height: 10),
                        Text('Impatience weakens yaqīn.', style: bodyStyle()),
                        Text('Patience strengthens it.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“The supplication of one of you will be answered\nso long as he is not hasty and says:\n‘I made duʿāʾ, but I was not answered.’”\n(Muslim)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // d) Certainty brings tranquillity after duʿāʾ
                        Text('d) Certainty brings tranquillity after duʿāʾ',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('When yaqīn is present:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('the heart settles'),
                        bullet('anxiety lifts'),
                        bullet('trust replaces urgency'),
                        const SizedBox(height: 10),
                        Text('Duʿāʾ is not meant to increase worry —', style: bodyStyle()),
                        Text('it is meant to return the heart to peace.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo anchor the heart in certainty, remove doubt, and trust Allah’s response — in timing, form, and wisdom.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '7. Presence of Heart',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duʿāʾ is not merely words — it is the heart turning to Allah.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('A tongue can ask while the heart is elsewhere.', style: bodyStyle()),
                        Text(
                          'But the duʿāʾ that is most alive is the one spoken with awareness, humility, and focus.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),
                        // a) Gather the Heart Before You Speak
                        Text('a) Gather the Heart Before You Speak',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Before you begin:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('slow down'),
                        bullet('breathe'),
                        bullet('remove distractions'),
                        bullet('remind yourself Who you are speaking to'),
                        const SizedBox(height: 10),
                        Text('You are standing before the King — not speaking into emptiness.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) A Heedless Heart Weakens Duʿāʾ
                        Text('b) A Heedless Heart Weakens Duʿāʾ',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Call upon Allah while you are certain of a response,\nand know that Allah does not respond to a supplication\nfrom a heedless, distracted heart.”\n(Tirmidhī)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('This is not a call to perfection — it is a call to presence.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Speak Like Someone Who Truly Needs Allah
                        Text('c) Speak Like Someone Who Truly Needs Allah',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Presence of heart looks like:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('sincerity over performance'),
                        bullet('truthfulness over eloquence'),
                        bullet('need over pride'),
                        const SizedBox(height: 10),
                        Text('It is the heart saying:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“O Allah, I have no one but You.”', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) Practical Ways to Restore Presence (Quick Reset)
                        Text('d) Practical Ways to Restore Presence (Quick Reset)',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('If you feel distracted, do one of these:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('start with “Astaghfirullah” a few times'),
                        bullet('send ṣalawāt upon the Prophet ﷺ'),
                        bullet('repeat a short praise: “Alhamdulillāh”'),
                        bullet('pause and restart slowly'),
                        const SizedBox(height: 10),
                        Text('Even a small return of focus can change everything.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo make duʿāʾ real — present, sincere, and directed to Allah with full attention.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '8. Being Firm, Not Conditional',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duʿāʾ is not a negotiation.', style: bodyStyle()),
                        Text('It is a declaration of need.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text(
                          'When asking Allah, the heart must be firm —\nnot hesitant, doubtful, or conditional.',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 12),

                        // a) Do Not Say “If You Will”
                        Text('a) Do Not Say “If You Will”',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text(
                          '“Let not one of you say:\n‘O Allah, forgive me if You will.’\n‘O Allah, have mercy on me if You will.’\nRather, let him be firm in his request,\nfor no one can compel Allah.”\n(Bukhārī & Muslim)',
                          style: bodyStyle(),
                        ),
                        const SizedBox(height: 10),
                        Text('Conditional language reflects inner doubt —', style: bodyStyle()),
                        Text('not adab.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // b) Firmness Is Not Demanding — It Is Trust
                        Text('b) Firmness Is Not Demanding — It Is Trust',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Being firm does not mean entitlement.', style: bodyStyle()),
                        Text('It means certainty that Allah hears,', style: bodyStyle()),
                        Text('Allah is able,', style: bodyStyle()),
                        Text('and Allah is generous.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('A believer asks with confidence,', style: bodyStyle()),
                        Text('then submits the outcome to Allah’s wisdom.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // c) Ask With Certainty, Accept the Decree
                        Text('c) Ask With Certainty, Accept the Decree',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('You may say:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('“O Allah, forgive me.”'),
                        bullet('“O Allah, heal me.”'),
                        bullet('“O Allah, guide me.”'),
                        bullet('“O Allah, grant me what is best.”'),
                        const SizedBox(height: 10),
                        Text('Ask clearly.', style: bodyStyle()),
                        Text('Ask directly.', style: bodyStyle()),
                        Text('Then surrender the *how* and *when* to Allah.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        // d) What Firm Duʿāʾ Sounds Like
                        Text('d) What Firm Duʿāʾ Sounds Like',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Firm duʿāʾ sounds like:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        bullet('clarity, not hesitation'),
                        bullet('hope, not fear of rejection'),
                        bullet('trust, not anxiety'),
                        const SizedBox(height: 10),
                        Text('Allah loves to be asked —', style: bodyStyle()),
                        Text('and He loves certainty from His servant.', style: bodyStyle()),
                        const SizedBox(height: 12),

                        Text(
                          'PURPOSE OF THIS STEP:\nTo remove doubt from duʿāʾ and replace it with confident reliance upon Allah alone.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '9. Asking Abundantly',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Allah is not limited by what you ask —', style: bodyStyle()),
                        Text('only by what you believe you are allowed to ask.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text('Duʿāʾ is not measured by size.', style: bodyStyle()),
                        Text('Nothing is too great for Allah,', style: bodyStyle()),
                        Text('and nothing is too small for the servant to ask.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // a) Ask for Everything — Great and Small
                        Text('a) Ask for Everything — Great and Small',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Messenger of Allah ﷺ said:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“When one of you asks Allah,', style: bodyStyle()),
                        Text('let him be abundant in his asking,', style: bodyStyle()),
                        Text('for indeed he is asking his Lord.”', style: bodyStyle()),
                        Text('(Ibn Ḥibbān)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Ask for guidance and forgiveness.', style: bodyStyle()),
                        Text('Ask for healing and relief.', style: bodyStyle()),
                        Text('Ask for strength, clarity, provision, and protection.', style: bodyStyle()),
                        Text('Ask even for the smallest needs —', style: bodyStyle()),
                        Text('for all is from Allah.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) Do Not Limit Allah by Your Circumstances
                        Text('b) Do Not Limit Allah by Your Circumstances',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Scarcity exists in creation —', style: bodyStyle()),
                        Text('not with the Creator.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Allah gives without depletion,', style: bodyStyle()),
                        Text('responds without exhaustion,', style: bodyStyle()),
                        Text('and bestows without measure.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Limiting your duʿāʾ is often a reflection', style: bodyStyle()),
                        Text('of how you see Allah —', style: bodyStyle()),
                        Text('not of His ability.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Ask for the Highest
                        Text('c) Ask for the Highest',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('The Prophet ﷺ instructed:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“When you ask Allah,', style: bodyStyle()),
                        Text('ask Him for al-Firdaws,', style: bodyStyle()),
                        Text('for it is the highest part of Paradise.”', style: bodyStyle()),
                        Text('(Tirmidhī)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('If the highest Jannah may be asked for,', style: bodyStyle()),
                        Text('then nothing below it is inappropriate to request.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) Abundance With Submission
                        Text('d) Abundance With Submission',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Asking abundantly does not contradict humility.', style: bodyStyle()),
                        Text('It completes it.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('You ask fully,', style: bodyStyle()),
                        Text('then accept fully —', style: bodyStyle()),
                        Text('trusting that Allah gives what is best,', style: bodyStyle()),
                        Text('when it is best,', style: bodyStyle()),
                        Text('in the way that is best.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text(
                          'PURPOSE OF THIS STEP:\nTo remove artificial limits from duʿāʾ and to ask Allah freely, generously, and without restraint.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  accordionBlock(
                    '10. Conversing Intimately with Allah',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Duʿāʾ is not a speech —', style: bodyStyle()),
                        Text('it is a private conversation between the servant and his Lord.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Allah hears every whisper,', style: bodyStyle()),
                        Text('every pause,', style: bodyStyle()),
                        Text('every unspoken thought of the heart.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // a) Speak as a Slave, Not a Speaker
                        Text('a) Speak as a Slave, Not a Speaker',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Do not perform duʿāʾ.', style: bodyStyle()),
                        Text('Do not polish it for sound.', style: bodyStyle()),
                        Text('Do not worry about structure or eloquence.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Speak honestly.', style: bodyStyle()),
                        Text('Speak plainly.', style: bodyStyle()),
                        Text('Speak as one who has nowhere else to turn.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('The Messenger of Allah ﷺ embodied this in his supplications,', style: bodyStyle()),
                        Text('speaking with humility, need, fear, and hope —', style: bodyStyle()),
                        Text('not with rehearsed words, but with truth.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // b) Whisper With Nearness
                        Text('b) Whisper With Nearness',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Allah says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“Invoke your Lord with humility and in secret.”', style: bodyStyle()),
                        Text('(Al-Aʿrāf 7:55)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('And He says:', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('“And when My servants ask you concerning Me,', style: bodyStyle()),
                        Text('indeed I am near.”', style: bodyStyle()),
                        Text('(Al-Baqarah 2:186)', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('This closeness invites intimacy.', style: bodyStyle()),
                        Text('Lower your voice.', style: bodyStyle()),
                        Text('Slow your words.', style: bodyStyle()),
                        Text('Allow silence between sentences.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('Allah is nearer than you realise.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // c) Say What You Cannot Say to Anyone Else
                        Text('c) Say What You Cannot Say to Anyone Else',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('In munājāt, nothing is hidden.', style: bodyStyle()),
                        Text('Speak of fear.', style: bodyStyle()),
                        Text('Speak of confusion.', style: bodyStyle()),
                        Text('Speak of shame, weakness, longing, and hope.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Confess what burdens the heart.', style: bodyStyle()),
                        Text('Admit what the tongue struggles to say.', style: bodyStyle()),
                        Text('Allah already knows —', style: bodyStyle()),
                        Text('but He loves to be turned to.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        // d) End With Trust, Not Control
                        Text('d) End With Trust, Not Control',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('When the heart has emptied itself,', style: bodyStyle()),
                        Text('release the outcome.', style: bodyStyle()),
                        const SizedBox(height: 6),
                        Text('You are not informing Allah.', style: bodyStyle()),
                        Text('You are surrendering to Him.', style: bodyStyle()),
                        const SizedBox(height: 10),
                        Text('Place the matter in His care,', style: bodyStyle()),
                        Text('content with His wisdom,', style: bodyStyle()),
                        Text('certain of His mercy —', style: bodyStyle()),
                        Text('then leave with peace.', style: bodyStyle()),
                        const SizedBox(height: 12),
                        Text('PURPOSE OF THIS STEP:', style: bodyStyle()),
                        Text(
                          'To transform duʿāʾ from a request into a relationship — a moment of nearness, honesty, and surrender.',
                          style: bodyStyle(),
                        ),
                      ],
                    ),
                  ),
                  goldDivider(),

                  // SECTION 5 — Etiquettes Checklist
                  sectionHeader('23 Etiquettes That Lead to Answered Duʿāʾ'),
                  const SizedBox(height: 6),
                  for (int i = 1; i <= 23; i++) numbered(i, 'Etiquette $i (placeholder)'),
                  goldDivider(),

                  // SECTION 6 — When Duʿāʾ Feels Unanswered
                  sectionHeader('If Your Duʿāʾ Feels Unanswered'),
                  Text('Placeholder paragraph offering gentle guidance.', style: bodyStyle()),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: colors.primary.withValues(alpha: 0.25), width: 3)),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('“Placeholder quote about patience and tawakkul.”', style: bodyStyle(15, 0.9)?.copyWith(fontStyle: FontStyle.italic)),
                        const SizedBox(height: 6),
                        Text('— Placeholder Attribution', style: bodyStyle(15, 0.85)),
                      ],
                    ),
                  ),
                  goldDivider(),

                  // SECTION 7 — Quick Recall Box
                  sectionHeader('A 20-Second Duʿāʾ Checklist'),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: brand.border),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _ChecklistBullet(text: 'Intend, Face Qiblah (optional)'),
                        _ChecklistBullet(text: 'Begin with Ḥamd'),
                        _ChecklistBullet(text: 'Send Ṣalawāt'),
                        _ChecklistBullet(text: 'Seek Forgiveness'),
                        _ChecklistBullet(text: 'Ask with Presence & Yaqīn'),
                        _ChecklistBullet(text: 'Rely on Allah, seal with Āmīn'),
                      ],
                    ),
                  ),
                  goldDivider(),

                  // SECTION 8 — Closing Reflection
                  sectionHeader('A Final Reminder'),
                  Text('Short reflection placeholder text.', style: bodyStyle()),
                  const SizedBox(height: 10),
                  Text('Āmīn.', style: bodyStyle()),
                  const SizedBox(height: 16),

                  // Footer
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false),
                      child: const Text('Return to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccordionBlock extends StatefulWidget {
  final String title;
  final Widget? content;
  const _AccordionBlock({required this.title, this.content});

  @override
  State<_AccordionBlock> createState() => _AccordionBlockState();
}

class _AccordionBlockState extends State<_AccordionBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final brand = context.brandTokens;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brand.border),
        boxShadow: [brand.cardShadowLight],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Minimal indicator (no new icons): subtle chevron using text
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _expanded ? 0.5 : 0.0,
                      child: Text('›', style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.5))),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      if (widget.content != null) widget.content!,
                    ],
                  ),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 180),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistBullet extends StatelessWidget {
  final String text;
  const _ChecklistBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
