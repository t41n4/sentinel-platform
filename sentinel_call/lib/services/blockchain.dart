import 'dart:async';

import 'package:call_log/call_log.dart';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:polkadart/polkadart.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:sentinel_call/generated/localhost/types/pallet_collective/votes.dart';
import 'package:sentinel_call/generated/localhost/types/scbc/pallet/phone_record.dart';
import 'package:sentinel_call/utils/utils.dart';
import 'package:ss58/ss58.dart' as ss58;

import '../generated/localhost/localhost.dart';

class BlockchainService {
  final String _wsEndpoint;
  late Provider _localProvider;

  BlockchainService(this._wsEndpoint) {
    final tempLocalProvider = Provider.fromUri(Uri.parse(_wsEndpoint));
    tempLocalProvider.isConnected()
        ? _localProvider = tempLocalProvider
        : throw Exception('Error connecting to the blockchain');
  }

  Future getAccountInfo(String address) async {
    final localApi = Localhost(_localProvider);

    final List<int> decodedBytes =
        ss58.Codec.fromNetwork('substrate').decode(address);
    final account = await localApi.query.system.account(decodedBytes);
    return account.toJson();
  }

  void Hello() {
    debugPrint('Hello from BlockchainService');
  }

  Future<KeyPair> createWalletFromPhrase(String mnemonic) async {
    return await KeyPair.ed25519.fromMnemonic(mnemonic);
  }

  Future<KeyPair> createWalletFromSeed(Uint8List seed) async {
    return KeyPair.sr25519.fromSeed(seed);
  }

  Future<KeyPair> createAliceWallet() async {
    const phrase =
        'bottom drive obey lake curtain smoke basket hold race lonely fit walk//Alice';
    return KeyPair.sr25519.fromMnemonic(phrase);
  }

  Future<KeyPair> createBobWallet() async {
    const phrase =
        'bottom drive obey lake curtain smoke basket hold race lonely fit walk//Alice';
    return KeyPair.sr25519.fromMnemonic(phrase);
  }

  bool isConnected() {
    return _localProvider.isConnected();
  }

  void disconnect() {
    _localProvider.disconnect();
  }

  Future<void> reconnect() async {
    debugPrint("🚩 ~ BlockchainService ~ ${_localProvider.isConnected()}:");

    _localProvider.disconnect();
    _localProvider = Provider.fromUri(Uri.parse(_wsEndpoint));
  }

  Future<Map<String, dynamic>> getChainInfomation(stateApi) async {
    final wallet = Get.find<KeyPair>();
    final runtimeVersion = await stateApi.getRuntimeVersion();
    final specVersion = runtimeVersion.specVersion;
    final transactionVersion = runtimeVersion.transactionVersion;
    final block = await _localProvider.send('chain_getBlock', []);
    final blockNumber = int.parse(block.result['block']['header']['number']);

    final blockHash = (await _localProvider.send('chain_getBlockHash', []))
        .result
        .replaceAll('0x', '');

    final genesisHash = (await _localProvider.send('chain_getBlockHash', [0]))
        .result
        .replaceAll('0x', '');
    final nonce1 =
        await SystemApi(_localProvider).accountNextIndex(wallet.address);
    return {
      'specVersion': specVersion,
      'transactionVersion': transactionVersion,
      'blockNumber': blockNumber,
      'blockHash': blockHash,
      'genesisHash': genesisHash,
      'nonce': nonce1
    };
  }

  Future<Uint8List> buildSpamExtrinsic(
      {required String reason,
      required String spammer,
      required KeyPair wallet}) async {
    final localApi = Localhost(_localProvider);
    final stateApi = StateApi(_localProvider);

    final runtimeVersion = await stateApi.getRuntimeVersion();
    final specVersion = runtimeVersion.specVersion;
    final transactionVersion = runtimeVersion.transactionVersion;
    final block = await _localProvider.send('chain_getBlock', []);
    final blockNumber = int.parse(block.result['block']['header']['number']);

    final blockHash = (await _localProvider.send('chain_getBlockHash', []))
        .result
        .replaceAll('0x', '');

    final genesisHash = (await _localProvider.send('chain_getBlockHash', [0]))
        .result
        .replaceAll('0x', '');

    final runtimeCall = localApi.tx.scbc
        .reportSpam(
            reason: hex.decode(hex.encode(toIntList(reason))),
            spammer: hex.decode(hex.encode(toIntList(spammer))),
            spammee: ss58.Codec.fromNetwork('substrate').decode(wallet.address))
        .encode();

    final nonce1 =
        await SystemApi(_localProvider).accountNextIndex(wallet.address);

    final payload = SigningPayload(
      method: runtimeCall,
      specVersion: specVersion,
      transactionVersion: transactionVersion,
      genesisHash: genesisHash,
      blockHash: blockHash,
      blockNumber: blockNumber,
      eraPeriod: 64,
      nonce: nonce1, // Supposing it is this wallet first transaction
      tip: 0,
    ).encode(localApi.registry);

    final signature = wallet.sign(payload);

    return ExtrinsicPayload(
      signer: Uint8List.fromList(wallet.publicKey.bytes),
      method: runtimeCall,
      signature: signature,
      eraPeriod: 64,
      blockNumber: blockNumber,
      nonce: nonce1,
      tip: 0,
    ).encode(localApi.registry, wallet.signatureType);
  }

