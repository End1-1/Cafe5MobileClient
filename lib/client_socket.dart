import 'dart:io';
import 'dart:typed_data';
import 'package:cafe5_mobile_client/client_socket_interface.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/socket_message.dart';

class ClientSocket {

  static late ClientSocket socket;
  static int _socketState = 0;
  SecureSocket? _socket;
  String remoteAddress;
  int remotePort;
  BytesBuilder _tempBuffer = BytesBuilder();
  List<SocketInterface> _interfaces = [];

  ClientSocket ({required this.remoteAddress, required this.remotePort});

  static void init(String ip, int port) async {
    socket = new ClientSocket(remoteAddress: ip, remotePort: port);
    socket.connectToServer();
  }

  Future<bool> connectToServer() async {
    await SecureSocket.connect(socket.remoteAddress, socket.remotePort, timeout: Duration(seconds: 10), onBadCertificate: (x){return true;}).then((s) {
      setSocketState(1);
      print("Socket connected");
      _socket = s as SecureSocket;

      _socket!.listen((data) {
        _tempBuffer.add(data);
        //print(data);
        int expectedSize = SocketMessage.calculateDataSize(_tempBuffer);
        if (expectedSize == _tempBuffer.length - 17) {
          for (SocketInterface s in _interfaces) {
            s.handler(_tempBuffer.toBytes());
          }
          _tempBuffer.clear();
        }
      }, onDone: () {
        setSocketState(0);
        print("Socket disconnected");
        _reconnectToServer();
      }, onError: (err)  {
        setSocketState(0);
        print(err);
        _reconnectToServer();
      });
    }).onError((error, stackTrace) {
      print(error);
      setSocketState(0);
      _reconnectToServer();
    });

    SocketMessage m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_hello);
    try {
      _socket!.add(m.data());
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<bool> _reconnectToServer() async {
    print("Socket reconnecting...");
    SocketMessage.resetPacketCounter();
    await Future.delayed(const Duration(seconds: 5));
    await connectToServer();
    return true;
  }

  void addInterface(SocketInterface si) {
    _interfaces.add(si);
  }

  void removeInterface(SocketInterface si) {
    _interfaces.remove(si);
  }

  static String imageConnectionState() {
    switch (_socketState) {
      case 0:
        return "images/wifi_off.png";
      case 1:
        return "images/wifib.png";
      case 2:
        return "images/wifi_on.png";
    }
    return "images/wifi_off.png";
  }

  static void send(List<int> data) {
    try {
      socket._socket!.add(data);
    } catch (e) {
      print(e);
      socket._reconnectToServer();
    }
  }

  static void setSocketState(int state) {
    _socketState = state;
    for (SocketInterface s in socket._interfaces) {
      switch (_socketState) {
        case 0:
          s.disconnected();
          break;
        case 1:
          s.connected();
          break;
        case 2:
          s.authenticate();
          break;
      }
    }
  }

}