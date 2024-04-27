import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: const Column(
        children: [
          SizedBox(height: 64),
          Text('Search'),
        ],
      ),
    );
  }
}