  // Build and submit a report spam extrinsic
  Future<StreamSubscription<ExtrinsicStatus>> submitReportSpamExtrinsic(
      Uint8List extrinsic, void Function(ExtrinsicStatus) statusHandler) {
    final authorApi = AuthorApi(_localProvider);
    try {
      final hashTx =
          authorApi.submitAndWatchExtrinsic(extrinsic, statusHandler);
      return hashTx;
    } catch (e) {
      throw Exception('Error submitting extrinsic: $e');
    }
  }

  // Make a call event
  Future<Uint8List> buildMakeCallPayload(
      String caller, String callee, KeyPair wallet) async {
    final localApi = Localhost(_localProvider);
    final stateApi = StateApi(_localProvider);

    final List<int> decodeSS58 =
        ss58.Codec.fromNetwork('substrate').decode(callee);

    // callee = '0x${hex.encode(decodeSS58)}';

    final runtimeCall = localApi.tx.scbc
        .makeCall(callee: decodeSS58, caller: caller.codeUnits)
        .encode();

    final runtimeVersion = await stateApi.getRuntimeVersion();
    final specVersion = runtimeVersion.specVersion;
    final transactionVersion = runtimeVersion.transactionVersion;
    final block = await _localProvider.send('chain_getBlock', []);
    final blockNumber = int.parse(block.result['block']['header']['number']);

    final blockHash = (await _localProvider.send('chain_getBlockHash', []))
        .result
        .replaceAll('0x', '');

    final genesisHash = (await _localProvider.send('chain_getBlockHash', [0]))
        .result
        .replaceAll('0x', '');

    final encodedMethod = hex.encode(runtimeCall);
    debugPrint('[🚩 makeCall(runtime)]: $encodedMethod');

    final nonce1 =
        await SystemApi(_localProvider).accountNextIndex(wallet.address);

    final payload = SigningPayload(
      method: runtimeCall,
      specVersion: specVersion,
      transactionVersion: transactionVersion,
      genesisHash: genesisHash,
      blockHash: blockHash,
      blockNumber: blockNumber,
      eraPeriod: 64,
      nonce: nonce1, // Supposing it is this wallet first transaction
      tip: 0,
    ).encode(localApi.registry);

    final signature = wallet.sign(payload);
    final encodedSignature = hex.encode(signature);
    final encodedPublicKey = hex.encode(wallet.publicKey.bytes);

    debugPrint('[🚩 encodedSignature buildMakeCallPayload]: $encodedSignature');
    debugPrint('[🚩 encodedPublicKey buildMakeCallPayload]: $encodedPublicKey');
    debugPrint('[🚩 encodedSignature buildMakeCallPayload]: $encodedSignature');
    debugPrint('[🚩 encodedPublicKey buildMakeCallPayload]: $encodedPublicKey');

    return ExtrinsicPayload(
      signer: Uint8List.fromList(wallet.publicKey.bytes),
      method: runtimeCall,
      signature: signature,
      eraPeriod: 64,
      blockNumber: blockNumber,
      nonce: nonce1,
      tip: 0,
    ).encode(localApi.registry, wallet.signatureType);
  }

  Future<Map<String, dynamic>> getFeeDetails(Uint8List extrinsic) async {
    final fee =
        await _localProvider.send('payment_queryInfo', [hex.encode(extrinsic)]);

    // {weight: {ref_time: 100010000, proof_size: 0}, class: normal, partialFee: 224424134}
    final feeDetails = {
      'weight': fee.result['weight'],
      'class': fee.result['class'],
      'partialFee': fee.result['partialFee']
    };

    return feeDetails;
  }

  Future<StreamSubscription<ExtrinsicStatus>> submitMakeCallExtrinsic(
      Uint8List extrinsic) {
    final authorApi = AuthorApi(_localProvider);
    try {
      final hashTx = authorApi.submitAndWatchExtrinsic(extrinsic, (status) {
        debugPrint(
            '[🚩 submitMakeCallExtrinsic]: ${status.type} # ${status.value}');
      });
      return hashTx;
    } catch (e) {
      throw Exception('Error submitting extrinsic: $e');
    }
  }

