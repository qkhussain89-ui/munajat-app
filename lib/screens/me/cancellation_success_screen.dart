import 'package:flutter/material.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/components/copper_button.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';

class CancellationSuccessScreen extends StatelessWidget {
const CancellationSuccessScreen({super.key});

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final bt = context.brandTokens;
return Scaffold(
body: SingleChildScrollView(
child: Column(
children: [
SafeArea(
bottom: false,
child: Container(
height: 56,
decoration: BoxDecoration(
color: theme.colorScheme.background,
border: Border(bottom: BorderSide(color: bt.border.withValues(alpha: 0.35), width: 1)),
),
child: Stack(
alignment: Alignment.center,
children: [
Align(
alignment: Alignment.centerLeft,
child: SizedBox(
width: 44,
child: IconButton(
icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: theme.colorScheme.secondary),
onPressed: () => Navigator.of(context).pop(),
padding: EdgeInsets.zero,
tooltip: 'Back',
),
),
),
Align(
alignment: Alignment.center,
child: ShaderMask(
shaderCallback: (bounds) => bt.copperGradient.createShader(bounds),
child: Text(
'Subscription Cancelled',
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
],
),
),
),
Padding(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Your subscription has been cancelled.', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
const SizedBox(height: 12),
Text(
"You’ll continue to have full access until the end of the current period.\nYou can restart your subscription at any time.",
style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
),
const SizedBox(height: 24),
SizedBox(
width: double.infinity,
child: CopperButton(
text: 'Return to Account',
onPressed: () {
// Pop success screen, then Subscription screen -> back to Me
Navigator.of(context)
..pop()
..pop();
},
),
),
const SizedBox(height: 12),
SizedBox(
width: double.infinity,
child: OutlinedButton(
onPressed: () async {
final restored = await RevenueCatService().restorePurchases();
if (context.mounted) {
if (restored) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Subscription restored successfully!'), duration: Duration(seconds: 2)),
);
}
Navigator.of(context).pop();
}
},
style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
child: Text('Restart subscription', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface)),
),
),
],
),
),
],
),
),
);
}
}
