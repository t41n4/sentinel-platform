import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/module/list_item.dart';
import 'package:sentinel_call/services/blockchain.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final recentlyCall = widget.service.getRecentlyCall();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 100,
        ),
        child: FutureBuilder(
            future: recentlyCall,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final List<CallLogEntry> callLogs =
                      snapshot.data as List<CallLogEntry>;
                  debugPrint(
                      "🚩 ~ file: report.dart:132 ~ _ReportPageState ~ ${callLogs.length}:");
                  //remove duplicate call logs
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: callLogs.length,
                    itemBuilder: (context, index) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                          callLogs[index].timestamp ?? 0);
                      final dateString =
                          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                      return ListItem(
                          name: callLogs[index].name ?? 'Unknown',
                          number: "${callLogs[index].number}",
                          dateTime: dateString,
                          service: widget.service,
                          wallet: widget.wallet);
                    },
                  );
                }
              }
            }),
      ),
    );
  }
}
