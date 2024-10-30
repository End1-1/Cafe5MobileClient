import 'dart:async';
import 'dart:convert';

import 'package:cafe5_mobile_client/app.dart';
import 'package:cafe5_mobile_client/base_widget.dart';
import 'package:cafe5_mobile_client/class_outlinedbutton.dart';
import 'package:cafe5_mobile_client/class_workshop.dart';
import 'package:cafe5_mobile_client/classes/bloc.dart';
import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/classes/prefs.dart';
import 'package:cafe5_mobile_client/db.dart';
import 'package:cafe5_mobile_client/network_table.dart';
import 'package:cafe5_mobile_client/screens/work_details/screen.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
import 'package:cafe5_mobile_client/the_task_process.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'class_product.dart';
import 'class_stages.dart';
import 'config.dart';

class TheTask extends App {
  int taskId;
  final _detailsStream = StreamController();
  List<Product> products = [];
  List<ClassWorkshop> workshop = [];
  List<ClassStage> stages = [];
  bool _showNotes = false;
  final _productQtyTextController = TextEditingController();
  final _pinController = TextEditingController();
  final NetworkTable _processTable = new NetworkTable();
  Product? _product;
  ClassWorkshop? _workshop;
  ClassStage? _stage;
  String _dateCreated = DateFormat('dd/MM/yyyy').format(DateTime.now());
  String _timeCreated = DateFormat('HH:mm').format(DateTime.now());
  num _totalpercent = 0.0;
  num _outQty = 0.0;
  num _readyQty = 0.0;

  TextEditingController _autoTextEditingController1 = TextEditingController();
  FocusNode _autoFocus1 = FocusNode();
  GlobalKey _autoKey1 = GlobalKey();

  TextEditingController _autoTextEditingController2 = TextEditingController();
  FocusNode _autoFocus2 = FocusNode();
  GlobalKey _autoKey2 = GlobalKey();
  final Map<String, TextEditingController> _notesCotroller = {
    tr("Color"): TextEditingController(),
    tr("Width"): TextEditingController(),
    tr("Height"): TextEditingController(),
    tr("Length"): TextEditingController()
  };

  TheTask({required this.taskId}) {
    init();
  }


  void init() {
    HttpQuery(route: 'rwlist').request({}).then((d) {
      for (final e in d['data']['workshop']) {
        workshop.add(ClassWorkshop(id: e['f_id'], name: e['f_name']));
      }
      for (final e in d['data']['stages']) {
        stages.add(ClassStage(id: e['f_id'], name: e['f_name']));
      }
      if (taskId == 0){
        _product = Product(id: 0, name: '...');
          for (final e in d['data']['product']) {
            products.add(Product(id: e['f_id'], name: e['f_name']));
          }
      } else {
        _product = Product(id: 0, name: '...');
        _loadTask(taskId);
      }
      BlocProvider.of<AppBloc>(prefs.context()).add(AppEvent());
    });
  }

