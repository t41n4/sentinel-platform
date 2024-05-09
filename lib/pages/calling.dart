import 'dart:typed_data';

import 'package:call_log/call_log.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_overlay_apps/flutter_overlay_apps.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:ss58/ss58.dart' as ss58;
import 'package:substrate_bip39/substrate_bip39.dart';
import 'package:trappist_extra/services/blockchain.dart';

class CallingPage extends StatefulWidget {
  const CallingPage({super.key, required this.service, required this.wallet});
  final BlockchainService service;
  final KeyPair wallet;

  @override
  State<CallingPage> createState() => _CallingPageState();
}

class _CallingPageState extends State<CallingPage> {
  void findContactByPhoneNumber(String number) async {
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final contact = contacts.any((element) => contacts.any(
        (element) => element.phones.any((phone) => phone.number == number)));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                Iterable<CallLogEntry> entries =
                    await CallLog.query(number: '02471093224');
                debugPrint("🚩 ~ entries. ~ ${entries.length}:");

                FlutterOverlayApps.sendDataToAndFromOverlay({
                  'title': 'Incoming call',
                  'number': '123123123',
                  'called_before': entries.length
                });
                FlutterOverlayApps.showOverlay(
                    height: 300, alignment: OverlayAlignment.center);
              },
              child: const Text('Show Overlay')),
          ElevatedButton(
              onPressed: () async {
                final ext = await widget.service.buildMakeCallPayload(
                    '0935834328', '0935834329', widget.wallet);

                widget.service.submitMakeCallExtrinsic(ext);
              },
              child: const Text('Make Call Event')),
          ElevatedButton(
              onPressed: () {
                findContactByPhoneNumber('0987209835');
              },
              child: const Text('Get Phone Contact')),
          ElevatedButton(
              onPressed: () => {
                    widget.service.reconnect(),
                  },
              child: const Text('Connect Blockchain')),
          ElevatedButton(
              onPressed: () async {
                var now = DateTime.now();
                int from = now
                    .subtract(const Duration(days: 60))
                    .millisecondsSinceEpoch;
                int to = now
                    .subtract(const Duration(days: 30))
                    .millisecondsSinceEpoch;
                String number = '02471093224';
                debugPrint("🚩 ~ _CallingPageState ~ ${number}:");
                // GET WHOLE CALL LOG
                Iterable<CallLogEntry> entries =
                    await CallLog.query(number: number);
                // print
                debugPrint("🚩 ~ _CallingPageState ~ ${entries.length}:");
              },
              child: const Text('Show call history')),
          ElevatedButton(
              onPressed: () async {
                String address =
                    '5DFJF7tY4bpbpcKPJcBTQaKuCDEPCpiz8TRjpmLeTtweqmXL';
                String encodedHex = hex.encode(address.codeUnits);
                //use ss58

                final List<int> decodeSS58 =
                    ss58.Codec.fromNetwork('substrate').decode(address);

                debugPrint(
                    "🚩 ~ _CallingPageState ~ ${hex.encode(decodeSS58)}:");
              },
              child: const Text('Encode addressk')),
          ElevatedButton(
              onPressed: () async {
                final data =
                    await widget.service.queryPhoneRecord('02471093224');


              },
              child: const Text('queryPhoneRecord')),
          ElevatedButton(
              onPressed: () async {
                const pharase = '//Alice';
                final seed = await SubstrateBip39.ed25519.seedFromUri(pharase);
                final keypair =
                    KeyPair.ed25519.fromSeed(Uint8List.fromList(seed));
                debugPrint("🚩 ~ _CallingPageState ~ ${keypair.address}:");
              },
              child: const Text('Generate address')),

          // Text('Call State: ${s.callState.value.status}'),
          // Text('Call Number: ${s.callState.value.number}'),
        ],
      ),
    );
  }
}
