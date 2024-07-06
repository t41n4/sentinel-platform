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

Future establishConnection() async {
  final service = BlockchainService(
      dotenv.env['WEBSOCKET_LOCALCHAIN_URL'] ?? 'ws://localhost:9944');
  final wallet = await service.createAliceWallet();
  Get.lazyPut<BlockchainService>(() => service);
  Get.lazyPut<KeyPair>(() => wallet);
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/env/local.env");
  await Permission.phone.request();
  await Permission.sms.request();
  await Permission.systemAlertWindow.request();
  await FlutterContacts.requestPermission();
  await establishConnection();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(msg: 'Sentinel Call is running');
  }

  @override
  void dispose() {
    super.dispose();
    final service = Get.find<BlockchainService>();
    service.disconnect();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.lazyPut<CallStateController>(() => CallStateController());
    return GetMaterialApp(
      title: 'Sentinel Call',
      theme: AppTheme.get(isLight: true, context: context),
      darkTheme: AppTheme.get(isLight: false, context: context),
      home: const MainWrapper(title: 'Sentinel Call'),
      builder: FToastBuilder(),
      navigatorKey: navigatorKey,
    );
  }
}
