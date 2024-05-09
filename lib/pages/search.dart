import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:ss58/ss58.dart' as ss58;
import 'package:trappist_extra/generated/localhost/types/scbc/pallet/phone_record.dart';
import 'package:trappist_extra/services/blockchain.dart';
import 'package:trappist_extra/utils/validator.dart';

import 'package:convert/convert.dart'; // Added missing import

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final service = Get.find<BlockchainService>();
  final TextEditingController searchTextController = TextEditingController();
  List<HumanPhoneRecord> records = <HumanPhoneRecord>[];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SafeArea(
          child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: phoneValidator,
                controller: searchTextController,
                decoration: InputDecoration(
                  labelText: "Search Phone Number",
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onFieldSubmitted: (value) {
                  setState(() {
                    records = [];
                  });
                },
              ),
              Expanded(
                child: FutureBuilder(
                    future: fetchPhoneRecord(searchTextController.text),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error while fetching data'),
                        );
                      }
                      return snapshot.data == null
                          ? const EmptyView()
                          : ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return PhoneRecordItem(
                                  phoneRecord: snapshot.data![index],
                                );
                              },
                            );
                    }),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Future<List<HumanPhoneRecord>?> fetchPhoneRecord(String number) async {
    debugPrint("🚩 ~ file: search.dart:48 ~ _SearchPageState ~ $number:");
    final records = await service.queryPhoneRecord(number);
    final human =
        records?.map((e) => HumanPhoneRecord.toHuman(e, number)).toList();

    return human;
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('Phone Number not found'),
      ],
    );
  }
}

class PhoneRecordItem extends StatelessWidget {
  final HumanPhoneRecord phoneRecord;

  const PhoneRecordItem({
    Key? key,
    required this.phoneRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wallet = Get.find<KeyPair>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        child: Row(
          children: [
            Icon(
              Icons.phone,
              color: Colors.yellow[700],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Trust: ${phoneRecord.trustRating}',
                ),
                Text(
                  'Identify: ${phoneRecord.phoneNumber}',
                ),
                Text(
                  'Status: ${phoneRecord.status}',
                ),
                Text(
                  'Detect called to you: ${howManyTimesCalled(wallet.address)} times',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String howManyTimesCalled(String address) {
    final data =
        hex.encode(ss58.Codec.fromNetwork('substrate').decode(address));
    debugPrint(
        "🚩 ~ file: search.dart:190 ~ PhoneRecordItem ~ $data:"); // Removed unnecessary braces

    return phoneRecord.callRecords
        .where((element) => element['callee'] == data)
        .length
        .toString();
  }
}

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

    for (var element in json.entries) {
      // debugPrint("🚩 ~ BlockchainService ~ ${element.key} ~ ${element.value.runtimeType.toString()}:");
      final type = element.value.runtimeType.toString();
      switch (type) {
        case 'int':
          res[element.key] = element.value;
          break;
        case 'Uint8Buffer':
          res[element.key] =
              String.fromCharCodes(Uint8List.fromList(element.value));
          break;
        case 'List<int>':
          res[element.key] = hex.encode(Uint8List.fromList(element.value));
          break;
        case 'List<Map<String, List<int>>>':
          res[element.key] = element.value
              .map((e) => e.map((key, value) {
                    switch (key) {
                      case 'caller':
                        return MapEntry(key,
                            String.fromCharCodes(Uint8List.fromList(value)));
                      case 'callee':
                        return MapEntry(
                            key, hex.encode(Uint8List.fromList(value)));
                      case 'reason':
                        return MapEntry(
                            key, hex.encode(Uint8List.fromList(value)));
                      case 'uniqueId':
                        return MapEntry(
                            key, hex.encode(Uint8List.fromList(value)));
                      case 'timestamp':
                        return MapEntry(
                            key, hex.encode(Uint8List.fromList(value)));
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
