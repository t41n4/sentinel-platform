import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Item extends StatelessWidget {
  const Item({
    Key? key,
    required this.name,
    required this.number,
    required this.dateTime,
  }) : super(key: key);

  final String name;
  final String number;
  final String dateTime;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onLongPress: () {
          // copy to clipboard
          Clipboard.setData(ClipboardData(text: number));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(name, style: textTheme.bodyLarge)),
            Expanded(
                child:
                    Text("$number - $dateTime", style: textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
