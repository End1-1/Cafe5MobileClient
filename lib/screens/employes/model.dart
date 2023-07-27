import 'dart:async';

import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/structs/employee.dart';

class EmployeeModel {
  final employeeStream = StreamController();
  final teamleadStream = StreamController();
  Teamlead? teamlead;
  static final teamLeadList = <Teamlead>[];
  static final employeeList = <Employee>[];

  Future<void> getEmployeeList() async {
    final t = await HttpQuery().request({'query': HttpQuery.qListOfTeamlead});
    if (t[HttpQuery.kStatus] != HttpQuery.hrOk) {
      return;
    }
    final e = await HttpQuery().request({'query': HttpQuery.qListOfEmployee});
    if (e[HttpQuery.kStatus] != HttpQuery.hrOk) {
      return;
    }
    teamLeadList.clear();
    employeeList.clear();
    for (final v in t[HttpQuery.kData]){
      teamLeadList.add(Teamlead.fromJson(v));
    }
    for (final v in e[HttpQuery.kData]) {
      employeeList.add(Employee.fromJson(v));
    }
    employeeStream.add(null);
  }
}