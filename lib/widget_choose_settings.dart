import 'package:cafe5_mobile_client/widget_read_qr.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/base_widget.dart';

import 'client_socket.dart';

class WidgetChooseSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WidgetChooseSettingsState();
  }

}

class WidgetChooseSettingsState extends BaseWidgetState {

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