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

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _dataFromApp['status'] == 'spam' ? _spamColors : _normalColors,
          borderRadius: BorderRadius.circular(12.0),
          // add borderline
          border: Border.all(
            color: Colors.black54,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      status == "spam"
                          ? const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 20.0,
                            )
                          : const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20.0,
                            )
                    ],
                  ),
                  const Divider(color: Colors.black54),
                  const Spacer(),
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
                  const Divider(color: Colors.black54),
                  const Spacer(),
                  Container(
                    // add border line
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
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
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
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
