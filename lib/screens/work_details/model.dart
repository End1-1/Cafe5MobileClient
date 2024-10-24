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
  int progressPending = 0;
  List<Map<String, dynamic>> pendingList = [];
  String err = '';
  final wdList = <WorkDetailsDone>[];
  final listController = StreamController();
  final progressController = StreamController();
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
    wdList.clear();
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
      wdList.add(wd);
    }
    listController.add(wdList);
    return wdList;
  }

  bool completeListExists(String color, String size) {
    if (!completeList.containsKey(color)) {
      return false;
    }
    return completeList[color]!.contains(size);
  }

  Future<void> completeListAddRemove(int id, String color, String size, int qty) async {
    var pp = false;
    if (id == 0) {
      for (int i = 0; i  < pendingList.length; i++) {
        final m = pendingList[i];
        if (m['a']! == color ) {
          return;
        }
      }
      pendingList.add({
        'a': color,
        'b': size,
        'c': qty,
      });
      pp = true;
      progressPending++;
      progressController.add(progressPending);
      final result = await HttpQuery().request({
        'query': HttpQuery.qWorkDetailsUpdateDone,
        'f_id': 0,
        'f_taskid': task_id,
        'f_processid': process,
        'f_dailyid': daily_id,
        'f_color': color,
        'f_field': 'f_${size}',
        'f_qty': 0,
      });
      if (result[HttpQuery.kStatus] == HttpQuery.hrOk) {
        id = int.tryParse(result[HttpQuery.kData].toString()) ?? 0;
      }
      pendingList.removeWhere((e) => e['a'] == color);
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
    if (pp) {
      progressPending--;
      progressController.add(progressPending);
    }
    listController.add(wdList);
  }

  Future<void> comleteRow(String key, List<String> value) async {

  }

  Future<void> updateQty() async {
    progressController.add(++progressPending);
  }

}