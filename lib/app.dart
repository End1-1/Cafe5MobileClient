import 'package:cafe5_mobile_client/classes/bloc.dart';
import 'package:cafe5_mobile_client/classes/prefs.dart';
import 'package:cafe5_mobile_client/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'classes/styles.dart';

abstract class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            body(context),
            BlocBuilder<AppBloc, AppState>(builder: (context, state) {
              if (state is AppStateLoading) {
                return loading('Loading...');
              } else {
                return Container();
              }
            }),
            BlocBuilder<AppBloc, AppState>(builder: (context, state) {
              if (state is AppStateHttpData) {
                if (state.error) {
                  return errorDialog(state.data);
                }
              }
              return Container();
            }),
          ],
        ),
      ),
    );
  }

  Widget body(BuildContext context);

  Widget loading(String text) {
    return Container(
      height: MediaQuery.sizeOf(prefs.context()).height,
      width: MediaQuery.sizeOf(prefs.context()).width,
      color: Colors.black26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
              height: 30, width: 30, child: CircularProgressIndicator()),
          Styling.columnSpacingWidget(),
          Styling.text(text)
        ],
      ),
    );
  }

  Widget errorDialog(String text) {
    return Container(
        color: Colors.black26,
        child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                        Styling.columnSpacingWidget(),
                        Container(
                            constraints: BoxConstraints(
                                maxHeight:
                                MediaQuery.sizeOf(prefs.context()).height *
                                    0.7),
                            child: SingleChildScrollView(
                                child: Styling.textCenter(text))),
                        Styling.columnSpacingWidget(),
                        Styling.textButton((){
                          BlocProvider.of<AppBloc>(prefs.context()).add(AppEvent());
                        }, 'Փակել')
                      ],
                    ),
                  )
                ])));
  }

  void httpQuery(String route, AppStateHttpData state, Map<String, dynamic> params) {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventHttpQuery(route, state, params));
  }

  Future<void> sd(String msg) async {
    return showDialog<void>(
      context: prefs.context(),
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('Tasks')),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(msg),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(tr("Ok")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sq(String msg, Function yes, Function no) async {
    return showDialog<void>(
      context: prefs.context(),
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr('Tasks')),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(msg),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(tr("Yes")),
              onPressed: () {
                Navigator.of(context).pop();
                yes();

              },
            ),
            TextButton(
              child: Text(tr("No")),
              onPressed: () {
                Navigator.of(context).pop();
                no();

              },
            )
          ],
        );
      },
    );
  }

}