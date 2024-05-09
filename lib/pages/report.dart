import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polkadart/polkadart.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:trappist_extra/module/alert_dialog.dart';
import 'package:trappist_extra/module/toast_message.dart';
import 'package:trappist_extra/services/blockchain.dart';
import 'package:trappist_extra/theme/custom_colors_theme.dart';
import 'package:trappist_extra/utils/validator.dart';
import 'package:validatorless/validatorless.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.service, required this.wallet});

  final BlockchainService service;
  final KeyPair wallet;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late String spammer = '';
  late String reason = '';

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
    switch (status.type) {
      case 'inBlock':
        toastMessage = ToastMessage(
            content: 'Your transaction is ${status.type}',
            typeToast: 'success');
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
            content: 'Your transaction is ${status.type}',
            typeToast: 'success');
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

  _reportSpam(String reason, String spammer) async {
    if (!widget.service.isConnected()) {
      debugPrint(widget.service.isConnected().toString());
      await widget.service.reconnect();
    }
    final extrinsic = await widget.service.buildSpamExtrinsic(
        reason: reason, spammer: spammer, wallet: widget.wallet);
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool isProcess = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColorsTheme>()!;
    final styleInput = TextStyle(
      color: colors.colorLabelColor,
    );

    return Center(
        heightFactor: 1.7,
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: styleInput,
                            onSaved: (newValue) {
                              spammer = newValue!;
                            },
                            validator: phoneValidator,
                            decoration: const InputDecoration(
                              labelText: 'Spammer',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            style: styleInput,
                            onSaved: (newValue) {
                              reason = newValue!;
                            },
                            validator: textValidator,
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: !isProcess
                                ? () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _status = const ExtrinsicStatus(
                                            type: 'signing', value: '');
                                        isProcess = true;
                                      });
                                      _formKey.currentState!.save();
                                      _reportSpam(reason, spammer);
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    }
                                  }
                                : null,
                            child: Text(
                              !isProcess ? 'Submit' : _status.type,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ))));
  }
}
