// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i5;

import 'package:polkadart/polkadart.dart' as _i1;
import 'package:polkadart/scale_codec.dart' as _i3;

import '../types/scbc/pallet/call.dart' as _i7;
import '../types/scbc/pallet/phone_record.dart' as _i2;
import '../types/sentinel_chain_runtime/runtime_call.dart' as _i6;

class Queries {
  const Queries(this.__api);

  final _i1.StateApi __api;

  final _i1.StorageMap<List<int>, _i2.PhoneRecord> _ledger =
      const _i1.StorageMap<List<int>, _i2.PhoneRecord>(
    prefix: 'SCBC',
    storage: 'Ledger',
    valueCodec: _i2.PhoneRecord.codec,
    hasher: _i1.StorageHasher.blake2b128Concat(_i3.U8SequenceCodec.codec),
  );

  _i4.Future<_i2.PhoneRecord?> ledger(
    List<int> key1, {
    _i1.BlockHash? at,
  }) async {
    final hashedKey = _ledger.hashedKeyFor(key1);
    final bytes = await __api.getStorage(
      hashedKey,
      at: at,
    );
    if (bytes != null) {
      return _ledger.decodeValue(bytes);
    }
    return null; /* Nullable */
  }

  /// Returns the storage key for `ledger`.
  _i5.Uint8List ledgerKey(List<int> key1) {
    final hashedKey = _ledger.hashedKeyFor(key1);
    return hashedKey;
  }

  /// Returns the storage map key prefix for `ledger`.
  _i5.Uint8List ledgerMapPrefix() {
    final hashedKey = _ledger.mapPrefix();
    return hashedKey;
  }
}

class Txs {
  const Txs();

  /// See `Pallet::register_phone_number`.
  _i6.RuntimeCall registerPhoneNumber({required List<int> phoneNumber}) {
    final call = _i7.Call.values.registerPhoneNumber(phoneNumber: phoneNumber);
    return _i6.RuntimeCall.values.scbc(call);
  }

  /// See `Pallet::report_spam`.
  _i6.RuntimeCall reportSpam({
    required List<int> spammee,
    required List<int> spammer,
    required List<int> reason,
  }) {
    final call = _i7.Call.values.reportSpam(
      spammee: spammee,
      spammer: spammer,
      reason: reason,
    );
    return _i6.RuntimeCall.values.scbc(call);
  }

  /// See `Pallet::update_spam_status`.
  _i6.RuntimeCall updateSpamStatus({
    required List<int> spammer,
    required List<int> metadata,
  }) {
    final call = _i7.Call.values.updateSpamStatus(
      spammer: spammer,
      metadata: metadata,
    );
    return _i6.RuntimeCall.values.scbc(call);
  }

  /// See `Pallet::make_call`.
  _i6.RuntimeCall makeCall({
    required List<int> caller,
    required List<int> callee,
  }) {
    final call = _i7.Call.values.makeCall(
      caller: caller,
      callee: callee,
    );
    return _i6.RuntimeCall.values.scbc(call);
  }
}

class Constants {
  Constants();

  /// The overarching event type.
  final int maximumOwned = 100;

  final int thresholdSpam = -50;
}
