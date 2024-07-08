import 'package:flutter/material.dart';

class Hint extends StatelessWidget {
  const Hint({
    Key? key,
    required this.colorNotifier,
  }) : super(key: key);

  final ValueNotifier<Color> colorNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: colorNotifier,
      builder: (context, color, child) {
        return Container(width: 8, color: color);
      },
    );
  }
}