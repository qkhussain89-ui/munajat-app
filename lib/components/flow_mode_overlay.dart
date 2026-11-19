import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hearth_prayer/state/app_state.dart';

class FlowModeOverlay extends StatefulWidget {
  final String content;
  final VoidCallback onClose;
  final String? title;
  final bool isRtl;

  const FlowModeOverlay({
    super.key,
    required this.content,
    required this.onClose,
    this.title,
    this.isRtl = false,
  });

  @override
  State<FlowModeOverlay> createState() => _FlowModeOverlayState();
}

class _FlowModeOverlayState extends State<FlowModeOverlay> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleText = (widget.title == null || widget.title!.trim().isEmpty)
        ? 'Duʿā'
        : widget.title!.trim();
    
    return Scaffold(
      backgroundColor: scheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Text(
                          '×',
                          style: TextStyle(
                            fontSize: 32,
                            color: scheme.primary,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          color: scheme.primary,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Poppins',
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Consumer<AppState>(
                builder: (context, appState, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        widget.content,
                        textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                        textAlign: widget.isRtl ? TextAlign.right : TextAlign.center,
                        style: TextStyle(
                          fontSize: (widget.isRtl ? 30 : 28) * appState.fontSizeMultiplier,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                          letterSpacing: 0.01,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