  // Build proposal motion extrinsic
  Future<Uint8List> buildProposalMotionPayload(
      {required String spammer,
      required String metaData,
      required KeyPair wallet}) async {
    final localApi = Localhost(_localProvider);
    final stateApi = StateApi(_localProvider);

    final member = await localApi.query.council.members();

    final threshHold = member.length;

    final proposal = localApi.tx.scbc.updateSpamStatus(
        spammer: spammer.codeUnits, metadata: metaData.codeUnits);

    final lengthBound = spammer.length + metaData.length + 9;

    final runtimeCall = localApi.tx.council
        .propose(
            threshold: BigInt.from(threshHold),
            proposal: proposal,
            lengthBound: BigInt.from(lengthBound))
        .encode();

    final chainInfo = await getChainInfomation(stateApi);

    final payload = SigningPayload(
      method: runtimeCall,
      specVersion: chainInfo['specVersion'],
      transactionVersion: chainInfo['transactionVersion'],
      genesisHash: chainInfo['genesisHash'],
      blockHash: chainInfo['blockHash'],
      blockNumber: chainInfo['blockNumber'],
      eraPeriod: 64,
      nonce: chainInfo['nonce'],
      tip: 0,
    ).encode(localApi.registry);

    final signature = wallet.sign(payload);
    final encodedSignature = hex.encode(signature);
    final encodedPublicKey = hex.encode(wallet.publicKey.bytes);

    debugPrint(
        '[🚩 encodedSignature buildProposalMotionPayload]: $encodedSignature');
    debugPrint(
        '[🚩 encodedPublicKey buildProposalMotionPayload]: $encodedPublicKey');

    return ExtrinsicPayload(
      signer: Uint8List.fromList(wallet.publicKey.bytes),
      method: runtimeCall,
      signature: signature,
      eraPeriod: 64,
      blockNumber: chainInfo['blockNumber'],
      nonce: chainInfo['nonce'],
      tip: 0,
    ).encode(localApi.registry, wallet.signatureType);
  }

  // Submit proposal motion extrinsic
  Future<StreamSubscription<ExtrinsicStatus>> submitProposalMotionExtrinsic(
      Uint8List extrinsic, void Function(ExtrinsicStatus) statusHandler) {
    final authorApi = AuthorApi(_localProvider);

    final hashTx = authorApi.submitAndWatchExtrinsic(extrinsic, statusHandler);
    return hashTx;
  }

  // Build Vote payload
  Future<Uint8List> buildVoteExtrinsicPayload(
      {required int index,
      required List<int> proposal,
      required bool approve,
      required KeyPair wallet}) async {
    final localApi = Localhost(_localProvider);
    final stateApi = StateApi(_localProvider);

    final chainInfo = await getChainInfomation(stateApi);

    final vote = localApi.tx.council
        .vote(proposal: proposal, index: BigInt.from(index), approve: approve);

    final runtimeCall = vote.encode();

    final payload = SigningPayload(
      method: runtimeCall,
      specVersion: chainInfo['specVersion'],
      transactionVersion: chainInfo['transactionVersion'],
      genesisHash: chainInfo['genesisHash'],
      blockHash: chainInfo['blockHash'],
      blockNumber: chainInfo['blockNumber'],
      eraPeriod: 64,
      nonce: chainInfo['nonce'],
      tip: 0,
    ).encode(localApi.registry);

    final signature = wallet.sign(payload);

    return ExtrinsicPayload(
      signer: Uint8List.fromList(wallet.publicKey.bytes),
      method: runtimeCall,
      signature: signature,
      eraPeriod: 64,
      blockNumber: chainInfo['blockNumber'],
      nonce: chainInfo['nonce'],
      tip: 0,
    ).encode(localApi.registry, wallet.signatureType);
  }

  // Submit vote extrinsic
  Future<StreamSubscription<ExtrinsicStatus>> submitVoteExtrinsic(
      Uint8List extrinsic, void Function(ExtrinsicStatus) statusHandler) {
    final authorApi = AuthorApi(_localProvider);

    final hashTx = authorApi.submitAndWatchExtrinsic(extrinsic, statusHandler);
    return hashTx;
  }

  // Map<String, dynamic>?
  Future<List<PhoneRecord>?> queryPhoneRecord(String query) async {
    // check connection
    if (!_localProvider.isConnected()) {
      throw Exception('Not connected to the blockchain');
    }
    // check connection
    if (!_localProvider.isConnected()) {
      throw Exception('Not connected to the blockchain');
    }

    // check if query is a phone number or an address
    final isPhoneNumber =
        (query.length == 10 || query.length == 11) && query.startsWith('0');
    final isAddress = query.length == 48 && query.startsWith('5');
    if (query.isEmpty) {
      return [];
    }

    if (!isPhoneNumber && !isAddress) {
      throw Exception('Invalid query');
    }

    final data = isPhoneNumber
        ? query.codeUnits
        : ss58.Codec.fromNetwork('substrate').decode(query);

    final localApi = Localhost(_localProvider);
    final fetch = await localApi.query.scbc.ledger(data);

    final List<PhoneRecord> res = [];
    if (fetch == null) return res;

    res.add(fetch);
    return res;
  }

