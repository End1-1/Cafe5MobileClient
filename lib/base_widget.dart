import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'client_socket_interface.dart';
import 'client_socket.dart';

abstract class BaseWidgetState <T extends StatefulWidget> extends State<T> implements SocketInterface {

  @override
  void initState() {
   super.initState();
   ClientSocket.socket.addInterface(this);
  }

  @override
  void authenticate() {
    // TODO: implement authenticate
  }

  @override
  void connected() {
    setState((){});
  }

  @override
  void disconnected() {
    setState((){});
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
}