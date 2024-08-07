import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:polkadart/polkadart.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/module/alert_dialog.dart';
import 'package:sentinel_call/module/hint.dart';
import 'package:sentinel_call/module/item.dart';
import 'package:sentinel_call/module/toast_message.dart';
import 'package:sentinel_call/pages/report.dart';
import 'package:sentinel_call/services/blockchain.dart';
import 'package:validatorless/validatorless.dart';

class ListItem extends StatefulWidget {
  const ListItem({
    Key? key,
    required this.name,
    required this.number,
    required this.service,
    required this.wallet,
    required this.dateTime,
  }) : super(key: key);

  final String name;
  final String number;
  final String dateTime;
  final BlockchainService service;
  final KeyPair wallet;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final colorNotifier = ValueNotifier<Color>(Colors.grey);

  late ExtrinsicStatus _status = const ExtrinsicStatus(type: '', value: '');

  _statusHandler(ExtrinsicStatus status) {
    debugPrint('[🚩 statusHandler]: ${status.type}, ${status.value}');
    setState(() {
      _status = status;
      isProcess = _status.type == 'broadcast' ||
              _status.type == 'inBlock' ||
              _status.type == 'ready' ||
              _status.type == 'signing'
          ? true
          : false;
    });

    ToastMessage toastMessage;
    switch (_status.type) {
      case 'inBlock':
        toastMessage = ToastMessage(
            content: 'Your transaction is ${status.type}', typeToast: 'info');
        toastMessage.build(context);
        break;
      case 'signing':
        toastMessage = ToastMessage(
            content: 'Your transaction is ${status.type}', typeToast: 'info');
        toastMessage.build(context);
        break;
      case 'ready':
        toastMessage = ToastMessage(
            content: 'Your transaction is ${status.type}', typeToast: 'info');
        toastMessage.build(context);
        break;
      case 'finalized':
        toastMessage = ToastMessage(
            content: 'Your transaction is ${status.type}',
            typeToast: 'success');
        toastMessage.build(context);
      case 'broadcast':
        toastMessage = ToastMessage(
            content: 'Your transaction is ${status.type}', typeToast: 'info');
        toastMessage.build(context);
      case 'invalid':
        debugPrint('Invalid');
        if (status.value != null) {
          toastMessage = ToastMessage(
              content: 'Your transaction is ${status.type}: ${status.value}',
              typeToast: 'error');
          toastMessage.build(context);
        } else {
          isProcess = false;
          const ShowAlertDialog(
            content:
                'Invalid transaction, please check your connection and try again',
            title: 'Alert',
          ).build(context);
        }
        break;
      default:
    }
  }

