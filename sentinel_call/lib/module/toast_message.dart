import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessage extends StatelessWidget {
  final String content;
  final String typeToast;
  const ToastMessage(
      {super.key, required this.content, required this.typeToast});

  Widget successToast(String content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Colors.black),
          const SizedBox(
            width: 12.0,
          ),
          AutoSizeText(
            content,
            maxLines: 1,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget alertToast(String content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.pinkAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check,
            color: Colors.black54,
          ),
          const SizedBox(
            width: 12.0,
          ),
          Text(
            content,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget warningToast(String content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.yellowAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check),
          const SizedBox(
            width: 12.0,
          ),
          Text(
            content,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget errorToast(String content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error),
          const SizedBox(
            width: 12.0,
          ),
          Text(
            content,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget infoToast(String content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.blueAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info),
          const SizedBox(
            width: 12.0,
          ),
          Text(content, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  _showToast(String typeToast, String content, FToast fToast) {
    Widget toast;
    switch (typeToast) {
      case "success":
        toast = successToast(content);
        break;
      case "alert":
        toast = alertToast(content);
        break;
      case "warning":
        toast = warningToast(content);
        break;
      case "info":
        toast = infoToast(content);
        break;
      case "error":
        toast = errorToast(content);
        break;
      default:
        toast = successToast(content);
    }

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fToast = FToast();

    fToast.init(context);

    _showToast(typeToast, content, fToast);

    return Container();
  }

  static void show(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
