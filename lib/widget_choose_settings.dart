import 'package:cafe5_mobile_client/app.dart';
import 'package:cafe5_mobile_client/classes/bloc.dart';
import 'package:cafe5_mobile_client/classes/styles.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/home_page.dart';
import 'package:cafe5_mobile_client/screens/journal/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WidgetChooseSettings extends App {
  final _pinController = TextEditingController();

  WidgetChooseSettings({super.key});

  @override
  Widget body(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
        listener: (context, state) {
          if (state is AppStateLoginSuccess) {
            if (state.error) {
              return;
            }
          //   Navigator.pushAndRemoveUntil(
          //       context,
          //       MaterialPageRoute(
          //           builder: (BuildContext context) => WidgetHome()),
          //       (route) => false);
          // }
            Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => JournalScreen()),
                    (route) => false);
              }
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              rowSpace(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Image.asset('images/logo_big.png')]),
              rowSpace(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.5),
                          child: Styling.textFormField(_pinController, 'ՊԻՆ')))
                ],
              ),
              rowSpace(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Styling.textButton(() {
                    httpQuery('login', AppStateLoginSuccess(),
                        {'pin': _pinController.text, 'method': 2});
                  }, 'Մուտք')
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  Config.getString('lasterror'),
                ),
              ),
              Expanded(child: Container()),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {},
                  child: Text(Config.getString('appversion')),
                ),
              ),
            ]));
  }
}
