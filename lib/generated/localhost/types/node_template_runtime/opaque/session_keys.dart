// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i4;

import 'package:polkadart/scale_codec.dart' as _i1;

import '../../sp_consensus_aura/sr25519/app_sr25519/public.dart' as _i2;
import '../../sp_consensus_grandpa/app/public.dart' as _i3;

class SessionKeys {
  const SessionKeys({
    required this.aura,
    required this.grandpa,
  });

  factory SessionKeys.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// <Aura as $crate::BoundToRuntimeAppPublic>::Public
  final _i2.Public aura;

  /// <Grandpa as $crate::BoundToRuntimeAppPublic>::Public
  final _i3.Public grandpa;

  static const $SessionKeysCodec codec = $SessionKeysCodec();

  _i4.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, List<int>> toJson() => {
        'aura': aura.toList(),
        'grandpa': grandpa.toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(
        this,
        other,
      ) ||
      other is SessionKeys && other.aura == aura && other.grandpa == grandpa;

  @override
  int get hashCode => Object.hash(
        aura,
        grandpa,
      );
}

class $SessionKeysCodec with _i1.Codec<SessionKeys> {
  const $SessionKeysCodec();

  @override
  void encodeTo(
    SessionKeys obj,
    _i1.Output output,
  ) {
    const _i1.U8ArrayCodec(32).encodeTo(
      obj.aura,
      output,
    );
    const _i1.U8ArrayCodec(32).encodeTo(
      obj.grandpa,
      output,
    );
  }

  @override
  SessionKeys decode(_i1.Input input) {
    return SessionKeys(
      aura: const _i1.U8ArrayCodec(32).decode(input),
      grandpa: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  @override
  int sizeHint(SessionKeys obj) {
    int size = 0;
    size = size + const _i2.PublicCodec().sizeHint(obj.aura);
    size = size + const _i3.PublicCodec().sizeHint(obj.grandpa);
    return size;
  }
}
