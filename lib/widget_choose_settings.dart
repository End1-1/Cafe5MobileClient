import 'package:flutter/material.dart';

class WidgetChooseSettings extends StatelessWidget {

  const WidgetChooseSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row (
        children: [
          Container(
            child: GestureDetector (
              onTap: () {

              },
              child: Text("Scan from QR code"),
            ),
          ),
          Container(
            child: GestureDetector (
              onTap: (){

              },
              child: Text("Input manual"),
            ),
          )
        ],
      )
    );
  }

}