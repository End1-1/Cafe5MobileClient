import 'dart:async';

import 'package:cafe5_mobile_client/class_employee.dart';
import 'package:cafe5_mobile_client/screens/appheader/appheader.dart';
import 'package:cafe5_mobile_client/screens/employes/model.dart';
import 'package:cafe5_mobile_client/screens/structs/employee.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';

class TeamleadScreen extends StatelessWidget {
  final streamController = StreamController<String?>();

  @override
  Widget build(BuildContext context) {
    return AppHeader(
        tr('Teamlead'),
        Column(children: [
          Row(
            children: [
              Container(
                  width: MediaQuery.sizeOf(context).width * .98,
                  child: TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      prefix: Container(margin: const EdgeInsets.fromLTRB(0, 0, 5, 0), child: Image.asset("images/search.png", height: 20, width: 20,))
                    ),
                    onChanged: (v) {
                      streamController.add(v);
                    },
                  ))
            ],
          ),
          Expanded(child: StreamBuilder<String?>(
            stream: streamController.stream,
              builder: (context, snapshot) {
            final tmp = <Teamlead>[];
            for (final e in EmployeeModel.teamLeadList) {
              if (e.f_name.toLowerCase().contains(snapshot.data?.toLowerCase() ?? '')) {
                tmp.add(e);
              }
            }
            return ListView.builder(
                itemCount: tmp.length,
                itemBuilder: (context, i) {
                  final t = tmp[i];
                  return InkWell(
                      onTap: () {
                        Navigator.pop(context, t);
                      },
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(5, 10, 10, 10),
                          child: Text(t.f_name)));
                });
          }))
        ]));
  }
}
