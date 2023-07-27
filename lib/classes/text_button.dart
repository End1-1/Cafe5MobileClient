import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TxtButton extends StatelessWidget {
  final Function () callback;
  final String text;
  const TxtButton(this.text, this.callback, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: callback, child: Container(
      alignment: Alignment.center,
        height: 40,
        child: Text(text, style: const TextStyle(color: Colors.indigo, fontSize: 16, fontWeight: FontWeight.bold))
    ));
  }

}