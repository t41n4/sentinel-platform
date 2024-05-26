import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:phone_state/phone_state.dart';

class MyOverlayContent extends StatefulWidget {
  const MyOverlayContent({Key? key}) : super(key: key);

  @override
  State<MyOverlayContent> createState() => _MyOverlayContentState();
}

class _MyOverlayContentState extends State<MyOverlayContent> {
  final _goldColors = const [
    Color(0xFFa2790d),
    Color(0xFFebd197),
    Color(0xFFa2790d),
  ];

  final _redcolors = const [
    Color.fromARGB(255, 255, 0, 0),
    Color.fromARGB(255, 255, 0, 212),
    Color.fromARGB(255, 255, 0, 0),
  ];

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

  // @override
  // Widget build(BuildContext context) {
  //   return Material(
  //     child: InkWell(
  //       child: Card(
  //         color: AppTheme.thirdLightColor,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         child: Center(
  //             child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               _dataFromApp['title'],
  //               style: const TextStyle(fontSize: 24),
  //             ),
  //             Text(
  //               'from ${_dataFromApp['number'].toString()}',
  //             ),
  //             Text(
  //               'We detect this number have called you ${_dataFromApp['called_before'].toString()} times before',
  //             ),
  //             ElevatedButton(
  //                 onPressed: () => FlutterOverlayWindow.closeOverlay(),
  //                 child: const Text('Close'))
  //           ],
  //         )),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  _dataFromApp['status'] == 'spam' ? _redcolors : _goldColors,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: GestureDetector(
            onTap: () {
              FlutterOverlayWindow.getOverlayPosition().then((value) {
                debugPrint("Overlay Position: $value");
              });
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    ListTile(
                      leading: Container(
                        height: 80.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54),
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: NetworkImage(
                                "https://api.multiavatar.com/x-slayer.png"),
                          ),
                        ),
                      ),
                      title: Text(
                        "${_dataFromApp["title"]}",
                        style: const TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      // subtitle: const Text("Sousse , Tunisia"), // maybe location of the caller
                    ),
                    const Spacer(),
                    const Divider(color: Colors.black54),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_dataFromApp["number"].toString()),
                              Text("Called - ${_dataFromApp["called_before"]}"),
                            ],
                          ),
                          Text(
                            "${_dataFromApp["status"]}",
                            style: const TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
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
          ),
        ),
      ),
    );
  }
}
