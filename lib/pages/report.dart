import 'package:flutter/material.dart';
import 'package:polkadart/polkadart.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:trappist_extra/module/alert_dialog.dart';
import 'package:trappist_extra/module/toast_message.dart';
import 'package:trappist_extra/services/services.dart';
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
  late String spammee = '';
  late String spammer = '';
  late String reason = '';

  _statusHandler(ExtrinsicStatus status) {
    debugPrint('[🚩 statusHandler]: ${status.type}, ${status.value}');
    ToastMessage toastMessage;
    switch (status.type) {
      case 'inBlock':
        toastMessage = ToastMessage(
            content: 'Your transaction is ${status.type}: ${status.value} ',
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
      case 'invalid':
        debugPrint('Invalid');
        if (status.value != null) {
          toastMessage = ToastMessage(
              content: 'Your transaction is ${status.type}: ${status.value}',
              typeToast: 'error');
          toastMessage.build(context);
        } else {
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

  _reportSpam(String reason, String spammer, String spammee) async {
    if (!widget.service.isConnected()) {
      debugPrint(widget.service.isConnected().toString());
      await widget.service.reconnect();
    }
    final extrinsic = await widget.service.buildSpamExtrinsic(
        reason: reason,
        spammer: spammer,
        spammee: spammee,
        wallet: widget.wallet);

    await widget.service
        .submitReportSpamExtrinsic(extrinsic, _statusHandler)
        .catchError((error, stackTrace) {
      if (context.mounted) {
        ShowAlertDialog(title: 'Error', content: '$error').build(context);
      } else {
        debugPrint('Error: $error');
      }
      return error;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                            onSaved: (newValue) {
                              spammee = newValue!;
                            },
                            validator: phoneValidator,
                            decoration: const InputDecoration(
                              labelText: 'Spammee',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
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
                            onSaved: (newValue) {
                              reason = newValue!;
                            },
                            validator: Validatorless.multiple([
                              Validatorless.required('This field is required'),
                              Validatorless.between(
                                  3, 70, 'Must be between 3 and 70'),
                            ]),
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                _reportSpam(reason, spammer, spammee);
                              }
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  )),
            ))));
  }
}
