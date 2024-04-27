// ... other utility functions your project might need
List<int> toIntList(String data) {
  List<int> list = [];
  for (int i = 0; i < data.length; i++) {
    list.add(data.codeUnitAt(i));
  }
  return list;
}
