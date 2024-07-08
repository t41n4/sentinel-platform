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
    // theme
    final theme = Theme.of(context);

    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    // final backgroundCard2 = isDarkMode
    //     ? theme.colorScheme.background
    //     : const Color.fromRGBO(255, 255, 128, 0.9);

    final backgroundCard2 = theme.colorScheme.background;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // add border line
        decoration: BoxDecoration(
          // border: Border.all(color: Colors.black, width: 2),
          // borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.background,
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
                      // add shadow
                      elevation: 15,
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
                              subtitle: Text(
                                snapshot.data.toString() == 'null'
                                    ? 'not connected'
                                    : snapshot.data.toString(),
                              )),
                        ],
                      ));
                }),
            Card(
                color: backgroundCard2,
                elevation: 15,
                child: const Column(children: [
                  ListTile(
                    title: Text('7 No Tips'),
                  ),
                  ListTile(
                    title: Text('1. No Unwanted Contacts'),
                    subtitle: Text("Block unwanted calls and text messages."),
                  ),
                  ListTile(
                    title: Text('2. No Sharing Info Unprompted'),
                    subtitle: Text(
                        "Never give your personal or financial information in response to a request that you dont expect. Even if they claim to have 'secret' information on you."),
                  ),
                  ListTile(
                    title: Text('3. No Pressure Tactics'),
                    subtitle: Text(
                        "Dont fall for their high pressure, 'must reply now', demands. Its all a trick."),
                  ),
                  ListTile(
                    title: Text('4. No Talking to Strangers'),
                    subtitle: Text(
                        "Dont talk to people you dont know in person. They could be anyone."),
                  ),
                  ListTile(
                    title: Text('5. No Unverified Contacts'),
                    subtitle: Text(
                        "Check our database for their email, username, phone number and Crypto address(and file a report!). You wont be the only target."),
                  ),
                  ListTile(
                    title: Text('6. No Over-Sharing Online'),
                    subtitle: Text(
                        "Be mindful of the information you share on social networks. Scammers can use this information against you."),
                  ),
                  ListTile(
                    title: Text('7. No Money in Online Dating'),
                    subtitle: Text(
                        "If you're online dating, never, ever, send them money."),
                  )
                ])),
            const SizedBox(
              height: 50,
            )
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
