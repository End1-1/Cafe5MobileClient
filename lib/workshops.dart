import 'dart:typed_data';

import 'package:cafe5_mobile_client/base_widget.dart';
import 'package:cafe5_mobile_client/class_workshop.dart';
import 'package:cafe5_mobile_client/db.dart';
import 'package:cafe5_mobile_client/network_table.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
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

class TheWorkshopsState extends BaseWidgetState<TheWorkshops> {
  List<ClassWorkshop> workshop = [];
  ClassWorkshop? _workshop;
  bool _dataLoading = false;
  NetworkTable _tw = NetworkTable();
  NetworkTable _td = NetworkTable();

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
            m = SocketMessage(messageId: SocketMessage.messageNumber(),  command: SocketMessage.c_dllop);
            m.addString("rwmftasks");
            m.addInt(SocketMessage.op_load_workshop_detail);
            m.addString(Config.getString(key_database_name));
            m.addInt(_workshop!.id);
            ClientSocket.send(m.data());
            break;
          case SocketMessage.op_load_workshop_detail:
            setState((){
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
    Db.query('workshop').then((map) {
      List.generate(map.length, (i) {
        ClassWorkshop p = ClassWorkshop(id: map[i]['id'], name: map[i]["name"]);
        workshop.add(p);
      });
      setState(() {

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
                        tr("Workshop"),
                        style: TextStyle(fontSize: 22),
                      ),
                      Expanded(child: Container()),
                      Visibility (
                        visible: workshop.length > 0,
                        child: Container(
                          width: 150,
                          child: Autocomplete<ClassWorkshop>(
                            displayStringForOption: (option) => option.name,
                            optionsBuilder: (TextEditingValue t) {
                              return workshop.where((ClassWorkshop p) {
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
                            onSelected: (ClassWorkshop p) {
                              _workshop = p;
                              _loadTWorkshop(_workshop!.id);
                            },
                          ))
                      )
                    ])),
                SingleChildScrollView(
                  child: SingleChildScrollView (
                    child : _table()
                  )
                )
              ],
            )
        )
    );
  }

  List<Widget> _stages(int code) {
    List<int> rows = [];
    for (int i = 0; i < _td.rowCount; i++) {
      if (_td.getRawData(i, 0) == code) {
        rows.add(i);
      }
    }
    List<Widget> s = [];
    s.add(Row(
        children: [
        Container(
          width: 120,
          child: Text(tr("Date"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
        ),
        Container(
            width: 300,
            child: Text(tr("Stage"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
        ),
        Container(
          width: 100,
          child: Text(tr("%"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        )
        ]
    ));
    for (int i = 0; i < rows.length; i++) {
      Row r = Row(
        children: [
          Container(
            width: 120,
            child: Text(_td.getDisplayData(rows[i], 1), style: TextStyle(fontSize: 18))
          ),
          Container(
            width: 300,
            child: Text(_td.getDisplayData(rows[i], 2), style: TextStyle(fontSize: 18))
          ),
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
    return Row (
      children: [
        Container(
          color: Colors.black12,
          height: 200,
          width: 200,
          child: Expanded(child: Align(alignment: Alignment.center, child: Text("IMAGE")))
        ),
        Column (
         children: _stages(code)
        ),
    ]
    );
  }

  Widget _tl1(String code, String date, String qty, int taskid) {
    return Column(
      children: [
        Row(
          children: [
            Container(
                width: 200,
                margin: EdgeInsets.only(right: 15),
                child: Text(tr("Goods code"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),
            Container(
                width: 120,
                margin: EdgeInsets.only(right: 15),
                child: Text(tr("Date"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),
            Container(
                width: 50,
                margin: EdgeInsets.only(right: 15),
                child: Text("Qty", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),
            Container(
                width: 50,
                margin: EdgeInsets.only(right: 15),
                child: Text("%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            )
          ],
        ),
        Row(
          children: [
            Container(
              width: 200,
              margin: EdgeInsets.only(right: 15),
              child: Text(code, style: TextStyle(fontSize: 18))
            ),
            Container(
              width: 120,
              margin: EdgeInsets.only(right: 15),
              child: Text(date, style: TextStyle(fontSize: 18))
            ),
            Container(
              width: 50,
              margin: EdgeInsets.only(right: 15),
              child: Text(qty, style: TextStyle(fontSize: 18))
            ),
            Container(
                width: 50,
                margin: EdgeInsets.only(right: 15),
                child: Text("0%", style: TextStyle(fontSize: 18))
            )
          ],
        ),
        _tl2(taskid),
        Container(
          height: 70,
        )
      ],
    );
  }

  Widget _table() {
    if (_tw.isEmpty()) {
      return (Text(tr("No data")));
    }

    ListView lv = ListView.builder(
      itemCount: _tw.rowCount,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return _tl1(_tw.getDisplayData(index, 2), _tw.getDisplayData(index, 3), _tw.getDisplayData(index, 4), int.tryParse(_tw.getRawData(index, 0).toString()) ?? 0);
      });

    return lv;
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
    SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(),  command: SocketMessage.c_dllop);
    m.addString("rwmftasks");
    m.addInt(SocketMessage.op_load_workshop);
    m.addString(Config.getString(key_database_name));
    m.addInt(id);
    ClientSocket.send(m.data());
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
