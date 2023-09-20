import 'dart:async';

import 'package:cafe5_mobile_client/classes/appdialog.dart';
import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/appheader/appheader.dart';
import 'package:cafe5_mobile_client/screens/structs/workdetails.dart';
import 'package:cafe5_mobile_client/screens/work_details/model.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';

class WorkDetailsScreen extends StatelessWidget {
  late final WorkDetailsModel model;

  WorkDetailsScreen(String work, int process, int task_id, {super.key}) {
    model = WorkDetailsModel(work, process, task_id, 0);
  }

  @override
  Widget build(BuildContext context) {
    const ts = TextStyle(fontSize: 16);
    return AppHeader(
        '${model.work}',
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            children: [
              InkWell(
                  onTap: () {
                    AppDialog.getString(context, model.work).then((value) {
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
                          if (value[HttpQuery.kStatus] != HttpQuery.hrOk) {
                            AppDialog.error(context, value[HttpQuery.kData]);
                            return;
                          }
                          model.getWorks();
                        });
                      }
                    });
                  },
                  child: Image.asset(
                    'images/new.png',
                    width: 30,
                    height: 30,
                  ))
            ],
          ),
          StreamBuilder(stream: model.listController.stream, builder: (builder, snapshot) {
            if (snapshot.data == null) {
              return const Center(child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()));
            }
            if (model.err.isNotEmpty) {
              return Center(child: Text(model.err));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(children: [
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 100, child: Text(tr('Color'), style: ts,)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('34', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('36', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('38', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('40', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('42', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('44', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('46', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('48', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('50', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: const Text('52', style: ts)),
                Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50,)
              ],),
              for (final e in snapshot.data! as List<WorkDetails>) ... [
                Row(children: [
                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 100, child: Text(e.f_color, style: ts)),
                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_34p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_34p }', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_36p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_36p}', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_38p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_38p }', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_40p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_40p}', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_field': 'f_42p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_42p}', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_44p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_44p }', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_46p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_46p }', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_48p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_48p }', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_50p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_50p }', style: ts))),

                  Container(margin: const EdgeInsets.fromLTRB(5, 5, 5, 5), width: 50, child: InkWell(onTap:(){
                    AppDialog.getInt(context, tr('Set quantity')).then((value) {
                      if (value != null) {
                        HttpQuery().request({
                          'query': HttpQuery.qWorkDetailsUpdate,
                          'f_id': e.f_id,
                          'f_process': e.f_process,
                          'f_field': 'f_52p',
                          'f_qty': value
                        }).then((value) {
                          model.getWorks();
                        });
                      }
                    });
                  }, child: Text('${e.f_52p }', style: ts))),

                  InkWell(
                      onTap: () {
                        AppDialog.question(context, tr('Confirm to remove'))
                            .then((value) {
                          if (value != null) {
                            if (value) {
                              HttpQuery().request({
                                'query': HttpQuery.qRemoveWorkDetails,
                                'f_task': model.task_id,
                                'f_color': e.f_color,
                              }).then((value) {
                                if (value[HttpQuery.kStatus] == HttpQuery.hrOk) {
                                  model.getWorks();
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
                          height: 40,
                          width: 40,
                          child: Image.asset(
                            'images/delete.png',
                            width: 30,
                            height: 30,
                          ))),

                ],)
              ]
            ],);
          })
        ]))));
  }
}
