import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hearth_prayer/theme.dart';
import 'package:hearth_prayer/theme/tokens.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/components/top_nav_bar.dart';
import 'package:hearth_prayer/components/flow_mode_overlay.dart';
import 'package:hearth_prayer/models/dua.dart';
import 'package:hearth_prayer/services/dua_service.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:provider/provider.dart';

class ViewerRefinedScreen extends StatefulWidget {
final Dua dua;

const ViewerRefinedScreen({super.key, required this.dua});

@override
State<ViewerRefinedScreen> createState() => _ViewerRefinedScreenState();
}

class _ViewerRefinedScreenState extends State<ViewerRefinedScreen> {
// Collapsed banner by default; expands in place when tapped.
bool _beforeExpanded = false;
// New: local answered state mirrors persisted Dua.isAnswered
late bool _isAnswered;
late final AppState _appState;

@override
void initState() {
super.initState();
_isAnswered = widget.dua.isAnswered;
_appState = context.read<AppState>();
_appState.setShowTabBar(false);
}

@override
void dispose() {
_appState.setShowTabBar(true);
super.dispose();
}

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

return Scaffold(
body: SafeArea(
bottom: true,
child: Column(
children: [
TopNavBar(
title: widget.dua.title,
showBack: true,
inBody: false,
onBack: () => Navigator.of(context).maybePop(),
rightAction: _ActionOverflow(
onEdit: () {
Navigator.pushNamed(
context,
'/edit_dua',
arguments: widget.dua,
);
},
onShare: () async {
await Clipboard.setData(
ClipboardData(text: widget.dua.englishText),
);
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Copied to clipboard')),
);
}
},
onCopy: () async {
await Clipboard.setData(
ClipboardData(text: widget.dua.englishText),
);
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Copied to clipboard')),
);
}
},
onDelete: _showDeleteConfirmation,
),
),
// STEP 1: Collapsed "Before You Read" banner (only for inaugural du'a)
if (widget.dua.isInaugural) ...[
_BeforeYouReadBanner(
expanded: _beforeExpanded,
onToggle: () => setState(() => _beforeExpanded = !_beforeExpanded),
),
],
const SizedBox(height: 16),
// Make the duʿā card ~20% shorter while keeping its top edge fixed.
Expanded(
child: LayoutBuilder(
builder: (context, constraints) {
final cardHeight = constraints.maxHeight * 0.8; // ~20% reduction
return Align(
alignment: Alignment.topCenter,
child: SizedBox(
height: cardHeight,
child: Container(
margin: const EdgeInsets.symmetric(horizontal: 24),
decoration: BoxDecoration(
// Keep existing surface, radius, and copper border exactly the same
color: theme.colorScheme.surfaceContainerLow,
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: const Color(0xFFC9A06A),
width: 1.0,
),
),
child: _buildContentTab(widget.dua.englishText, theme, isArabic: widget.dua.isRtl),
),
),
);
},
),
),
const SizedBox(height: 16),
_DuaStatusSection(
isAnswered: _isAnswered,
onToggle: _toggleAnswered,
),
// Add bottom breathing room so the strip doesn't hug the screen edge.
const SizedBox(height: 24),
// Respect device safe area on the bottom as additional spacing.
SizedBox(height: MediaQuery.of(context).padding.bottom),
// Bottom action buttons removed in favor of top-right overflow menu
// to avoid layout changes elsewhere while consolidating actions.
],
),
),
);
}

