import 'package:flutter/material.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:trappist_extra/services/services.dart';

class UserPage extends StatefulWidget {
  final KeyPair wallet;
  final BlockchainService service;

  const UserPage({super.key, required this.wallet, required this.service});

  @override
  State<UserPage> createState() => _UserPageState();
}

String unitAbbreviationConverter(String value, {int unitValue = 1000000}) {
  final doubleValue = double.parse(value);
  if (doubleValue >= unitValue) {
    return '${(doubleValue / unitValue).toStringAsFixed(2)}MUnit';
  }
  return value;
}

class _UserPageState extends State<UserPage> {
  Future<String> _getBalance(String address) async {
    final account = await widget.service.getAccountInfo(address);
    debugPrint("[🚩 account]: ${account.toString()}");
    return unitAbbreviationConverter(account['data']['free'].toString(),
        unitValue: 1000000000000);
  }

  @override
  Widget build(BuildContext context) {
    final balance = _getBalance(widget.wallet.address);

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          const SizedBox(height: 64),
          FutureBuilder(
              future: balance,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
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
        image: DecorationImage(
          image:
              NetworkImage('https://robohash.org/${widget.address}?set=set4'),
        ),
      ),
    );
  }
}
