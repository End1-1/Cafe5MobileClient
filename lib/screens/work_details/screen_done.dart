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
                                List<String> keys =
                                    model.completeList.keys.toList();
                                for (final key in keys) {
                                  List<String> value = model.completeList[key]!;
                                  for (final e in value) {
                                    if (model.listId[key] == 0) {
                                      AppDialog.error(
                                          context, tr('Incorrect data'));
                                      return;
                                    }
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                      tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                        model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_34',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_34c > 0) {
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
                                                    'f_qty': e.f_34c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '34',
                                                e.f_34p - e.f_34d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_34c : e.f_34c > 0 ? e.f_34c : e.f_34p - e.f_34d}',
                                              style: e.f_34c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_36',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_36c > 0) {
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
                                                    'f_qty': e.f_36c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '36',
                                                e.f_36p - e.f_36d);
                                          },
                                          child: Text('${model.task_id == 53 ?  e.f_36d : e.f_36c > 0 ? e.f_36c : e.f_36p - e.f_36d}',
                                              style: e.f_36c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_38',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_38c > 0) {
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
                                                    'f_qty': e.f_38c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '38',
                                                e.f_38p - e.f_38d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_38d : e.f_38c > 0 ? e.f_38c : e.f_38p - e.f_38d}',
                                              style: e.f_38c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_40',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_40c > 0) {
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
                                                    'f_qty': e.f_40c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '40',
                                                e.f_40p - e.f_40d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_40d : e.f_40c > 0 ? e.f_40c : e.f_40p - e.f_40d}',
                                              style: e.f_40c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_42',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_42c > 0) {
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
                                                    'f_qty': e.f_42c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '42',
                                                e.f_42p - e.f_42d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_42d : e.f_42c > 0 ? e.f_42c : e.f_42p - e.f_42d}',
                                              style: e.f_42c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_44',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_44c > 0) {
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
                                                    'f_qty': e.f_44c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '44',
                                                e.f_44p - e.f_44d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_44d : e.f_44c > 0 ? e.f_44c : e.f_44p - e.f_44d}',
                                              style: e.f_44c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_46',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_46c > 0) {
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
                                                    'f_qty': e.f_46c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '46',
                                                e.f_46p - e.f_46d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_46d : e.f_46c > 0 ? e.f_46c : e.f_46p - e.f_46d}',
                                              style: e.f_46c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_48',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_48c > 0) {
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
                                                    'f_qty': e.f_48c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '48',
                                                e.f_48p - e.f_48d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_48d : e.f_48c > 0 ? e.f_48c : e.f_48p - e.f_48d}',
                                              style: e.f_48c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_50',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_50c > 0) {
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
                                                    'f_qty': e.f_50c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '50',
                                                e.f_50p - e.f_50d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_50d : e.f_50c > 0 ? e.f_50c : e.f_50p - e.f_50d}',
                                              style: e.f_50c > 0
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
                                          onTap: () async {
                                            if (model.task_id == 53) {
                                              AppDialog.getInt(context,
                                                  tr('Set quantity'))
                                                  .then((value) {
                                                if (value != null) {
                                                  HttpQuery().request({
                                                    'query': HttpQuery
                                                        .qWorkDetailsUpdateDone,
                                                    'f_id': e.f_id,
                                                    'f_taskid': model.task_id,
                                                    'f_processid':
                                                    model.process,
                                                    'f_color': e.f_color,
                                                    'f_field': 'f_52',
                                                    'f_qty': value,
                                                  }).then((value) =>
                                                      model.getWorksDone());
                                                }
                                              });
                                              return;
                                            }
                                            if (e.f_52c > 0) {
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
                                                    'f_qty': e.f_52c,
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
                                            await model.completeListAddRemove(
                                                e.f_id,
                                                e.f_color,
                                                '52',
                                                e.f_52p - e.f_52d);
                                          },
                                          child: Text('${model.task_id == 53 ? e.f_52d : e.f_52c > 0 ? e.f_52c : e.f_52p - e.f_52d}',
                                              style: e.f_52c > 0
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
