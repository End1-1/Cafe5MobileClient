import 'dart:typed_data';

import 'package:cafe5_mobile_client/base_widget.dart';
import 'package:cafe5_mobile_client/class_workshop.dart';
import 'package:cafe5_mobile_client/db.dart';
import 'package:cafe5_mobile_client/network_table.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
import 'package:cafe5_mobile_client/the_task.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'client_socket.dart';
import 'config.dart';

class TheWorkshops extends StatefulWidget {
  TheWorkshops();

  @override
  State<StatefulWidget> createState() {
    return TheWorkshopsState();
  }
}

class TheWorkshopsState extends BaseWidgetState<TheWorkshops> with TickerProviderStateMixin {
  List<ClassWorkshop> workshop = [];
  ClassWorkshop? _workshop;
  bool _dataLoading = false;
  NetworkTable _tw = NetworkTable();
  NetworkTable _td = NetworkTable();
  late AnimationController animationController;
  TextEditingController _autoTextEditingController = TextEditingController();
  FocusNode _autoFocus = FocusNode();
  GlobalKey _autoKey = GlobalKey();

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
          case SocketMessage.op_load_workshop:
            _tw.readFromSocketMessage(m);
            m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_load_workshop_detail);
            m.addString(Config.getString(key_database_name));
            m.addInt(_workshop!.id);
            sendSocketMessage(m);
            break;
          case SocketMessage.op_load_workshop_detail:
            setState(() {
              _td.readFromSocketMessage(m);
            });
            break;
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      workshop.clear();
      Db.query('workshop').then((map) {
        List.generate(map.length, (i) {
          ClassWorkshop p = ClassWorkshop(id: map[i]['id'], name: map[i]["name"]);
          workshop.add(p);
        });
        setState(() {
          animationController.stop();
        });
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Visibility(
            visible: workshop.length == 0,
            child: Container(
                margin: EdgeInsets.only(top: 10),
                child: Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: animationController.value,
                    )))),
        Visibility(
            visible: workshop.length > 0,
            child: Container(
                padding: EdgeInsets.all(5),
                color: Colors.black12,
                child: Row(children: [
                  Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Text(
                        tr("Workshop"),
                        style: TextStyle(fontSize: 22),
                      )),
                  Container(
                      width: 200,
                      margin: EdgeInsets.only(right: 5),
                      child: RawAutocomplete<ClassWorkshop>(
                        textEditingController: _autoTextEditingController,
                        focusNode: _autoFocus,
                        key: _autoKey,
                        displayStringForOption: (option) => option.name,
                        optionsBuilder: (TextEditingValue t) {
                          // if (t.text.isEmpty) {
                          //   return List.filled(0, ClassWorkshop(id: 0, name: ""));
                          // }
                          return workshop.where((ClassWorkshop p) {
                            return p.name.toLowerCase().startsWith(t.text.toLowerCase());
                          }).toList();
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                          return TextField(controller: fieldTextEditingController, focusNode: fieldFocusNode, style: TextStyle(fontSize: 18));
                        },
                        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<ClassWorkshop> onSelected, Iterable<ClassWorkshop> options) {
                          return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                child: Container(
                                    width: 300,
                                    height: 400,
                                    child: ListView.builder(
                                        itemCount: options.length,
                                        itemBuilder: (BuildContext context, int i) {
                                          final ClassWorkshop w = options.elementAt(i);
                                          return GestureDetector(
                                              onTap: () {
                                                onSelected(w);
                                              },
                                              child: ListTile(title: Text(w.name)));
                                        })),
                              ));
                        },
                        onSelected: (ClassWorkshop w) {
                          _workshop = w;
                          _loadTWorkshop(w.id);
                        },
                      )),
                  SizedBox(
                      width: 36,
                      height: 36,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(padding: EdgeInsets.all(0), side: BorderSide(color: Colors.transparent)),
                        child: Image.asset(
                          "images/delete.png",
                          width: 36,
                          height: 36,
                        ),
                        onPressed: () {
                          _autoTextEditingController.clear();
                          setState(() {
                            _td = NetworkTable();
                            _tw = NetworkTable();
                          });
                        },
                      )),
                  Expanded(child: Container()),
                  SizedBox(
                      width: 36,
                      height: 36,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(padding: EdgeInsets.all(0), side: BorderSide(color: Colors.transparent)),
                        child: Image.asset(
                          "images/refresh.png",
                          width: 36,
                          height: 36,
                        ),
                        onPressed: () {
                          if (_workshop != null) {
                            _loadTWorkshop(_workshop!.id);
                          }
                        },
                      )),
                ]))),
        Expanded(child: SingleChildScrollView(padding: EdgeInsets.all(0), child: SingleChildScrollView(padding: EdgeInsets.all(0), scrollDirection: Axis.horizontal, child: _table())))
      ],
    )));
  }

  List<Widget> _stages(int code) {
    List<int> rows = [];
    for (int i = 0; i < _td.rowCount; i++) {
      if (_td.getRawData(i, 0) == code) {
        rows.add(i);
      }
    }
    List<Widget> s = [];
    s.add(Row(children: [
      Container(width: 120, child: Text(tr("Date"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      Container(width: 300, child: Text(tr("Stage"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      Container(
        width: 100,
        child: Text(tr("%"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      )
    ]));
    for (int i = 0; i < rows.length; i++) {
      Row r = Row(
        children: [
          Container(width: 120, child: Text(_td.getDisplayData(rows[i], 1), style: TextStyle(fontSize: 18))),
          Container(width: 300, child: Text(_td.getDisplayData(rows[i], 2), style: TextStyle(fontSize: 18))),
          Container(
            width: 100,
            child: Text(_td.getDisplayData(rows[i], 3), style: TextStyle(fontSize: 18)),
          )
        ],
      );
      s.add(r);
    }
    return s;
  }

  Widget _tl2(int code) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
       GestureDetector(
         onTap: ()
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => TheTask(taskId: code)));
    }
         ,
           child: Container(margin: EdgeInsets.only(right: 15), color: Colors.black12, height: 200, width: 200,
          child: Align(
              alignment: Alignment.center,
              child: Image.asset("images/dress.png")))),
      Column(children: _stages(code)),
    ]);
  }

  Widget _tl1(String code, String date, String qty, int taskid, String cmpt) {
    return Container(
        margin: EdgeInsets.only(top: 5, bottom: 5),
        child: Container(
          color: Color(0xffddeeaa),
          child: Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                color: Color(0xFFADBE76),
                child: Column(children: [
                  Row(
                    children: [
                      Container(width: 200, margin: EdgeInsets.only(right: 15), child: Text(tr("Goods code"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Container(width: 120, margin: EdgeInsets.only(right: 15), child: Text(tr("Date"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Container(width: 50, margin: EdgeInsets.only(right: 15), child: Text("Qty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Container(width: 50, margin: EdgeInsets.only(right: 15), child: Text("%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
                    ],
                  ),
                  Row(
                    children: [
                      Container(width: 200, margin: EdgeInsets.only(right: 15), child: Text(code, style: TextStyle(fontSize: 18))),
                      Container(width: 120, margin: EdgeInsets.only(right: 15), child: Text(date, style: TextStyle(fontSize: 18))),
                      Container(width: 50, margin: EdgeInsets.only(right: 15), child: Text(qty, style: TextStyle(fontSize: 18))),
                      Container(width: 50, margin: EdgeInsets.only(right: 15), child: Text("$cmpt%", style: TextStyle(fontSize: 18))),
                    ],
                  )
                ])),
            Container(
              height: 10,
            ),
            _tl2(taskid),
            Container(
              height: 70,
            ),
          ]),
        ));
  }

  List<Widget> _tl1s() {
    List<Widget> ls = [];
    for (int i = 0; i < _tw.rowCount; i++) {
      ls.add(_tl1(_tw.getDisplayData(i, 2), _tw.getDisplayData(i, 3), _tw.getDisplayData(i, 4), int.tryParse(_tw.getRawData(i, 0).toString()) ?? 0, _tw.getDisplayData(i, 8)));
    }
    return ls;
  }

  Widget _table() {
    if (_tw.isEmpty()) {
      return (Text(tr("No data")));
    }

    return Column(children: _tl1s());
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

  void _loadTWorkshop(int id) {
    setState(() {
      _dataLoading = true;
    });
    SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
    m.addString("rwmftasks");
    m.addInt(SocketMessage.op_load_workshop);
    m.addString(Config.getString(key_database_name));
    m.addInt(id);
    sendSocketMessage(m);
  }

  ClassWorkshop? _workshopById(int id) {
    for (ClassWorkshop w in workshop) {
      if (w.id == id) {
        return w;
      }
    }
    return null;
  }
}