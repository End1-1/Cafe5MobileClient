import 'dart:async';

import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/structs/employee.dart';
import 'package:cafe5_mobile_client/classes/small_button.dart';
import 'package:cafe5_mobile_client/screens/teamlead/screen.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model.dart';

class EmployesList extends StatelessWidget {
  final DateTime date;
  final model = EmployeeModel();
  var filter = '';

  EmployesList(this.date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            minimum: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Column(children: [
              Row(children: [
                SmallButton("images/back.png", () => Navigator.pop(context)),
                Container(margin: const EdgeInsets.fromLTRB(5, 0, 0, 0  ), child: Text(tr('Employee'))),
                Expanded(
                        child: TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              prefix: Container(margin: const EdgeInsets.fromLTRB(10, 0, 5, 0), child: Image.asset("images/search.png", height: 20, width: 20,))
                          ),
                          onChanged: (v) {
                            filter = v;
                            model.employeeStream.add(null);
                          },
                        ))
                  ],
                ),
              const Divider(height: 2, color: Colors.black54),
              StreamBuilder(
                stream: model.teamleadStream.stream,
                  builder: (context, snapshot) {
                  return Row(
                    children: [
                      SmallButton('images/newpartner.png', () async {
                        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => TeamleadScreen()));
                        if (result != null) {
                          model.teamlead = result;
                          model.employeeStream.add(null);
                          model.teamleadStream.add(null);
                        }
                      }),
                      Container(margin: const EdgeInsets.fromLTRB(10, 0, 0, 0), child: model.teamlead == null ? Text(tr('Teamlead')) : Text(model.teamlead!.f_name)),
                      Expanded(child: Container())
                    ],
                  );

              }),
              const Divider(height: 2, color: Colors.black54),
              Expanded(child: StreamBuilder(
                stream: model.employeeStream.stream,
                builder: (context, snapshot) {
                  if (EmployeeModel.employeeList.isEmpty) {
                    model.getEmployeeList();
                    return const Center(child: CircularProgressIndicator());
                  }
                  final lst = <Employee>[];
                  for (final e in EmployeeModel.employeeList) {
                    if (model.teamlead != null) {
                      if (model.teamlead!.f_id != e.f_teamlead) {
                        continue;
                      }
                    }
                    if (!e.f_name.toLowerCase().contains(filter.toLowerCase())) {
                        continue;
                    }
                    lst.add(e);
                  }
                  return ListView.builder(
                    itemCount: lst.length,
                      itemBuilder: (context, i){
                    final e = lst[i];
                    return InkWell(onTap:() {
                      HttpQuery().request({'query': HttpQuery.qAddWorkerToWork, 'f_worker': e.f_id, 'f_date': DateFormat('dd/MM/yyyy').format(date)}).then((value) {
                        if (value[HttpQuery.kStatus] == HttpQuery.hrOk) {
                          Navigator.pop(context, e);
                        }
                      });
                    }, child: Container(margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: Text(e.f_name)));
                  });
                }
              ))
            ])));
  }
}
