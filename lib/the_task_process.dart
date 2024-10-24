import 'dart:io';
import 'dart:typed_data';

import 'package:cafe5_mobile_client/base_widget.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'class_employee.dart';
import 'config.dart';
import 'db.dart';

class TheTaskProcess extends StatefulWidget {
  int taskId;
  int processId;
  String processName;
  double price;

  TheTaskProcess({required this.taskId, required this.processId, required this.processName, required this.price});

  @override
  State<StatefulWidget> createState() {
    return TheTaskProcessState();
  }
}

class TheTaskProcessState extends BaseWidgetState<TheTaskProcess> {
  List<Employee> _employes = [];
  Employee? _employee;
  TextEditingController _processQtyTextController = TextEditingController();

  @override
  void handler(Uint8List data) {
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
  void initState() {
    Db.query('employes').then((map) {
      List.generate(map.length, (i) {
        Employee e = Employee(id: map[i]['id'], group: map[i]['group_id'], name: map[i]["name"]);
        _employes.add(e);
      });
    });
    // Db.query('processes').then((map) {
    //   List.generate(map.length, (i) {
    //     MfProcess p = MfProcess(id: map[i]['id'], name: map[i]["name"]);
    //     _processes.add(p);
    //   });
    // });
    super.initState();
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
                child: Container(
                    color: Colors.amberAccent,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          tr("Completed action"),
                          style: TextStyle(fontSize: 22),
                        ))))
          ],
        ),
        Row(
          children: [
            Text(
              tr("Employee"),
              style: TextStyle(fontSize: 18),
            ),
            Expanded(child: Container()),
            Container(
                width: 300,
                child: Autocomplete<Employee>(
                  displayStringForOption: (option) => option.name,
                  optionsBuilder: (TextEditingValue t) {
                    return _employes.where((Employee p) {
                      return p.name.toLowerCase().startsWith(t.text.toLowerCase());
                    }).toList();
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                    );
                  },
                  onSelected: (Employee p) {
                    _employee = p;
                  },
                ))
          ],
        ),
        Row(
          children: [
            Text(
              tr("Process"),
              style: TextStyle(fontSize: 18),
            ),
            Expanded(child: Container()),
            Container(width: 300, child: Text(widget.processName, style: TextStyle(fontSize: 18)))
          ],
        ),
        Row(
          children: [
            Text(
              tr("Price"),
              style: TextStyle(fontSize: 18),
            ),
            Expanded(child: Container()),
            Container(width: 300, child: Text(widget.price.toString(), style: TextStyle(fontSize: 18)))
          ],
        ),
        Row(
          children: [
            Text(
              tr("Quantity"),
              style: TextStyle(fontSize: 18),
            ),
            Expanded(child: Container()),
            Container(width: 200, child: TextFormField(keyboardType: TextInputType.number, controller: _processQtyTextController, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]))
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                  child: Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        child: Text(
                          tr("Save"),
                          style: TextStyle(fontSize: 22),
                        ),
                        onPressed: _save,
                      ))),
            )
          ],
        )
      ],
    )));
  }

  void _save() {
    if (_employee == null) {
      sd(tr("Select employee"));
      return;
    }
    double? qty = double.tryParse(_processQtyTextController.text);
    if (qty == null || qty < 0.1) {
      sd(tr("Input right quantity"));
      return;
    }

    SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_dllop);
    m.addString("rwmftasks");
    m.addInt(SocketMessage.op_save_process);
    m.addString(Config.getString(key_database_name));
    m.addInt(widget.taskId);
    m.addInt(widget.processId);
    m.addInt(_employee!.id);
    m.addDouble(qty);
    m.addDouble(widget.price);
    m.addString(DateFormat("dd/MM/yyyy").format(DateTime.now()));
    sendSocketMessage(m);
  }
}
