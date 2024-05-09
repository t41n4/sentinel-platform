// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i3;

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

  Map<String, Map<String, List<int>>> toJson();
}

class $Event {
  const $Event();

  RegisterPhoneNumber registerPhoneNumber({required List<int> phoneNumber}) {
    return RegisterPhoneNumber(phoneNumber: phoneNumber);
  }

  RegiterDomain regiterDomain({required List<int> domain}) {
    return RegiterDomain(domain: domain);
  }

  ReportSPAM reportSPAM({
    required List<int> spammee,
    required List<int> spammer,
    required List<int> reason,
  }) {
    return ReportSPAM(
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

  MarkSpam markSpam({required List<int> phoneNumber}) {
    return MarkSpam(phoneNumber: phoneNumber);
  }
}

class $EventCodec with _i1.Codec<Event> {
  const $EventCodec();

  @override
  Event decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return RegisterPhoneNumber._decode(input);
      case 1:
        return RegiterDomain._decode(input);
      case 2:
        return ReportSPAM._decode(input);
      case 3:
        return MakeCall._decode(input);
      case 4:
        return MarkSpam._decode(input);
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
      case RegisterPhoneNumber:
        (value as RegisterPhoneNumber).encodeTo(output);
        break;
      case RegiterDomain:
        (value as RegiterDomain).encodeTo(output);
        break;
      case ReportSPAM:
        (value as ReportSPAM).encodeTo(output);
        break;
      case MakeCall:
        (value as MakeCall).encodeTo(output);
        break;
      case MarkSpam:
        (value as MarkSpam).encodeTo(output);
        break;
      default:
        throw Exception(
            'Event: Unsupported "$value" of type "${value.runtimeType}"');
    }
  }

  @override
  int sizeHint(Event value) {
    switch (value.runtimeType) {
      case RegisterPhoneNumber:
        return (value as RegisterPhoneNumber)._sizeHint();
      case RegiterDomain:
        return (value as RegiterDomain)._sizeHint();
      case ReportSPAM:
        return (value as ReportSPAM)._sizeHint();
      case MakeCall:
        return (value as MakeCall)._sizeHint();
      case MarkSpam:
        return (value as MarkSpam)._sizeHint();
      default:
        throw Exception(
            'Event: Unsupported "$value" of type "${value.runtimeType}"');
    }
  }
}

class RegisterPhoneNumber extends Event {
  const RegisterPhoneNumber({required this.phoneNumber});

  factory RegisterPhoneNumber._decode(_i1.Input input) {
    return RegisterPhoneNumber(
        phoneNumber: _i1.U8SequenceCodec.codec.decode(input));
  }

  /// PhoneNumber
  final List<int> phoneNumber;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
        'RegisterPhoneNumber': {'phoneNumber': phoneNumber}
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

class RegiterDomain extends Event {
  const RegiterDomain({required this.domain});

  factory RegiterDomain._decode(_i1.Input input) {
    return RegiterDomain(domain: _i1.U8SequenceCodec.codec.decode(input));
  }

  /// StatusType
  final List<int> domain;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
        'RegiterDomain': {'domain': domain}
      };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(domain);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      1,
      output,
    );
    _i1.U8SequenceCodec.codec.encodeTo(
      domain,
      output,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is RegiterDomain &&
          _i3.listsEqual(
            other.domain,
            domain,
          );

  @override
  int get hashCode => domain.hashCode;
}

class ReportSPAM extends Event {
  const ReportSPAM({
    required this.spammee,
    required this.spammer,
    required this.reason,
  });

  factory ReportSPAM._decode(_i1.Input input) {
    return ReportSPAM(
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
        'ReportSPAM': {
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
      2,
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
      other is ReportSPAM &&
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

class MakeCall extends Event {
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
        'MakeCall': {
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

class MarkSpam extends Event {
  const MarkSpam({required this.phoneNumber});

  factory MarkSpam._decode(_i1.Input input) {
    return MarkSpam(phoneNumber: _i1.U8SequenceCodec.codec.decode(input));
  }

  /// PhoneNumber
  final List<int> phoneNumber;

  @override
  Map<String, Map<String, List<int>>> toJson() => {
        'MarkSpam': {'phoneNumber': phoneNumber}
      };

  int _sizeHint() {
    int size = 1;
    size = size + _i1.U8SequenceCodec.codec.sizeHint(phoneNumber);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      4,
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
      other is MarkSpam &&
          _i3.listsEqual(
            other.phoneNumber,
            phoneNumber,
          );

  @override
  int get hashCode => phoneNumber.hashCode;
}
