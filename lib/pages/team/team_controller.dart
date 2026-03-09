import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/api_exception.dart';
import '../../models/meeting_model.dart';
import '../../services/http_service.dart';

class TeamController extends GetxController {
  final _http = HttpService.instance;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<MeetingModel> conversations = <MeetingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final responseMap = await _http.get(
        'conversations/rooms?pageNumber=1&pageSize=20',
      );

      if (responseMap.responseBody != null &&
          responseMap.responseBody['data'] != null) {
        final List<dynamic> data = responseMap.responseBody['data'];
        conversations.value = data
            .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        errorMessage.value = 'Failed to load conversations data format.';
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
      debugPrint('Error fetching conversations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void openTeam(MeetingModel meeting) {
    Get.toNamed('/chat-detail', arguments: meeting);
  }
}
