import 'dart:convert';

import 'package:convert/convert.dart'; // Added missing import
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:ss58/ss58.dart' as ss58;
import 'package:trappist_extra/services/blockchain.dart';
import 'package:trappist_extra/types/human_phone_record.dart';
import 'package:uuid/uuid.dart';

// ViewModel for managing call states and handling PDF uploads
class CallStateController extends GetxController {
  Stream<PhoneState> callStateStream = PhoneState.stream;
  Rx<PhoneState> callState = PhoneState.nothing().obs;
  Uuid uuid = const Uuid();
  String currentUuid = '';
  final service = Get.find<BlockchainService>();
  final wallet = Get.find<KeyPair>();

  Future<List<Contact>> findMyContact(String number) async {
    debugPrint(
        "🚩 ~ file: call_state_controller.dart:25 ~ CallStateController ~ $number:");
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final contact = contacts
        .where((element) => element.phones
            .any((phone) => phone.number.replaceAll(' ', '') == '0935834329'))
        .toList();
    return contact;
  }

  Future<String> getCallerData(String number) async {
    // Query the phone records using the service.
    final records = await service.queryPhoneRecord(number);
    // Decode the wallet address to a hex string.
    final data =
        hex.encode(ss58.Codec.fromNetwork('substrate').decode(wallet.address));
    // Convert records to a list of human-readable phone records.
    final human =
        records?.map((e) => HumanPhoneRecord.toHuman(e, number)).toList();

    // If the human list is not empty, count the call records matching the callee data.
    final count =
        (human?.isNotEmpty == true && human!.first.callRecords != null)
            ? human.first.callRecords!
                .where((element) => element['callee'] == data)
                .length
            : 0;

    final status = human?.first.status;

    // Print debug information.
    debugPrint(
        "🚩 ~ file: call_state_controller.dart:37 ~ CallStateController ~ $count:");

    // Create a JSON object with relevant data.
    final jsonData = {
      'count': count,
      'status': status,
    };

    // Return the JSON-encoded string.
    return jsonEncode(jsonData);
  }

  @override
  void onInit() {
    super.onInit();
    PhoneState.stream.listen((event) async {
      String caller = event.number.toString();
      if (caller.isNotEmpty && caller != 'null' && caller != '') {
        switch (event.status) {
          case PhoneStateStatus.CALL_INCOMING:
            final data = await getCallerData(caller);
            final jsonData = jsonDecode(data);
            String callee = wallet.address;
            final myContact = await findMyContact(caller);
            debugPrint(
                "🚩 ~ file: call_state_controller.dart:79 ~ CallStateController ~ $myContact:");
            if (myContact.isEmpty) {
              FlutterOverlayWindow.shareData({
                'title': '???',
                'number': '${event.number}',
                'called_before': jsonData["count"],
                'status': jsonData['status'],
              });
              FlutterOverlayWindow.showOverlay(
                  enableDrag: true,
                  height: 400,
                  alignment: OverlayAlignment.center);
              final ext =
                  await service.buildMakeCallPayload(caller, callee, wallet);
              await service.submitMakeCallExtrinsic(ext);
            } else {
              debugPrint(
                  "🚩 ~ file: call_state_controller.dart:104 ~ CallStateController ~ ${myContact.first.displayName}:");
              FlutterOverlayWindow.shareData({
                'title': myContact.first.displayName,
                'number': '${event.number}',
                'called_before': jsonData["count"],
                'status': jsonData['status'],
              });
              FlutterOverlayWindow.showOverlay(
                  enableDrag: true,
                  height: 400,
                  alignment: OverlayAlignment.center);
              final ext =
                  await service.buildMakeCallPayload(caller, callee, wallet);
              await service.submitMakeCallExtrinsic(ext);
            }
            break;
          default:
            break;
        }

        callState.value = event;
        update();
      }
    });
  }
}
