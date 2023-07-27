import 'dart:async';

import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:intl/intl.dart';

class EmployeeOfDayModel {
  final DateTime date;
  final streamController = StreamController();

  EmployeeOfDayModel(this.date);

  Future<void> getList() async {
    final result = await HttpQuery().request({'query': HttpQuery.qEmployesOfDay, 'f_date': DateFormat('dd/MM/yyyy').format(date)});
    streamController.add(result);
  }
}