import 'package:cafe5_mobile_client/classes/appdialog.dart';
import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/appheader/appheader.dart';
import 'package:cafe5_mobile_client/screens/structs/employee.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'model.dart';

class EmployeOfDay extends StatelessWidget {
  late final EmployeeOfDayModel model;

  EmployeOfDay(DateTime date, {super.key}) {
    model = EmployeeOfDayModel(date);
  }

  @override
  Widget build(BuildContext context) {
    return AppHeader(
        '${tr('Employes')} ${DateFormat('dd/MM/yyyy').format(model.date)}',
        Column(
          children: [
            StreamBuilder(
                stream: model.streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    model.getList();
                    return const Expanded(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  Map<String, dynamic> m =
                      (snapshot.data as Map<String, dynamic>);
                  if (m[HttpQuery.kStatus] != HttpQuery.hrOk) {
                    return Expanded(
                        child: Center(child: Text(m[HttpQuery.kData])));
                  }
                  List<Employee> e = [];
                  for (final j in m[HttpQuery.kData]) {
                    e.add(Employee.fromJson(j));
                  }
                  return Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      for (final em in e) ...[
                        Row(children: [
                          InkWell(
                              onTap: () {
                                AppDialog.question(
                                        context, tr('Confirm to remove'))
                                    .then((value) {
                                  if (value != null) {
                                    if (value) {
                                      HttpQuery().request({
                                        'query': HttpQuery.qRemoveWorker,
                                        'f_worker': em.f_id,
                                        'f_date': DateFormat('dd/MM/yyyy')
                                            .format(model.date)
                                      }).then((value) {
                                        if (value[HttpQuery.kStatus] ==
                                            HttpQuery.hrOk) {
                                          model.getList();
                                        } else {
                                          AppDialog.error(
                                              context, value[HttpQuery.kData]);
                                        }
                                      });
                                    }
                                  }
                                });
                              },
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 80,
                                  width: 40,
                                  child: Image.asset(
                                    'images/delete.png',
                                    width: 30,
                                    height: 30,
                                  ))),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context, em);
                              },
                              child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                  child: Text(em.f_name)))
                        ])
                      ]
                    ],
                  )));
                })
          ],
        ));
  }
}
