import 'dart:async';
import 'dart:core';

import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/structs/workdetails.dart';
import 'package:flutter/widgets.dart';

class WorkDetailsModel {
  String work;
  int process;
  int daily_id;
  int task_id;
  String err = '';
  final listController = StreamController();
  final Map<String, List<String>> completeList = {};
  final Map<String, int> listId = {};
  final Map<int, Map<String, int>> idQty = {};

  WorkDetailsModel(this.work, this.process, this.task_id, this.daily_id) {
    if (process == 0) {
      getWorks();
    } else {
      getWorksDone();
    }
  }

  Future<List<WorkDetails>?> getWorks() async {
    err = '';
    final List<WorkDetails> l = [];
    final result = await HttpQuery().request({
      'query': HttpQuery.qWorkDetailsList,
      'f_taskid': task_id
    });
    if (result[HttpQuery.kStatus] != HttpQuery.hrOk) {
      err = result[HttpQuery.kData];
      listController.add('');
      return null;
    }
    for (final e in result[HttpQuery.kData]) {
      WorkDetails wd = WorkDetails.fromJson(e);
      l.add(wd);
    }
    listController.add(l);
    return l;
  }

  Future<List<WorkDetailsDone>?> getWorksDone() async {
    err = '';
    final List<WorkDetailsDone> l = [];
    final result = await HttpQuery().request({
      'query': HttpQuery.qWorkDetailsDone,
      'f_task': task_id,
      'f_process': process,
      'f_dailyid': daily_id,
    });
    if (result[HttpQuery.kStatus] != HttpQuery.hrOk) {
      err = result[HttpQuery.kData];
      listController.add('');
      return null;
    }
    for (final e in result[HttpQuery.kData]) {
      WorkDetailsDone wd = WorkDetailsDone.fromJson(e);
      l.add(wd);
    }
    listController.add(l);
    return l;
  }

  bool completeListExists(String color, String size) {
    if (!completeList.containsKey(color)) {
      return false;
    }
    return completeList[color]!.contains(size);
  }

  Future<void> completeListAddRemove(int id, String color, String size, int qty) async {
    listController.add(null);
    if (id == 0) {
      final result = await HttpQuery().request({
        'query': HttpQuery.qWorkDetailsUpdateDone,
        'f_id': 0,
        'f_taskid': task_id,
        'f_processid': process,
        'f_color': color,
        'f_field': 'f_${size}',
        'f_qty': 0,
      });
      if (result[HttpQuery.kStatus] == HttpQuery.hrOk) {
        id = int.tryParse(result[HttpQuery.kData].toString()) ?? 0;
      }
    }
    if (id == 0) {
      return;
    }
    listId[color] = id;
    if (!idQty.containsKey(id)) {
      idQty[id] = {};
    }
    idQty[id]![size] = qty;
    if (!completeList.containsKey(color)) {
      completeList[color] = [];
      completeList[color]!.add(size);
    } else {
      if (completeList[color]!.contains(size)) {
        completeList[color]!.remove(size);
      } else {
        completeList[color]!.add(size);
      }
    }
    getWorksDone();
  }

  Future<void> comleteRow(String key, List<String> value) async {

  }

}