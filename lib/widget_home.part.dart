part of 'widget_home.dart';

class WidgetHomeModel  {
  WidgetHomeModel() {
   // BlocProvider.of<AppBloc>(prefs.context()).add(AppEventHttpQuery<AppStateHomePage>('tasks', AppStateHomePage(), {}));
  }
}

extension WidgetHomeExt on WidgetHome {
  void loadTasks() async {
    httpQuery('rwtasklist', AppStateTasks(), {});
  }
}