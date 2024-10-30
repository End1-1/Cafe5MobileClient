import 'dart:typed_data';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:cafe5_mobile_client/class_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'base_widget.dart';
import 'package:cafe5_mobile_client/socket_message.dart';

import 'db.dart';
import 'network_table.dart';

class Storage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return StorageState();
  }
}

class StorageState extends BaseWidgetState<Storage> with TickerProviderStateMixin {

  List<ClassStorage> _storages = [];
  ClassStorage? _storage;
  bool _dataLoading = false;
  late AnimationController animationController;
  NetworkTable _networkTable = NetworkTable();

  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(() {
      setState(() {

      });
    });
    animationController.repeat(reverse: false);
    Db.query('storages').then((map) {
      List.generate(map.length, (i) {
        ClassStorage e = ClassStorage(
            id: map[i]['id'], name: map[i]["name"]);
        _storages.add(e);
      });
      animationController.stop();
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void handler(Uint8List data) {
    setState(() {
      _dataLoading = false;
    });
    SocketMessage m = SocketMessage(messageId: 0, command: 0);
    m.setBuffer(data);
    int dllok = m.getByte();
    switch (dllok) {
      case 0:
        sd(tr("Required dll not found on server."));
        break;
      case 1:
        sd(tr("Required dll function not found on server."));
        break;
      case 2:
        int dllop = m.getInt();
        int dlloperror = m.getByte();
        if (dlloperror == 0) {
          sd(m.getString());
          return;
        }
        switch (dllop) {
          case SocketMessage.op_save_process:
            Navigator.pop(context);
            break;
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Container (
                            color: Colors.amberAccent,
                            child: Align (
                              alignment: Alignment.center,
                              child: Text(tr("Material in the store"), style: TextStyle(fontSize: 22))
                            )
                          )
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(tr("Storage"), style: TextStyle(fontSize: 18),),
                      Expanded(child: Container()),
                      Container(
                          width: 300,
                          child: Autocomplete<ClassStorage>(
                            displayStringForOption: (option) => option.name,
                            optionsBuilder: (TextEditingValue t) {
                              return _storages.where((ClassStorage p) {
                                return p.name
                                    .toLowerCase()
                                    .startsWith(t.text.toLowerCase());
                              }).toList();
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted) {
                              return TextField(
                                controller: fieldTextEditingController,
                                focusNode: fieldFocusNode,
                              );
                            },
                            onSelected: (ClassStorage p) {
                              _storage = p;
                            },
                          ))
                    ],
                  ),
                  // Flexible(
                  //   flex: 1,
                  //     child: _dataLoading ? _bodyLoad() : _bodyData()
                  // )
                ]
            )
        )
    );
  }

  Widget _bodyLoad() {
    return Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator (
          value: animationController.value,
        )
    );
  }

  Widget _bodyData() {
    if (_networkTable.isEmpty()) {
      return Text(tr("No data"));
    }
    Map<int, double> colsWidths = {
      0:0, 1: 90, 2: 100, 3: 50, 4:50
    };
    List<DataColumn> cols = [];
    for (int i = 0; i < _networkTable.columnCount(); i++) {
      DataColumn dataCol = DataColumn(
          label: Container(
              width: colsWidths[i],
              child: Text(_networkTable.columnName(i)))
      );
      cols.add(dataCol);
    }
    List<DataRow> rows = [];
    for (int i = 0; i < _networkTable.rowCount(); i++) {
      List<DataCell> cells = [];
      for (int c = 0; c < _networkTable.columnCount(); c++) {
        DataCell cell = DataCell(Container(width: colsWidths[c], child:Text(_networkTable.getDisplayData(i, c))));
        cells.add(cell);
      }
      DataRow dr = DataRow(
          cells: cells,
          selected: i == _networkTable.selectedIndex,
          onSelectChanged:(val) {
            setState(() {
              _networkTable.selectedIndex = val! ? i : -1;
            });
          }
      );
      rows.add(dr);
    }
    DataTable dt = DataTable(
      columns: cols,
      rows: rows,
      dataRowColor: MaterialStateProperty.resolveWith(_getDataRowColor),
    );

    return SingleChildScrollView(
      child: SingleChildScrollView (
        child: dt,
        scrollDirection: Axis.horizontal,
      ),
      scrollDirection: Axis.vertical,
    );
  }

  void _loadData() {
    if (_storage == null) {
      return;
    }
    setState(() {
      _dataLoading = true;
    });
  }

  Color _getDataRowColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };

    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    } else if (states.contains(MaterialState.selected)) {
      return Colors.amberAccent;
    }
    return Colors.transparent;
  }
}