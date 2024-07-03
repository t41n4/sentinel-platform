import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:phone_state/phone_state.dart';

class MyOverlayContent extends StatefulWidget {
  const MyOverlayContent({Key? key}) : super(key: key);

  @override
  State<MyOverlayContent> createState() => _MyOverlayContentState();
}

class _MyOverlayContentState extends State<MyOverlayContent> {
  final _normalColors = const Color.fromARGB(255, 150, 202, 244);
  final _spamColors = const Color.fromARGB(255, 209, 3, 99);

  dynamic _dataFromApp = {
    'title': 'No data',
    'message': 'No data',
    'called_before': 0,
    'number': 'No data',
    'status': 'No data',
  };

  @override
  void initState() {
    super.initState();

    // lisent for any data from the main app
    FlutterOverlayWindow.overlayListener.listen((event) {
      setState(() {
        _dataFromApp = event;
      });
    });
    PhoneState.stream.listen((event) {
      switch (event.status) {
        case PhoneStateStatus.CALL_ENDED:
          // TODO: POP-UP SHOW ASK SPAM
          FlutterOverlayWindow.closeOverlay();
          break;
        case PhoneStateStatus.CALL_STARTED:
          FlutterOverlayWindow.closeOverlay();
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final callerName = _dataFromApp["title"];
    final callerNumber = _dataFromApp["number"];
    final calledBefore = _dataFromApp["called_before"];
    final status = _dataFromApp["status"];

    final color = status == "spam" ? Colors.white : Colors.black54;
    final colorTextStyle = status == "spam"
        ? const TextStyle(color: Colors.white)
        : const TextStyle(color: Colors.black);

    final icon = status == "spam"
        ? const Icon(
            Icons.error,
            color: Colors.white,
            size: 20.0,
          )
        : const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20.0,
          );
    final closeIcon = status == "spam"
        ? const Icon(
            Icons.close,
            color: Colors.white,
            size: 20.0,
          )
        : const Icon(
            Icons.close,
            color: Colors.black54,
            size: 20.0,
          );

    final divider = status == "spam"
        ? const Divider(color: Colors.white)
        : const Divider(color: Colors.black54);

    return Material(
      color: Colors.transparent,
      textStyle: colorTextStyle,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _dataFromApp['status'] == 'spam' ? _spamColors : _normalColors,
          borderRadius: BorderRadius.circular(12.0),
          // add borderline
          border: Border.all(
            color: color,
            width: 1.0,
          ),
        ),
        child: GestureDetector(
          onTap: () async {
            // await FlutterOverlayWindow.closeOverlay();
            // FlutterOverlayWindow.getOverlayPosition().then((value) {
            //   debugPrint("Overlay Position: $value");
            // });
          },
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Column(
                children: [
                  Text(
                    "$callerName",
                    style: const TextStyle(
                        fontSize: 13.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  icon,
                  const Spacer(),
                  divider,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(callerNumber),
                          status == "spam"
                              ? const Text("This is a Spam number !")
                              : Text("Called to you $calledBefore time before"),
                        ],
                      ),
                    ],
                  ),
                  divider,
                  const Spacer(),
                  Container(
                    // add border line
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color,
                        width: 1.0,
                      ),
                      // circle button
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      //add border line
                      onPressed: () async {
                        await FlutterOverlayWindow.closeOverlay();
                      },
                      icon: closeIcon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
