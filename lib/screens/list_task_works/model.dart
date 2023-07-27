import 'dart:async';

import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/structs/employee.dart';
import 'package:cafe5_mobile_client/screens/structs/task.dart';
import 'package:intl/intl.dart';

class ListTaskWorkModel {
  final Task task;
  final Employee employee;
  final DateTime date;
  final streamController = StreamController<Map<String, dynamic>>();

  ListTaskWorkModel(this.task, this.employee, this.date);

  Future<void> getWorks() async {
    final result = await HttpQuery().request(
        {'query': HttpQuery.qListOfTaskWorks, 'f_product': task.f_product});
    streamController.add(result);
  }

  Future<bool> insertWork(int process, double price) async {
    final result = await HttpQuery().request({
      'query': HttpQuery.qAddWorkToTas,
      'f_date': DateFormat("dd/MM/yyyy").format(date),
      'f_worker': employee.f_id,
      'f_taskid': task.f_id,
      'f_product': task.f_product,
      'f_process': process,
      'f_price': price,
      'f_laststep': 0
    });
    return result[HttpQuery.kStatus] == HttpQuery.hrOk;
  }
}
