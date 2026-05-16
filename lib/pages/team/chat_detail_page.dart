import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/responsive/responsive_builder.dart';
import 'chat_detail_controller.dart';
import 'mobile/mobile_chat_detail_page.dart';
import 'desktop/desktop_chat_detail_page.dart';

/// Responsive chat detail page router.
///
/// Delegates to [MobileChatDetailPage] or [DesktopChatDetailPage]
/// based on viewport width (breakpoint: 800px).
///
/// On desktop, the preferred UX is the inline master-detail view
/// in [DesktopTeamPage]. This route is used as a fallback when
/// navigating directly to `/chat-detail`.
class ChatDetailPage extends GetView<ChatDetailController> {
  const ChatDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => const MobileChatDetailPage(),
      desktop: (_) => const DesktopChatDetailPage(),
    );
  }
}
