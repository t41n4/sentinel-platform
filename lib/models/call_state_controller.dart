import 'package:call_log/call_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_overlay_apps/flutter_overlay_apps.dart';
import 'package:get/get.dart';
import 'package:phone_state/phone_state.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:trappist_extra/pages/search.dart';
import 'package:trappist_extra/services/blockchain.dart';
import 'package:uuid/uuid.dart';
import 'package:convert/convert.dart'; // Added missing import
import 'package:ss58/ss58.dart' as ss58;

// ViewModel for managing call states and handling PDF uploads
class CallStateController extends GetxController {
  Stream<PhoneState> callStateStream = PhoneState.stream;
  Rx<PhoneState> callState = PhoneState.nothing().obs;
  Uuid uuid = const Uuid();
  String currentUuid = '';
  final service = Get.find<BlockchainService>();
  final wallet = Get.find<KeyPair>();
  Future<bool> isInMyContact(String number) async {
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final contact = contacts.any((element) => contacts.any(
        (element) => element.phones.any((phone) => phone.number == number)));
    return contact;
  }

  Future<String?> countingCall(String number) async {
    debugPrint("🚩 ~ file: search.dart:48 ~ _SearchPageState ~ $number:");
    final records = await service.queryPhoneRecord(number);
    final data =
        hex.encode(ss58.Codec.fromNetwork('substrate').decode(wallet.address));
    final human =
        records?.map((e) => HumanPhoneRecord.toHuman(e, number)).toList();

    final count = human?.first.callRecords
        .where((element) => element['callee'] == data)
        .length
        .toString();

    debugPrint(
        "🚩 ~ file: call_state_controller.dart:36 ~ CallStateController ~ $count:");
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    PhoneState.stream.listen((event) async {
      String caller = event.number.toString();
      debugPrint("🚩 ~ caller.runtimeType ~ ${caller.runtimeType}:");
      debugPrint("🚩 ~ reading caller ~ $caller:");

      if (caller.isNotEmpty && caller != 'null' && caller != '') {
        switch (event.status) {
          case PhoneStateStatus.CALL_INCOMING:
            final count = await countingCall(caller);
            FlutterOverlayApps.sendDataToAndFromOverlay({
              'title': 'Incoming call',
              'number': '${event.number}',
              'called_before': count
            });

            FlutterOverlayApps.showOverlay(
                height: 300, alignment: OverlayAlignment.center);
            String callee = wallet.address;

            if (!await isInMyContact(caller)) {
              final ext =
                  await service.buildMakeCallPayload(caller, callee, wallet);
              await service.submitMakeCallExtrinsic(ext);
            }

            break;
          default:
        }

        callState.value = event;
        update();
      }
    });
  }
}
