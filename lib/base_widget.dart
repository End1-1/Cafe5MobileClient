import 'dart:typed_data';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/cupertino.dart';
import 'client_socket_interface.dart';
import 'client_socket.dart';
import 'package:flutter/material.dart';
import 'package:cafe5_mobile_client/widget_choose_settings.dart';

abstract class BaseWidgetState <T extends StatefulWidget> extends State<T> implements SocketInterface {

  @override
  void initState() {
   super.initState();
   ClientSocket.socket.addInterface(this);
  }

  @override
  void dispose() {
    ClientSocket.socket.removeInterface(this);
    super.dispose();
  }

  @override
  void authenticate() {
    setState((){});
  }

  @override
  void connected() {
    setState((){});
  }

  @override
  void disconnected() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => WidgetChooseSettings()), (route) => false);
  }

  @override
  void handler(Uint8List data) {
    // TODO: implement handler
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

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
                if (yes != null) {
                  yes();
                }
              },
            ),
            TextButton(
              child: Text(tr("No")),
              onPressed: () {
                Navigator.of(context).pop();
                if (no != null) {
                  no();
                }
              },
            )
          ],
        );
      },
    );
  }
}