  @override
  Widget body(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(listener: (context, state) {
      if (state is AppStateTaskWindows) {
        switch (state.cmd) {
          case SocketMessage.op_create_task:
            taskId = state.data["id"];
            _loadTask(taskId);
            break;
          case SocketMessage.op_load_task:
            _dateCreated = state.data['task']['f_datecreate'];
            _timeCreated = state.data['task']['f_timecreate'];
            _productQtyTextController.text = '${state.data['task']['f_qty']}';
            _product = Product(id: 0, name: state.data['task']['f_productname']);
            _workshop = _workshopById(state.data['task']['f_workshop']);
            _stage = _stageById(state.data['task']['f_stage']);
            _readyQty = state.data['task']['f_ready'];
            _outQty = state.data['task']['f_out'] ?? 0;
            String notes = state.data['task']['notes'] ?? '';
            try {
              Map<String, dynamic> notesJson = jsonDecode(notes);
              notesJson.forEach((key, value) {
                if (_notesCotroller.containsKey(key)) {
                  _notesCotroller[key]!.text = value;
                }
              });
            } catch (e) {
              print('CANNOT PARSE NOTES $e');
            }

            _processTable.readData(state.data['description']);
            double d1 = 0, d2 = 0;
            for (int i = 0; i < _processTable.rowCount(); i++) {
              d1 += _processTable.getRawData(i, 5);
              d2 += double.tryParse(_processTable.getRawData(i, 6)) ?? 0;
            }
            _totalpercent = 100 * (d2 / d1);

            break;
          case SocketMessage.op_set_workshop:
            _workshop = _workshopById(state.data['workshopid']);

            break;
          case SocketMessage.op_set_state:
            _stage = _stageById(state.data['stateid']);

            break;
          case SocketMessage.op_save_task_notes:
            _showNotes = false;

            break;
        }
      }
    }, builder: (builder, state) {
      return SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                      visible: taskId > 0,
                      child: Container(
                          width: double.infinity,
                          color: Colors.black12,
                          padding: const EdgeInsets.all(5),
                          child: Text(_product == null ? "..." : _product!.name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)))),
                  Visibility(
                      visible: taskId == 0,
                      child: Container(
                          color: Colors.black12,
                          padding: const EdgeInsets.all(5),
                          child: Row(children: [
                            Text(tr("New task")),
                            Expanded(child: Container()),
                            Container(
                                width: 300,
                                child: RawAutocomplete<Product>(
                                  textEditingController:
                                      _autoTextEditingController1,
                                  key: _autoKey1,
                                  focusNode: _autoFocus1,
                                  displayStringForOption: (option) =>
                                      option.name,
                                  optionsBuilder: (TextEditingValue t) {
                                    return products.where((Product p) {
                                      return p.name
                                          .toLowerCase()
                                          .contains(t.text.toLowerCase());
                                    }).toList();
                                  },
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          fieldTextEditingController,
                                      FocusNode fieldFocusNode,
                                      VoidCallback onFieldSubmitted) {
                                    return TextField(
                                      controller: fieldTextEditingController,
                                      focusNode: fieldFocusNode,
                                    );
                                  },
                                  optionsViewBuilder: (BuildContext context,
                                      AutocompleteOnSelected<Product>
                                          onSelected,
                                      Iterable<Product> options) {
                                    return Align(
                                        alignment: Alignment.topLeft,
                                        child: Material(
                                          child: SizedBox(
                                              width: 300,
                                              height: 400,
                                              child: ListView.builder(
                                                  itemCount: options.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int i) {
                                                    final Product w =
                                                        options.elementAt(i);
                                                    return GestureDetector(
                                                        onTap: () {
                                                          onSelected(w);
                                                        },
                                                        child: ListTile(
                                                            title:
                                                                Text(w.name)));
                                                  })),
                                        ));
                                  },
                                  onSelected: (Product p) {
                                    _product = p;
                                  },
                                )),
                          ]))),

                  //WORKSHOP
                  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xABABABEA)),
                          color: const Color(0xEAD9D9D9)),
                      padding: const EdgeInsets.all(5),
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Text(
                                tr("Workshop"),
                                style: const TextStyle(fontSize: 22),
                              )),
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        tr("Stage"),
                                        style: const TextStyle(fontSize: 22),
                                      ))),
                            ]),
                            Row(children: [
                              Expanded(
                                  child: Row(children: [
                                Expanded(
                                    child: RawAutocomplete<ClassWorkshop>(
                                  textEditingController:
                                      _autoTextEditingController2,
                                  key: _autoKey2,
                                  focusNode: _autoFocus2,
                                  displayStringForOption: (option) =>
                                      option.name,
                                  optionsBuilder: (TextEditingValue t) {
                                    return workshop.where((ClassWorkshop p) {
                                      return p.name
                                          .toLowerCase()
                                          .startsWith(t.text.toLowerCase());
                                    }).toList();
                                  },
                                  fieldViewBuilder: (BuildContext context,
                                      TextEditingController
                                          fieldTextEditingController,
                                      FocusNode fieldFocusNode,
                                      VoidCallback onFieldSubmitted) {
                                    return TextFormField(
                                      controller: fieldTextEditingController
                                        ..text = (_workshop == null
                                            ? ""
                                            : _workshop?.name)!,
                                      focusNode: fieldFocusNode,
                                    );
                                  },
                                  optionsViewBuilder: (BuildContext context,
                                      AutocompleteOnSelected<ClassWorkshop>
                                          onSelected,
                                      Iterable<ClassWorkshop> options) {
                                    return Align(
                                        alignment: Alignment.topLeft,
                                        child: Material(
                                          child: Container(
                                              width: 300,
                                              height: 400,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: options.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int i) {
                                                    final ClassWorkshop w =
                                                        options.elementAt(i);
                                                    return GestureDetector(
                                                        onTap: () {
                                                          onSelected(w);
                                                        },
                                                        child: ListTile(
                                                            title:
                                                                Text(w.name)));
                                                  })),
                                        ));
                                  },
                                  onSelected: (ClassWorkshop p) {
                                    if (taskId > 0) {
                                      sq(tr("Change workshop?"), () {
                                        httpQuery(
                                            '/engine/elinaworkshop/index.php',
                                            AppStateTaskWindows(
                                                SocketMessage.op_set_workshop),
                                            {
                                              'action': 'rwmtasks',
                                              'actionid':
                                                  SocketMessage.op_set_workshop,
                                              'taskid': taskId,
                                              'pid': p.id
                                            });
                                      }, () {});
                                    } else {
                                      _workshop = p;
                                    }
                                  },
                                )),
                                taskId == 0
                                    ? Container()
                                    : ClassOutlinedButton.createImage(() {
                                        _autoTextEditingController2.clear();
                                      }, "images/delete.png", w: 24, h: 24)
                              ])),
                              Expanded(
                                  child: Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      child: Text(
                                          _stage == null ? "?" : _stage!.name,
                                          style:
                                              const TextStyle(fontSize: 18))))
                            ]),
                          ])),

                  Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Container(
                                  padding: const EdgeInsets.all(5),
                                  child: Text(tr("Date created")),
                                )),
                                Expanded(
                                    child: Container(
                                  padding: const EdgeInsets.all(5),
                                  //decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), color: Colors.white),
                                  child: Text(tr("Total qty")),
                                ))
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      //decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), color: Colors.white),
                                      child:
                                          Text("$_dateCreated $_timeCreated")),
                                ),
                                Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      //decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), color: Colors.white),
                                      child: TextFormField(
                                          decoration: const InputDecoration(
                                              //border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10),
                                              //Change this value to custom as you like
                                              isDense: true,
                                              // and add this line
                                              hintText: 'User Name',
                                              hintStyle: TextStyle(
                                                color: Color(0xFFF00),
                                              )),
                                          readOnly: taskId > 0,
                                          keyboardType: TextInputType.number,
                                          controller: _productQtyTextController,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ])),
                                )
                              ],
                            )
                          ])),

                  //DETAILS
                  Divider(),
                  Row(children: [
                    Text(tr('Details')),
                    Expanded(child: Container()),
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => WorkDetailsScreen(
                                        _product!.name,
                                        0,
                                        taskId,
                                      ))).then((value) {
                            _loadTask(taskId);
                          });
                        },
                        child: Image.asset(
                          'images/new.png',
                          width: 30,
                          height: 30,
                        )),
                    const SizedBox(width: 10)
                  ]),
                  StreamBuilder(
                      stream: _detailsStream.stream,
                      builder: (builder, snapshot) {
                        return Container();
                      }),
                  Divider(),

                  Container(
                    color: Colors.indigo,
                      padding: const EdgeInsets.all(5),
                      child: taskId == 0
                          ? TextButton(
                              onPressed: _createTask, child: Text(tr("Create"), style: const TextStyle(color: Colors.white),))
                          : Row(
                              children: [
                                Expanded(
                                    child: TextButton(
                                        onPressed: _doShowNotes,
                                        child: Text(tr("Notes")))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: _activateState,
                                        child: Text(tr("Activate state")))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: _executeProcess,
                                        child: Text(tr("Execute")))),
                              ],
                            )),

                  AnimatedContainer(
                      height: _showNotes ? 400 : 0,
                      padding: const EdgeInsets.all(5),
                      duration: const Duration(milliseconds: 500),
                      child: SingleChildScrollView(
                          child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _notesCotroller.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          return index < _notesCotroller.length
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                        child: Text(_notesCotroller.keys
                                            .elementAt(index))),
                                    Expanded(
                                        child: TextFormField(
                                            controller: _notesCotroller.values
                                                .elementAt(index)))
                                  ],
                                )
                              : TextButton(
                                  onPressed: _doSaveNotes,
                                  child: Text(tr("Save")));
                        },
                      ))),

                  Row(children: [Expanded(child:
                  LinearPercentIndicator(
                    //leaner progress bar
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20.0,
                    percent: (_totalpercent / 100.0).isNaN? 0 :_totalpercent / 100.0 ,

                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.blue[400],
                    backgroundColor: Colors.grey[300],
                    center: Text(
                      "${_totalpercent.toStringAsFixed(1)}%",
                      style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ))]),
                  Expanded(child: _listOfProcesses()),
                ],
              )));
    });
  }

  Widget _listOfProcesses() {
    if (taskId == 0) {
      return Text(tr("Please, create new task"));
    }
    if (_processTable.isEmpty()) {
      return Text(tr("Empty process"));
    }
    Map<int, double> colw = {0: 0, 1: 100, 2: 200, 3: 0, 4: 50, 5: 50, 6: 50};
    List<DataColumn> columns = [];
    for (int i = 0; i < _processTable.columnCount(); i++) {
      DataColumn dataColumn = DataColumn(
          label: colw[i] == 0
              ? Container()
              : Container(
                  width: colw[i], child: Text(_processTable.columnName(i))));
      columns.add(dataColumn);
    }
    List<DataRow> rows = [];
    for (int i = 0; i < _processTable.rowCount(); i++) {
      List<DataCell> cells = [];
      for (int c = 0; c < _processTable.columnCount(); c++) {
        DataCell dc = DataCell(colw[c] == 0
            ? Container()
            : Container(
                width: colw[c],
                child: Text(_processTable.getDisplayData(i, c))));
        cells.add(dc);
      }
      DataRow dr = DataRow(
          cells: cells,
          selected: i == _processTable.selectedIndex,
          onSelectChanged: (val) {
            //NOTIFY WIDGET
            _processTable.selectedIndex = val! ? i : -1;
          });
      rows.add(dr);
    }
    DataTable dt = DataTable(
      columns: columns,
      rows: rows,
      dataRowColor: MaterialStateProperty.resolveWith(_getDataRowColor),
    );
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:
            SingleChildScrollView(scrollDirection: Axis.vertical, child: dt));
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
    double? qty = double.tryParse(_productQtyTextController.text);
    if (qty == null || qty < 0.1) {
      sd(tr("Input right quantity"));
      return;
    }
    httpQuery('rwcreatetask',
        AppStateTaskWindows(SocketMessage.op_create_task), {
      'action': 'rmwtasks',
      'actionid': SocketMessage.op_create_task,
      'productid': _product!.id,
      'qty': qty,
      'workshopid': _workshop!.id,
      'stage': _stage == null ? 0 : _stage?.id
    });
  }

  void _loadTask(int id) {
    httpQuery('rwloadtask',
        AppStateTaskWindows(SocketMessage.op_load_task), {
      'action': 'rwmftasks',
      'actionid': SocketMessage.op_load_task,
      'id': id
    });
  }

  void _activateState() {
    if (_processTable.selectedIndex < 0) {
      sd(tr("Nothing selected"));
      return;
    }
    sq(tr("Change current state?"), () {
      httpQuery('/engine/elinaworkshop/index.php',
          AppStateTaskWindows(SocketMessage.op_set_state), {
        'action': 'rwmfasks',
        'actionid': SocketMessage.op_set_state,
        'taskid': taskId,
        'processid': _processTable.getRawData(_processTable.selectedIndex, 0)
      });
    }, () {});
  }

  void _executeProcess() {
    if (_processTable.selectedIndex < 0) {
      sd(tr("Nothing selected"));
      return;
    }
    Navigator.push(
        prefs.context(),
        MaterialPageRoute(
          builder: (context) => TheTaskProcess(
              taskId: taskId,
              processId:
                  _processTable.getRawData(_processTable.selectedIndex, 0),
              processName:
                  _processTable.getRawData(_processTable.selectedIndex, 1),
              price: double.tryParse(_processTable
                  .getRawData(_processTable.selectedIndex, 3)
                  .toString())!),
        )).then((value) {
      _loadTask(taskId);
    });
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

  void _doShowNotes() {
//STATE
      _showNotes = !_showNotes;

  }

  void _doSaveNotes() {
    if (!_showNotes) {
      return;
    }
    httpQuery('/engine/elinaworkshop/index.php', AppStateLoginSuccess(),
        {'pin': _pinController.text, 'method': 1});
    // _showNotes = false;
    // SocketMessage m = SocketMessage(
    //     messageId: SocketMessage.messageNumber(),
    //     command: SocketMessage.c_dllop);
    // m.addString("rwmftasks");
    // m.addInt(SocketMessage.op_save_task_notes);
    // m.addString(Config.getString(key_database_name));
    // m.addInt(widget.taskId);
    // Map<String, String> vals = Map();
    // _notesCotroller.forEach((key, value) {
    //   vals[key] = value.text;
    // });
    // m.addString(jsonEncode(vals));
    // sendSocketMessage(m);
  }
}
