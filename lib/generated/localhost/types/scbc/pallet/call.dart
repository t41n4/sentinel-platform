// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i3;

/// Contains a variant per dispatchable extrinsic that this pallet has.
abstract class Call {
  const Call();

  factory Call.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $CallCodec codec = $CallCodec();

  static const $Call values = $Call();

  _i2.Uint8List encode() {
    final output = _i1.ByteOutput(codec.sizeHint(this));
    codec.encodeTo(this, output);
    return output.toBytes();
  }

  int sizeHint() {
    return codec.sizeHint(this);
  }

  Map<String, Map<String, List<int>>> toJson();
}

class $Call {
  const $Call();

  RegisterPhoneNumber registerPhoneNumber({required List<int> phoneNumber}) {
    return RegisterPhoneNumber(phoneNumber: phoneNumber);
  }

  ReportSpam reportSpam({
    required List<int> spammee,
    required List<int> spammer,
    required List<int> reason,
  }) {
    return ReportSpam(
      spammee: spammee,
      spammer: spammer,
      reason: reason,
    );
  }

  MakeCall makeCall({
    required List<int> caller,
    required List<int> callee,
  }) {
    return MakeCall(
      caller: caller,
      callee: callee,
    );
  }
}

class $CallCodec with _i1.Codec<Call> {
  const $CallCodec();

  @override
  Call decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return RegisterPhoneNumber._decode(input);
      case 1:
        return ReportSpam._decode(input);
      case 3:
        return MakeCall._decode(input);
      default:
        throw Exception('Call: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(
    Call value,
    _i1.Output output,
  ) {
    switch (value.runtimeType) {
      case RegisterPhoneNumber:
        (value as RegisterPhoneNumber).encodeTo(output);
        break;
      case ReportSpam:
        (value as ReportSpam).encodeTo(output);
        break;
      case MakeCall:
        (value as MakeCall).encodeTo(output);
        break;
      default:
        throw Exception(
            'Call: Unsupported "$value" of type "${value.runtimeType}"');
    }
  }

  @override
  int sizeHint(Call value) {
    switch (value.runtimeType) {
      case RegisterPhoneNumber:
        return (value as RegisterPhoneNumber)._sizeHint();
      case ReportSpam:
        return (value as ReportSpam)._sizeHint();
      case MakeCall:
        return (value as MakeCall)._sizeHint();
      default:
        throw Exception(
            'Call: Unsupported "$value" of type "${value.runtimeType}"');
    }
  }
}

/// See `Pallet::register_phone_number`.
class RegisterPhoneNumber extends Call {
  const RegisterPhoneNumber({required this.phoneNumber});

  factory RegisterPhoneNumber._decode(_i1.Input input) {
    return RegisterPhoneNumber(
        phoneNumber: _i1.U8SequenceCodec.codec.decode(input));
  }

  /// PhoneNumber
  final List<int> phoneNumber;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
        'register_phone_number': {'phoneNumber': phoneNumber}
      };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(phoneNumber);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      0,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      phoneNumber,
      output,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is RegisterPhoneNumber &&
          _i3.listsEqual(
            other.phoneNumber,
            phoneNumber,
          );

  @override
  int get hashCode => phoneNumber.hashCode;
}

/// See `Pallet::report_spam`.
class ReportSpam extends Call {
  const ReportSpam({
    required this.spammee,
    required this.spammer,
    required this.reason,
  });

  factory ReportSpam._decode(_i1.Input input) {
    return ReportSpam(
      spammee: _i1.U8SequenceCodec.codec.decode(input),
      spammer: _i1.U8SequenceCodec.codec.decode(input),
      reason: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  /// PhoneNumber
  final List<int> spammee;

  /// PhoneNumber
  final List<int> spammer;

  /// Reason
  final List<int> reason;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
        'report_spam': {
          'spammee': spammee,
          'spammer': spammer,
          'reason': reason,
        }
      };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(spammee);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(spammer);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(reason);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      1,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      spammee,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      spammer,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      reason,
      output,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is ReportSpam &&
          _i3.listsEqual(
            other.spammee,
            spammee,
          ) &&
          _i3.listsEqual(
            other.spammer,
            spammer,
          ) &&
          _i3.listsEqual(
            other.reason,
            reason,
          );

  @override
  int get hashCode => Object.hash(
        spammee,
        spammer,
        reason,
      );
}

/// See `Pallet::make_call`.
class MakeCall extends Call {
  const MakeCall({
    required this.caller,
    required this.callee,
  });

  factory MakeCall._decode(_i1.Input input) {
    return MakeCall(
      caller: _i1.U8SequenceCodec.codec.decode(input),
      callee: _i1.U8SequenceCodec.codec.decode(input),
    );
  }

  /// PhoneNumber
  final List<int> caller;

  /// PhoneNumber
  final List<int> callee;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
        'make_call': {
          'caller': caller,
          'callee': callee,
        }
      };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(caller);
    size = size + _i1.U8SequenceCodec.codec.sizeHint(callee);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      3,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      caller,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      callee,
      output,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is MakeCall &&
          _i3.listsEqual(
            other.caller,
            caller,
          ) &&
          _i3.listsEqual(
            other.callee,
            callee,
          );

  @override
  int get hashCode => Object.hash(
        caller,
        callee,
      );
}