Widget _buildContentTab(String content, ThemeData theme,
{bool isArabic = false, bool isItalic = false}) {
return Consumer<AppState>(
builder: (context, appState, _) {
return Stack(
children: [
// Center the duʿā text within the card (both horizontally and,
// for short content, vertically). Long content remains scrollable.
LayoutBuilder(
builder: (context, constraints) {
return SingleChildScrollView(
padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
child: ConstrainedBox(
constraints: BoxConstraints(minHeight: constraints.maxHeight),
child: Align(
alignment: Alignment.topCenter,
child: Text(
content,
style: theme.textTheme.bodyLarge?.copyWith(
fontSize: 18 * appState.fontSizeMultiplier,
// Maintain existing readable line height
height: 1.9,
color: theme.colorScheme.onSurface,
fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
),
textDirection:
isArabic ? TextDirection.rtl : TextDirection.ltr,
// Align text to center to match Create Duʿā preview
textAlign: TextAlign.center,
),
),
),
);
},
),
Positioned(
bottom: 16,
right: 16,
child: Material(
color: Colors.transparent,
child: InkWell(
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => FlowModeOverlay(
content: widget.dua.englishText,
title: widget.dua.title,
onClose: () => Navigator.pop(context),
isRtl: widget.dua.isRtl,
),
),
);
},
borderRadius: BorderRadius.circular(24),
child: Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: theme.colorScheme.primary,
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: theme.colorScheme.onBackground.withValues(alpha: 0.2),
blurRadius: 8,
offset: const Offset(0, 2),
),
],
),
child: Icon(
Icons.play_arrow,
color: theme.colorScheme.onPrimary,
size: 24,
),
),
),
),
),
],
);
},
);
}

Widget _buildGuidelineItem(ThemeData theme, String text) {
return Padding(
padding: const EdgeInsets.only(bottom: 8, left: 0),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.only(right: 12, top: 4),
child: Text('•', style: theme.textTheme.bodySmall),
),
Expanded(
child: Text(
text,
style: theme.textTheme.bodySmall?.copyWith(
color: theme.colorScheme.onSurface,
),
),
),
],
),
);
}

void _showDeleteConfirmation() {
final theme = Theme.of(context);
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text('Delete Duʿā?'),
content: const Text(
'This will permanently delete this duʿā from your collection.',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
TextButton(
onPressed: () async {
await DuaService.deleteDua(widget.dua.id);
if (mounted) {
Navigator.pop(context);
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Duʿā deleted')),
);
}
},
child: Text(
'Delete',
style: TextStyle(color: theme.colorScheme.error),
),
),
],
),
);
}

void _showMarkAnsweredSheet() {
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
padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Mark as answered?',
style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
),
const SizedBox(height: 8),
Text(
'Alḥamdulillāh. This will mark this duʿā as answered.',
style: theme.textTheme.bodyMedium?.copyWith(
color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
),
),
const SizedBox(height: 20),
Row(
children: [
Expanded(
child: TextButton(
onPressed: () => Navigator.pop(context),
child: Text(
'Cancel',
style: theme.textTheme.bodyMedium?.copyWith(
color: theme.colorScheme.primary,
),
),
),
),
const SizedBox(width: 12),
Expanded(
child: FilledButton(
onPressed: () async {
final updated = widget.dua.copyWith(isAnswered: true, updatedAt: DateTime.now());
await DuaService.updateDua(updated);
if (mounted) {
setState(() => _isAnswered = true);
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Marked as answered. Alḥamdulillāh.')),
);
}
},
style: FilledButton.styleFrom(
backgroundColor: theme.colorScheme.primary,
padding: const EdgeInsets.symmetric(vertical: 12),
shape: const StadiumBorder(),
),
child: Text(
'Mark Answered',
style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
),
),
),
],
),
],
),
),
);
},
);
}

Future<void> _toggleAnswered() async {
final newValue = !_isAnswered;
final updated = widget.dua.copyWith(
isAnswered: newValue,
updatedAt: DateTime.now(),
);
await DuaService.updateDua(updated);
if (!mounted) return;
setState(() => _isAnswered = newValue);
}
}

class _ActionOverflow extends StatelessWidget {
final VoidCallback onEdit;
final VoidCallback onShare;
final VoidCallback onCopy;
final VoidCallback onDelete;

const _ActionOverflow({
required this.onEdit,
required this.onShare,
required this.onCopy,
required this.onDelete,
});

@override
Widget build(BuildContext context) {
final cs = Theme.of(context).colorScheme;
return Align(
alignment: Alignment.centerRight,
child: PopupMenuButton<_MenuAction>(
icon: Icon(Icons.more_vert, color: cs.secondary),
onSelected: (value) async {
switch (value) {
case _MenuAction.edit:
onEdit();
break;
case _MenuAction.share:
onShare();
break;
case _MenuAction.copy:
onCopy();
break;
case _MenuAction.delete:
onDelete();
break;
}
},
itemBuilder: (context) => [
PopupMenuItem(
value: _MenuAction.edit,
child: const Text('Edit duʿā’'),
),
PopupMenuItem(
value: _MenuAction.share,
child: const Text('Share duʿā’'),
),
PopupMenuItem(
value: _MenuAction.copy,
child: const Text('Copy text'),
),
const PopupMenuDivider(),
PopupMenuItem(
value: _MenuAction.delete,
child: Text(
'Delete duʿā’',
style: TextStyle(color: cs.error),
),
),
],
),
);
}
}

