// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

import '../frame_system/pallet/event.dart' as _i3;
import '../pallet_balances/pallet/event.dart' as _i7;
import '../pallet_collective/pallet/event.dart' as _i10;
import '../pallet_grandpa/pallet/event.dart' as _i6;
import '../pallet_session/pallet/event.dart' as _i5;
import '../pallet_sudo/pallet/event.dart' as _i9;
import '../pallet_template/pallet/event.dart' as _i11;
import '../pallet_transaction_payment/pallet/event.dart' as _i8;
import '../scbc/pallet/event.dart' as _i12;
import '../validator_set/pallet/event.dart' as _i4;

abstract class RuntimeEvent {
  const RuntimeEvent();

  factory RuntimeEvent.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $RuntimeEventCodec codec = $RuntimeEventCodec();

  static const $RuntimeEvent values = $RuntimeEvent();

  _i2.Uint8List encode() {
    final output = _i1.ByteOutput(codec.sizeHint(this));
    codec.encodeTo(this, output);
    return output.toBytes();
  }

  int sizeHint() {
    return codec.sizeHint(this);
  }

  Map<String, Map<String, dynamic>> toJson();
}

class $RuntimeEvent {
  const $RuntimeEvent();

  System system(_i3.Event value0) {
    return System(value0);
  }

  ValidatorSet validatorSet(_i4.Event value0) {
    return ValidatorSet(value0);
  }

  Session session(_i5.Event value0) {
    return Session(value0);
  }

  Grandpa grandpa(_i6.Event value0) {
    return Grandpa(value0);
  }

  Balances balances(_i7.Event value0) {
    return Balances(value0);
  }

  TransactionPayment transactionPayment(_i8.Event value0) {
    return TransactionPayment(value0);
  }

  Sudo sudo(_i9.Event value0) {
    return Sudo(value0);
  }

  Council council(_i10.Event value0) {
    return Council(value0);
  }

  TemplateModule templateModule(_i11.Event value0) {
    return TemplateModule(value0);
  }

  Scbc scbc(_i12.Event value0) {
    return Scbc(value0);
  }
}

class $RuntimeEventCodec with _i1.Codec<RuntimeEvent> {
  const $RuntimeEventCodec();

  @override
  RuntimeEvent decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return System._decode(input);
      case 2:
        return ValidatorSet._decode(input);
      case 3:
        return Session._decode(input);
      case 5:
        return Grandpa._decode(input);
      case 6:
        return Balances._decode(input);
      case 8:
        return TransactionPayment._decode(input);
      case 9:
        return Sudo._decode(input);
      case 10:
        return Council._decode(input);
      case 11:
        return TemplateModule._decode(input);
      case 12:
        return Scbc._decode(input);
      default:
        throw Exception('RuntimeEvent: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(
    RuntimeEvent value,
    _i1.Output output,
  ) {
    switch (value.runtimeType) {
      case System:
        (value as System).encodeTo(output);
        break;
      case ValidatorSet:
        (value as ValidatorSet).encodeTo(output);
        break;
      case Session:
        (value as Session).encodeTo(output);
        break;
      case Grandpa:
        (value as Grandpa).encodeTo(output);
        break;
      case Balances:
        (value as Balances).encodeTo(output);
        break;
      case TransactionPayment:
        (value as TransactionPayment).encodeTo(output);
        break;
      case Sudo:
        (value as Sudo).encodeTo(output);
        break;
      case Council:
        (value as Council).encodeTo(output);
        break;
      case TemplateModule:
        (value as TemplateModule).encodeTo(output);
        break;
      case Scbc:
        (value as Scbc).encodeTo(output);
        break;
      default:
        throw Exception(
            'RuntimeEvent: Unsupported "$value" of type "${value.runtimeType}"');
    }
  }

  @override
  int sizeHint(RuntimeEvent value) {
    switch (value.runtimeType) {
      case System:
        return (value as System)._sizeHint();
      case ValidatorSet:
        return (value as ValidatorSet)._sizeHint();
      case Session:
        return (value as Session)._sizeHint();
      case Grandpa:
        return (value as Grandpa)._sizeHint();
      case Balances:
        return (value as Balances)._sizeHint();
      case TransactionPayment:
        return (value as TransactionPayment)._sizeHint();
      case Sudo:
        return (value as Sudo)._sizeHint();
      case Council:
        return (value as Council)._sizeHint();
      case TemplateModule:
        return (value as TemplateModule)._sizeHint();
      case Scbc:
        return (value as Scbc)._sizeHint();
      default:
        throw Exception(
            'RuntimeEvent: Unsupported "$value" of type "${value.runtimeType}"');
    }
  }
}

