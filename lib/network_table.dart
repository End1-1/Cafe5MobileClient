import 'package:cafe5_mobile_client/socket_message.dart';

const datatype_int = 1;
const datatype_double = 2;
const datatype_string = 3;

class NetworkTable {
  int columnCount = 0;
  int rowCount = 0;
  int selectedIndex = -1;
  List<int> dataTypes = [];
  List<List<dynamic>> data = [];
  int _stringsCount = 0;
  List<String> strings = [];

  NetworkTable() {
    reset();
  }

  void reset() {
    columnCount = 0;
    rowCount = 0;
    _stringsCount = 0;
    dataTypes.clear();
    data.clear();
    strings.clear();
    selectedIndex = -1;
  }



  void readDataTypes(SocketMessage m) {
    for (int i = 0; i < columnCount; i++) {
      dataTypes.add(m.getByte());
    }
  }

  void readData(List<List<dynamic>> m) {
    data.clear();
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
    return strings.length == 0;
  }

  String getDisplayData(int r, int c) {
    switch (dataTypes[c]) {
      case datatype_int:
        return data[r][c].toString();
      case datatype_double:
        return data[r][c].toString();
      case datatype_string:
        return strings[data[r][c]];
    }
    return "Unknown";
  }

  dynamic getRawData(int r, int c) {
    switch (dataTypes[c]) {
      case datatype_int:
      case datatype_double:
        return data[r][c];
      case datatype_string:
        return strings[data[r][c]];
    }
    return "Unknown raw";
  }
}