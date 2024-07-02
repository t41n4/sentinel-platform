import 'package:flutter/material.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/services/blockchain.dart';
import 'package:sentinel_call/utils/utils.dart';

class UserPage extends StatefulWidget {
  final KeyPair wallet;
  final BlockchainService service;

  const UserPage({super.key, required this.wallet, required this.service});

  @override
  State<UserPage> createState() => _UserPageState();
}

String unitAbbreviationConverter(String value, {int unitValue = Unit}) {
  final doubleValue = double.parse(value);
  if (doubleValue >= unitValue) {
    return '${(doubleValue / unitValue).toStringAsFixed(2)}MUnit';
  }
  return value;
}

class _UserPageState extends State<UserPage> {
  Future<String> _getBalance(String address) async {
    final account = await widget.service.getAccountInfo(address);

    debugPrint("[🚩 account]: ${account.toString()} ${widget.wallet.address}");
    return unitAbbreviationConverter(account['data']['free'].toString(),
        unitValue: MUnit);
  }

  @override
  Widget build(BuildContext context) {
    final balance = _getBalance(widget.wallet.address);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // add border line
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.background,
        ),
        child: Column(
          children: [
            FutureBuilder(
                future: balance,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    widget.service.reconnect();
                  }
                  return Card(
                      child: Column(
                    children: [
                      Avatar(
                        address: widget.wallet.address,
                        size: 100,
                      ),
                      ListTile(
                        title: const Text('Address'),
                        subtitle: Text(widget.wallet.address),
                      ),
                      ListTile(
                        title: const Text('Balance'),
                        subtitle: Text(snapshot.data.toString()),
                      ),
                    ],
                  ));
                })
          ],
        ),
      ),
    );
  }
}

class Avatar extends StatefulWidget {
  const Avatar({super.key, required this.address, required this.size});

  final String address;
  final int size;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.toDouble(),
      height: widget.size.toDouble(),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        shape: BoxShape.circle,
      ),
      child: Image.network(
        'https://robohash.org/${widget.address}',
        fit: BoxFit.fill,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }
}
