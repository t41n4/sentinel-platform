import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:polkadart/polkadart.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:ss58/ss58.dart' as ss58;
import 'package:trappist_extra/generated/localhost/types/scbc/pallet/phone_record.dart';
import 'package:trappist_extra/utils/utils.dart';

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

  bool isConnected() {
    return _localProvider.isConnected();
  }

  void deconnect() {
    _localProvider.disconnect();
  }

  Future<void> reconnect() async {
    debugPrint("🚩 ~ BlockchainService ~ ${_localProvider.isConnected()}:");

    _localProvider.disconnect();
    _localProvider = Provider.fromUri(Uri.parse(_wsEndpoint));
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

    debugPrint('[🚩 encodedSignature]: $encodedSignature');
    debugPrint('[🚩 encodedPublicKey]: $encodedPublicKey');

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

// Map<String, dynamic>?
  Future<List<PhoneRecord>?> queryPhoneRecord(String query) async {
    debugPrint(
        "🚩 ~ file: blockchain.dart:216 ~ BlockchainService ~ ${query}:");

    // check if query is a phone number or an address
    final isPhoneNumber = query.length == 11 && query.startsWith('0');
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
    debugPrint("🚩 ~ BlockchainService ~ ${fetch!.toJson()}");

    final List<PhoneRecord> list = [];
    list.add(fetch);
    return list;
  }
}
