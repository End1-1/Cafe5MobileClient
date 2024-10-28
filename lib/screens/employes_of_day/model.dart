import 'dart:async';

import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/screens/structs/employee.dart';
import 'package:intl/intl.dart';

class EmployeeOfDayModel {
  final DateTime date;
  final streamController = StreamController();
  Teamlead teamlead = Teamlead(
      f_id: Config.getInt('teamleaderid'),
      f_name: Config.getString('teamleadername'));

  EmployeeOfDayModel(this.date);

  Future<void> getList() async {
    final result = await HttpQuery().request({
      'query': HttpQuery.qEmployesOfDay,
      'f_date': DateFormat('yyyy-MM-dd').format(date),
      'f_teamlead': teamlead.f_id,
    });
    streamController.add(result);
  }
}
