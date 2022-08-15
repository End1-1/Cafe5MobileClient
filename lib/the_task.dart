import 'dart:typed_data';

import 'package:cafe5_mobile_client/base_widget.dart';
import 'package:cafe5_mobile_client/class_workshop.dart';
import 'package:cafe5_mobile_client/db.dart';
import 'package:cafe5_mobile_client/network_table.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
import 'package:cafe5_mobile_client/the_task_process.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'class_product.dart';
import 'class_stages.dart';
import 'client_socket.dart';
import 'config.dart';

class TheTask extends StatefulWidget {
  int taskId;

  TheTask({required this.taskId});

  @override
  State<StatefulWidget> createState() {
    return TheTaskState();
  }
}

class TheTaskState extends BaseWidgetState<TheTask> {
  List<Product> products = [];
  List<ClassWorkshop> workshop = [];
  List<ClassStage> stages = [];
  late TextEditingController _productQtyTextController;
  NetworkTable _processTable = new NetworkTable();
  Product? _product;
  ClassWorkshop? _workshop;
  ClassStage? _stage;
  String _dateCreated = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String _timeCreated = DateFormat('HH:mm').format(DateTime.now());
  bool _dataLoading = false;

  @override
  void handler(Uint8List data) {
    _dataLoading = false;
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
          case SocketMessage.op_create_task:
            widget.taskId = m.getInt();
            _loadTask(widget.taskId);
            break;
          case SocketMessage.op_load_task:
            setState(() {
              _dateCreated = m.getString();
              _timeCreated = m.getString();
              _productQtyTextController.text = m.getDouble().toString();
              _product = Product(id: 0, name: m.getString());
              _workshop = _workshopById(m.getInt());
              _stage = _stageById(m.getInt());
              int processok = m.getByte();
              if (processok == 0) {
                return;
              }
              _processTable.readFromSocketMessage(m);
            });
            break;
          case SocketMessage.op_set_workshop:
            setState(() {
              _workshop = _workshopById(m.getInt());
            });
            break;
          case SocketMessage.op_set_state:
            setState(() {
              _stage = _stageById(m.getInt());
            });
            break;
        }
        break;
    }
  }

  @override
  void initState() {
    _productQtyTextController = TextEditingController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Db.query('workshop').then((map) {
        List.generate(map.length, (i) {
          ClassWorkshop p = ClassWorkshop(id: map[i]['id'], name: map[i]["name"]);
          workshop.add(p);
        });
        Db.query('stages').then((map) {
          List.generate(map.length, (i) {
            ClassStage p = ClassStage(id: map[i]['id'], name: map[i]["name"]);
            stages.add(p);
          });
          if (widget.taskId == 0) {
            Db.query('products').then((map) {
              List.generate(map.length, (i) {
                Product p = Product(id: map[i]['id'], name: map[i]["name"]);
                products.add(p);
              });
            });
          } else {
            _product = Product(id: 0, name: "...");
            _loadTask(widget.taskId);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Container(
            margin: EdgeInsets.all(5),
            child: Row(children: [
              Text(
                widget.taskId == 0
                    ? tr("New task")
                    : _product == null
                        ? "..."
                        : _product!.name,
                style: TextStyle(fontSize: 22),
              ),
              Expanded(child: Container()),
              Container(
                  width: 150,
                  child: widget.taskId == 0
                      ? Autocomplete<Product>(
                          displayStringForOption: (option) => option.name,
                          optionsBuilder: (TextEditingValue t) {
                            return products.where((Product p) {
                              return p.name.toLowerCase().startsWith(t.text.toLowerCase());
                            }).toList();
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                            return TextField(
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                            );
                          },
                          onSelected: (Product p) {
                            _product = p;
                          },
                        )
                      : Text(""))
            ])),
        Container(
            margin: EdgeInsets.all(5),
            child: Row(children: [
              Text(
                tr("Workshop"),
                style: TextStyle(fontSize: 22),
              ),
              Expanded(child: Container()),
              Container(
                  width: 150,
                  child: Autocomplete<ClassWorkshop>(
                    displayStringForOption: (option) => option.name,
                    optionsBuilder: (TextEditingValue t) {
                      return workshop.where((ClassWorkshop p) {
                        return p.name.toLowerCase().startsWith(t.text.toLowerCase());
                      }).toList();
                    },
                    fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: fieldTextEditingController..text = (_workshop == null ? "" : _workshop?.name)!,
                        focusNode: fieldFocusNode,
                      );
                    },
                    onSelected: (ClassWorkshop p) {
                      if (widget.taskId > 0) {
                        sq(tr("Change workshop?"), () {
                          SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
                          m.addString("rwmftasks");
                          m.addInt(SocketMessage.op_set_workshop);
                          m.addString(Config.getString(key_database_name));
                          m.addInt(widget.taskId);
                          m.addInt(p.id);
                          ClientSocket.send(m.data());
                        }, () {});
                      } else {
                        _workshop = p;
                      }
                    },
                  ))
            ])),
        Container(
            margin: EdgeInsets.all(5),
            child: Row(children: [
              Text(
                tr("Stage"),
                style: TextStyle(fontSize: 22),
              ),
              Expanded(child: Container()),
              Container(width: 150, child: Text(_stage == null ? "?" : _stage!.name, style: TextStyle(fontSize: 18)))
            ])),
        Container(
            margin: EdgeInsets.all(5),
            child: Row(
              children: [
                Text(tr("Date created")),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(_dateCreated),
                ),
                Expanded(child: Container()),
                Text(tr("Time created")),
                Container(margin: EdgeInsets.only(left: 5), child: Text(_timeCreated))
              ],
            )),
        Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: [
                Text(tr("Total qty")),
                Container(margin: EdgeInsets.only(left: 5), width: 100, child: TextFormField(readOnly: widget.taskId > 0, keyboardType: TextInputType.number, controller: _productQtyTextController, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly])),
                Expanded(child: Container()),
                widget.taskId == 0
                    ? TextButton(onPressed: _createTask, child: Text(tr("Create")))
                    : Row(
                        children: [
                          TextButton(child: Text(tr("Activate state")), onPressed: _activateState),
                          TextButton(child: Text(tr("Execute")), onPressed: _executeProcess),
                        ],
                      )
              ],
            )),
        LinearPercentIndicator(
          //leaner progress bar
          animation: true,
          animationDuration: 1000,
          lineHeight: 20.0,
          percent: 0.3,
          center: Text(
            "30%",
            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          linearStrokeCap: LinearStrokeCap.roundAll,
          progressColor: Colors.blue[400],
          backgroundColor: Colors.grey[300],
        ),
        Flexible(flex: 1, child: _listOfProcesses())
      ],
    )));
  }

  Widget _listOfProcesses() {
    if (widget.taskId == 0) {
      return Text(tr("Please, create new task"));
    }
    if (_processTable.isEmpty()) {
      return Text(tr("Empty process"));
    }
    Map<int, double> colw = {0: 0, 1: 100, 2: 200, 3: 0, 4: 50, 5: 50, 6: 50};
    List<DataColumn> columns = [];
    for (int i = 0; i < _processTable.columnCount; i++) {
      DataColumn dataColumn = DataColumn(label: colw[i] == 0 ? Container() : Container(width: colw[i], child: Text(_processTable.columnName(i))));
      columns.add(dataColumn);
    }
    List<DataRow> rows = [];
    for (int i = 0; i < _processTable.rowCount; i++) {
      List<DataCell> cells = [];
      for (int c = 0; c < _processTable.columnCount; c++) {
        DataCell dc = DataCell(colw[c] == 0 ? Container() : Container(width: colw[c], child: Text(_processTable.getDisplayData(i, c))));
        cells.add(dc);
      }
      DataRow dr = DataRow(
          cells: cells,
          selected: i == _processTable.selectedIndex,
          onSelectChanged: (val) {
            setState(() {
              _processTable.selectedIndex = val! ? i : -1;
            });
          });
      rows.add(dr);
    }
    DataTable dt = DataTable(
      columns: columns,
      rows: rows,
      dataRowColor: MaterialStateProperty.resolveWith(_getDataRowColor),
    );
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(scrollDirection: Axis.vertical, child: dt));
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

  void _createTask() {
    if (_product == null) {
      sd(tr("Product is not selected"));
      return;
    }
    if (_workshop == null) {
      sd(tr("Workshop is not selected"));
      return;
    }
    if (_stage == null) {
      sd(tr("Stage is not selected"));
      return;
    }
    double? qty = double.tryParse(_productQtyTextController.text);
    if (qty == null || qty < 0.1) {
      sd(tr("Input right quantity"));
      return;
    }
    SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
    m.addString("rwmftasks");
    m.addInt(SocketMessage.op_create_task);
    m.addString(Config.getString(key_database_name));
    m.addInt(_product!.id);
    m.addDouble(qty);
    m.addInt(_workshop!.id);
    m.addInt(_stage!.id);
    ClientSocket.send(m.data());
  }

  void _loadTask(int id) {
    setState(() {
      _dataLoading = true;
    });
    SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
    m.addString("rwmftasks");
    m.addInt(SocketMessage.op_load_task);
    m.addString(Config.getString(key_database_name));
    m.addInt(id);
    ClientSocket.send(m.data());
  }

  void _activateState() {
    if (_processTable.selectedIndex < 0) {
      sd(tr("Nothing selected"));
      return;
    }
    sq(tr("Change current state?"), () {
      SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
      m.addString("rwmftasks");
      m.addInt(SocketMessage.op_set_state);
      m.addString(Config.getString(key_database_name));
      m.addInt(widget.taskId);
      m.addInt(_processTable.getRawData(_processTable.selectedIndex, 0));
      ClientSocket.send(m.data());
    }, () {});
  }

  void _executeProcess() {
    if (_processTable.selectedIndex < 0) {
      sd(tr("Nothing selected"));
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TheTaskProcess(taskId: widget.taskId,
              processId: _processTable.getRawData(_processTable.selectedIndex, 0),
              processName: _processTable.getRawData(_processTable.selectedIndex, 1),
              price: double.tryParse(_processTable.getRawData(_processTable.selectedIndex, 3).toString())!),
        ));
  }

  ClassWorkshop? _workshopById(int id) {
    for (ClassWorkshop w in workshop) {
      if (w.id == id) {
        return w;
      }
    }
    return null;
  }

  ClassStage? _stageById(int id) {
    for (ClassStage w in stages) {
      if (w.id == id) {
        return w;
      }
    }
    return null;
  }
}
