import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:polkadart/scale_codec.dart';
import 'package:trappist_extra/generated/localhost/types/scbc/pallet/phone_record.dart';

class HumanPhoneRecord {
  final String phoneNumber;
  final int trustRating;
  final String status;
  final String uniqueId;
  final List<dynamic> spamRecords;
  final List<dynamic> callRecords;

  HumanPhoneRecord(
      {required this.phoneNumber,
      required this.trustRating,
      required this.status,
      required this.uniqueId,
      required this.spamRecords,
      required this.callRecords});

  static HumanPhoneRecord toHuman(PhoneRecord rawFetch, String number) {
    // super.toHuman();
    final json = rawFetch.toJson();
    final res = {};
// Sample Data
// trustRating: -10
//  status: normal
//   uniqueId: 0x00000000000000000000000000000000
//   spamRecords: [
//     {
//       timestamp: 0x13b55a5e8f010000
//       reason: Spam
//       uniqueId: 0x8dd7df3dcfa3ac8e64221bea71aa0856
//       who: 0935834329
//     }
//   ]
//   callRecords: [
//     {
//       caller: 0935834328
//       callee: 0935834329
//       uniqueId: 0xe34fba9cef5c3142aa86e424a28e1a8f
//       timestamp: 0x10b9835e8f010000
//     }
//   ]
    for (var element in json.entries) {
      switch (element.key) {
        case 'trustRating':
          res[element.key] = element.value;
          break;
        case 'status':
          res[element.key] =
              String.fromCharCodes(Uint8List.fromList(element.value));
          break;
        case 'uniqueId':
          res[element.key] = hex.encode(Uint8List.fromList(element.value));
          break;
        case 'spamRecords':
          res[element.key] = element.value
              .map((e) => e.map((key, value) {
                    switch (key) {
                      case 'timestamp':
                        final input = Input.fromHex(
                            hex.encode(Uint8List.fromList(value)));
                        final decoded = U64Codec.codec.decode(input);
                        return MapEntry(
                          key,
                          decoded.toString(),
                        );
                      case 'reason':
                        return MapEntry(key,
                            String.fromCharCodes(Uint8List.fromList(value)));
                      case 'uniqueId':
                        return MapEntry(
                            key, hex.encode(Uint8List.fromList(value)));
                      case 'who':
                        return MapEntry(
                            key, hex.encode(Uint8List.fromList(value)));
                      default:
                        return MapEntry(key, value);
                    }
                  }))
              .toList();

        case 'callRecords':
          res[element.key] = element.value
              .map((e) => e.map((key, value) {
                    switch (key) {
                      case 'caller':
                        return MapEntry(key,
                            String.fromCharCodes(Uint8List.fromList(value)));
                      case 'callee':
                        return MapEntry(
                            key, hex.encode(Uint8List.fromList(value)));
                      case 'uniqueId':
                        return MapEntry(
                            key, hex.encode(Uint8List.fromList(value)));
                      case 'timestamp':
                        final input = Input.fromHex(
                            hex.encode(Uint8List.fromList(value)));
                        final decoded = U64Codec.codec.decode(input);
                        return MapEntry(
                          key,
                          decoded.toString(),
                        );
                      default:
                        return MapEntry(key, value);
                    }
                  }))
              .toList();
          break;
        default:
      }
    }

    return HumanPhoneRecord(
      phoneNumber: number,
      trustRating: res['trustRating'],
      status: res['status'],
      uniqueId: res['uniqueId'],
      spamRecords: res['spamRecords'],
      callRecords: res['callRecords'],
    );
  }
}
