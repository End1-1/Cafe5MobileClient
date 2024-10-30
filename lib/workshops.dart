
import 'package:cafe5_mobile_client/app.dart';
import 'package:cafe5_mobile_client/class_workshop.dart';
import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/classes/prefs.dart';
import 'package:cafe5_mobile_client/db.dart';
import 'package:cafe5_mobile_client/network_table.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
import 'package:cafe5_mobile_client/the_task.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';

import 'config.dart';

class TheWorkshops extends App {
  List<ClassWorkshop> workshop = [];
  ClassWorkshop? _workshop;
  final _autoTextEditingController = TextEditingController();
  final _autoFocus = FocusNode();
  final _autoKey = GlobalKey();
  final NetworkTable _tw = NetworkTable();
  final NetworkTable _td = NetworkTable();

  TheWorkshops({super.key});

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      HttpQuery(route: 'rwlist').request({}).then((d) {
        for (final e in d['data']['workshop']) {
          workshop.add(ClassWorkshop(id: e['f_id'], name: e['f_name']));
        }
      });});
  }

  @override
  Widget body(BuildContext context) {
    return Column(
      children: [

        Visibility(
            visible: workshop.isNotEmpty,
            child: Container(
                padding: const EdgeInsets.all(5),
                color: Colors.black12,
                child: Row(children: [
                  Container(
                      margin: const EdgeInsets.only(right: 5),
                      child: Text(
                        tr("Workshop"),
                        style: const TextStyle(fontSize: 22),
                      )),
                  Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 5),
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
                              style: const TextStyle(fontSize: 18));
                        },
                        optionsViewBuilder: (BuildContext context,
                            AutocompleteOnSelected<ClassWorkshop> onSelected,
                            Iterable<ClassWorkshop> options) {
                          return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                child: Container(
                                    width: 300,
                                    height: 400,
                                    child: ListView.builder(
                                        itemCount: options.length,
                                        itemBuilder:
                                            (BuildContext context, int i) {
                                          final ClassWorkshop w =
                                              options.elementAt(i);
                                          return GestureDetector(
                                              onTap: () {
                                                onSelected(w);
                                              },
                                              child: ListTile(
                                                  title: Text(w.name)));
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
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            side: const BorderSide(color: Colors.transparent)),
                        child: Image.asset(
                          "images/delete.png",
                          width: 36,
                          height: 36,
                        ),
                        onPressed: () {
                          _autoTextEditingController.clear();

                        },
                      )),
                  Expanded(child: Container()),
                  SizedBox(
                      width: 36,
                      height: 36,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            side: const BorderSide(color: Colors.transparent)),
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
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(0),
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(0),
                    scrollDirection: Axis.horizontal,
                    child: _table())))
      ],
    );
  }

  List<Widget> _stages(int code) {
    List<int> rows = [];
    for (int i = 0; i < _td.rowCount(); i++) {
      if (_td.getRawData(i, 0) == code) {
        rows.add(i);
      }
    }
    List<Widget> s = [];
    s.add(Row(children: [
      Container(
          width: 120,
          child: Text(tr("Date"),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      Container(
          width: 300,
          child: Text(tr("Stage"),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      Container(
        width: 100,
        child: Text(tr("%"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      )
    ]));
    for (int i = 0; i < rows.length; i++) {
      Row r = Row(
        children: [
          Container(
              width: 120,
              child: Text(_td.getDisplayData(rows[i], 1),
                  style: const TextStyle(fontSize: 18))),
          Container(
              width: 300,
              child: Text(_td.getDisplayData(rows[i], 2),
                  style: const TextStyle(fontSize: 18))),
          Container(
            width: 100,
            child: Text(_td.getDisplayData(rows[i], 3),
                style: const TextStyle(fontSize: 18)),
          )
        ],
      );
      s.add(r);
    }
    return s;
  }

  Widget _tl2(int code) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                    prefs.context(),
                    MaterialPageRoute(
                        builder: (context) => TheTask(taskId: code)));
              },
              child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  color: Colors.black12,
                  height: 200,
                  width: 200,
                  child: Align(
                      alignment: Alignment.center,
                      child: Image.asset("images/dress.png")))),
          Column(children: _stages(code)),
        ]);
  }

  Widget _tl1(String code, String date, String qty, int taskid, String cmpt) {
    return Container(
        margin: const EdgeInsets.only(top: 5, bottom: 5),
        child: Container(
          color: const Color(0xffddeeaa),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    color: const Color(0xFFADBE76),
                    child: Column(children: [
                      Row(
                        children: [
                          Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 15),
                              child: Text(tr("Goods code"),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                          Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 15),
                              child: Text(tr("Date"),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                          Container(
                              width: 50,
                              margin: const EdgeInsets.only(right: 15),
                              child: const Text("Qty",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                          Container(
                              width: 50,
                              margin: const EdgeInsets.only(right: 15),
                              child: const Text("%",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                          Container(
                              width: 50,
                              margin: const EdgeInsets.only(right: 15),
                              child: const Text("Ready",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                          Container(
                              width: 50,
                              margin: const EdgeInsets.only(right: 15),
                              child: const Text("Out",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)))
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 15),
                              child: Text(code,
                                  style: const TextStyle(fontSize: 18))),
                          Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 15),
                              child: Text(date,
                                  style: const TextStyle(fontSize: 18))),
                          Container(
                              width: 50,
                              margin: const EdgeInsets.only(right: 15),
                              child: Text(qty,
                                  style: const TextStyle(fontSize: 18))),
                          Container(
                              width: 50,
                              margin: const EdgeInsets.only(right: 15),
                              child: Text("$cmpt%",
                                  style: const TextStyle(fontSize: 18))),
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
    for (int i = 0; i < _tw.rowCount(); i++) {
      ls.add(_tl1(
          _tw.getDisplayData(i, 2),
          _tw.getDisplayData(i, 3),
          _tw.getDisplayData(i, 4),
          int.tryParse(_tw.getRawData(i, 0).toString()) ?? 0,
          _tw.getDisplayData(i, 8)));
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
    // httpQuery('/engine/production/loadworkshop.php',
    //     .request({'workshop': id,
    //   'action':'rwmftasks',
    //   'actionid':SocketMessage.op_load_workshop,
    //   'id': id}).then((value) {
    //
    // });

  }
}
