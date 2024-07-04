import 'package:convert/convert.dart'; // Added missing import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/services/blockchain.dart';
import 'package:sentinel_call/types/human_phone_record.dart';
import 'package:sentinel_call/utils/validator.dart';
import 'package:ss58/ss58.dart' as ss58;

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
                keyboardType: TextInputType.phone,
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
                        // log error
                        debugPrint(
                            "🚩 ~ file: search.dart:71 ~ _SearchPageState ~ ${snapshot.error}:");
                        return const Center(
                          child: Text('Error while fetching data'),
                        );
                      }
                      return snapshot.data == null || snapshot.data!.isEmpty
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
    final records = await service.queryPhoneRecord(number);
    debugPrint("🚩 ~ file: search.dart:91 ~ _SearchPageState ~ $records");
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
                  'Detect called to you: ${howManyTimesCalled(wallet.address, phoneRecord)} times',
                ),
                Text(
                  'Detect spam record: ${phoneRecord.spamRecords.length}',
                ),
                // padding left 5px
                Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var record in phoneRecord.spamRecords)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Reason: ${record['reason']}',
                                // text bold
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'By: ${'0x${record['who'].substring(0, 4)}...${record['who'].substring(record['who'].length - 4)}'}',
                                    ),
                                    Text(
                                      'At: ${record['timestamp']}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String howManyTimesCalled(String address, HumanPhoneRecord phoneRecord) {
    final data =
        hex.encode(ss58.Codec.fromNetwork('substrate').decode(address));
    return phoneRecord.callRecords
        .where((element) => element['callee'] == data)
        .length
        .toString();
  }
}
