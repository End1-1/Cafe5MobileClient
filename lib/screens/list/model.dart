import 'dart:async';

import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/screens/structs/task.dart';

class ListScreenModel {
  final dataStream = StreamController<Map<String, dynamic>?>();
  final List<Task> tasks = [];

  Future<void> getList(int query) async {
    Map<String, dynamic> inData = {};
    inData['query'] = query;
    final result = await HttpQuery().request(inData);
    if (result[HttpQuery.kStatus] == HttpQuery.hrOk) {
      for (final e in result[HttpQuery.kData]) {
        switch (query) {
          case HttpQuery.qListOfTasks:
            tasks.add(Task.fromJson(e));
            break;
        }
      }
    }

    switch(query) {
      case HttpQuery.qListOfTasks:
        dataStream.add({
          HttpQuery.kStatus: result[HttpQuery.kStatus],
          HttpQuery.kData: tasks
        });
        break;
    }
  }
}