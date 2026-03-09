import 'package:conference/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/meeting_model.dart';
import '../../models/chat_message_model.dart';

class ChatDetailController extends GetxController {
  final MeetingModel conversation = Get.arguments as MeetingModel;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final _http = HttpService.instance;

  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchMessages();
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreMessages();
    }
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    _currentPage = 1;
    _hasMore = true;
    try {
      final response = await _http.get(
        'messages/get?id=${conversation.id}&page=$_currentPage&limit=20',
      );

      if (response.responseBody != null) {
        final data = response.responseBody;
        if (data != null) {
          final chatResponse = ChatMessageResponse.fromJson(data);
          messages.value = chatResponse.messages;
          _hasMore = chatResponse.hasMore;
          _currentPage++;
        }
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !_hasMore) return;

    isLoadingMore.value = true;
    try {
      final response = await _http.get(
        'messages/get?id=${conversation.id}&page=$_currentPage&limit=20',
      );

      if (response.responseBody != null &&
          response.responseBody['ResponseBody'] != null) {
        final data = response.responseBody['ResponseBody'];
        if (data['messages'] != null) {
          final chatResponse = ChatMessageResponse.fromJson(data);
          messages.addAll(chatResponse.messages);
          _hasMore = chatResponse.hasMore;
          _currentPage++;
        }
      }
    } catch (e) {
      debugPrint('Error loading more messages: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.id,
      senderId: 'currentUser', // In a real app, get from Auth service
      type: 'text',
      body: text,
      createdAt: DateTime.now(),
    );

    // Insert at beginning because messages are latest-first
    messages.insert(0, newMessage);
    messageController.clear();

    // In a real app, this would call an API to send the message
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
