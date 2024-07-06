// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:sentinel_call/services/call_state.dart';

// Future<void> initializeService() async {
//   final callStateBackgroundService = FlutterBackgroundService();
//   IosConfiguration iosConfiguration = IosConfiguration();

//   // Monitoring Service should have an OnBoot Broadcast Receiver Attached as well
//   // It would also popup a notification signifying its running status
//   AndroidConfiguration androidConfiguration = AndroidConfiguration(
//     onStart: onCallStateServiceStart,
//     autoStart: true,
//     isForegroundMode: true,
//     autoStartOnBoot: true,
//   );

//   await callStateBackgroundService.configure(
//       iosConfiguration: iosConfiguration,
//       androidConfiguration: androidConfiguration);

//   await callStateBackgroundService.startService();
// }
