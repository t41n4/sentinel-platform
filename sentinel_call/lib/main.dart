import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/models/call_state_controller.dart';
import 'package:sentinel_call/models/main_wrapper.dart';
import 'package:sentinel_call/models/overlay_content.dart';
import 'package:sentinel_call/services/blockchain.dart';
import 'package:sentinel_call/theme/app_theme.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: MyOverlayContent(),
    debugShowCheckedModeBanner: false,
  ));
}

Future main() async {
  await dotenv.load(fileName: "assets/env/local.env");
  await Permission.phone.request();
  await Permission.sms.request();
  await Permission.systemAlertWindow.request();
  await FlutterContacts.requestPermission();
  debugPrint(
      "🚩 ~ file: main.dart:40 ~ ${dotenv.env['WEBSOCKET_LOCALCHAIN_URL']}");

  final service = BlockchainService(
      dotenv.env['WEBSOCKET_LOCALCHAIN_URL'] ?? 'ws://localhost:9944');

  final wallet = await service.createAliceWallet();

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(service: service, wallet: wallet));
}

class MyApp extends StatelessWidget {
  final BlockchainService service;
  final KeyPair wallet;
  const MyApp({super.key, required this.service, required this.wallet});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.lazyPut<CallStateController>(() => CallStateController());
    Get.lazyPut<BlockchainService>(() => service);
    Get.lazyPut<KeyPair>(() => wallet);
    return GetMaterialApp(
      title: 'Sentinel Call',
      theme: AppTheme.get(isLight: true, context: context),
      darkTheme: AppTheme.get(isLight: false, context: context),
      home:
          MainWrapper(title: 'Sentinel Call', service: service, wallet: wallet),
      builder: FToastBuilder(),
      navigatorKey: navigatorKey,
    );
  }
}