  // get proposals
  Future<List<List<int>>> _getProposals() async {
    final localApi = Localhost(_localProvider);
    final fetch = await localApi.query.council.proposals();
    return fetch;
  }

  // get voting
  Future<Votes?> _getVoting(List<int> key1) async {
    final localApi = Localhost(_localProvider);
    final fetch = await localApi.query.council.voting(key1);
    return fetch;
  }

  // get proposal list
  Future<List<Proposal>> getProposalList() async {
    final localApi = Localhost(_localProvider);
    final proposals = await _getProposals();
    final numberBlock = await getNumberBlock();

    final data = await Future.wait(proposals.map((e) async {
      final proposal = await localApi.query.council.proposalOf(e);
      final voting = await _getVoting(e);
      // voting json
      // {
      //   index: 0
      //   threshold: 2
      //   ayes: [
      //     5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY
      //   ]
      //   nays: []
      //   end: 73,535
      // }
      // proposal json
      // {SCBC: {update_spam_status: {spammer: [48, 57, 51, 53, 56, 51, 52, 51, 50, 57], metadata: [83, 111, 97, 109]}}}
      final data1 = proposal?.toJson();
      // debugPrint(
      //     "🚩 ~ file: blockchain.dart:386 ~ BlockchainService ~ $data1:");
      final data2 = voting;

      final section = data1?.keys.first;
      final method = data1?[section]?.keys.first;
      final args = data1?[section]?[method];

      // debugPrint(
      //     "🚩 ~ file: blockchain.dart:403 ~ BlockchainService ~ end: ${data2?.end}:");
      // debugPrint(
      //     "🚩 ~ file: blockchain.dart:403 ~ BlockchainService ~ nays: ${data2?.nays}:");
      // debugPrint(
      //     "🚩 ~ file: blockchain.dart:403 ~ BlockchainService ~ ayes: ${data2?.ayes}:");
      // debugPrint(
      //     "🚩 ~ file: blockchain.dart:403 ~ BlockchainService ~ args: ${args}:");
      // debugPrint(
      //     "🚩 ~ file: blockchain.dart:403 ~ BlockchainService ~ method: ${method}:");
      // debugPrint(
      //     "🚩 ~ file: blockchain.dart:403 ~ BlockchainService ~ section: ${section}:");
      // debugPrint(
      //     "🚩 ~ file: blockchain.dart:403 ~ BlockchainService ~ threshold: ${data2?.threshold}:");

      final res = Proposal(
          index: data2!.index,
          threshold: data2.threshold,
          section: section,
          method: method,
          args: {
            'spammer': String.fromCharCodes(args?['spammer']),
            'metadata': String.fromCharCodes(args?['metadata'])
          },
          ayes: data2.ayes
              .map((e) => ss58.Codec.fromNetwork('substrate').encode(e))
              .toList(),
          nays: data2.nays
              .map((e) => ss58.Codec.fromNetwork('substrate').encode(e))
              .toList(),
          end: data2.end,
          numberBlock: numberBlock,
          proposal: e);

      return res;
    }));

    return data;
  }

  int queryThreshold() {
    final localApi = Localhost(_localProvider);
    return localApi.constant.scbc.thresholdSpam;
  }

  Future<int> getNumberBlock() async {
    final localApi = Localhost(_localProvider);
    final number = await localApi.query.system.number();
    return number;
  }

  Future<List<CallLogEntry>> getRecentlyCall() async {
    // QUERY CALL LOG (ALL PARAMS ARE OPTIONAL)
    var now = DateTime.now();
    // query CallLog 30 days ago
    int from = now.subtract(const Duration(days: 5)).millisecondsSinceEpoch;

    // query CallLog 30 days ago

    Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: from,
    );
    // to list

    return entries.toSet().toList();
  }
}

class Proposal {
  late int? index;
  late int? threshold;
  late String? section;
  late String? method;
  late Map<String, dynamic> args;
  late List<String>? ayes;
  late List<String>? nays;
  late int? end;
  late int? numberBlock;
  late List<int>? proposal;

  Proposal({
    required this.index,
    required this.threshold,
    required this.section,
    required this.method,
    required this.args,
    required this.ayes,
    required this.nays,
    required this.end,
    required this.numberBlock,
    required this.proposal,
  });

  bool isBlank() {
    return index == null ||
        threshold == null ||
        section == null ||
        method == null ||
        args.isEmpty ||
        ayes == null ||
        nays == null ||
        end == null;
  }
}
