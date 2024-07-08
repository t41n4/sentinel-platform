// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i3;

class SpamRecord {
  const SpamRecord({
    required this.timestamp,
    required this.reason,
    required this.uniqueId,
    required this.who,
    required this.isSpam,
  });

  factory SpamRecord.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// Timestamp
  final List<int> timestamp;

  /// Reason
  final List<int> reason;

  /// UniqueId
  final List<int> uniqueId;

  /// PhoneNumber
  final List<int> who;

  /// bool
  final bool isSpam;

  static const $SpamRecordCodec codec = $SpamRecordCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'reason': reason,
        'uniqueId': uniqueId.toList(),
        'who': who,
        'isSpam': isSpam,
      };

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is SpamRecord &&
          _i3.listsEqual(
            other.timestamp,
            timestamp,
          ) &&
          _i3.listsEqual(
            other.reason,
            reason,
          ) &&
          _i3.listsEqual(
            other.uniqueId,
            uniqueId,
          ) &&
          _i3.listsEqual(
            other.who,
            who,
          ) &&
          other.isSpam == isSpam;

  @override
  int get hashCode => Object.hash(
        timestamp,
        reason,
        uniqueId,
        who,
        isSpam,
      );
}

class $SpamRecordCodec with _i1.Codec<SpamRecord> {
  const $SpamRecordCodec();

  @override
  void encodeTo(
    SpamRecord obj,
    _i1.Output output,
  ) {
    _i1.U8SequenceCodec.codec.encodeTo(
      obj.timestamp,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      obj.reason,
      output,
    );
    const _i1.U8ArrayCodec(16).encodeTo(
      obj.uniqueId,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      obj.who,
      output,
    );
    _i1.BoolCodec.codec.encodeTo(
      obj.isSpam,
      output,
    );
  }

  @override
  SpamRecord decode(_i1.Input input) {
    return SpamRecord(
      timestamp: _i1.U8SequenceCodec.codec.decode(input),
      reason: _i1.U8SequenceCodec.codec.decode(input),
      uniqueId: const _i1.U8ArrayCodec(16).decode(input),
      who: _i1.U8SequenceCodec.codec.decode(input),
      isSpam: _i1.BoolCodec.codec.decode(input),
    );
  }

  @override
  int sizeHint(SpamRecord obj) {
    int size = 0;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.timestamp);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.reason);
    size = size + const _i1.U8ArrayCodec(16).sizeHint(obj.uniqueId);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.who);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.isSpam);
    return size;
  }
}
