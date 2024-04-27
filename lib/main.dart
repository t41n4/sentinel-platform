import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:provider/provider.dart';
import 'package:trappist_extra/models/chain.dart';
import 'package:trappist_extra/pages/home.dart';
import 'package:trappist_extra/services/services.dart';
import 'package:trappist_extra/theme/app_theme.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as libphonenumber;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  await dotenv.load(fileName: "assets/env/local.env");
  final service = BlockchainService(
      dotenv.env['WS_LOCALCHAIN_URL'] ?? 'ws://localhost:9944');
  final wallet = await service.createWallet(
      "bottom drive obey lake curtain smoke basket hold race lonely fit walk");

  var localchain = RelayChain(
      "Sentinel Chain",
      chainSpec("localSpec-validator.json"),
      logo("sentinel.svg", "Sentinel Logo"));

  // await libphonenumber.init();

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
    return MaterialApp(
      title: 'Sentinel Call',
      theme: AppTheme.get(isLight: true, context: context),
      darkTheme: AppTheme.get(isLight: false, context: context),
      home: HomePage(title: 'Sentinel Call', service: service, wallet: wallet),
      builder: FToastBuilder(),
      navigatorKey: navigatorKey,
    );
  }
}
