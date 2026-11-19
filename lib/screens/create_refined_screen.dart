import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hearth_prayer/theme/brand_theme.dart';
import 'package:hearth_prayer/theme/brand_tokens_extension.dart';
import 'package:hearth_prayer/supabase/supabase_config.dart';
import 'package:hearth_prayer/components/processing_overlay.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:hearth_prayer/state/app_state.dart';
import 'package:hearth_prayer/services/revenucat_service.dart';
import 'package:hearth_prayer/screens/me/subscription_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hearth_prayer/components/copper_button.dart';

class CreateRefinedScreen extends StatefulWidget {
  final String? draftText;
  final String? initialMode;
  final bool autoStartRecording;
  // Controls visibility of the back arrow in the header.
  // Use an explicit flag instead of relying on Navigator.canPop.
  final bool showBackButton;

  const CreateRefinedScreen({
    super.key,
    this.draftText,
    this.initialMode,
    this.autoStartRecording = false,
    this.showBackButton = true,
  });

  @override
  State<CreateRefinedScreen> createState() => _CreateRefinedScreenState();
}

class _CreateRefinedScreenState extends State<CreateRefinedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _recordingController;
  final _textController = TextEditingController();
  // Speak mode captured text controller/state
  final TextEditingController _speakTextController = TextEditingController();
  bool _isRecording = false;
  late String _mode;
  bool _showHelperText = true;

  // New local state for Speak mode (UI-only per spec)
  String _capturedSpeechText = '';
  bool _showCapturedTextBox = false;

  // Audio recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isTranscribing = false;

  // Local UI-only state for Refine panel
  // Defaults per spec
  String _duaLength = 'balanced'; // {concise, extended, balanced}
  bool _includeSayyidIstighfar = true; // default ON
  String _primaryFocus = 'everything'; // {din, rizq, family, hardship, everything}
  bool _refinePanelExpanded = false; // panel starts collapsed

  // Generation state
  bool _isGenerating = false;

  // Output language selector
  String _outputLanguage = 'english';

  static const List<Map<String, String>> _languageOptions = [
    {'value': 'english', 'label': 'English'},
    {'value': 'arabic', 'label': 'Arabic'},
    {'value': 'urdu', 'label': 'Urdu'},
    {'value': 'french', 'label': 'Français'},
    {'value': 'spanish', 'label': 'Español'},
    {'value': 'turkish', 'label': 'Türkçe'},
    {'value': 'malay', 'label': 'Bahasa'},
    {'value': 'bengali', 'label': 'Bengali'},
    {'value': 'chinese', 'label': 'Chinese'},
  ];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode ?? 'type';
    _isRecording = false;
    _recordingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _textController.text = widget.draftText ?? '';
    _textController.addListener(_updateHelperTextVisibility);
    _speakTextController.addListener(() {
      setState(() {});
      _capturedSpeechText = _speakTextController.text;
    });
  }

  @override
  void dispose() {
    _recordingController.dispose();
    _textController.dispose();
    _speakTextController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _updateHelperTextVisibility() {
    setState(() {
      _showHelperText = _textController.text.trim().isEmpty;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _recordingController.repeat();
      } else {
        _recordingController.stop();
      }
    });
  }

  Future<void> _handleMicTap() async {
    if (_isTranscribing) return;

    if (_isRecording) {
      await _stopRecordingAndTranscribe();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required to use voice input')),
          );
        }
        return;
      }

      // Get proper temp directory for iOS
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/munajat_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = filePath;

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _showCapturedTextBox = false;
      });
      _recordingController.repeat();
    } catch (e, stackTrace) {
      debugPrint('Error starting recording: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recording error: ${e.toString().substring(0, (e.toString().length > 100) ? 100 : e.toString().length)}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _stopRecordingAndTranscribe() async {
    try {
      final path = await _audioRecorder.stop();
      _recordingController.stop();
      setState(() {
        _isRecording = false;
        _isTranscribing = true;
      });

      if (path == null || path.isEmpty) {
        debugPrint('Recording path is null or empty');
        setState(() => _isTranscribing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recording failed. Please try again.')),
          );
        }
        return;
      }

      final transcribedText = await _transcribeAudio(path);

      if (transcribedText != null && transcribedText.isNotEmpty) {
        setState(() {
          _speakTextController.text = transcribedText;
          _capturedSpeechText = transcribedText;
          _showCapturedTextBox = true;
        });
      } else {
        setState(() {
          _showCapturedTextBox = true;
          _speakTextController.text = '';
        });
      }

      await _deleteAudioFile(path);
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not transcribe audio. Please try again or use Type mode.')),
        );
      }
      setState(() {
        _showCapturedTextBox = true;
        _speakTextController.text = '';
      });
      if (_currentRecordingPath != null) {
        await _deleteAudioFile(_currentRecordingPath!);
      }
    } finally {
      if (mounted) {
        setState(() => _isTranscribing = false);
      }
    }
  }

  Future<String?> _transcribeAudio(String audioPath) async {
    try {
      final session = SupabaseConfig.auth.currentSession;
      final uri = Uri.parse('${SupabaseConfig.supabaseUrl}/functions/v1/whisper-transcribe');
      
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['apikey'] = SupabaseConfig.anonKey;
      if (session != null && session.accessToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }

      // FIX: Read file as bytes first, then use fromBytes instead of fromPath
      // fromPath uses dart:io internals that fail in DreamFlow's preview environment
      final audioFile = File(audioPath);
      final audioBytes = await audioFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        audioBytes,
        filename: 'audio.m4a',
        contentType: MediaType('audio', 'm4a'),
      ));

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final json = jsonDecode(responseBody);
        return json['text'] as String?;
      } else {
        debugPrint('Whisper transcription failed: ${streamedResponse.statusCode} - $responseBody');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transcribe error ${streamedResponse.statusCode}: ${responseBody.substring(0, (responseBody.length > 80) ? 80 : responseBody.length)}'),
              duration: const Duration(seconds: 6),
            ),
          );
        }
        return null;
      }
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transcribe exception: ${e.toString().substring(0, (e.toString().length > 80) ? 80 : e.toString().length)}'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _deleteAudioFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting audio file: $e');
    }
  }

  Future<void> _navigateToPreview() async {
    FocusScope.of(context).unfocus();

    // AI data consent check — required by Apple before sending data to OpenAI
    final prefs = await SharedPreferences.getInstance();
    final hasConsented = prefs.getBool('ai_data_consent') ?? false;
    if (!hasConsented) {
      if (!mounted) return;
      final agreed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final theme = Theme.of(dialogContext);
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shield icon
                  Icon(
                    Icons.verified_user_outlined,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  // Heading
                  Text(
                    'Your Privacy Matters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Section 1 — What happens
                  Text(
                    'When you create a du\u02BBā, your words are securely sent to our AI partner to craft your personalised supplication.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Section 2 — Who processes it
                  Text(
                    'Powered by OpenAI — your text is processed solely to generate your du\u02BBā and is not stored or used for any other purpose.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Section 3 — Your control
                  Text(
                    'You can decline at any time. Your privacy and trust are sacred to us.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Primary button (Accept)
                  SizedBox(
                    width: double.infinity,
                    child: CopperButton(
                      text: 'I Understand & Agree',
                      variant: CopperButtonVariant.primary,
                      onPressed: () => Navigator.pop(dialogContext, true),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Secondary button (Decline)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      'No thanks',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      if (agreed != true) return;
      await prefs.setBool('ai_data_consent', true);
    }

    // Allow anonymous users to create their first du'a
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isAnonymous) {
      // Only check subscription for real (non-anonymous) users
      final isPro = await RevenueCatService().isProUser();
      if (!isPro) {
        final isTrial = await RevenueCatService().isInTrial();
        if (!isTrial) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            );
          }
          return;
        }
      }
    }

    final rawInput = _mode == 'type'
        ? _textController.text.trim()
        : _speakTextController.text.trim();

    if (rawInput.length < 10) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least 10 characters.')),
        );
      }
      return;
    }

    setState(() => _isGenerating = true);

    final overlayEntry = OverlayEntry(
      builder: (context) => const ProcessingOverlay(text: 'Crafting your duʿā...'),
    );

    if (mounted) {
      Overlay.of(context).insert(overlayEntry);
    }

    try {
      const uuid = Uuid();
      final payload = {
        'raw_input': rawInput,
        'input_mode': _mode,
        'dua_length': _duaLength,
        'include_sayyid_istighfar': _includeSayyidIstighfar,
        'primary_focus': _primaryFocus,
        'client_request_id': uuid.v4(),
        'output_language': _outputLanguage,
      };

      final response = await SupabaseService.invokeFunction('generate-dua', payload);

      final generatedEnglish = (response['english'] as String? ?? '').trim();

      if (generatedEnglish.isEmpty) {
        throw Exception('Empty response from generation service');
      }

      overlayEntry.remove();

      if (mounted) {
        await Navigator.pushNamed(context, '/preview', arguments: {
          'english': generatedEnglish,
          'output_language': _outputLanguage,
        });
      }
    } catch (e) {
      debugPrint('Error generating duʿā: $e');

      overlayEntry.remove();

      if (mounted) {
        String errorMessage = 'Unable to generate duʿā. Please try again.';

        if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
          errorMessage = 'Please log in again and try.';
        } else if (e.toString().contains('timeout') ||
            e.toString().contains('network') ||
            e.toString().contains('SocketException')) {
          errorMessage = 'Request timed out. Please check your connection.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brandTokens = context.brandTokens;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 32),
              child: Column(
                children: [
                  _buildHeader(colorScheme, brandTokens),
                  const SizedBox(height: 32),
                  _buildModeSelector(colorScheme, brandTokens),
                  const SizedBox(height: 24),
                  if (_mode == 'type')
                    _buildTypeMode(colorScheme, brandTokens)
                  else
                    _buildSpeakMode(colorScheme, brandTokens),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, BrandTokens brandTokens) {
    final bool showBackArrow = widget.showBackButton;
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: showBackArrow
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 22,
                          color: colorScheme.secondary,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        padding: EdgeInsets.zero,
                        tooltip: 'Back',
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (_) => brandTokens.copperGradient.createShader(const Rect.fromLTWH(0, 0, 400, 50)),
                    child: Text(
                      "Express What's in Your Heart",
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
              SizedBox(
                width: 44,
                child: IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => Navigator.of(context).pushNamed('/how-it-works'),
                  padding: EdgeInsets.zero,
                  tooltip: 'How It Works',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Share your thoughts, and we'll refine them with Sunnah etiquette.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector(ColorScheme colorScheme, BrandTokens brandTokens) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: brandTokens.border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildModeButton('Type', 'type', colorScheme, brandTokens),
          _buildModeButton('Speak', 'speak', colorScheme, brandTokens),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String value, ColorScheme colorScheme, BrandTokens brandTokens) {
    final isActive = _mode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = value),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeMode(ColorScheme colorScheme, BrandTokens brandTokens) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Column(
        key: const ValueKey('type'),
        children: [
          TextField(
            controller: _textController,
            minLines: 8,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: "What's on your heart? Share your thoughts, and we'll help craft them into a beautiful duʿā.",
              hintStyle: TextStyle(
                fontSize: 16,
                color: brandTokens.textMuted,
                fontFamily: 'Poppins',
              ),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡', style: TextStyle(fontSize: 13)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'The more you share, the more personal your du\'ā becomes. Mention specific details — names, situations, emotions — and Allah\'s most relevant Names will be woven throughout.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFD4A574).withOpacity(0.6),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildLanguageSelector(colorScheme, brandTokens),
          _buildCTA(colorScheme, brandTokens),
          if (_showHelperText) ...[
            const SizedBox(height: 24),
            Text(
              'Start typing to enable.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: brandTokens.textMuted.withValues(alpha: 0.6),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeakMode(ColorScheme colorScheme, BrandTokens brandTokens) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Column(
        key: const ValueKey('speak'),
        children: [
          const SizedBox(height: 40),
          Center(
            child: _isTranscribing
                ? _buildTranscribingIndicator(colorScheme, brandTokens)
                : AnimatedBuilder(
                    animation: _recordingController,
                    builder: (context, child) {
                      double scale = 1.0;
                      if (_isRecording) {
                        scale = 1.0 + (_recordingController.value * 0.3);
                      }
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isRecording)
                            Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: _handleMicTap,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? colorScheme.primary : colorScheme.surface,
                                border: Border.all(color: brandTokens.border, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                size: 48,
                                color: _isRecording ? colorScheme.onPrimary : colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 32),
          Text(
            _isTranscribing
                ? 'Transcribing your words...'
                : (_isRecording ? 'Listening…' : 'Tap to speak'),
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isTranscribing
                ? 'Please wait a moment.'
                : (_isRecording
                    ? "Share what's on your heart. We're listening."
                    : "Speak naturally. We'll help you craft it into a beautiful duʿā."),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 40),
          if (_showCapturedTextBox) ...[
            TextField(
              controller: _speakTextController,
              minLines: 8,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: 'Your words will appear here…',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: brandTokens.textMuted,
                  fontFamily: 'Poppins',
                ),
                helperText: 'Review and edit before creating your duʿā.',
                helperStyle: TextStyle(
                  fontSize: 12,
                  color: brandTokens.textMuted,
                  fontFamily: 'Poppins',
                  height: 1.3,
                ),
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
            _buildLanguageSelector(colorScheme, brandTokens),
            _buildCTA(colorScheme, brandTokens),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildTranscribingIndicator(ColorScheme colorScheme, BrandTokens brandTokens) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surface,
        border: Border.all(color: brandTokens.border, width: 2),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildCTA(ColorScheme colorScheme, BrandTokens brandTokens) {
    final bool hasInput = _mode == 'type'
        ? _textController.text.trim().isNotEmpty
        : (_showCapturedTextBox && _speakTextController.text.trim().isNotEmpty);
    final bool isEnabled = hasInput && !_isGenerating && !_isTranscribing;
    return Semantics(
      label: 'Create Duʿā button',
      enabled: isEnabled,
      child: GestureDetector(
        onTap: isEnabled ? _navigateToPreview : null,
        child: IgnorePointer(
          ignoring: !isEnabled,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isEnabled ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: isEnabled ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 8),
                Text(
                  'Create Duʿā',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.3),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentOption({
    required String label,
    required String value,
    required String groupValue,
    required void Function(String) onSelected,
    required ColorScheme colorScheme,
  }) {
    final isActive = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(value),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusChip({
    required String label,
    required String value,
    required bool selected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required BrandTokens brandTokens,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: brandTokens.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(ColorScheme colorScheme, BrandTokens brandTokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Duʿā Language (scroll for more)',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            color: brandTokens.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _languageOptions.map((option) {
              final isSelected = _outputLanguage == option['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _outputLanguage = option['value']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: brandTokens.border),
                    ),
                    child: Text(
                      option['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}