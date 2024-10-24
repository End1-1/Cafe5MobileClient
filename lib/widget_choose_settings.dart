import 'package:cafe5_mobile_client/app.dart';
import 'package:cafe5_mobile_client/classes/bloc.dart';
import 'package:cafe5_mobile_client/classes/styles.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/home_page.dart';
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
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => WidgetHome()),
                (route) => false);
          }
        },
        child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Styling.textFormField(_pinController, 'ՊԻՆ'))
                ],
              ),
              Row(
                children: [
                  Styling.textButton(() {
                    httpQuery('/engine/login.php', AppStateLoginSuccess(),
                        {'pin': _pinController.text, 'method': 1});
                  }, 'Մուտք')
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {},
                  child: Text(Config.getString('appversion')),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  Config.getString('lasterror'),
                ),
              ),
            ]));
  }
}
