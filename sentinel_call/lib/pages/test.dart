import 'dart:typed_data';

import 'package:call_log/call_log.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:polkadart/scale_codec.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:ss58/ss58.dart' as ss58;
import 'package:substrate_bip39/substrate_bip39.dart';
import 'package:sentinel_call/services/blockchain.dart';

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
                final contacts =
                    await FlutterContacts.getContacts(withProperties: true);
                debugPrint(
                    "🚩 ~ file: calling.dart:42 ~ _CallingPageState ~ $contacts:");
                final contact = contacts
                    .where((element) => element.phones.any((phone) =>
                        phone.number.replaceAll(' ', '') == '0935834329'))
                    .toList();

                FlutterOverlayWindow.shareData({
                  'title': contact.first.displayName,
                  'number': contact.first.phones.first.number,
                  'called_before': 0,
                  'status': 'spam'
                });
                FlutterOverlayWindow.showOverlay(
                    enableDrag: true,
                    height: 470,
                    width: 500,
                    alignment: OverlayAlignment.center);
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
              onPressed: () async {
                // debugPrint(
                //     "🚩 ~ file: call_state_controller.dart:25 ~ CallStateController ~ $number:");
                final contacts =
                    await FlutterContacts.getContacts(withProperties: true);
                final myContact = contacts
                    .where((element) => element.phones.any((phone) =>
                        phone.number.replaceAll(' ', '') == '0935834329'))
                    .toList();
                debugPrint(
                    "🚩 ~ file: call_state_controller.dart:30 ~ CallStateController ~ contact: $contacts");
                debugPrint(
                    "🚩 ~ file: call_state_controller.dart:29 ~ CallStateController ~ contact: $myContact");
              },
              child: const Text('Find my contact')),
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
                debugPrint("🚩 ~ _CallingPageState ~ $number:");
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
          ElevatedButton(
              onPressed: () async {
                const encodedHex = '0x13b55a5e8f010000';
                final input = Input.fromHex(encodedHex);
                var decoded = U64Codec.codec.decode(input);
                debugPrint(
                    "🚩 ~ file: calling.dart:130 ~ _CallingPageState ~ ${decoded}:");
              },
              child: const Text('Decode Scale Codec')),
          ElevatedButton(
              onPressed: () async {
                const blockHash =
                    '0x3e4cf3ab69c240bc5362b454b9d7cc384eae8c36725c1e79b8c784e206166807';
                // widget.service.queryBlockByHash(blockHash);
              },
              child: const Text('Decode Scale Codec')),
          ElevatedButton(
              onPressed: () async {
                debugPrint(
                    "🚩 ~ file: calling.dart:140 ~ _CallingPageState ~ async:");

                await widget.service.getProposalList();
              },
              child: const Text('getProposalList')),
        ],
      ),
    );
  }
}
