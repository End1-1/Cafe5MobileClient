import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:cafe5_mobile_client/classes/small_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class ListScreen extends StatelessWidget {
  final model = ListScreenModel();
  final int query;
  final String title;

  ListScreen(this.title, this.query, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
              children: [
                Row(children: [
                  SmallButton("images/back.png", () => Navigator.pop(context)),
                  Expanded(child:
                    Container(alignment: Alignment.center, child: Text(title))),
                  SmallButton("images/done.png", () => Navigator.pop(context)),
                ]),
                const Divider(height: 2, color: Colors.black54),
                Expanded(
                  child: StreamBuilder<Map<String, dynamic>?>(
                    stream: model.dataStream.stream,
                    builder: (context, snapshot) {
                      if (snapshot.data ==  null) {
                        model.getList(query);
                        return const Center(child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()));
                      }
                      if (snapshot.data![HttpQuery.kStatus] != HttpQuery.hrOk) {
                        return Center(child: Text(snapshot.data![HttpQuery.kData], textAlign: TextAlign.center,));
                      }
                      switch(query) {
                        case HttpQuery.qListOfTasks:
                          return _listOfTasks(context);
                        default:
                          return Container();
                      }
                    },
                  )
                )
              ],
            )));
  }

  Widget _listOfTasks(BuildContext context) {
    return ListView.builder(
      itemCount: model.tasks.length,
        itemBuilder: (context, i) {
        final t = model.tasks[i];
          return InkWell(onTap: (){
            Navigator.pop(context, t);
          },
            child: Container(margin: const EdgeInsets.fromLTRB(5, 10, 5, 10), child: Text(t.f_name))
          );
        });
  }

}