  _reportSpam(String reason, String spammer, bool isSpam) async {
    if (!widget.service.isConnectedSucess()) {
      debugPrint(widget.service.isConnectedSucess().toString());
      await widget.service.reconnect();
    }

    if (!widget.service.isConnectedSucess()) {
      if (context.mounted) {
        const ShowAlertDialog(
          title: 'Error',
          content: 'Please check your connection and try again',
        ).build(context);
        setState(() {
          isProcess = false;
        });
      }
      return;
    }
    // ============= check if spammer is exist =============
    final phoneRecord = await widget.service.queryPhoneRecord(spammer);
    final spamThreshHold = widget.service.querySpamThreshold();
    final normalThreshHold = widget.service.queryNormalThreshold();
    final trustRating =
        phoneRecord!.isEmpty ? 0 : phoneRecord.first.trustRating;

    final status = phoneRecord.isEmpty
        ? 'normal'
        : String.fromCharCodes(Uint8List.fromList(phoneRecord.first.status));

    if ((status.toLowerCase() == 'spam' && isSpam) ||
        (status.toLowerCase() == 'normal' && !isSpam)) {
      if (context.mounted) {
        ShowAlertDialog(
          title: 'Error',
          content: isSpam
              ? 'This number is already in spam status'
              : "This number is already in not spam normal",
        ).build(context);
        setState(() {
          isProcess = false;
        });
      }
      return;
    }

    final proposal = await widget.service.getProposalList();

    if (proposal.isNotEmpty) {
      final proposalExist = proposal.firstWhere(
          (element) => element.args['spammer'] == spammer,
          orElse: () => Proposal(
              index: 0,
              threshold: 0,
              section: '',
              method: '',
              args: {},
              ayes: [],
              nays: [],
              end: 0,
              numberBlock: 0,
              proposal: []));

      if (proposalExist.args['spammer'] == spammer) {
        if (context.mounted) {
          const ShowAlertDialog(
            title: 'Info',
            content:
                'This number is considering as spam, please visit vote page to vote on it',
          ).build(context);
          setState(() {
            isProcess = false;
          });
        }
        return;
      }
    }

    if ((trustRating <= spamThreshHold && status == "normal") ||
        (trustRating >= normalThreshHold && status == "spam")) {
      final payload = await widget.service.buildProposalMotionPayload(
        wallet: widget.wallet,
        spammer: spammer,
        metaData: status == "normal"
            ? "Update status to spam"
            : "Update status to normal",
      );

      final tx = await widget.service
          .submitProposalMotionExtrinsic(payload, _statusHandler)
          .catchError((error, stackTrace) {
        if (context.mounted) {
          ShowAlertDialog(title: 'Error', content: '$error').build(context);
          setState(() {
            isProcess = false;
          });
        } else {
          debugPrint('Error: $error');
        }
        return error;
      });
      return;
    }

    final extrinsic = await widget.service.buildSpamExtrinsic(
        reason: reason,
        spammer: spammer,
        wallet: widget.wallet,
        isSpam: isSpam);

    await widget.service
        .submitReportSpamExtrinsic(extrinsic, _statusHandler)
        .catchError((error, stackTrace) {
      if (context.mounted) {
        ShowAlertDialog(title: 'Error', content: '$error').build(context);
        setState(() {
          isProcess = false;
        });
      } else {
        debugPrint('Error: $error');
      }
      return error;
    });
  }

  late bool isProcess = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    late String reason = '';
    final String spammer = widget.number;
    final form = GlobalKey<FormState>();
    return SizedBox(
      height: 50,
      child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                colorNotifier.value = Colors.green;
                setState(() {
                  _status = const ExtrinsicStatus(type: 'signing', value: '');
                  isProcess = true;
                });
                const toastMessage = ToastMessage(
                    content: 'Your transaction is signing', typeToast: 'info');
                toastMessage.build(context);
                _reportSpam("Not Spam", spammer, false);
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.cancel,
              label: 'Not Spam',
            )
          ],
        ),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                colorNotifier.value = Colors.red;
                setState(() {
                  _status = const ExtrinsicStatus(type: 'signing', value: '');
                  isProcess = true;
                });

                // const toastMessage = ToastMessage(
                //     content: 'Your transaction is signing', typeToast: 'info');
                // toastMessage.build(context);
                // _reportSpam("Spam", widget.number);

                // show only reason text field dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return Form(
                      key: form,
                      child: AlertDialog(
                        title: const Text('Report spam'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Reason',
                                  hintText: 'Enter the reason'),
                              validator: Validatorless.multiple(
                                [
                                  Validatorless.required('Reason is required'),
                                  Validatorless.min(
                                      3, " Reason must be at least 3 "),
                                  Validatorless.max(
                                      50, " Reason must be at most 50 ")
                                ],
                              ),
                              onChanged: (value) {
                                reason = value;
                              },
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Spammer: $spammer',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (form.currentState!.validate()) {
                                const toastMessage = ToastMessage(
                                    content: 'Your transaction is signing',
                                    typeToast: 'info');
                                toastMessage.build(context);
                                _reportSpam(reason, spammer, true);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Report'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.report,
              label: 'Spam',
            ),
          ],
        ),
        child: Row(
          children: [
            Hint(colorNotifier: colorNotifier),
            Expanded(
              child: Item(
                name: widget.name,
                number: widget.number,
                dateTime: widget.dateTime,
              ),
            )
          ],
        ),
      ),
    );
  }
}
