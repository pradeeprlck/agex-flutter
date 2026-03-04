import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_service.dart';

// ── Voice Assistant State ──
enum VoiceState { idle, listening, processing, speaking }

class VoiceAssistantState {
  final VoiceState state;
  final String recognizedText;
  final String reply;
  final String? error;
  final List<_ChatMessage> history;

  const VoiceAssistantState({
    this.state = VoiceState.idle,
    this.recognizedText = '',
    this.reply = '',
    this.error,
    this.history = const [],
  });

  VoiceAssistantState copyWith({
    VoiceState? state,
    String? recognizedText,
    String? reply,
    String? error,
    List<_ChatMessage>? history,
  }) => VoiceAssistantState(
    state: state ?? this.state,
    recognizedText: recognizedText ?? this.recognizedText,
    reply: reply ?? this.reply,
    error: error,
    history: history ?? this.history,
  );
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  _ChatMessage({required this.text, required this.isUser}) : time = DateTime.now();
}

// ── Voice FAB Widget ──
class VoiceAssistantFab extends ConsumerStatefulWidget {
  const VoiceAssistantFab({super.key});

  @override
  ConsumerState<VoiceAssistantFab> createState() => _VoiceAssistantFabState();
}

class _VoiceAssistantFabState extends ConsumerState<VoiceAssistantFab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;

  VoiceAssistantState _state = const VoiceAssistantState();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_state.state == VoiceState.listening && _state.recognizedText.isNotEmpty) {
            _processQuestion(_state.recognizedText);
          } else if (_state.state == VoiceState.listening) {
            setState(() => _state = _state.copyWith(state: VoiceState.idle));
            _pulseController.stop();
          }
        }
      },
      onError: (error) {
        setState(() => _state = _state.copyWith(state: VoiceState.idle, error: 'Speech recognition error'));
        _pulseController.stop();
      },
    );
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      setState(() => _state = _state.copyWith(state: VoiceState.idle));
    });
  }

  void _startListening() async {
    if (!_speechAvailable) {
      _showBottomSheet(textMode: true);
      return;
    }

    setState(() => _state = _state.copyWith(
      state: VoiceState.listening,
      recognizedText: '',
      error: null,
    ));
    _pulseController.repeat();

    await _speech.listen(
      onResult: (result) {
        setState(() => _state = _state.copyWith(recognizedText: result.recognizedWords));
      },
      localeId: 'en_IN',
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
    );

    _showBottomSheet();
  }

  void _stopListening() {
    _speech.stop();
    _pulseController.stop();
    if (_state.recognizedText.isNotEmpty) {
      _processQuestion(_state.recognizedText);
    } else {
      setState(() => _state = _state.copyWith(state: VoiceState.idle));
    }
  }

  Future<void> _processQuestion(String question) async {
    setState(() {
      final history = [..._state.history, _ChatMessage(text: question, isUser: true)];
      _state = _state.copyWith(state: VoiceState.processing, history: history, error: null);
    });
    _pulseController.stop();

    try {
      final api = ref.read(apiServiceProvider);
      final res = await api.askAssistant(question);
      final reply = res.data['reply']?.toString() ?? 'I couldn\'t understand. Please try again.';

      setState(() {
        final history = [..._state.history, _ChatMessage(text: reply, isUser: false)];
        _state = _state.copyWith(state: VoiceState.speaking, reply: reply, history: history);
      });

      await _tts.speak(reply);
    } catch (e) {
      setState(() => _state = _state.copyWith(
        state: VoiceState.idle,
        error: 'Failed to get response. Check your connection.',
      ));
    }
  }

  void _showBottomSheet({bool textMode = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VoiceAssistantSheet(
        state: _state,
        textMode: textMode,
        onStop: _stopListening,
        onSubmit: (text) {
          Navigator.of(ctx).pop();
          _processQuestion(text);
          _showBottomSheet();
        },
        onClose: () {
          _speech.stop();
          _tts.stop();
          _pulseController.stop();
          setState(() => _state = _state.copyWith(state: VoiceState.idle));
          Navigator.of(ctx).pop();
        },
        onMicTap: () {
          Navigator.of(ctx).pop();
          _startListening();
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _state.state != VoiceState.idle;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        final scale = isActive ? 1.0 + (_pulseController.value * 0.15) : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: FloatingActionButton(
        onPressed: _startListening,
        backgroundColor: isActive ? AppColors.red500 : AppColors.brand600,
        elevation: isActive ? 8 : 4,
        child: Icon(
          isActive ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

// ── Bottom Sheet ──
class _VoiceAssistantSheet extends StatefulWidget {
  final VoiceAssistantState state;
  final bool textMode;
  final VoidCallback onStop;
  final ValueChanged<String> onSubmit;
  final VoidCallback onClose;
  final VoidCallback onMicTap;

  const _VoiceAssistantSheet({
    required this.state,
    required this.textMode,
    required this.onStop,
    required this.onSubmit,
    required this.onClose,
    required this.onMicTap,
  });

  @override
  State<_VoiceAssistantSheet> createState() => _VoiceAssistantSheetState();
}

class _VoiceAssistantSheetState extends State<_VoiceAssistantSheet> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Center(child: Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40, height: 4,
          decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(2)),
        )),

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(children: [
            const Icon(Icons.assistant, color: AppColors.brand600, size: 22),
            const SizedBox(width: 8),
            const Expanded(child: Text('AgriExpert Assistant',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray800))),
            IconButton(icon: const Icon(Icons.close, size: 20), onPressed: widget.onClose),
          ]),
        ),
        const Divider(height: 1),

        // Chat history
        Expanded(
          child: s.history.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.record_voice_over, size: 48, color: AppColors.brand200),
                  const SizedBox(height: 12),
                  const Text('Ask me anything about farming!',
                      style: TextStyle(fontSize: 14, color: AppColors.gray500)),
                  const SizedBox(height: 4),
                  const Text('Tap the mic or type your question',
                      style: TextStyle(fontSize: 11, color: AppColors.gray400)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: s.history.length,
                  itemBuilder: (_, i) {
                    final msg = s.history[i];
                    return _ChatBubble(message: msg);
                  },
                ),
        ),

        // Status indicator
        if (s.state == VoiceState.listening) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(children: [
              const _PulsingDot(),
              const SizedBox(width: 8),
              Expanded(child: Text(
                s.recognizedText.isEmpty ? 'Listening...' : s.recognizedText,
                style: TextStyle(
                  fontSize: 13,
                  color: s.recognizedText.isEmpty ? AppColors.gray400 : AppColors.gray700,
                  fontStyle: s.recognizedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              )),
              IconButton(
                onPressed: widget.onStop,
                icon: const Icon(Icons.stop_circle, color: AppColors.red500, size: 28),
              ),
            ]),
          ),
        ],

        if (s.state == VoiceState.processing) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand600)),
              SizedBox(width: 8),
              Text('Thinking...', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
            ]),
          ),
        ],

        if (s.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(s.error!, style: const TextStyle(fontSize: 12, color: AppColors.red500)),
          ),

        // Input area
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            border: Border(top: BorderSide(color: AppColors.gray100)),
          ),
          child: SafeArea(
            child: Row(children: [
              // Mic button
              GestureDetector(
                onTap: s.state == VoiceState.listening ? widget.onStop : widget.onMicTap,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: s.state == VoiceState.listening ? AppColors.red500 : AppColors.brand600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    s.state == VoiceState.listening ? Icons.stop : Icons.mic,
                    color: Colors.white, size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Text input
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type your question...',
                    hintStyle: const TextStyle(fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      widget.onSubmit(text.trim());
                      _textController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              GestureDetector(
                onTap: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onSubmit(text);
                    _textController.clear();
                  }
                },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.brand600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Chat Bubble ──
class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.brand600 : AppColors.gray100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 13,
            color: isUser ? Colors.white : AppColors.gray800,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ── Pulsing Dot ──
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.red500.withOpacity(0.5 + _controller.value * 0.5),
        ),
      ),
    );
  }
}
