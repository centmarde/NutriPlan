import 'dart:async';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:groq_sdk/groq_sdk.dart';
import 'concatAi.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final List<MealData>? mealData;

  ChatMessage({required this.content, required this.isUser, this.mealData});
}

class ChatService {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() => _instance;

  ChatService._internal();

  late Groq _groq;
  late GroqChat _chat;
  final StreamController<ChatMessage> _chatStreamController =
      StreamController<ChatMessage>.broadcast();

  Stream<ChatMessage> get chatStream => _chatStreamController.stream;

  bool _isInitialized = false;
  String _assistantRole =
      "You are a nutrition assistant. Provide helpful, accurate information about nutrition, diet plans, healthy eating habits, and food recommendations. IMPORTANT: For EVERY response you provide, you MUST include at least 2-3 specific meal names wrapped in double asterisks like this: **Meal Name**. For example, you might say 'You could try **Grilled Salmon with Asparagus** or **Mediterranean Quinoa Bowl**.' Always use this exact format with the double asterisks so the system can recognize your meal suggestions.";

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('Error: GEMINI_API_KEY not found in .env file');
        return false;
      }

      _groq = Groq(apiKey);
      if (!await _groq.canUseModel(GroqModels.llama3_8b)) {
        print('Error: Cannot use the specified model');
        return false;
      }

      _chat = _groq.startNewChat(
        GroqModels.llama3_8b,
        settings: GroqChatSettings(temperature: 0.7, maxTokens: 800),
      );

      // Add assistant message to define its role
      _chat.addMessageWithoutSending(_assistantRole);

      _setupChatListener();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing ChatService: $e');
      return false;
    }
  }

  // Set or update the assistant's role
  void setAssistantRole(String role) {
    _assistantRole = role;
    if (_isInitialized) {
      _chat.addMessageWithoutSending(role);
    }
  }

  // Add additional context to guide the conversation
  void addContext(String context) {
    if (_isInitialized) {
      _chat.addMessageWithoutSending(context);
    }
  }

  void _setupChatListener() {
    try {
      print("DEBUG CHAT: Setting up chat listener");
      _chat.stream.listen(
        (event) {
          print("DEBUG CHAT: Received event from stream: ${event.runtimeType}");
          event.when(
            request: (requestEvent) {
              print("DEBUG CHAT: Request event received");
            },
            response: (responseEvent) async {
              try {
                print("DEBUG CHAT: Response event received");
                final content = responseEvent.response.choices.first.message;
                print(
                  "DEBUG CHAT: Content received: ${content.substring(0, min(50, content.length))}...",
                );

                // Extract meal names from the response
                print("DEBUG CHAT: Starting meal extraction process");
                List<String> mealNames = MealExtractor.extractMealNames(
                  content,
                );
                print("DEBUG CHAT: Extracted meal names: $mealNames");

                if (mealNames.isNotEmpty) {
                  // Fetch meal data for the extracted meal names
                  print("DEBUG CHAT: Starting meal data fetch for: $mealNames");
                  List<MealData> meals = await MealExtractor.fetchMealData(
                    mealNames,
                  );
                  print("DEBUG CHAT: Fetched ${meals.length} meal data items");

                  _chatStreamController.add(
                    ChatMessage(
                      content: content,
                      isUser: false,
                      mealData: meals,
                    ),
                  );
                  print("DEBUG CHAT: Added response with meal data to stream");
                } else {
                  _chatStreamController.add(
                    ChatMessage(content: content, isUser: false),
                  );
                  print(
                    "DEBUG CHAT: Added response without meal data to stream",
                  );
                }
              } catch (e, stackTrace) {
                print("DEBUG CHAT ERROR: Exception in response handler: $e");
                print("DEBUG CHAT STACK: $stackTrace");

                // Still try to add a message to not block the UI
                _chatStreamController.add(
                  ChatMessage(
                    content:
                        "Sorry, there was an error processing the response: $e",
                    isUser: false,
                  ),
                );
              }
            },
          );
        },
        onError: (e, stackTrace) {
          print("DEBUG CHAT ERROR: Stream listener error: $e");
          print("DEBUG CHAT STACK: $stackTrace");
        },
        onDone: () {
          print("DEBUG CHAT: Chat stream done/closed");
        },
      );
      print("DEBUG CHAT: Chat listener setup complete");
    } catch (e, stackTrace) {
      print("DEBUG CHAT ERROR: Error setting up chat listener: $e");
      print("DEBUG CHAT STACK: $stackTrace");
    }
  }

  Future<bool> sendMessage(String message) async {
    print("DEBUG CHAT: Sending message: $message");
    if (!_isInitialized) {
      print("DEBUG CHAT: Chat not initialized, attempting to initialize");
      if (!await initialize()) {
        print("DEBUG CHAT ERROR: Failed to initialize chat");
        return false;
      }
    }

    try {
      _chatStreamController.add(ChatMessage(content: message, isUser: true));
      print("DEBUG CHAT: Added user message to stream");

      // Add a try/catch specifically around the send message operation
      try {
        await _chat.sendMessage(message);
        print("DEBUG CHAT: Message sent to AI service successfully");
      } catch (e, stackTrace) {
        print("DEBUG CHAT ERROR: Error during _chat.sendMessage: $e");
        print("DEBUG CHAT STACK: $stackTrace");
        throw e; // Re-throw to be caught by the outer try/catch
      }

      return true;
    } catch (e, stackTrace) {
      print("DEBUG CHAT ERROR: Error sending message: $e");
      print("DEBUG CHAT STACK: $stackTrace");
      _chatStreamController.add(
        ChatMessage(
          content:
              "Sorry, I couldn't process your request. Please try again later. Error: $e",
          isUser: false,
        ),
      );
      return false;
    }
  }

  void dispose() {
    _chatStreamController.close();
  }
}
