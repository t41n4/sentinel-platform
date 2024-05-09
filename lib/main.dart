import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:provider/provider.dart';
import 'package:trappist_extra/models/call_state_controller.dart';
import 'package:trappist_extra/models/chain.dart';
import 'package:trappist_extra/models/main_wrapper.dart';
import 'package:trappist_extra/models/overlay_content.dart';
import 'package:trappist_extra/services/blockchain.dart';
import 'package:trappist_extra/theme/app_theme.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma("vm:entry-point")
void showOverlay() {
  runApp(const MaterialApp(
    home: MyOverlayContent(),
    debugShowCheckedModeBanner: false,
  ));
}

Future main() async {
  await dotenv.load(fileName: "assets/env/local.env");
  final service = BlockchainService(
      dotenv.env['WEBSOCKET_LOCALCHAIN_URL'] ?? 'ws://localhost:9944');

  // const phrase = '//Alice';
  // final seed = await SubstrateBip39.ed25519.seedFromUri(phrase);
  final wallet = await service.createAliceWallet();

  var localchain = RelayChain(
      "Sentinel Chain",
      chainSpec("network-spec-validator.json"),
      logo("sentinel.svg", "Sentinel Logo"));

  await Permission.phone.request();
  await Permission.sms.request();
  await Permission.systemAlertWindow.request();
  await FlutterContacts.requestPermission();

  // await FlutterCallkitIncoming.requestNotificationPermission({
  //   "rationaleMessagePermission":
  //       "Notification permission is required, to show notification.",
  //   "postNotificationMessageRequired":
  //       "Notification permission is required, Please allow notification permission from setting."
  // });

  runApp(ChangeNotifierProvider(
      create: (context) => Chains([localchain]),
      child: MyApp(service: service, wallet: wallet)));
}

String chainSpec(String fileName) {
  return "assets/chainspecs/$fileName";
}

Widget logo(String assetName, String semanticsLabel) {
  assetName = "assets/images/logos/$assetName";
  if (assetName.endsWith(".svg")) {
    // Note: use https://crates.io/crates/usvg to convert the source svg if not
    // displaying correctly due to lack of CSS support in flutter_svg package
    return SvgPicture.asset(
      assetName,
      semanticsLabel: semanticsLabel,
      height: 42,
      width: 42,
      fit: BoxFit.fitWidth,
    );
  }
  return Image(
    image: AssetImage(assetName),
    semanticLabel: semanticsLabel,
    height: 42,
    width: 42,
    fit: BoxFit.fitWidth,
  );
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
