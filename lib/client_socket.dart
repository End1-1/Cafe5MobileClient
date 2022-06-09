import 'package:cafe5_mobile_client/client_socket_interface.dart';

class ClientSocket {

  static late ClientSocket socket;
  String remoteAddress;
  int remotePort;
  List<SocketInterface> _interfaces = [];

  ClientSocket({required this.remoteAddress, required this.remotePort});

  void init(String ip, int port) {
    socket = new ClientSocket(remoteAddress: ip, remotePort: port);
  }

  void addInterface(SocketInterface si) {
    _interfaces.add(si);
  }

}