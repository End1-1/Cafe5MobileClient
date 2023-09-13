import 'package:cafe5_mobile_client/classes/appdialog.dart';
import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/appheader/appheader.dart';
import 'package:cafe5_mobile_client/screens/structs/workdetails.dart';
import 'package:cafe5_mobile_client/screens/work_details/model.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';

class WorkDetailsScreenDone extends StatelessWidget {
  late final WorkDetailsModel model;

  WorkDetailsScreenDone(String work, int process, int task_id, {super.key}) {
    model = WorkDetailsModel(work, process, task_id);
  }

  @override
  Widget build(BuildContext context) {
    const ts1 =
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red);
    const ts2 = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green);
    const ts3 = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple);
    return AppHeader(
        '${model.work}',
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            AppDialog.getStringInt(context, model.work)
                                .then((value) {
                              if (value != null) {
                                HttpQuery().request({
                                  'query': HttpQuery.qWorkDetails,
                                  'f_id': 0,
                                  'f_task': model.task_id,
                                  'f_process': model.process,
                                  'f_color': value,
                                  'f_36': 0,
                                  'f_38': 0,
                                  'f_40': 0,
                                  'f_42': 0,
                                  'f_44': 0,
                                  'f_46': 0,
                                  'f_48': 0,
                                  'f_50': 0,
                                  'f_52': 0,
                                }).then((value) {
                                  if (value[HttpQuery.kStatus] !=
                                      HttpQuery.hrOk) {
                                    AppDialog.error(
                                        context, value[HttpQuery.kData]);
                                    return;
                                  }
                                  model.getWorksDone();
                                });
                              }
                            });
                          },
                          child: Image.asset(
                            'images/new.png',
                            width: 30,
                            height: 30,
                          )),
                      //Expanded(child: Container()),
                      const SizedBox(width: 50),
                      InkWell(
                          onTap: () async {
                            await AppDialog.question(context, tr('Execute?'))
                                .then((value) async {
                              if (value != null) {
                                List<String> keys = model.completeList.keys.toList();
                                for (final key in keys) {
                                  List<String> value = model.completeList[key]!;
                                  for (final e in value) {
                                     await HttpQuery().request({
                                      'query': HttpQuery.qWorkDetailsUpdateDone,
                                      'f_id': model.listId[key]!,
                                      'f_taskid': model.task_id,
                                      'f_processid': model.process,
                                      'f_color': key,
                                      'f_field': 'f_${e}',
                                      'f_qty':
                                          model.idQty[model.listId[key]!]![e],
                                    });
                                  }
                                }
                                model.idQty.clear();
                                model.listId.clear();
                                model.completeList.clear();
                                model.getWorksDone();
                              }
                            });
                          },
                          child: Image.asset(
                            'images/edit.png',
                            width: 30,
                            height: 30,
                          ))
                    ],
                  ),
                  StreamBuilder(
                      stream: model.listController.stream,
                      builder: (builder, snapshot) {
                        if (snapshot.data == null) {
                          return const Center(
                              child: SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator()));
                        }
                        if (model.err.isNotEmpty) {
                          return Center(child: Text(model.err));
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 100,
                                    child: Text(
                                      tr('Color'),
                                      style: ts2,
                                    )),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('34', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('36', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('38', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('40', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('42', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('44', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('46', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('48', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('50', style: ts2)),
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    width: 50,
                                    child: const Text('52', style: ts2)),
                              ],
                            ),
                            for (final e in (snapshot.data ?? [])
                                as List<WorkDetailsDone>) ...[
                              Row(
                                children: [
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 100,
                                      child: Text(e.f_color, style: ts2)),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_34p == e.f_34d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_34',
                                                    'f_qty': e.f_34p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '34', e.f_34p);
                                          },
                                          child: Text('${e.f_34p}',
                                              style: e.f_34p == e.f_34d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '34')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_36p == e.f_36d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_36',
                                                    'f_qty': e.f_36p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '36', e.f_36p);
                                          },
                                          child: Text('${e.f_36p}',
                                              style: e.f_36p == e.f_36d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '36')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_38p == e.f_38d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_38',
                                                    'f_qty': e.f_38p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '38', e.f_38p);
                                          },
                                          child: Text('${e.f_38p}',
                                              style: e.f_38p == e.f_38d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '38')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_40p == e.f_40d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_40',
                                                    'f_qty': e.f_40p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '40', e.f_40p);
                                          },
                                          child: Text('${e.f_40p}',
                                              style: e.f_40p == e.f_40d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '40')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_42p == e.f_42d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_42',
                                                    'f_qty': e.f_42p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '42', e.f_42p);
                                          },
                                          child: Text('${e.f_42p}',
                                              style: e.f_42p == e.f_42d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '42')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_44p == e.f_44d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_44',
                                                    'f_qty': e.f_44p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '44', e.f_44p);
                                          },
                                          child: Text('${e.f_44p}',
                                              style: e.f_44p == e.f_44d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '44')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_46p == e.f_46d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_46',
                                                    'f_qty': e.f_46p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '46', e.f_46p);
                                          },
                                          child: Text('${e.f_46p}',
                                              style: e.f_46p == e.f_46d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '46')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_48p == e.f_48d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_48',
                                                    'f_qty': e.f_48p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '48', e.f_48p);
                                          },
                                          child: Text('${e.f_48p}',
                                              style: e.f_48p == e.f_48d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '48')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_50p == e.f_50d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_50',
                                                    'f_qty': e.f_50p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '50', e.f_50p);
                                          },
                                          child: Text('${e.f_50p}',
                                              style: e.f_50p == e.f_50d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '50')
                                                      ? ts3
                                                      : ts1))),
                                  Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      width: 50,
                                      child: InkWell(
                                          onTap: () {
                                            if (e.f_52p == e.f_52d) {
                                              AppDialog.question(
                                                      context, tr('Rollback?'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateUnDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_52',
                                                    'f_qty': e.f_52p,
                                                  }).then((value) {
                                                    if (value[HttpQuery
                                                            .kStatus] !=
                                                        HttpQuery.hrOk) {
                                                      AppDialog.error(
                                                          context,
                                                          value[
                                                              HttpQuery.kData]);
                                                      return;
                                                    }
                                                    model.getWorksDone();
                                                  });
                                                }
                                              });
                                              return;
                                            }
                                            model.completeListAddRemove(e.f_id,
                                                e.f_color, '52', e.f_52p);
                                          },
                                          child: Text('${e.f_52p}',
                                              style: e.f_52p == e.f_52d
                                                  ? ts2
                                                  : model.completeListExists(
                                                          e.f_color, '52')
                                                      ? ts3
                                                      : ts1))),
                                ],
                              )
                            ]
                          ],
                        );
                      })
                ]))));
  }
}
