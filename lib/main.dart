import 'package:cafe5_mobile_client/classes/bloc.dart';
import 'package:cafe5_mobile_client/classes/prefs.dart';
import 'package:cafe5_mobile_client/config.dart';
import 'package:cafe5_mobile_client/widget_choose_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.init();
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    Config.setString('appversion', '$version.$buildNumber');
  });
  Config.setString(key_database_name, 'store');

  runApp(
    MultiBlocProvider(providers: [
      BlocProvider<AppBloc>(create: (create) => AppBloc(AppState()))
    ], child: const MyApp())
      );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elina workshop',
      key: Prefs.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: WidgetChooseSettings(),
      
    );
  }
}