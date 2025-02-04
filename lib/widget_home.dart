import 'package:cafe5_mobile_client/classes/bloc.dart';
import 'package:cafe5_mobile_client/classes/prefs.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/network_table.dart';
import 'package:cafe5_mobile_client/screens/journal/screen.dart';
import 'package:cafe5_mobile_client/the_task.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:cafe5_mobile_client/workshops.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';

part 'widget_home.part.dart';

class WidgetHome extends App {
  final model = WidgetHomeModel();

  final _networkTable = NetworkTable();

  WidgetHome({super.key}) {
    loadTasks();
  }

  @override
  Widget body(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(listener: (builder, state) {
      if (state is AppStateTasks) {
        _networkTable.readData(state.data);
      }
    }, builder: (builder, state) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                color: Colors.yellow,
                child: Align(
                    alignment: Alignment.center,
                    child: Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        child: InkWell(
                            onTap: () {},
                            child: Text(
                              "ELINA ${Config.getString('appversion')}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ))))),
            Container(
                //color: Colors.green,
                child: SizedBox(
                    height: 40,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2)),
                            backgroundColor: Colors.blueGrey,
                            side: const BorderSide(
                              width: 1.0,
                              color: Colors.black38,
                              style: BorderStyle.solid,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => JournalScreen()));
                          },
                          child: Text(tr("Journal"),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2)),
                            backgroundColor: Colors.blueGrey,
                            side: const BorderSide(
                              width: 1.0,
                              color: Colors.black38,
                              style: BorderStyle.solid,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TheTask(taskId: 0)));
                          },
                          child: Text(tr("New task"),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2)),
                            backgroundColor: Colors.blueGrey,
                            side: const BorderSide(
                              width: 1.0,
                              color: Colors.black38,
                              style: BorderStyle.solid,
                            ),
                          ),
                          onPressed: () {
                            if (_networkTable.selectedIndex < 0) {
                              sd(tr("Select task"));
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TheTask(
                                        taskId: _networkTable.getRawData(
                                            _networkTable.selectedIndex,
                                            0)))).then((value) {
                              loadTasks();
                            });
                          },
                          child: Text(tr("Edit task"),
                              style: TextStyle(color: Colors.white)),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2)),
                            backgroundColor: Colors.blueGrey,
                            side: const BorderSide(
                              width: 1.0,
                              color: Colors.black38,
                              style: BorderStyle.solid,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TheWorkshops()));
                          },
                          child: Text(tr("Workshops"),
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ))),
            Container(
              color: Colors.black12,
              child: Align(
                alignment: Alignment.center,
                child: Text(tr("Current tasks")),
              ),
            ),
            Flexible(flex: 1, child: _mainBody())
          ]);
    });
  }

  Widget _mainBody() {
    if (_networkTable.isEmpty()) {
      return InkWell(
          onTap: () {
            loadTasks();
          },
          child: Text(tr("No data")));
    }
    Map<int, double> colsWidths = {0: 0, 1: 90, 2: 100, 3: 50, 4: 50};
    List<DataColumn> cols = [];
    for (int i = 0; i < _networkTable.columnCount(); i++) {
      DataColumn dataCol = DataColumn(
          label: Container(
              width: colsWidths[i], child: Text(_networkTable.columnName(i))));
      cols.add(dataCol);
    }
    List<DataRow> rows = [];
    for (int i = 0; i < _networkTable.rowCount(); i++) {
      List<DataCell> cells = [];
      for (int c = 0; c < _networkTable.columnCount(); c++) {
        DataCell cell = DataCell(Container(
            width: colsWidths[c],
            child: Text(_networkTable.getDisplayData(i, c))));
        cells.add(cell);
      }
      DataRow dr = DataRow(
          cells: cells,
          selected: i == _networkTable.selectedIndex,
          onSelectChanged: (val) {
            //UPATE STREAM
            _networkTable.selectedIndex = val! ? i : -1;
            BlocProvider.of<AppBloc>(prefs.context()).add(AppEventRefresh());
          });
      rows.add(dr);
    }
    DataTable dt = DataTable(
      columns: cols,
      rows: rows,
      dataRowColor: MaterialStateProperty.resolveWith(_getDataRowColor),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: BlocBuilder<AppBloc, AppState>(
            buildWhen: (p, c) => c is AppStateRefresh,
            builder: (builder, state) {
              return dt;
            }),
      ),
    );
  }

  Color _getDataRowColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };

    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    } else if (states.contains(MaterialState.selected)) {
      return Colors.amberAccent;
    }
    return Colors.transparent;
  }
}
