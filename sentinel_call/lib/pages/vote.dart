import 'package:date_count_down/date_count_down.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/module/toast_message.dart';
import 'package:sentinel_call/services/blockchain.dart';
import 'package:sentinel_call/types/human_phone_record.dart';
import 'package:sentinel_call/utils/utils.dart';

class VotePage extends StatefulWidget {
  VotePage({super.key});
  final service = Get.find<BlockchainService>();
  final wallet = Get.find<KeyPair>();

  @override
  State<VotePage> createState() => _VotePageState();
}

bool isContains(List<String> list, String address) {
  return list.contains(address);
}

DateTime minutesToUTC(int minutes) {
  return DateTime.now().add(Duration(minutes: (minutes ~/ 12)));
}

class _VotePageState extends State<VotePage> {
  Future<List<HumanPhoneRecord>?> fetchPhoneRecord(String number) async {
    final records = await widget.service.queryPhoneRecord(number);
    debugPrint("🚩 ~ file: search.dart:91 ~ _SearchPageState ~ $records");
    return records?.map((e) => HumanPhoneRecord.toHuman(e, number)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final proposalData = widget.service.getProposalList();

    return Container(
      color: Theme.of(context).colorScheme.background,
      height: MediaQuery.of(context).size.height * 0.75,
      child: FutureBuilder(
        future: proposalData,
        builder: (context, snapshotProposal) {
          if (snapshotProposal.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshotProposal.hasError) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: Text('not connected')),
            );
          }
          if (snapshotProposal.data!.isEmpty) {
            return const Center(child: Text('No proposals found'));
          }

          return ListView.builder(
            itemCount: snapshotProposal.data?.length,
            itemBuilder: (context, index) {
              final proposal = snapshotProposal.data?[index];
              final isVoted =
                  isContains(proposal!.ayes!, widget.wallet.address) ||
                      isContains(proposal.nays!, widget.wallet.address);
              final displayIndex = proposal.index.toString();
              final spammer = proposal.args['spammer'];
              final voted =
                  "${proposal.ayes!.length + proposal.nays!.length}/${proposal.threshold}";
              final deadline =
                  minutesToUTC(proposal.end! - proposal.numberBlock!);
              final spammerData = fetchPhoneRecord(spammer);

              return Column(
                children: [
                  FutureBuilder(
                    future: spammerData,
                    builder: (context, snapshotSpammer) {
                      if (snapshotSpammer.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshotSpammer.hasError) {
                        return const Text('Error fetching spammer data');
                      }
                      final humanData = snapshotSpammer.data;
                      final spamData = humanData?.first.spamRecords;

                      return ListTile(
                        leading: CircleAvatar(child: Text(displayIndex)),
                        title: Text('Target: $spammer'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voted: $voted'),
                            CountDownText(
                              due: deadline,
                              finishedText: "Done",
                              showLabel: true,
                              longDateName: true,
                              style: const TextStyle(color: Colors.blue),
                            ),
                            if (spamData != null)
                              for (var record in spamData)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reason: ${record['reason']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'By: 0x${record['who'].substring(0, 4)}...${record['who'].substring(record['who'].length - 4)}'),
                                          Text('At: ${record['timestamp']}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          ],
                        ),
                        trailing:
                            VoteButton(isVoted: isVoted, proposal: proposal),
                      );
                    },
                  ),
                  const Divider(height: 0),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class VoteButton extends StatefulWidget {
  const VoteButton({super.key, required this.isVoted, required this.proposal});
  final bool isVoted;
  final Proposal proposal;

  @override
  State<VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton> {
  final service = Get.find<BlockchainService>();
  final wallet = Get.find<KeyPair>();
  late bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final index = widget.proposal.index;
    final proposal = widget.proposal;

    return IconButton(
      onPressed: widget.isVoted
          ? null
          : () async {
              setState(() {
                isProcessing = true;
              });
              final ext = await service.buildVoteExtrinsicPayload(
                index: proposal.index ?? 0,
                proposal: proposal.proposal ?? [],
                approve: false,
                wallet: wallet,
              );
              final feeDetail = await service.getFeeDetails(ext);

              final result = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    alignment: Alignment.center,
                    title: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_vote),
                        Text('Vote on proposal'),
                      ],
                    ),
                    content: Text(
                      'Fees of ${unitAbbreviationConverter(feeDetail['partialFee'])} will be applied to the submission',
                      textAlign: TextAlign.center,
                    ),
                    actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context, 'Nye'),
                                icon: const Icon(Icons.cancel),
                              ),
                              const Text('Nye')
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context, 'Aye'),
                                icon: const Icon(Icons.check),
                              ),
                              const Text('Aye')
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );

              if (result == 'Aye' || result == 'Nye') {
                final ayeExt = await service.buildVoteExtrinsicPayload(
                  index: proposal.index ?? 0,
                  proposal: proposal.proposal ?? [],
                  approve: result == 'Aye',
                  wallet: wallet,
                );

                await service.submitVoteExtrinsic(ayeExt, (status) {
                  setState(() {
                    isProcessing = false;
                  });
                  ToastMessage.show(status.value);
                });
              } else {
                setState(() {
                  isProcessing = false;
                });
              }
            },
      icon: widget.isVoted
          ? const Icon(Icons.check)
          : isProcessing
              ? const CircularProgressIndicator()
              : const Icon(Icons.how_to_vote),
    );
  }
}
