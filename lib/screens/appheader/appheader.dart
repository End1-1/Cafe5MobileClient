import 'package:cafe5_mobile_client/classes/small_button.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final Widget body;
  final String title;

  const AppHeader(this.title, this.body, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            minimum: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                SmallButton("images/back.png", () => Navigator.pop(context)),
                Expanded(child: Container(
                    margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Text(title, maxLines: 2, ))),
                Expanded(child: Container())
              ]),
              const Divider(
                height: 5,
                color: Colors.black54,
              ),
              Expanded(child: body)
            ])));
  }
}
