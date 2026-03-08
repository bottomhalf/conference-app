import 'package:conference/config/app_config.dart';
import 'package:conference/models/api_response.dart';
import 'package:conference/models/meeting_model.dart';
import 'package:conference/services/http_service.dart';
import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final tokenCtrl = TextEditingController();
  final roomIdCtrl = TextEditingController();
  final accessCodeCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final http = HttpService.instance;

  final ConferenceManager conferenceManager = ConferenceManager();
  final isJoining = false.obs;

  // ─── Recent Meetings ────────────────────────────────────────────
  final recentMeetings = <MeetingModel>[].obs;
  final isLoadingMeetings = true.obs;
  final meetingsError = Rxn<String>();

  Future<void> fetchRecentMeetings() async {
    isLoadingMeetings.value = true;
    meetingsError.value = null;

    try {
      ApiResponse response = await http.get('meeting/get-recent-meetings');

      if (response.responseBody != null) {
        final body = response.responseBody as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        final meetings = data
            .map((e) => MeetingModel.fromJson(e as Map<String, dynamic>))
            .take(6)
            .toList();
        recentMeetings.value = meetings;
      }
    } catch (e) {
      debugPrint('Failed to load recent meetings: $e');
      meetingsError.value = e.toString();
    } finally {
      isLoadingMeetings.value = false;
    }
  }

  void openMeeting(MeetingModel meeting) {
    Get.toNamed('/meeting', arguments: conferenceManager);
  }

  // ─── Join Meeting ───────────────────────────────────────────────

  Future<void> joinMeeting() async {
    if (!formKey.currentState!.validate()) return;

    isJoining.value = true;

    try {
      Get.toNamed('/meeting', arguments: conferenceManager);
    } catch (e) {
      Get.snackbar(
        'Connection Failed',
        'Failed to join: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF6B6B),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isJoining.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    roomIdCtrl.text = '694f949da08d8877589cbdda';
    accessCodeCtrl.text = "1244o1i434k8974r";
    fetchRecentMeetings();
  }

  @override
  void onClose() {
    tokenCtrl.dispose();
    roomIdCtrl.dispose();
    super.onClose();
  }
}
