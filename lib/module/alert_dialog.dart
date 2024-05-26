import 'dart:convert';

import 'package:flutter/material.dart';

class ShowAlertDialog extends StatelessWidget {
  const ShowAlertDialog({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  formatException(String exception) {
    var data = exception
        .replaceAll("Exception: ", '')
        .replaceAll("{", '')
        .replaceAll("}", '')
        .replaceAll("code: ", '')
        .replaceAll("message: ", '')
        .replaceAll("data: ", '');

    if (data != exception) return data.split(',');
    return exception;
  }

  @override
  Widget build(BuildContext context) {
    final display = formatException(content);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            alignment: Alignment.center,
            title: Row(
              // alignment: MainAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title == "Error"
                    ? const Icon(Icons.warning)
                    : const Icon(Icons.info),
                Text(' $title'),
              ],
            ),
            content: Text(
              display is List ? display[2] : display,
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          );
        });

    return Container();
  }
}
