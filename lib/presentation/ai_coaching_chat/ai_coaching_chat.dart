import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_export.dart';
import '../../services/firestore_service.dart';
import '../../services/openai_client.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../subscription_management/subscription_management.dart';
import './widgets/chat_input_widget.dart';
import './widgets/chat_message_widget.dart';
import './widgets/coach_avatar_selector.dart';
import './widgets/crisis_dectection_modal.dart';
import './widgets/typing_indicator_widget.dart';

class AiCoachingChat extends StatefulWidget {
  const AiCoachingChat({super.key});

  @override
  State<AiCoachingChat> createState() => _AiCoachingChatState();
}

class _AiCoachingChatState extends State<AiCoachingChat>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final OpenAIClient _openAIClient = OpenAIClient();
  final FirestoreService _firestoreService = FirestoreService();
  final User? _user = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];
  final List<Message> _conversationHistory = <Message>[];
  Map<String, dynamic>? get selectedCoach => _selectedCoach;

  bool _isTyping = false;
  bool _isInputEnabled = true;
  bool _welcomeMessageAdded = false;
  String _selectedCoachId = 'maya';
  Map<String, dynamic>? _selectedCoach;
  String? _userName;

  final List<Map<String, dynamic>> _coaches = [
    {
      'id': 'ayana',
      'name': 'Ayana',
      'description':
          'She helps you slow down, breathe, and reconnect to yourself',
      'imageUrl': 'assets/coach/ayana.webp',
      'tone': 'gentle',
      'isOnline': true,
      'specialties': ['Warm', 'Maternal', 'Grounding'],
      'systemPrompt':
      'You are AYANA. You are warm, gentle, grounding, and emotionally safe. '
          'Your presence feels calm and steady, like a maternal figure sitting beside the user. '
          'Speak softly. Never rush. Prioritize comfort and reassurance. '
          'You are best for anxiety, overwhelm, and sadness.',    },
    {
      'id': 'omari',
      'name': 'Omari',
      'description':
          'Direct but loving. Helps you build boundaries, clarity, and inner strength.',
      'imageUrl': 'assets/coach/alex.webp',
      'tone': 'practical',
      'isOnline': true,
      'specialties': ['Grounded', 'Masculine', 'Steady'],
      'systemPrompt':
      'You are OMARI. You are calm, steady, honest, and grounding. '
          'Your presence feels like a strong, protective brother or father figure. '
          'Speak clearly and simply. Do not sugarcoat, but never be harsh. '
          'Focus on clarity, boundaries, self-respect, and decision-making.',    },
    {
      'id': 'nia',
      'name': 'Nia (Child Specialist)',
      'description':
          'She helps you process your feelings through creativity, imagination, and play.',
      'imageUrl': 'assets/coach/nia.webp',
      'tone': 'creative',
      'isOnline': true,
      'specialties': ['Artistic', 'Intuitive', 'Emotional'],
      'systemPrompt':
      'You are Nia. You are tender, soft, and emotionally attuned. '
          'You are highly protective of vulnerability. Move slowly. Avoid all pressure. '
          'Help the user feel safe to open up. You are best for trauma, grief, shame, and sensitivity.',
    },
    {
      'id': 'daniel',
      'name': 'Daniel',
      'description':
          'She guides you through heavy emotions with compassion and soulful insight.',
      'imageUrl': 'assets/coach/daniel.webp',
      'tone': 'compassionate',
      'isOnline': true,
      'specialties': ['Self-Esteem & Confidence'],
      'systemPrompt':
      'You are DANIEL. You are deep, soulful, and emotionally insightful. '
          'Your presence feels wise and meaningful. Speak with warmth and depth, but never preach. '
          'Help the user understand themselves, make meaning of pain, and rebuild self-worth.',    },

    {
      'id': 'matthew',
      'name': 'Matthew',
      'description':
          'She helps you explore childhood wounds, self-worth, and emotional triggers with love.',
      'imageUrl': 'assets/coach/matthew.webp',
      'tone': 'nurturing',
      'isOnline': true,
      'specialties': ['Soft', 'Playful', 'Nurturing'],
      'systemPrompt':
      'You are MATTHEW. You are gentle, playful, and emotionally nurturing. '
          'Your presence is safe and non-judgmental. '
          'Focus on "Inner Child" work: helping the user feel seen, lovable, and safe. '
          'Address feelings of being small or unseen with great care.',    },
    {
      'id': 'mateo',
      'name': 'Mateo',
      'description':
          'Helps you stay consistent, form habits, and keep your promises to yourself.',
      'imageUrl': 'assets/coach/mateo.webp',
      'tone': 'motivational',
      'isOnline': true,
      'specialties': ['Calm', 'Structured', 'Motivating'],
      'systemPrompt':
      'You are MATEO. You are calm, clear, practical, and organized. '
          'Your presence is structured but kind. '
          'Help the user untangle messy thoughts and find simple next steps. '
          'Never pressure or shame. Focus on curiosity and gentle consistency.',
    },
  ];

  String? get _uid => _user?.uid;
  late Future<void> _coachLoadFuture;

  @override
  void initState() {
    super.initState();
    _coachLoadFuture = _loadSelectedCoach().then((_) {
      // _addWelcomeMessageIfNeeded();
    });
    _testOpenAIConnection();
    _listenToChatHistory();
    // NEW: Check subscription on init to enable/disable input
    if (_uid != null) {
      _firestoreService.isSubscribed(_uid!).then((subscribed) {
        setState(() => _isInputEnabled = subscribed);
      });
    }
    // TEMPORARY FOR TESTING: Hardcode to true to always enable input (remove for production)
    // setState(() => _isInputEnabled = true);
  }

  Future<void> _loadSelectedCoach() async {
    if (_uid == null) return;
    final selectedId = await _firestoreService.getSelectedCoach(_uid!);
    _selectedCoachId = selectedId ?? 'maya';

    _selectedCoach = _coaches.firstWhere(
      (coach) => coach['id'] == _selectedCoachId,
      orElse: () => _coaches.first,
    );

    if (mounted) {
      setState(() {}); // This updates app bar + typing indicator immediately
    }

    // _addWelcomeMessageIfNeeded(); // Fresh welcome with correct coach name
    
    // NEW: Fetch user name
    try {
      final profile = await _firestoreService.getUserProfile(_uid!);
      if (profile != null && profile['name'] != null) {
        setState(() {
          _userName = profile['name'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  // void _addWelcomeMessageIfNeeded() {
  //   if (_messages.isNotEmpty || _welcomeMessageAdded || _selectedCoach == null) return;
  //
  //   final coachName = _selectedCoach!['name'] ?? 'Your Coach';
  //   final welcomeText = "Hi love, I’m $coachName, your Soul Pocket Coach. How are you feeling today? 🫂";
  //
  //   final welcomeMsg = {
  //     'id': 'welcome_${DateTime.now().millisecondsSinceEpoch}',
  //     'content': welcomeText,
  //     'isUser': false,
  //     'timestamp': DateTime.now(),
  //     'status': 'delivered',
  //   };
  //
  //   setState(() {
  //     _messages.add(welcomeMsg);
  //     _welcomeMessageAdded = true;
  //   });
  //   _scrollToBottom();
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _testOpenAIConnection() async {
    try {
      final isConnected = await _openAIClient.testConnection();
      if (!isConnected) {
        _showErrorMessage(
          'Unable to connect to service. Please check your internet connection.',
        );
      }
    } catch (_) {
      _showErrorMessage(
        'Service configuration issue. Please check Internet Connection.',
      );
    }
  }

  void _listenToChatHistory() {
    final currentUid = _uid;
    if (currentUid == null) return;

    _firestoreService
        .listenToChatHistory(currentUid)
        .listen(
          (snapshot) {
            setState(() {
              _messages.clear();

              for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                  in snapshot.docs) {
                final Map<String, dynamic> data = doc.data();

                // timestamp safe conversion
                final rawTs = data['timestamp'];
                DateTime time;
                if (rawTs is Timestamp) {
                  time = rawTs.toDate();
                } else if (rawTs is DateTime) {
                  time = rawTs;
                } else {
                  time = DateTime.now();
                }

                // ensure string types
                final String content = (data['message'] ?? '').toString();
                final String role = (data['role'] ?? 'assistant').toString();
                final bool isUser = role.toLowerCase() == 'user';

                _messages.add(<String, dynamic>{
                  'id': doc.id,
                  'content': content,
                  'isUser': isUser,
                  'timestamp': time,
                  'status': 'delivered',
                });
              }
            });

            _scrollToBottom();

            // ←←← NEW WELCOME LOGIC STARTS HERE
            // Inside _listenToChatHistory()'s listener callback, replace the welcome block:
            if (snapshot.docs.isEmpty && _selectedCoach != null && _uid != null) {
              // Prevent duplicate welcome even if listener fires multiple times
              if (_welcomeMessageAdded) return;

              _welcomeMessageAdded = true;

              final String coachName = _selectedCoach!['name'] as String;
              final specialties = (_selectedCoach!['specialties'] as List).join(', ');
              final String welcomeText =
                  "Hi! I'm $coachName. I'll continue with a ${_selectedCoach!['tone']} approach. My specialties include $specialties. How can I help you today?";

              // Save to Firestore (will trigger listener again → but now guarded by _welcomeMessageAdded)
              _firestoreService.saveChatMessage(
                uid: _uid!,
                role: 'assistant',
                message: welcomeText,
              );

              // Also add to local history so OpenAI knows
              _conversationHistory.add(Message(role: 'assistant', content: welcomeText));
            }
          },
          onError: (err) {
            debugPrint('Firestore chat listen error: $err');
          },
        );
  }

  Future<void> _sendMessage(String content) async {
    final currentUid = _uid;
    if (content.trim().isEmpty || currentUid == null) return;

    // NEW: Subscription check
    final isSubscribed = await _firestoreService.isSubscribed(currentUid);
    if (!isSubscribed) {
      setState(() {
        _messages.add(<String, dynamic>{
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'content':
              'Your free trial has ended. Please subscribe to continue using the AI coach.',
          'isUser': false,
          'timestamp': DateTime.now(),
          'status': 'delivered',
        });
        _isInputEnabled = false;
      });
      // Navigate to subscription screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SubscriptionManagement()),
      );
      return;
    }

    final isCrisis = await _checkForCrisis(content);
    if (isCrisis) {
      _showCrisisModal();
      return;
    }

    final userMessage = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': content,
      'isUser': true,
      'timestamp': DateTime.now(),
      'status': 'sending',
    };

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _isInputEnabled = false;
    });

    _conversationHistory.add(Message(role: 'user', content: content));
    _scrollToBottom();

    // Save user message as String (explicit)
    await _firestoreService.saveChatMessage(
      uid: currentUid,
      role: 'user',
      message: content,
    );

    await _generateOpenAIResponse();

    // NEW: Increment AI session usage after successful send
    await _firestoreService.incrementUsage(currentUid, 'aiSessionsCount');
  }

  Future<bool> _checkForCrisis(String message) async {
    try {
      return await _openAIClient.checkForCrisisContent(message);
    } catch (_) {
      return _containsBasicCrisisKeywords(message);
    }
  }

  bool _containsBasicCrisisKeywords(String message) {
    const crisisKeywords = [
      'suicide',
      'kill myself',
      'end it all',
      'hurt myself',
      'self harm',
      'want to die',
      'better off dead',
      'no point living',
      'hopeless',
      'worthless',
      'nobody cares',
    ];
    final lower = message.toLowerCase();
    return crisisKeywords.any(lower.contains);
  }

  Future<void> _generateOpenAIResponse() async {
    final currentUid = _uid;
    try {
      final coachInstruction = _selectedCoach!['systemPrompt'] as String? ?? '';
      
      final completion = await _openAIClient.createChatCompletion(
        messages: _conversationHistory,
        model: 'gpt-4o-mini',
        coachInstruction: coachInstruction,
        userName: _userName,
      );

      final String assistantText = completion.text ?? '';

      final aiMessage = <String, dynamic>{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': assistantText,
        'isUser': false,
        'timestamp': DateTime.now(),
        'status': 'delivered',
      };

      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
        _isInputEnabled = true;
      });

      _conversationHistory.add(
        Message(role: 'assistant', content: assistantText),
      );
      _updateLastUserMessageStatus('read');
      _scrollToBottom();
      HapticFeedback.lightImpact();

      if (currentUid != null) {
        await _firestore_service_save(currentUid, 'assistant', assistantText);
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _isInputEnabled = true;
      });

      String errorMessage = 'Connection issue. Please try again shortly.';
      if (e is OpenAIException) {
        if (e.statusCode == 401) {
          errorMessage = 'Invalid API key. Please verify your configuration.';
        } else if (e.statusCode == 429) {
          errorMessage = 'Rate limit exceeded. Try again in a few seconds.';
        } else {
          errorMessage = e.message;
        }
      }
      _showErrorMessage(errorMessage);

      final fallbackText =
          'I\'m experiencing technical difficulties right now.';

      final fallbackMessage = <String, dynamic>{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': fallbackText,
        'isUser': false,
        'timestamp': DateTime.now(),
        'status': 'delivered',
      };

      setState(() => _messages.add(fallbackMessage));

      if (currentUid != null) {
        await _firestore_service_save(currentUid, 'assistant', fallbackText);
      }
    }
  }

  // small wrapper to guarantee String param when calling service
  Future<void> _firestore_service_save(
    String uid,
    String role,
    String message,
  ) async {
    await _firestoreService.saveChatMessage(
      uid: uid,
      role: role,
      message: message,
    );
  }

  void _updateLastUserMessageStatus(String status) {
    final idx = _messages.lastIndexWhere((m) => m['isUser'] == true);
    if (idx != -1) setState(() => _messages[idx]['status'] = status);
  }

  void _showCoachSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        // Fix bottom overflow
        child: CoachAvatarSelector(
          coaches: _coaches, // Pass the list
          selectedAvatarId: _selectedCoachId,
          onAvatarSelected: (coach) async {
            setState(() {
              _selectedCoachId = coach['id'];
              _selectedCoach = coach;
              _welcomeMessageAdded = false; // Allow welcome only if chat empty
            });

            if (_uid != null) {
              await _firestoreService.saveSelectedCoach(_uid!, _selectedCoachId);
            }

            Navigator.pop(context);

            // Only send "I'm now your coach" if there are already messages
            if (_messages.isNotEmpty) {
              final switchMessage = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'content':
                "Hi! I'm ${coach['name']}. I’ll continue with a ${coach['tone']} approach. My specialties include ${(coach['specialties'] as List).join(', ')}. How can I help you today?",
                'isUser': false,
                'timestamp': DateTime.now(),
                'status': 'delivered',
              };

              setState(() => _messages.add(switchMessage));
              _conversationHistory.add(Message(role: 'assistant', content: switchMessage['content']));

              // Save switch message
              if (_uid != null) {
                _firestoreService.saveChatMessage(
                  uid: _uid!,
                  role: 'assistant',
                  message: switchMessage['content'].toString(),
                );
              }
            }
            // If chat is empty → let the listener add the proper welcome once
          },
        ),
      ),
    );
  }

  void _showCrisisModal() {
    setState(() => _isInputEnabled = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => CrisisDetectionModal(
        onClose: () {
          Navigator.pop(context);
          setState(() => _isInputEnabled = true);
        },
        onCallHotline: () {
          Navigator.pop(context);
          _callEmergencyHotline();
        },
        onSafetyPlan: () {
          Navigator.pop(context);
          _openSafetyPlan();
        },
      ),
    );
  }

  void _callEmergencyHotline() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Connecting to 988 Suicide & Crisis Lifeline...'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _openSafetyPlan() {
    setState(() => _isInputEnabled = true);
    final msg = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content':
          'Let’s create a safety plan together. What are some things that help you feel calmer when you’re upset?',
      'isUser': false,
      'timestamp': DateTime.now(),
      'status': 'delivered',
    };
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearChatHistory() async {
    if (_uid == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Chat History'),
          content: const Text(
            'Are you sure you want to clear your chat history? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Clear'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _firestoreService.clearChatHistory(_uid!);
        setState(() {
          _messages.clear();
          _conversationHistory.clear();
          _welcomeMessageAdded = false;
        });
        _showErrorMessage('Chat history cleared successfully.');
      } catch (e) {
        _showErrorMessage('Failed to clear chat history: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder(
      future: _coachLoadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: _selectedCoach?['name'] ?? 'AI Coach',
            actions: [
              IconButton(
                onPressed: _showCoachSelector,
                icon: CustomIconWidget(
                  iconName: 'person_outline',
                  color: colorScheme.onSurface,
                  size: 24,
                ),
                tooltip: 'Switch Coach',
              ),
              IconButton(
                onPressed: _clearChatHistory,
                icon: CustomIconWidget(
                  iconName: 'delete_outline',
                  color: colorScheme.onSurface,
                  size: 24,
                ),
                tooltip: 'Clear History',
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return ChatMessageWidget(
                      message: message,
                      isUser: message['isUser'] as bool,
                      coachImageUrl: _selectedCoach?['imageUrl'] ?? 'assets/coach/default_coach.jpg',
                      onLongPress: () {},
                    );
                  },
                ),
              ),
              TypingIndicatorWidget(
                key: ValueKey('typing_${_selectedCoach?['imageUrl']}'), // Add this key!
                isVisible: _isTyping,
                coachImageUrl: _selectedCoach?['imageUrl'] ?? '',
              ),
              ChatInputWidget(
                onSendMessage: _sendMessage,
                onSendVoiceMessage: (path) =>
                    _sendMessage('🎤 Voice message sent'),
                isEnabled: _isInputEnabled,
              ),
            ],
          ),
          bottomNavigationBar: CustomBottomBar(),
        );
      },
    );
  }
}
