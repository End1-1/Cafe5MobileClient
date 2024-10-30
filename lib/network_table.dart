import 'package:cafe5_mobile_client/socket_message.dart';

const datatype_int = 1;
const datatype_double = 2;
const datatype_string = 3;

class NetworkTable {
  int columnCount() {
    return strings.length;
  }

  int rowCount() {
    return data.length;
  }

  int selectedIndex = -1;
  List<int> dataTypes = [];
  List<dynamic> data = [];
  int _stringsCount = 0;
  List<String> strings = [];

  NetworkTable() {
    reset();
  }

  void reset() {
    _stringsCount = 0;
    dataTypes.clear();
    data.clear();
    strings.clear();
    selectedIndex = -1;
  }

  void readData(dynamic m) {
    data.clear();
    strings.clear();
    if (m == null) {
      return;
    }
    if (m.isNotEmpty) {
      Map<String, dynamic> f = m[0];
      strings.addAll(f.keys);
    }
    data.addAll(m);
  }

  void readStrings(SocketMessage m) {
    _stringsCount = m.getInt();
    for (int i = 0; i < _stringsCount; i++) {
      strings.add(m.getString());
    }
  }

  String columnName(int i) {
    return strings[i];
  }

  bool isEmpty() {
    return strings.isEmpty;
  }

  String getDisplayData(int r, int c) {
    final key = strings[c];
    final d = data[r][key];
    return d.toString();
  }

  dynamic getRawData(int r, int c) {
    final key = strings[c];
    final d = data[r][key];
    return d;
  }
}
