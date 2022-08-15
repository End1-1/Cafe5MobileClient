import 'dart:typed_data';

import 'package:cafe5_mobile_client/base_widget.dart';
import 'package:cafe5_mobile_client/store.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/the_task.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:cafe5_mobile_client/network_table.dart';
import 'package:cafe5_mobile_client/db.dart';
import 'package:cafe5_mobile_client/workshops.dart';
import 'package:flutter/material.dart';

import 'client_socket.dart';

class WidgetHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WidgetHomeState();
  }
}

class WidgetHomeState extends BaseWidgetState with TickerProviderStateMixin {
  bool _dataLoading = false;
  bool _dataError = false;
  bool _allDataLoaded = false;
  NetworkTable _networkTable = NetworkTable();
  late String _dataErrorString;
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: false);
    loadTasks();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void handler(Uint8List data) {
    _dataLoading = false;
    SocketMessage m = SocketMessage(messageId: 0, command: 0);
    m.setBuffer(data);
    int dllok = m.getByte();
    switch (dllok) {
      case 0:
        setState(() {
          _dataErrorString = "Required dll not found on server.";
          _dataError = true;
        });
        break;
      case 1:
        setState(() {
          _dataErrorString = "Required dll function not found on server.";
          _dataError = true;
        });
        break;
      case 2:
        int dllop = m.getInt();
        int dlloperror = m.getByte();
        if (dlloperror == 0) {
          _dataError = true;
          _dataErrorString = m.getString();
          return;
        }
        switch (dllop) {
          case SocketMessage.op_get_task_list:
            _networkTable.reset();
            _networkTable.columnCount = m.getShort();
            _networkTable.rowCount = m.getInt();
            _networkTable.readDataTypes(m);
            _networkTable.readData(m);
            _networkTable.readStrings(m);
            setState(() {
              _allDataLoaded = true;
            });
            break;
          case SocketMessage.op_get_products:
            NetworkTable nt = NetworkTable();
            nt.columnCount = m.getShort();
            nt.rowCount = m.getInt();
            nt.readDataTypes(m);
            nt.readData(m);
            nt.readStrings(m);

            Db.delete("delete from products");
            for (int i = 0; i < nt.rowCount; i++) {
              Db.insert("insert into products (id, name) values (?,?)", [nt.getRawData(i, 0), nt.getRawData(i, 1)]);
            }

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_processes);
            m.addString(Config.getString(key_database_name));
            ClientSocket.send(m.data());
            break;
          case SocketMessage.op_get_employes:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);
            Db.delete("delete from employes");
            for (int i = 0; i < nt.rowCount; i++) {
              Db.insert("insert into employes (id, group_id, name) values (?,?,?)", [nt.getRawData(i, 0), nt.getRawData(i, 1), nt.getRawData(i, 2)]);
            }

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_task_list);
            m.addString(Config.getString(key_database_name));
            ClientSocket.send(m.data());
            break;
          case SocketMessage.op_get_processes:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);
            Db.delete("delete from processes");
            for (int i = 0; i < nt.rowCount; i++) {
              Db.insert("insert into processes (id, name) values (?,?)", [nt.getRawData(i, 0), nt.getRawData(i, 1)]);
            }

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_storage_list);
            m.addString(Config.getString(key_database_name));
            ClientSocket.send(m.data());
            break;
          case SocketMessage.op_get_storage_list:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);
            Db.delete("delete from storages");
            for (int i = 0; i < nt.rowCount; i++) {
              Db.insert("insert into storages (id, name) values (?,?)", [nt.getRawData(i, 0), nt.getRawData(i, 1)]);
            }

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_workshop_list);
            m.addString(Config.getString(key_database_name));
            ClientSocket.send(m.data());
            break;
          case SocketMessage.op_get_workshop_list:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);
            Db.delete("delete from workshop");
            for (int i = 0; i < nt.rowCount; i++) {
              Db.insert("insert into workshop (id, name) values (?,?)", [nt.getRawData(i, 0), nt.getRawData(i, 1)]);
            }

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_stages);
            m.addString(Config.getString(key_database_name));
            ClientSocket.send(m.data());
            break;
          case SocketMessage.op_get_stages:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);
            Db.delete("delete from stages");
            for (int i = 0; i < nt.rowCount; i++) {
              Db.insert("insert into stages (id, name) values (?,?)", [nt.getRawData(i, 0), nt.getRawData(i, 1)]);
            }

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_employes);
            m.addString(Config.getString(key_database_name));
            ClientSocket.send(m.data());
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
                //mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          Container(
              color: Colors.yellow,
              child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(
                        "ELINA",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      )))),
          Visibility(
              visible: _allDataLoaded,
              child: Container(
                  color: Colors.green,
                  child: Row(
                    children: [
                      Expanded(
                          child: Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TheTask(taskId: 0)));
                          },
                          child: Text(tr("New task")),
                        ),
                      )),
                      Expanded(
                          child: Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            if (_networkTable.selectedIndex < 0) {
                              sd(tr("Select task"));
                              return;
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TheTask(taskId: _networkTable.getRawData(_networkTable.selectedIndex, 0))));
                          },
                          child: Text(tr("Edit task")),
                        ),
                      )),
                      Expanded(
                          child: Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TheWorkshops()));
                          },
                          child: Text(tr("Workshops")),
                        ),
                      ))
                    ],
                  ))),
          // Container (
          //     color: Colors.green,
          //     child : Align(
          //       alignment: Alignment.center,
          //       child: TextButton(
          //         onPressed: () {
          //           sd("Error in create store document");
          //         },
          //         child: Text(tr("New store document")),
          //       ),
          //     )
          // ),
          // Container (
          //     color: Colors.green,
          //     child : Align(
          //       alignment: Alignment.center,
          //       child: TextButton(
          //         onPressed: () {
          //           Navigator.push(context, MaterialPageRoute(builder: (context) => Storage()));
          //         },
          //         child: Text(tr("Material in the store")),
          //       ),
          //     )
          // ),
          Container(
            color: Colors.black12,
            child: Align(
              alignment: Alignment.center,
              child: Text(tr("Current tasks")),
            ),
          ),
          Flexible(flex: 1, child: _dataLoading ? _mainIndicator() : (_dataError ? _errorBody() : _mainBody()))
        ])));
  }

  Widget _mainIndicator() {
    return Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          value: animationController.value,
        ));
  }

  Widget _errorBody() {
    return Align(child: TextButton(onPressed: loadTasks, child: Text(_dataErrorString + "\r\n" + tr("Error loading tasks. Click to try again."))));
  }

  Widget _mainBody() {
    if (_networkTable.isEmpty()) {
      return Text(tr("No data"));
    }
    Map<int, double> colsWidths = {0: 0, 1: 90, 2: 100, 3: 50, 4: 50};
    List<DataColumn> cols = [];
    for (int i = 0; i < _networkTable.columnCount; i++) {
      DataColumn dataCol = DataColumn(label: Container(width: colsWidths[i], child: Text(_networkTable.columnName(i))));
      cols.add(dataCol);
    }
    List<DataRow> rows = [];
    for (int i = 0; i < _networkTable.rowCount; i++) {
      List<DataCell> cells = [];
      for (int c = 0; c < _networkTable.columnCount; c++) {
        DataCell cell = DataCell(Container(width: colsWidths[c], child: Text(_networkTable.getDisplayData(i, c))));
        cells.add(cell);
      }
      DataRow dr = DataRow(
          cells: cells,
          selected: i == _networkTable.selectedIndex,
          onSelectChanged: (val) {
            setState(() {
              _networkTable.selectedIndex = val! ? i : -1;
            });
          });
      rows.add(dr);
    }
    DataTable dt = DataTable(
      columns: cols,
      rows: rows,
      dataRowColor: MaterialStateProperty.resolveWith(_getDataRowColor),
    );

    return SingleChildScrollView(
      child: SingleChildScrollView(
        child: dt,
        scrollDirection: Axis.horizontal,
      ),
      scrollDirection: Axis.vertical,
    );
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

  void loadTasks() async {
    setState(() {
      _dataErrorString = "Unknown error";
      _dataError = false;
      _dataLoading = true;
    });
    SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
    m.addString("rwmftasks");
    m.addInt(SocketMessage.op_get_products);
    m.addString(Config.getString(key_database_name));
    ClientSocket.send(m.data());
  }
}
