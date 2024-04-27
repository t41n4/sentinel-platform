// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../sp_core/crypto/account_id32.dart' as _i3;

/// The `Event` enum of this pallet
abstract class Event {
  const Event();

  factory Event.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $EventCodec codec = $EventCodec();

  static const $Event values = $Event();

  _i2.Uint8List encode() {
    final output = _i1.ByteOutput(codec.sizeHint(this));
    codec.encodeTo(this, output);
    return output.toBytes();
  }

  int sizeHint() {
    return codec.sizeHint(this);
  }

  Map<String, List<int>> toJson();
}

class $Event {
  const $Event();

  ValidatorAdditionInitiated validatorAdditionInitiated(
      _i3.AccountId32 value0) {
    return ValidatorAdditionInitiated(value0);
  }

  ValidatorRemovalInitiated validatorRemovalInitiated(_i3.AccountId32 value0) {
    return ValidatorRemovalInitiated(value0);
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return ValidatorAdditionInitiated._decode(input);
      case 1:
        return ValidatorRemovalInitiated._decode(input);
      default:
        throw Exception('Event: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(
    Event value,
    _i1.Output output,
  ) {
    switch (value.runtimeType) {
      case ValidatorAdditionInitiated:
        (value as ValidatorAdditionInitiated).encodeTo(output);
        break;
      case ValidatorRemovalInitiated:
        (value as ValidatorRemovalInitiated).encodeTo(output);
        break;
      default:
        throw Exception(
            'Event: Unsupported "$value" of type "${value.runtimeType}"');
    }
  }

  @override
  int sizeHint(Event value) {
    switch (value.runtimeType) {
      case ValidatorAdditionInitiated:
        return (value as ValidatorAdditionInitiated)._sizeHint();
      case ValidatorRemovalInitiated:
        return (value as ValidatorRemovalInitiated)._sizeHint();
      default:
        throw Exception(
            'Event: Unsupported "$value" of type "${value.runtimeType}"');
    }
  }
}

/// New validator addition initiated. Effective in ~2 sessions.
class ValidatorAdditionInitiated extends Event {
  const ValidatorAdditionInitiated(this.value0);

  factory ValidatorAdditionInitiated._decode(_i1.Input input) {
    return ValidatorAdditionInitiated(const _i1.U8ArrayCodec(32).decode(input));
  }

  /// T::ValidatorId
  final _i3.AccountId32 value0;

  @override
  Map<String, List<int>> toJson() =>
      {'ValidatorAdditionInitiated': value0.toList()};

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      0,
      output,
    );
    const _i1.U8ArrayCodec(32).encodeTo(
      value0,
      output,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is ValidatorAdditionInitiated &&
          _i4.listsEqual(
            other.value0,
            value0,
          );

  @override
  int get hashCode => value0.hashCode;
}

/// Validator removal initiated. Effective in ~2 sessions.
class ValidatorRemovalInitiated extends Event {
  const ValidatorRemovalInitiated(this.value0);

  factory ValidatorRemovalInitiated._decode(_i1.Input input) {
    return ValidatorRemovalInitiated(const _i1.U8ArrayCodec(32).decode(input));
  }

  /// T::ValidatorId
  final _i3.AccountId32 value0;

  @override
  Map<String, List<int>> toJson() =>
      {'ValidatorRemovalInitiated': value0.toList()};

  int _sizeHint() {
    int size = 1;
    size = size + const _i3.AccountId32Codec().sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      1,
      output,
    );
    const _i1.U8ArrayCodec(32).encodeTo(
      value0,
      output,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is ValidatorRemovalInitiated &&
          _i4.listsEqual(
            other.value0,
            value0,
          );

  @override
  int get hashCode => value0.hashCode;
}
