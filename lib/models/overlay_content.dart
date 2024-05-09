import 'package:flutter/material.dart';
import 'package:flutter_overlay_apps/flutter_overlay_apps.dart';
import 'package:phone_state/phone_state.dart';
import 'package:trappist_extra/theme/app_theme.dart';

class MyOverlayContent extends StatefulWidget {
  const MyOverlayContent({Key? key}) : super(key: key);

  @override
  State<MyOverlayContent> createState() => _MyOverlayContentState();
}

class _MyOverlayContentState extends State<MyOverlayContent> {
  dynamic _dataFromApp = {
    'title': 'No data',
    'message': 'No data',
    'called_before': 0
  };

  @override
  void initState() {
    super.initState();

    // lisent for any data from the main app
    FlutterOverlayApps.overlayListener().stream.listen((event) {
      setState(() {
        _dataFromApp = event;
      });
    });

    debugPrint('[Debug] set phone state listener at overlaycontent');

    PhoneState.stream.listen((event) {
      switch (event.status) {
        case PhoneStateStatus.CALL_ENDED:
          // TODO: POP-UP SHOW ASK SPAM
          FlutterOverlayApps.closeOverlay();
          break;
        case PhoneStateStatus.CALL_STARTED:
          FlutterOverlayApps.closeOverlay();
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: isLight ? AppTheme.secondaryLightColor : AppTheme.colorGray,
      child: InkWell(
        onTap: () {
          FlutterOverlayApps.closeOverlay();
        },
        child: Card(
          color: isLight
              ? AppTheme.thirdLightColor
              : AppTheme.colorGray.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _dataFromApp['title'],
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                'from ${_dataFromApp['number'].toString()}',
              ),
              Text(
                'This number have called you ${_dataFromApp['called_before'].toString()} times before',
              )
            ],
          )),
        ),
      ),
    );
  }
}
