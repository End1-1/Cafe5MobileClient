import 'dart:typed_data';

import 'package:cafe5_mobile_client/base_widget.dart';
import 'package:cafe5_mobile_client/screens/journal/screen.dart';
import 'package:cafe5_mobile_client/store.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/the_task.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:cafe5_mobile_client/network_table.dart';
import 'package:cafe5_mobile_client/db.dart';
import 'package:cafe5_mobile_client/workshops.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'client_socket.dart';

class WidgetHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WidgetHomeState();
  }
}

class WidgetHomeState extends BaseWidgetState with TickerProviderStateMixin, WidgetsBindingObserver {
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
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTasks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // went to Background
    }
    if (state == AppLifecycleState.resumed) {
      // came back to Foreground
      loadTasks();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void handler(Uint8List data) async {
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

            await Db.db!.transaction((txn) async {
              Batch b = txn.batch();
              b.delete("products");
              for (int i = 0; i < nt.rowCount; i++) {
                b.insert("products", {"id": nt.getRawData(i, 0), "name": nt.getRawData(i, 1)});
              }
              await b.commit();
            });


            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_processes);
            m.addString(Config.getString(key_database_name));
            sendSocketMessage(m);
            break;
          case SocketMessage.op_get_employes:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);
            await Db.db!.transaction((txn) async {
              Batch b = txn.batch();
              b.delete("employes");
              for (int i = 0; i < nt.rowCount; i++) {
                b.insert("employes", {"id":nt.getRawData(i, 0), "group_id": nt.getRawData(i, 1), "name": nt.getRawData(i, 2)});
              }
              await b.commit();
            });
            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_task_list);
            m.addString(Config.getString(key_database_name));
            sendSocketMessage(m);
            break;
          case SocketMessage.op_get_processes:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);
            await Db.db!.transaction((txn) async {
              Batch b = txn.batch();
              b.delete("processes");
              for (int i = 0; i < nt.rowCount; i++) {
                b.insert("processes", {"id": nt.getRawData(i, 0), "name": nt.getRawData(i, 1)});
              }
              await b.commit();
            });
            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_storage_list);
            m.addString(Config.getString(key_database_name));
            sendSocketMessage(m);
            break;
          case SocketMessage.op_get_storage_list:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);
            await Db.db!.transaction((txn) async {
              Batch b = txn.batch();
              b.delete("storages");
              for (int i = 0; i < nt.rowCount; i++) {
                b.insert("storages", {"id": nt.getRawData(i, 0), "name": nt.getRawData(i, 1)});
              }
              await b.commit();
            });

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_workshop_list);
            m.addString(Config.getString(key_database_name));
            sendSocketMessage(m);
            break;
          case SocketMessage.op_get_workshop_list:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);

            await Db.db!.transaction((txn) async {
              Batch b = txn.batch();
              b.delete("workshop");
              for (int i = 0; i < nt.rowCount; i++) {
                b.insert("workshop", {"id": nt.getRawData(i, 0), "name": nt.getRawData(i, 1)});
              }
              await b.commit();
            });

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_stages);
            m.addString(Config.getString(key_database_name));
            sendSocketMessage(m);
            break;
          case SocketMessage.op_get_stages:
            NetworkTable nt = NetworkTable();
            nt.readFromSocketMessage(m);

            await Db.db!.transaction((txn) async {
              Batch b = txn.batch();
              b.delete("stages");
              for (int i = 0; i < nt.rowCount; i++) {
                 b.insert("stages", {"id":nt.getRawData(i, 0), "name":nt.getRawData(i, 1)});
              }
              await b.commit();
            });

            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_get_employes);
            m.addString(Config.getString(key_database_name));
            sendSocketMessage(m);
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
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(
                        "ELINA ${Config.getString('appversion')}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      )))),
          Visibility(
              visible: _allDataLoaded,
              child: Container(
                  //color: Colors.green,
                  child: SizedBox(height: 40, child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      backgroundColor: Colors.blueGrey,
                      side: const BorderSide(
                        width: 1.0,
                        color: Colors.black38,
                        style: BorderStyle.solid,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => JournalScreen()));
                    },
                    child:   Text(tr("Journal"), style: const TextStyle(color: Colors.white)),
                  ),
                   OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        backgroundColor: Colors.blueGrey,
                        side: const BorderSide(
                          width: 1.0,
                          color: Colors.black38,
                          style: BorderStyle.solid,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TheTask(taskId: 0)));
                      },
                      child:   Text(tr("New task"), style: const TextStyle(color: Colors.white)),
                    )
                  , OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        backgroundColor: Colors.blueGrey,
                        side: const BorderSide(
                          width: 1.0,
                          color: Colors.black38,
                          style: BorderStyle.solid,
                        ),
                      ),
                      onPressed: () {
                        if (_networkTable.selectedIndex < 0) {
                          sd(tr("Select task"));
                          return;
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TheTask(taskId: _networkTable.getRawData(_networkTable.selectedIndex, 0)))).then((value) {
                          loadTasks();
                        });
                      },
                      child: Text(tr("Edit task"), style: TextStyle(color: Colors.white)),
                  ),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        backgroundColor: Colors.blueGrey,
                        side: const BorderSide(
                          width: 1.0,
                          color: Colors.black38,
                          style: BorderStyle.solid,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TheWorkshops()));
                      },
                      child: Text(tr("Workshops"), style: TextStyle(color: Colors.white)),
                  ),
                ],
              )))),
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
    sendSocketMessage(m);
  }
}