enum _MenuAction { edit, share, copy, delete }

// STEP 1: Collapsible "Before You Read" banner (compact by default)
class _BeforeYouReadBanner extends StatelessWidget {
final bool expanded;
final VoidCallback onToggle;

const _BeforeYouReadBanner({required this.expanded, required this.onToggle});

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final cs = theme.colorScheme;

return Container(
margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
decoration: BoxDecoration(
color: cs.surface,
borderRadius: BorderRadius.circular(20),
border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
),
child: Material(
color: Colors.transparent,
child: InkWell(
borderRadius: BorderRadius.circular(20),
onTap: onToggle,
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Icon(Icons.info_outline, color: cs.primary, size: 18),
const SizedBox(width: 8),
Expanded(
child: Text(
'Before you read',
style: theme.textTheme.labelMedium?.copyWith(
fontWeight: FontWeight.w600,
color: cs.onSurface,
),
),
),
AnimatedRotation(
duration: const Duration(milliseconds: 200),
turns: expanded ? 0.5 : 0.0, // ▼ rotates to ▲ when expanded
child: Icon(
Icons.expand_more,
color: cs.onSurface.withValues(alpha: 0.7),
size: 20,
),
),
],
),
AnimatedCrossFade(
firstChild: const SizedBox(height: 0),
secondChild: Padding(
padding: const EdgeInsets.only(top: 8, bottom: 4, right: 2, left: 2),
child: Text(
'This is the first du\u02BBā of Munājāt, created to ask Allah \uFDFA to place barakah in this app and make it a source of benefit for Muslims worldwide. It was read by every person who joined Munājāt during its launch.',
style: TextStyle(
fontSize: 14,
height: 1.6,
color: theme.brightness == Brightness.dark
? Colors.white70
: Colors.black87,
),
),
),
crossFadeState:
expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
duration: const Duration(milliseconds: 200),
),
],
),
),
),
),
);
}

Widget _bullet(ThemeData theme, String text) {
final cs = theme.colorScheme;
return Padding(
padding: const EdgeInsets.only(bottom: 6, left: 2),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.only(right: 10, top: 2),
child: Text('•', style: theme.textTheme.bodySmall),
),
Expanded(
child: Text(
text,
style: theme.textTheme.bodySmall?.copyWith(
color: cs.onSurface,
height: 1.4,
),
),
),
],
),
);
}
}

// (Language pill/segmented controls removed for English-only MVP)

class _DuaStatusSection extends StatelessWidget {
final bool isAnswered;
final VoidCallback onToggle;

const _DuaStatusSection({required this.isAnswered, required this.onToggle});

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
final cs = theme.colorScheme;

final neutralIconColor = cs.onSurfaceVariant.withValues(alpha: 0.6);
final answeredIconColor = cs.primary;

// Compact, single-line strip. No card background or shadow; minimal padding.
return Padding(
padding: const EdgeInsets.symmetric(horizontal: 24),
child: GestureDetector(
onTap: onToggle,
behavior: HitTestBehavior.opaque,
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 12), // ~10–14px as requested
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
Text(
'Duʿā Status',
style: theme.textTheme.labelMedium?.copyWith(
fontWeight: FontWeight.w600,
color: cs.onSurface.withValues(alpha: 0.7),
),
),
Icon(
isAnswered ? Icons.check_circle : Icons.radio_button_unchecked,
size: 18,
color: isAnswered ? answeredIconColor : neutralIconColor,
),
],
),
),
),
);
}
}
