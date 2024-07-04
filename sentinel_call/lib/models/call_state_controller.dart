import 'dart:convert';

import 'package:convert/convert.dart'; // Added missing import
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/services/blockchain.dart';
import 'package:sentinel_call/types/human_phone_record.dart';
import 'package:ss58/ss58.dart' as ss58;
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
    // debugPrint(
    //     "🚩 ~ file: call_state_controller.dart:25 ~ CallStateController ~ $number:");
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final myContact = contacts
        .where((element) => element.phones
            .any((phone) => phone.number.replaceAll(' ', '') == number))
        .toList();
    debugPrint(
        "🚩 ~ file: call_state_controller.dart:30 ~ CallStateController ~ contact: $contacts");
    debugPrint(
        "🚩 ~ file: call_state_controller.dart:29 ~ CallStateController ~ contact: $myContact");

    return myContact;
  }

  didReported(String spammer, List<dynamic> history) {
    for (var element in history) {
      if (element['who'] == spammer) {
        return true;
      }
    }
    return false;
  }

  Future<String> getCallerData(String incommingNumber) async {
    final userAddress =
        hex.encode(ss58.Codec.fromNetwork('substrate').decode(wallet.address));

    final records = await service.queryPhoneRecord(incommingNumber);
    final humanRecords = records
            ?.map((e) => HumanPhoneRecord.toHuman(e, incommingNumber))
            .toList() ??
        [];

    // Ensure that the list is not empty before accessing its first element.
    final count = humanRecords.isNotEmpty
        ? humanRecords.first.callRecords
                ?.where((element) => element['callee'] == userAddress)
                .length ??
            0
        : 0;

    final reportHistory =
        humanRecords.isNotEmpty ? humanRecords.first.spamRecords : [];
    // debugPrint(
    //     "🚩 ~ file: call_state_controller.dart:46 ~ CallStateController ~ ss58userAddress: $userAddress");

    // debugPrint(
    //     "🚩 ~ file: call_state_controller.dart:58 ~ CallStateController ~ reportHistory: $reportHistory");

    // Get the status of the first human record if available, otherwise set to null.
    final status = humanRecords.isNotEmpty
        ? didReported(userAddress, reportHistory)
            ? "spam"
            : humanRecords.first.status
        : "normal";

    final myContact = await findMyContact(incommingNumber);

    // Print debug information.
    // debugPrint(
    //     "🚩 ~ file: call_state_controller.dart:38 ~ CallStateController ~ Records: $records");
    // debugPrint(
    //     "🚩 ~ file: call_state_controller.dart:41 ~ CallStateController ~ Data: $userAddress");
    // debugPrint(
    //     "🚩 ~ file: call_state_controller.dart:47 ~ CallStateController ~ Human Records: $humanRecords");
    // debugPrint(
    //     "🚩 ~ file: call_state_controller.dart:50 ~ CallStateController ~ Count: $count");

    // Create a JSON object with relevant data.
    final jsonData = {'count': count, 'status': status, 'myContact': myContact};

    // Return the JSON-encoded string.
    return jsonEncode(jsonData);
  }

  @override
  void onInit() {
    super.onInit();
    PhoneState.stream.listen((event) async {
      String caller = event.number.toString();
      String callee = wallet.address;

      if (caller.isNotEmpty && caller != 'null' && caller != '') {
        switch (event.status) {
          case PhoneStateStatus.CALL_INCOMING:
            final data = await getCallerData(caller);
            final jsonData = jsonDecode(data);

            final count = jsonData["count"];
            final status = jsonData['status'];
            final myContact = jsonData["myContact"] ?? [];
            final title =
                myContact.isEmpty ? '???' : myContact.first['displayName'];

            debugPrint(
                "🚩 ~ file: call_state_controller.dart:79 ~ CallStateController ~ $myContact:");

            if (myContact.isNotEmpty) {
              final ext =
                  await service.buildMakeCallPayload(caller, callee, wallet);
              service.submitMakeCallExtrinsic(ext);
            }

            // Determine title based on the presence of myContact

            // Share data and show overlay
            FlutterOverlayWindow.shareData({
              'title': title,
              'number': caller,
              'called_before': count,
              'status': status,
            });

            FlutterOverlayWindow.showOverlay(
              enableDrag: true,
              height: 470,
              width: 500,
              alignment: OverlayAlignment.center,
            );

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
