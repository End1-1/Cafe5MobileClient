import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/appheader/appheader.dart';
import 'package:cafe5_mobile_client/screens/structs/employee.dart';
import 'package:cafe5_mobile_client/screens/structs/task.dart';
import 'package:cafe5_mobile_client/screens/structs/workoftask.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class ListTaskWorks extends StatelessWidget {
  late final ListTaskWorkModel model;
  final ts = const TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
  final bso = const BoxDecoration(color: Colors.black12);
  final bse = const BoxDecoration(color: Colors.white);

  ListTaskWorks(Task t, Employee e, DateTime d, {super.key}) {
    model = ListTaskWorkModel(t, e, d);
  }

  @override
  Widget build(BuildContext context) {
    return AppHeader(
        model.task.f_name,
        StreamBuilder<Map<String, dynamic>>(
            stream: model.streamController.stream,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                model.getWorks();
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data![HttpQuery.kStatus] != HttpQuery.hrOk) {
                return Center(child: Text(snapshot.data![HttpQuery.kData]));
              }
              final lst = <WorkOfTask>[];
              for (final e in snapshot.data![HttpQuery.kData]) {
                lst.add(WorkOfTask.fromJson(e));
              }
              int i = 0;
              return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                      child: Column(children: [
                    for (final w in lst) ...[
                      InkWell(onTap:(){
                        model.insertWork(w.f_process, w.f_price).then((value) {
                          if (value == null) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context, true);
                          }
                        });
                      }, child: Row(children: [
                        Container(
                            decoration: (i % 2) == 0 ? bso : bse,
                            height: 40,
                            width: 40,
                            child: Text(
                              w.f_rowid.toString(),
                              style: ts,
                            )),
                        Container(
                            decoration: (i++ % 2) == 0 ? bso : bse,
                            height: 40,
                            width: 400,
                            child: Text(w.f_acname, style: ts))
                      ]))
                    ]
                  ])));
            }));
  }
}
