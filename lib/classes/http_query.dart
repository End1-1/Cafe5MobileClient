import 'dart:convert';

import 'package:cafe5_mobile_client/classes/prefs.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HttpQuery {
  static const port = 10002;
  static const hrFail = 0;
  static const hrOk = 1;
  static const hrNetworkError = 2;
  static const hrUnauthorized = 3;
  static const hrUnknown = 4;
  static const kStatus = 'status';
  static const kData = 'data';

  static const qListOfTasks = 1;
  static const qListOfTeamlead = 2;
  static const qListOfEmployee = 3;
  static const qListOfWorks = 4;
  static const qListOfTaskWorks = 5;
  static const qAddWorkToTas = 6;
  static const qEmployesOfDay = 7;
  static const qAddWorkerToWork = 8;
  static const qChangeQty = 9;
  static const qRemoveWork = 10;
  static const qRemoveWorker = 11;
  static const qWorkDetails = 12;
  static const qWorkDetailsList = 13;
  static const qWorkDetailsUpdate = 14;
  static const qWorkDetailsDone = 15;
  static const qWorkDetailsUpdateDone = 16;
  static const qRemoveWorkDetails = 17;
  static const qWorkDetailsUpdateDoneArray = 18;
  static const qWorkDetailsUpdateUnDone = 19;
  static const qWorkDetailsUpdateDoneArray2 = 20;

  String route;
  HttpQuery({this.route = 'index'});

  Future<Map<String, dynamic>> request(Map<String, Object?> inData) async {
    Map<String, Object?> outData = {};
    if (kDebugMode) {
      inData['debug'] = true;
    }
    inData['app'] = 'workshop';
    inData['appversion'] = Config.getString('appversion');
    String strBody = jsonEncode(inData..addAll({'sessionkey': prefs.getString('sessionkey') ?? ''}));
    if (kDebugMode) {
      print('route: /engine/elinaworkshop/$route.php');
      print('request: $strBody');
    }
    try {
      var response = await http
          .post(Uri.https('e3.picasso.am', '/engine/elinaworkshop/$route.php'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: utf8.encode(strBody))
          .timeout(const Duration(seconds: 25), onTimeout: () {
        return http.Response('Timeout', 408);
      });
      String strResponse = utf8.decode(response.bodyBytes);
      if (kDebugMode) {
        print('Row body $strResponse');
      }
      if (response.statusCode < 299) {
        try {
          outData = jsonDecode(strResponse);
        } catch (e) {
          outData[kStatus] = hrFail;
          outData[kData] = '${e.toString()} $strResponse';
        }
      } else {
        outData[kStatus] = hrFail;
        outData[kData] = strResponse;
      }
    } catch (e) {
      outData[kStatus] = hrNetworkError;
      outData[kData] = e.toString();
    }
    if (kDebugMode) {
      print('Output $outData');
    }
    return outData;
  }
}