import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';


abstract class BaseWidgetState <T extends StatefulWidget> extends State<T>  {

  Future<void> sd(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('Tasks')),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(msg),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(tr("Ok")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sq(String msg, Function yes, Function no) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('Tasks')),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(msg),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(tr("Yes")),
              onPressed: () {
                Navigator.of(context).pop();
                  yes();

              },
            ),
            TextButton(
              child: Text(tr("No")),
              onPressed: () {
                Navigator.of(context).pop();
                  no();

              },
            )
          ],
        );
      },
    );
  }
}