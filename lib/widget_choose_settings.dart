import 'dart:io';
import 'dart:typed_data';
import 'package:cafe5_mobile_client/widget_read_qr.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/base_widget.dart';
import 'package:cafe5_mobile_client/socket_message.dart';
import 'package:cafe5_mobile_client/home_page.dart';

import 'client_socket.dart';

class WidgetChooseSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WidgetChooseSettingsState();
  }
}

class WidgetChooseSettingsState extends BaseWidgetState {

  @override
  void handler(Uint8List data) {
    SocketMessage m = new SocketMessage(messageId: 0, command: 0);
    m.setBuffer(data);
    print(m.command);
    switch (m.command) {
      case SocketMessage.c_hello:
        m = SocketMessage(messageId: SocketMessage.messageNumber(), command: SocketMessage.c_auth);
        m.addString(Config.getString(key_server_username));
        m.addString(Config.getString(key_server_password));
        ClientSocket.send(m.data());
        break;
      case SocketMessage.c_auth:
        int userid = m.getInt();
        if (userid > 0) {
          ClientSocket.setSocketState(2);
        }
        break;
    }
  }

  @override
  void authenticate() {
    super.authenticate();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => WidgetHome()), (route) => false);
    //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => WidgetHome()));
  }

  @override
  void disconnected() {
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Image(image: AssetImage(ClientSocket.imageConnectionState()),)
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WidgetReadQR()),
                    ).then((result) {
                      if (result == null) {
                        return;
                      }
                      Barcode? bc = result as Barcode?;
                      List<String> params = bc!.code!.split(";");
                      if (params.length >= 4) {
                        Config.setString(key_server_address, params[0]);
                        Config.setString(key_server_port, params[1]);
                        Config.setString(key_server_username, params[2]);
                        Config.setString(key_server_password, params[3]);
                        Config.setString(key_database_name, params[4]);
                        ClientSocket.init(Config.getString(key_server_address), int.tryParse(Config.getString(key_server_port)) ?? 0);
                      }
                    });
                  },
                  child: Text(tr("Scan from QR code")),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {

                  },
                  child: Text(tr("Input manual")),
                ),
              )
            ]
        )
    );
  }
}