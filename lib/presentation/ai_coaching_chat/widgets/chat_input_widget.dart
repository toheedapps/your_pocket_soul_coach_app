import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/app_export.dart';
import '../../../services/openai_audio_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String)? onSendVoiceMessage;
  final bool isEnabled;

  const ChatInputWidget({
    super.key,
    required this.onSendMessage,
    this.onSendVoiceMessage,
    this.isEnabled = true,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isTranscribing = false;
  bool _isRecording = false;
  bool _hasText = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _textController.text.trim().isNotEmpty;
    });
  }

  Future<void> _sendTextMessage() async {
    if (!widget.isEnabled || !_hasText) return;

    final message = _textController.text.trim();
    _textController.clear();
    setState(() => _hasText = false);

    HapticFeedback.lightImpact();
    widget.onSendMessage(message);
  }

  Future<void> _startRecording() async {
    if (!widget.isEnabled) return;

    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        await Permission.microphone.request();
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final config = const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _audioRecorder.start(config, path: filePath);

      setState(() {
        _isRecording = true;
        _recordingPath = filePath;
      });

      HapticFeedback.mediumImpact();
    } catch (e, st) {
      debugPrint('Recording start failed: $e\n$st');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);

      if (path == null) return;
      final file = File(path);

      setState(() => _isTranscribing = true);

      final audioService = OpenAIAudioService();
      String? transcript;
      try {
        transcript = await audioService.transcribeAudio(file);
      } catch (e) {
        debugPrint('Transcription failed: $e');
      } finally {
        // ✅ Always delete the audio file after transcription
        if (await file.exists()) await file.delete();
      }

      if (transcript != null && transcript.trim().isNotEmpty) {
        HapticFeedback.lightImpact();
        widget.onSendMessage(transcript.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not transcribe voice message.')),
        );
      }
    } catch (e, st) {
      debugPrint('Recording stop failed: $e\n$st');
    } finally {
      setState(() => _isTranscribing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        enabled: widget.isEnabled && !_isRecording && !_isTranscribing,
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: _isRecording
                              ? 'Recording...'
                              : _isTranscribing
                              ? 'Transcribing...'
                              : 'Share what\'s on your mind...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        onSubmitted: (_) => _sendTextMessage(),
                      ),
                    ),

                    // ✅ Spinner shown while transcribing
                    if (_isTranscribing)
                      Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                            AlwaysStoppedAnimation(colorScheme.primary),
                          ),
                        ),
                      )
                    // 🎙️ Mic button
                    else if (widget.onSendVoiceMessage != null && !_hasText)
                      GestureDetector(
                        onTapDown: (_) => _startRecording(),
                        onTapUp: (_) => _stopRecording(),
                        onTapCancel: () => _stopRecording(),
                        child: Container(
                          margin: EdgeInsets.only(right: 2.w),
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording
                                ? colorScheme.error
                                : colorScheme.primary.withValues(alpha: 0.1),
                          ),
                          child: CustomIconWidget(
                            iconName: _isRecording ? 'stop' : 'mic',
                            color: _isRecording
                                ? colorScheme.onError
                                : colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: _hasText ? _sendTextMessage : null,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasText && widget.isEnabled
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
                child: CustomIconWidget(
                  iconName: 'send',
                  color: _hasText && widget.isEnabled
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
