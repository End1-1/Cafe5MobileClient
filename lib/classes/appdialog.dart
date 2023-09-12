import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDialog {
  static Future<void> error(BuildContext context, String msg) async {
    return showDialog(
      context: context, builder: (BuildContext context) {
        return SimpleDialog(
          alignment: Alignment.center,
          children: [
            const Text('Elina', textAlign: TextAlign.center,),
            const Divider(height: 5, color: Colors.black54),
            const SizedBox(height: 10,),
            Text(msg, textAlign: TextAlign.center),
            OutlinedButton(onPressed: (){Navigator.pop(context);}, child: const Text('Ok', textAlign: TextAlign.center),)
          ],
        );
    },
    );
  }

  static Future<String?> getString(BuildContext context, String msg) async {
    final qtyController = TextEditingController();
    return showDialog<String?>(
      context: context, builder: (BuildContext context) {
      return SimpleDialog(
        alignment: Alignment.center,
        children: [
          Text(msg, textAlign: TextAlign.center,),
          const Divider(height: 5, color: Colors.black54),
          const SizedBox(height: 10,),
          Row(children: [
            Expanded(child: Container(margin: const EdgeInsets.fromLTRB(10, 10, 10, 10), child: TextFormField(
              autofocus: true,
              controller: qtyController,
            ))),
          ],),
          Row(children:[
            Expanded(child: Container(),),
            OutlinedButton(onPressed: (){Navigator.pop(context, qtyController.text);}, child: const Text('Ok', textAlign: TextAlign.center)),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: (){Navigator.pop(context);}, child: const Text('Cancel', textAlign: TextAlign.center)),
            Expanded(child: Container(),),
          ])
        ],
      );
    },
    );
  }

  static Future<int?> getInt(BuildContext context, String msg) async {
    final qtyController = TextEditingController();
    return showDialog<int?>(
      context: context, builder: (BuildContext context) {
      return SimpleDialog(
        alignment: Alignment.center,
        children: [
          Text(msg, textAlign: TextAlign.center,),
          const Divider(height: 5, color: Colors.black54),
          const SizedBox(height: 10,),
          Row(children: [
            Expanded(child: Container(margin: const EdgeInsets.fromLTRB(10, 10, 10, 10), child: TextFormField(
              autofocus: true,
              keyboardType: TextInputType.number,
              controller: qtyController,
            ))),
          ],),
          Row(children:[
            Expanded(child: Container(),),
            OutlinedButton(onPressed: (){Navigator.pop(context, int.tryParse(qtyController.text) ?? 0);}, child: const Text('Ok', textAlign: TextAlign.center)),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: (){Navigator.pop(context);}, child: const Text('Cancel', textAlign: TextAlign.center)),
            Expanded(child: Container(),),
          ])
        ],
      );
    },
    );
  }

  static Future<String?> getStringInt(BuildContext context, String msg) async {
    final qtyController = TextEditingController();
    return showDialog<String?>(
      context: context, builder: (BuildContext context) {
      return SimpleDialog(
        alignment: Alignment.center,
        children: [
          Text(msg, textAlign: TextAlign.center,),
          const Divider(height: 5, color: Colors.black54),
          const SizedBox(height: 10,),
          Row(children: [
            Expanded(child: Container(margin: const EdgeInsets.fromLTRB(10, 10, 10, 10), child: TextFormField(
              autofocus: true,
              keyboardType: TextInputType.number,
              controller: qtyController,
            ))),
          ],),
          Row(children:[
            Expanded(child: Container(),),
            OutlinedButton(onPressed: (){Navigator.pop(context, qtyController.text);}, child: const Text('Ok', textAlign: TextAlign.center)),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: (){Navigator.pop(context);}, child: const Text('Cancel', textAlign: TextAlign.center)),
            Expanded(child: Container(),),
          ])
        ],
      );
    },
    );
  }

  static Future<bool?> question(BuildContext context, String msg) async {
    return showDialog<bool?>(
      context: context, builder: (BuildContext context) {
      return SimpleDialog(
        alignment: Alignment.center,
        children: [
          Text(msg, textAlign: TextAlign.center,),
          const Divider(height: 5, color: Colors.black54),
          const SizedBox(height: 10,),
          Row(children:[
            Expanded(child: Container(),),
            OutlinedButton(onPressed: (){Navigator.pop(context, true);}, child: const Text('Yes', textAlign: TextAlign.center)),
            const SizedBox(width: 10),
            OutlinedButton(onPressed: (){Navigator.pop(context, false);}, child: const Text('Cancel', textAlign: TextAlign.center)),
            Expanded(child: Container(),),
          ])
        ],
      );
    },
    );
  }
}