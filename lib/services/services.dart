import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:polkadart/polkadart.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:ss58/ss58.dart' as ss58;
import 'package:trappist_extra/utils/utils.dart';

import '../generated/localhost/localhost.dart';

class BlockchainService {
  final String _wsEndpoint;
  Provider _localProvider;

  BlockchainService(this._wsEndpoint)
      : _localProvider = Provider.fromUri(Uri.parse(_wsEndpoint)) {
    _localProvider = Provider.fromUri(Uri.parse(_wsEndpoint));
  }

  Future getAccountInfo(String address) async {
    debugPrint('[🚩 address]: $address');
    final localApi = Localhost(_localProvider);
    final List<int> decodedBytes =
        ss58.Codec.fromNetwork('substrate').decode(address);
    final account = await localApi.query.system.account(decodedBytes);
    return account.toJson();
  }

  // Create an SR25519 Wallet
  Future<KeyPair> createWallet(String mnemonic) async {
    return await KeyPair.fromMnemonic(mnemonic);
  }

  // Check if     _localProvider.isConnected();
  bool isConnected() {
    return _localProvider.isConnected();
  }

  // Reconect to the blockchain
  Future<void> reconnect() async {
    _localProvider = Provider.fromUri(Uri.parse(_wsEndpoint));
  }

  Future<Uint8List> buildSpamExtrinsic(
      {required String reason,
      required String spammer,
      required String spammee,
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
            spammee: hex.decode(hex.encode(toIntList(spammee))))
        .encode();

    final encodedMethod = hex.encode(runtimeCall);
    debugPrint('[🚩 encodedCall(Method)]: $encodedMethod');

    final nonce1 =
        await SystemApi(_localProvider).accountNextIndex(wallet.address);

    final payload = SigningPayload(
      method: encodedMethod,
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

    return Extrinsic(
      signer: encodedPublicKey,
      method: encodedMethod,
      signature: encodedSignature,
      eraPeriod: 64,
      blockNumber: blockNumber,
      nonce: nonce1,
      tip: 0,
    ).encode(localApi.registry);
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

  // Get the balance of an account
}
