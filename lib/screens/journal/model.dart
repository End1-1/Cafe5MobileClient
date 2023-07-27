import 'dart:async';

import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/structs/employee.dart';
import 'package:cafe5_mobile_client/screens/structs/task.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:intl/intl.dart';

class JournalModel {
  DateTime date = DateTime.now();
  final dateStream = StreamController();
  final taskStream = StreamController();
  final employeeStream = StreamController();
  final tableStream = StreamController();
  var task = Task(f_id: 0, f_name: tr('Task'), f_product: 0);
  Employee? employee;

  void changeDate(int lr) {
    date = date.add(Duration(days: lr * 1));
    dateStream.add(date);
    getTask();
  }

  Future<void> getTask() async {
    if ((employee?.f_id ?? 0) == 0) {
      tableStream.add([]);
      return;
    }
    tableStream.add(true);
    final result = await HttpQuery().request({
      'query': HttpQuery.qListOfWorks,
      'f_worker': employee?.f_id ?? 0,
      'f_task': task.f_id,
      'f_date': DateFormat('dd/MM/yyyy').format(date)
    });
    if (result[HttpQuery.kStatus] != HttpQuery.hrOk) {
      tableStream.add(result[HttpQuery.kData] as String);
      return;
    }
    tableStream.add(result[HttpQuery.kData]);
  }


}
