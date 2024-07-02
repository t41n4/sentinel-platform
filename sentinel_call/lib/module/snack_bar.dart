import 'package:flutter/material.dart';

class ShowSnackBar extends StatelessWidget {
  const ShowSnackBar({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        duration: const Duration(milliseconds: 1500),
        width:
            MediaQuery.of(context).size.width - 8.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 10.0 // Inner padding for SnackBar content.
            ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
    return Container();
  }
}
