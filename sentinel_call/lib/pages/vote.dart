import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polkadart/primitives/primitives.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/module/alert_dialog.dart';
import 'package:sentinel_call/module/toast_message.dart';
import 'package:sentinel_call/module/vote_dialog.dart';
import 'package:sentinel_call/services/blockchain.dart';
import 'package:date_count_down/date_count_down.dart';
import 'package:sentinel_call/utils/utils.dart';

class VotePage extends StatefulWidget {
  VotePage({super.key});
  final service = Get.find<BlockchainService>();
  final wallet = Get.find<KeyPair>();
  @override
  State<VotePage> createState() => _VotePageState();
}

bool isContains(List<String> list, String address) {
  for (var i = 0; i < list.length; i++) {
    if (list[i] == address) {
      return true;
    }
  }
  return false;
}

DateTime minutesToUTC(int minutes) {
  return DateTime.now().add(Duration(minutes: (minutes ~/ 12)));
}

class _VotePageState extends State<VotePage> {
  // late ExtrinsicStatus _status = const ExtrinsicStatus(type: '', value: '');

  // _submitPayload(Uint8List extrinsic) {
  //   debugPrint("🚩 ~ file: vote.dart:95 ~ _VotePageState ~ _submitPayload:");

  //   // widget.service.submitVoteExtrinsic(extrinsic, _statusHandler);
  // }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final data = widget.service.getProposalList();
    return Container(
      color: Theme.of(context).colorScheme.background,
      height: MediaQuery.of(context).size.height * 0.75,
      child: SizedBox.expand(
          child: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: Text('not connected')),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No proposals found'));
          }
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              final proposal = snapshot.data?[index];
              final isVoted =
                  isContains(proposal!.ayes!, widget.wallet.address) ||
                      isContains(proposal.nays!, widget.wallet.address);
              return Column(
                children: [
                  ListTile(
                    leading:
                        CircleAvatar(child: Text(proposal!.index.toString())),
                    title: Text('spam: ${proposal.args['spammer']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Voted: ${proposal.ayes!.length + proposal.nays!.length}/${proposal.threshold}'),
                        CountDownText(
                          due: minutesToUTC(
                              proposal.end! - proposal.numberBlock!),
                          finishedText: "Done",
                          showLabel: true,
                          longDateName: true,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    trailing: VoteButton(isVoted: isVoted, proposal: proposal),
                  ),
                  const Divider(height: 0),
                ],
              );
            },
          );
        },
      )),
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

  late bool isProcess = false;

  @override
  Widget build(BuildContext context) {
    final index = widget.proposal.index;
    final proposal = widget.proposal;
    return IconButton(
      onPressed: widget.isVoted
          ? null
          : () async {
              setState(() {
                isProcess = true;
              });
              final ext = await service.buildVoteExtrinsicPayload(
                  index: proposal.index ?? 0,
                  proposal: proposal.proposal ?? [],
                  approve: false,
                  wallet: wallet);
              final feeDetail = await service.getFeeDetails(ext);
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (context) {
                  return AlertDialog(
                    alignment: Alignment.center,
                    title: const Column(
                      // alignment: MainAxisAlignment.center,
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
                                onPressed: () async {
                                  var currentContext = context;
                                  Future.delayed(Duration.zero, () {
                                    Navigator.pop(currentContext, 'Aye');
                                  });
                                },
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
              ).then((value) async {
                debugPrint(
                    "🚩 ~ file: vote.dart:190 ~ _VoteButtonState ~ $value:");
                switch (value) {
                  case 'Aye':
                    final ayeExt = await service.buildVoteExtrinsicPayload(
                        index: proposal.index ?? 0,
                        proposal: proposal.proposal ?? [],
                        approve: true,
                        wallet: wallet);

                    await service.submitVoteExtrinsic(ayeExt, (status) {
                      setState(() {
                        isProcess = false;
                      });
                      ToastMessage.show(status.value);
                    });
                    break;
                  case 'Nye':
                    final ayeExt = await service.buildVoteExtrinsicPayload(
                        index: proposal.index ?? 0,
                        proposal: proposal.proposal ?? [],
                        approve: true,
                        wallet: wallet);

                    service.submitVoteExtrinsic(ayeExt, (status) {
                      setState(() {
                        isProcess = false;
                      });
                      ToastMessage.show(status.value);
                    });
                    break;
                  default:
                    setState(() {
                      isProcess = false;
                    });
                    break;
                }
              });
            },
      icon: widget.isVoted
          ? const Icon(Icons.check)
          : isProcess
              ? const CircularProgressIndicator()
              : const Icon(Icons.how_to_vote),
    );
  }
}
