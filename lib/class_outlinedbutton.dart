import 'package:flutter/material.dart';

class ClassOutlinedButton {
  static Widget createImage(Function f, String img, {double h = 36, double w = 36}) {
    return Container(
        width: w,
        height: h,
        margin: EdgeInsets.only(left: 5),
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.all(2),
            ),
            onPressed: () {
              f();
            },
            child: Image.asset(img, width: w, height: h)));
  }
}