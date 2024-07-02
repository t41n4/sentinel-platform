// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i3;

class CallRecord {
  const CallRecord({
    required this.caller,
    required this.callee,
    required this.uniqueId,
    required this.timestamp,
  });

  factory CallRecord.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// PhoneNumber
  final List<int> caller;

  /// PhoneNumber
  final List<int> callee;

  /// UniqueId
  final List<int> uniqueId;

  /// Timestamp
  final List<int> timestamp;

  static const $CallRecordCodec codec = $CallRecordCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, List<int>> toJson() => {
        'caller': caller,
        'callee': callee,
        'uniqueId': uniqueId.toList(),
        'timestamp': timestamp,
      };

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is CallRecord &&
          _i3.listsEqual(
            other.caller,
            caller,
          ) &&
          _i3.listsEqual(
            other.callee,
            callee,
          ) &&
          _i3.listsEqual(
            other.uniqueId,
            uniqueId,
          ) &&
          _i3.listsEqual(
            other.timestamp,
            timestamp,
          );

  @override
  int get hashCode => Object.hash(
        caller,
        callee,
        uniqueId,
        timestamp,
      );
}

class $CallRecordCodec with _i1.Codec<CallRecord> {
  const $CallRecordCodec();

  @override
  void encodeTo(
    CallRecord obj,
    _i1.Output output,
  ) {
    _i1.U8SequenceCodec.codec.encodeTo(
      obj.caller,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      obj.callee,
      output,
    );
    const _i1.U8ArrayCodec(16).encodeTo(
      obj.uniqueId,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      obj.timestamp,
      output,
    );
  }

  @override
  CallRecord decode(_i1.Input input) {
    return CallRecord(
      caller: _i1.U8SequenceCodec.codec.decode(input),
      callee: _i1.U8SequenceCodec.codec.decode(input),
      uniqueId: const _i1.U8ArrayCodec(16).decode(input),
      timestamp: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  @override
  int sizeHint(CallRecord obj) {
    int size = 0;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.caller);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.callee);
    size = size + const _i1.U8ArrayCodec(16).sizeHint(obj.uniqueId);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(obj.timestamp);
    return size;
  }
}
