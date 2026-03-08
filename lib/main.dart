import 'package:conference_sdk/conference_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'config/app_config.dart';
import 'core/storage/storage.dart';
import 'services/http_service.dart';
import 'pages/home/home_controller.dart';
import 'pages/home/home_page.dart';
import 'pages/login/login_controller.dart';
import 'pages/login/login_page.dart';
import 'pages/meeting_room/meeting_room_page.dart';
import 'theme/app_theme.dart';

Future<void> _checkPermissions() async {
  var status = await Permission.bluetooth.request();
  if (status.isPermanentlyDenied) {
    debugPrint('Bluetooth Permission disabled');
  }
  status = await Permission.bluetoothConnect.request();
  if (status.isPermanentlyDenied) {
    debugPrint('Bluetooth Connect Permission disabled');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _checkPermissions();
  await AppConfig.initialize();
  await StorageService.instance.initialize();
  await HttpService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Conference',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => LoginController());
          }),
        ),
        GetPage(
          name: '/home',
          page: () => const HomePage(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => HomeController());
          }),
        ),
        GetPage(
          name: '/meeting',
          page: () {
            final manager = Get.arguments as ConferenceManager;
            return MeetingRoomPage(conferenceManager: manager);
          },
        ),
      ],
    );
  }
}
