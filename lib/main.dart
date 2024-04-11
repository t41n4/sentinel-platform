import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:trappist_extra/pages/home.dart';
import 'package:trappist_extra/models/chain.dart';

void main() {
  // Define the available chains
  // var polkadot = RelayChain("Polkadot", chainSpec("polkadot.json"),
  //         logo("polkadot.svg", "Polkadot Logo"))
  //     // Statemint
  //     .addParachain("Statemint", chainSpec("statemint.json"),
  //         logo("statemint.svg", "Statemint Logo"))
  //     // BridgeHub
  //     .addParachain("BridgeHub", chainSpec("bridge-hub-polkadot.json"),
  //         logo("bridgehub-polkadot.svg", "BridgeHub Logo"));

  var local = RelayChain("Sentinel Chain", chainSpec("localSpec.json"), logo("sentinel.svg", "Sentinel Logo"));

  runApp(ChangeNotifierProvider(
      // create: (context) => Chains([]),
      create: (context) => Chains([local]),

      child: const MyApp()));
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
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trappist Extra',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.pink,
          fontFamily: 'Syncopate',
          dividerColor: Colors.transparent),
      home: const HomePage(title: 'Trappist Extra'),
    );
  }
}
