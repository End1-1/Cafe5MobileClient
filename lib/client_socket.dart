import 'dart:io';
import 'package:cafe5_mobile_client/client_socket_interface.dart';
import 'package:cafe5_mobile_client/socket_message.dart';

class ClientSocket {

  static late ClientSocket socket;
  SecureSocket? _socket;
  String remoteAddress;
  int remotePort;
  List<SocketInterface> _interfaces = [];

  ClientSocket ({required this.remoteAddress, required this.remotePort});

  static void init(String ip, int port) async {
    socket = new ClientSocket(remoteAddress: ip, remotePort: port);
    socket.connectToServer();
  }

  void connectToServer() async {
    await SecureSocket.connect(socket.remoteAddress, socket.remotePort, timeout: Duration(seconds: 10), onBadCertificate: (x){return true;}).then((s) {
      print("Socket connected");
      _socket = s as SecureSocket;

      SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_hello);
      _socket!.add(m.data());

      _socket!.listen((data) {
        print(data);
        for (SocketInterface s in _interfaces) {
          s.handler(data);
        }
      }, onDone: () {
        print("Socket disconnected");
        _reconnectToServer();
      }, onError: (err) {
        print(err);
        _reconnectToServer();
      });
    }).onError((error, stackTrace) {
      print(error);
      _reconnectToServer();
    });
  }

  void _reconnectToServer() {
    print("Socket reconnecting...");
    if (_socket != null) {
      _socket!.close();
    }
    sleep(Duration(seconds: 5));
    SocketMessage.resetPacketCounter();
    connectToServer();
  }

  void addInterface(SocketInterface si) {
    _interfaces.add(si);
  }

}