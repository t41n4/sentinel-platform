import 'package:flutter/material.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: const Column(
        children: [
          SizedBox(height: 64),
          Text('Vote Page'),
        ],
      ),
    );
  }
}
