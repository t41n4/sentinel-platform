// ... other utility functions your project might need
List<int> toIntList(String data) {
  List<int> list = [];
  for (int i = 0; i < data.length; i++) {
    list.add(data.codeUnitAt(i));
  }
  return list;
}

String unitAbbreviationConverter(dynamic value) {
  final oneUnit = BigInt.from(1000000000);
  final milionUnit = oneUnit * BigInt.from(1000000);
  final microUnit = BigInt.from(oneUnit / BigInt.from(1000));

  final bigInt = BigInt.parse(value.toString());

  //micro Unit
  if (bigInt < oneUnit) {
    return '${bigInt / microUnit} micro Unit';
  }

  // MUnit
  if (bigInt >= milionUnit) {
    return '${(bigInt / milionUnit).toStringAsFixed(3)} MUnit';
  }

  return bigInt.toString();
}

// 0x516c013b75a60c0354bdba683da0d00d042962dc7e70d8682e008427ece4af6a -> 0x516c013b75...ece4af6a
String stringAbbreviationConverter(String str) {
  if (str.length > 10) {
    return '${str.substring(0, 10)}...${str.substring(str.length - 8)}';
  }
  return str;
}

const MUnit = 1000000000000;
const Unit = 1000000;
