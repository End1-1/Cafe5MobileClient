import 'package:cafe5_mobile_client/classes/appdialog.dart';
import 'package:cafe5_mobile_client/classes/date_utils.dart';
import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/classes/small_button.dart';
import 'package:cafe5_mobile_client/classes/text_button.dart';
import 'package:cafe5_mobile_client/screens/employes/screen.dart';
import 'package:cafe5_mobile_client/screens/employes_of_day/screen.dart';
import 'package:cafe5_mobile_client/screens/list/screen.dart';
import 'package:cafe5_mobile_client/screens/list_task_works/screen.dart';
import 'package:cafe5_mobile_client/screens/structs/work.dart';
import 'package:cafe5_mobile_client/screens/work_details/screen.dart';
import 'package:cafe5_mobile_client/screens/work_details/screen_done.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class JournalScreen extends StatelessWidget {
  final model = JournalModel();

  JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            minimum: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Column(children: [
              Row(children: [
                SmallButton("images/back.png", () => Navigator.pop(context)),
                Expanded(
                    child: StreamBuilder(
                        stream: model.taskStream.stream,
                        builder: (context, snapshot) {
                          return TxtButton(
                              model.task.f_name, () => getTask(context));
                        })),
                StreamBuilder<bool?>(
                    stream: model.filterTaskStream.stream,
                    builder: (context, snapshot) {
                      return Checkbox(
                        value: snapshot.data ?? false,
                        onChanged: (v) {
                          model.changeTaskFilter(v ?? false);
                        },
                      );
                    }),
                SmallButton("images/left.png", () => model.changeDate(-1)),
                StreamBuilder(
                    stream: model.dateStream.stream,
                    builder: (context, snapshot) {
                      return Text(DateUtil.format(model.date));
                    }),
                SmallButton("images/right.png", () => model.changeDate(1))
              ]),
              const Divider(
                height: 5,
                color: Colors.black54,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SmallButton('images/searching.png', () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmployeOfDay(model.date)));
                    if (result != null) {
                      if (result is bool) {
                        model.employee = null;
                        model.employeeStream.add(null);
                        model.getTask();
                      } else {
                        model.employee = result;
                        model.employeeStream.add(null);
                        model.getTask();
                      }
                    }
                  }),
                  const SizedBox(width: 10),
                  SmallButton('images/newpartner.png', () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmployesList(model.date)));
                    if (result != null) {
                      model.employee = result;
                      model.employeeStream.add(null);
                      model.getTask();
                    }
                  }),
                  StreamBuilder(
                      stream: model.employeeStream.stream,
                      builder: (context, snapshot) {
                        return Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text(model.employee == null
                                ? tr('Select worker')
                                : model.employee!.f_name));
                      }),
                  Expanded(child: Container()),
                  SmallButton('images/upload.png', () {
                    String err = '';
                    if (model.employee == null) {
                      err += '${tr('Select employee')}\r\n';
                    }
                    if (model.task.f_id == 0) {
                      err += '${tr('Select task')}\r\n';
                    }
                    if (err.isNotEmpty) {
                      AppDialog.error(context, err);
                      return;
                    }
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListTaskWorks(
                                    model.task, model.employee!, model.date)))
                        .then((value) {
                      if (value == null) {
                        AppDialog.error(context, tr('Could not append work'));
                      } else {
                        model.getTask();
                      }
                    });
                  })
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              Row(children: [
                  SmallButton('images/filter.png', () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EmployesList(model.date)));
                    if (result != null) {
                      model.teamleaderId = result.f_id;
                      model.teamLeaderName = result.f_name;
                      model.saveTeamleader();
                      model.filterTeamleadStream.add(null);
                      model.getTask();
                    }
                  }),
                Text(tr('Teamleader')),
                const SizedBox(width: 10),
                StreamBuilder(stream: model.filterTeamleadStream.stream, builder: (builder, snapshot) {
                  return Text(model.teamLeaderName);
                }),
                Expanded(child: Container()),
                SmallButton('images/delete.png', () async {
                    model.teamleaderId = 0;
                    model.teamLeaderName = '';
                    model.saveTeamleader();
                    model.filterTeamleadStream.add(null);
                    model.getTask();
                  }
                ),
              ],),
              const SizedBox(height: 10),
              const Divider(),
              Expanded(
                  child: StreamBuilder(
                      stream: model.tableStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.data is String) {
                          return Center(child: Text(snapshot.data as String));
                        }
                        if (snapshot.data is bool) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.data == null) {
                          return Container();
                        }
                        final listWork = <Work>[];
                        for (final e in (snapshot.data as List<dynamic>)) {
                          listWork.add(Work.fromJson(e));
                        }
                        int i = 0;

                        return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                                child: Column(
                              children: [
                                for (final e in listWork) ...[
                                  _workRow(context, e, (i++ % 2) == 0)
                                ]
                              ],
                            )));
                      }))
            ])));
  }

  Widget _workRow(BuildContext context, Work w, bool odd) {
    const m = EdgeInsets.fromLTRB(5, 10, 10, 10);
    const od = BoxDecoration(color: Colors.black12);
    const ed = BoxDecoration(color: Colors.white);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
            onTap: () {
              AppDialog.question(context, tr('Confirm to remove'))
                  .then((value) {
                if (value != null) {
                  if (value) {
                    HttpQuery().request({
                      'query': HttpQuery.qRemoveWork,
                      'f_id': w.f_id
                    }).then((value) {
                      if (value[HttpQuery.kStatus] == HttpQuery.hrOk) {
                        model.getTask();
                      } else {
                        AppDialog.error(context, value[HttpQuery.kData]);
                      }
                    });
                  }
                }
              });
            },
            child: Container(
                alignment: Alignment.centerLeft,
                height: 80,
                padding: m,
                decoration: odd ? od : ed,
                width: 40,
                child: Image.asset(
                  'images/delete.png',
                  width: 30,
                  height: 30,
                ))),
        Container(
            alignment: Alignment.centerLeft,
            height: 80,
            padding: m,
            decoration: odd ? od : ed,
            width: 150,
            child: Text(w.f_productname)),
        Container(
            alignment: Alignment.centerLeft,
            height: 80,
            padding: m,
            decoration: odd ? od : ed,
            width: 250,
            child: Text(w.f_processname)),
        InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => WorkDetailsScreenDone(
                          '${model.task.f_name} ${w.f_processname}',
                          w.f_process, w.f_taskid, w.f_id))).then((value) {
                model.getTask();
              });

            },
            child: Container(
                alignment: Alignment.centerLeft,
                height: 80,
                padding: m,
                decoration: odd ? od : ed,
                width: 80,
                child: Text(w.f_qty.toString()))),
        Container(
            alignment: Alignment.centerLeft,
            height: 80,
            padding: m,
            decoration: odd ? od : ed,
            width: 80,
            child: Text(w.f_ready.toString())),
        Container(
            alignment: Alignment.centerLeft,
            height: 80,
            padding: m,
            decoration: odd ? od : ed,
            width: 80,
            child: Text(w.f_goal.toString())),
      ],
    );
  }

  void getTask(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ListScreen(tr("List of task"), HttpQuery.qListOfTasks)));
    if (result != null) {
      model.task = result;
      model.taskStream.add(null);
      model.getTask();
    }
  }
}
