// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  /// The phone number is already registered
  phoneNumberAlreadyRegistered('PhoneNumberAlreadyRegistered', 0),

  /// The domain is already registered
  domainAlreadyRegistered('DomainAlreadyRegistered', 1),

  /// The phone number is not registered
  phoneNumberNotRegistered('PhoneNumberNotRegistered', 2),

  /// The domain is not registered
  domainNotRegistered('DomainNotRegistered', 3),

  /// The phone number is not spam
  phoneNumberNotSpam('PhoneNumberNotSpam', 4),

  /// The domain is not spam
  domainNotSpam('DomainNotSpam', 5),

  /// The phone number is spam
  phoneNumberSpam('PhoneNumberSpam', 6),

  /// The domain is spam
  domainSpam('DomainSpam', 7),

  /// The phone number is not reach threshold
  phoneNumberNotReachThreshold('PhoneNumberNotReachThreshold', 8);

  const Error(
    this.variantName,
    this.codecIndex,
  );

  factory Error.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ErrorCodec codec = $ErrorCodec();

  String toJson() => variantName;
  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ErrorCodec with _i1.Codec<Error> {
  const $ErrorCodec();

  @override
  Error decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return Error.phoneNumberAlreadyRegistered;
      case 1:
        return Error.domainAlreadyRegistered;
      case 2:
        return Error.phoneNumberNotRegistered;
      case 3:
        return Error.domainNotRegistered;
      case 4:
        return Error.phoneNumberNotSpam;
      case 5:
        return Error.domainNotSpam;
      case 6:
        return Error.phoneNumberSpam;
      case 7:
        return Error.domainSpam;
      case 8:
        return Error.phoneNumberNotReachThreshold;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(
    Error value,
    _i1.Output output,
  ) {
    _i1.U8Codec.codec.encodeTo(
      value.codecIndex,
      output,
    );
  }
}