class System extends RuntimeEvent {
  const System(this.value0);

  factory System._decode(_i1.Input input) {
    return System(_i3.Event.codec.decode(input));
  }

  /// frame_system::Event<Runtime>
  final _i3.Event value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'System': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      0,
      output,
    );
    _i3.Event.codec.encodeTo(
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
      other is System && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class ValidatorSet extends RuntimeEvent {
  const ValidatorSet(this.value0);

  factory ValidatorSet._decode(_i1.Input input) {
    return ValidatorSet(_i4.Event.codec.decode(input));
  }

  /// validator_set::Event<Runtime>
  final _i4.Event value0;

  @override
  Map<String, Map<String, List<int>>> toJson() =>
      {'ValidatorSet': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i4.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      2,
      output,
    );
    _i4.Event.codec.encodeTo(
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
      other is ValidatorSet && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Session extends RuntimeEvent {
  const Session(this.value0);

  factory Session._decode(_i1.Input input) {
    return Session(_i5.Event.codec.decode(input));
  }

  /// pallet_session::Event
  final _i5.Event value0;

  @override
  Map<String, Map<String, Map<String, int>>> toJson() =>
      {'Session': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i5.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      3,
      output,
    );
    _i5.Event.codec.encodeTo(
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
      other is Session && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Grandpa extends RuntimeEvent {
  const Grandpa(this.value0);

  factory Grandpa._decode(_i1.Input input) {
    return Grandpa(_i6.Event.codec.decode(input));
  }

  /// pallet_grandpa::Event
  final _i6.Event value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Grandpa': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i6.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      5,
      output,
    );
    _i6.Event.codec.encodeTo(
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
      other is Grandpa && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Balances extends RuntimeEvent {
  const Balances(this.value0);

  factory Balances._decode(_i1.Input input) {
    return Balances(_i7.Event.codec.decode(input));
  }

  /// pallet_balances::Event<Runtime>
  final _i7.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() =>
      {'Balances': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i7.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      6,
      output,
    );
    _i7.Event.codec.encodeTo(
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
      other is Balances && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class TransactionPayment extends RuntimeEvent {
  const TransactionPayment(this.value0);

  factory TransactionPayment._decode(_i1.Input input) {
    return TransactionPayment(_i8.Event.codec.decode(input));
  }

  /// pallet_transaction_payment::Event<Runtime>
  final _i8.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() =>
      {'TransactionPayment': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i8.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      8,
      output,
    );
    _i8.Event.codec.encodeTo(
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
      other is TransactionPayment && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Sudo extends RuntimeEvent {
  const Sudo(this.value0);

  factory Sudo._decode(_i1.Input input) {
    return Sudo(_i9.Event.codec.decode(input));
  }

  /// pallet_sudo::Event<Runtime>
  final _i9.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() =>
      {'Sudo': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i9.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      9,
      output,
    );
    _i9.Event.codec.encodeTo(
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
      other is Sudo && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Council extends RuntimeEvent {
  const Council(this.value0);

  factory Council._decode(_i1.Input input) {
    return Council(_i10.Event.codec.decode(input));
  }

  /// pallet_collective::Event<Runtime, pallet_collective::Instance1>
  final _i10.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() =>
      {'Council': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i10.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      10,
      output,
    );
    _i10.Event.codec.encodeTo(
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
      other is Council && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class TemplateModule extends RuntimeEvent {
  const TemplateModule(this.value0);

  factory TemplateModule._decode(_i1.Input input) {
    return TemplateModule(_i11.Event.codec.decode(input));
  }

  /// pallet_template::Event<Runtime>
  final _i11.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() =>
      {'TemplateModule': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i11.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      11,
      output,
    );
    _i11.Event.codec.encodeTo(
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
      other is TemplateModule && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Scbc extends RuntimeEvent {
  const Scbc(this.value0);

  factory Scbc._decode(_i1.Input input) {
    return Scbc(_i12.Event.codec.decode(input));
  }

  /// scbc::Event<Runtime>
  final _i12.Event value0;

  @override
  Map<String, Map<String, Map<String, List<int>>>> toJson() =>
      {'SCBC': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i12.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(
      12,
      output,
    );
    _i12.Event.codec.encodeTo(
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
      other is Scbc && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}
