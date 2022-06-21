import 'package:cafe5_mobile_client/widget_read_qr.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class WidgetChooseSettings extends StatelessWidget {

  const WidgetChooseSettings();

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
              child: GestureDetector (
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WidgetReadQR()),
                  ).then((result) {
                    if (result == null) {
                      return;
                    }
                    Barcode? bc = result as Barcode?;
                    print(bc!.format);
                  });
                },
                child: Text("Scan from QR code"),
              ),
            ),
          Align(
            alignment: Alignment.center,
              child: GestureDetector (
                onTap: (){

                },
                child: Text("Input manual"),
              ),
            )
          ]
      )
    );
  }

}