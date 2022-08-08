import 'package:cafe5_mobile_client/client_socket.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/db.dart';
import 'package:cafe5_mobile_client/widget_choose_settings.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.init();
  Db.init(dbCreate);
  ClientSocket.init(Config.getString(key_server_address), int.tryParse(Config.getString(key_server_port)) ?? 0);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafe5MobileClient',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: WidgetChooseSettings(),
    );
  }
}