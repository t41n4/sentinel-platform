// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i4;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i5;

import 'call_record.dart' as _i3;
import 'spam_record.dart' as _i2;

class PhoneRecord {
  const PhoneRecord({
    required this.trustRating,
    required this.status,
    required this.spamRecords,
    required this.callRecords,
  });

  factory PhoneRecord.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// TrustRating
  final int trustRating;

  /// StatusType
  final List<int> status;

  /// Vec<SpamRecord>
  final List<_i2.SpamRecord> spamRecords;

  /// Vec<CallRecord>
  final List<_i3.CallRecord> callRecords;

  static const $PhoneRecordCodec codec = $PhoneRecordCodec();

  _i4.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
        'trustRating': trustRating,
        'status': status,
        'spamRecords': spamRecords.map((value) => value.toJson()).toList(),
        'callRecords': callRecords.map((value) => value.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is PhoneRecord &&
          other.trustRating == trustRating &&
          _i5.listsEqual(
            other.status,
            status,
          ) &&
          _i5.listsEqual(
            other.spamRecords,
            spamRecords,
          ) &&
          _i5.listsEqual(
            other.callRecords,
            callRecords,
          );

  @override
  int get hashCode => Object.hash(
        trustRating,
        status,
        spamRecords,
        callRecords,
      );
}

class $PhoneRecordCodec with _i1.Codec<PhoneRecord> {
  const $PhoneRecordCodec();

  @override
  void encodeTo(
    PhoneRecord obj,
    _i1.Output output,
  ) {
    _i1.I8Codec.codec.encodeTo(
      obj.trustRating,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      obj.status,
      output,
    );
    const _i1.SequenceCodec<_i2.SpamRecord>(_i2.SpamRecord.codec).encodeTo(
      obj.spamRecords,
      output,
    );
    const _i1.SequenceCodec<_i3.CallRecord>(_i3.CallRecord.codec).encodeTo(
      obj.callRecords,
      output,
    );
  }

  @override
  PhoneRecord decode(_i1.Input input) {
    return PhoneRecord(
      trustRating: _i1.I8Codec.codec.decode(input),
      status: _i1.U8SequenceCodec.codec.decode(input),
      spamRecords: const _i1.SequenceCodec<_i2.SpamRecord>(_i2.SpamRecord.codec)
          .decode(input),
      callRecords: const _i1.SequenceCodec<_i3.CallRecord>(_i3.CallRecord.codec)
          .decode(input),
    );
  }

  @override
  int sizeHint(PhoneRecord obj) {
    int size = 0;
    size = size + _i1.I8Codec.codec.sizeHint(obj.trustRating);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.status);
    size = size +
        const _i1.SequenceCodec<_i2.SpamRecord>(_i2.SpamRecord.codec)
            .sizeHint(obj.spamRecords);
    size = size +
        const _i1.SequenceCodec<_i3.CallRecord>(_i3.CallRecord.codec)
            .sizeHint(obj.callRecords);
    return size;
  }
}
