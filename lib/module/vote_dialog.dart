import 'package:flutter/material.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:trappist_extra/utils/utils.dart';

class VoteDialog extends StatelessWidget {
  VoteDialog({super.key, required this.wallet, required this.feeDetails});

  final KeyPair wallet;
  final String fee = unitAbbreviationConverter(224424136);
  final Map<String, dynamic> feeDetails;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      title: const Row(
        // alignment: MainAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.how_to_vote),
          Text('Vote on proposal'),
        ],
      ),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Do you want to sign this transaction?'),
            const SizedBox(height: 10),
            Text('Address: ${stringAbbreviationConverter(wallet.address)}'),
            const SizedBox(height: 10),
            Text(
              'Fees of ${fee} will be applied to the submission',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            var currentContext = context;
            Future.delayed(Duration.zero, () {
              Navigator.pop(currentContext, 'Sign');
            });
          },
          child: const Text('Sign'),
        ),
      ],
    );
  }
}
