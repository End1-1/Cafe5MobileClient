import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmallButton extends StatelessWidget {
  final Function () callback;
  final String image;
  const SmallButton(this.image, this.callback, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: callback, child: Container(
      width: 40,
      height: 40,
      child: Image.asset(image)
    ));
  }

}