import 'package:cafe5_mobile_client/classes/http_query.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStateLoading extends AppState{}

class AppStateHttpData extends AppState {
  late bool error;
  late dynamic data;
  AppStateHttpData();
}

class AppStateWorkshop extends AppStateHttpData {

}

class AppStateHomePage extends AppStateHttpData{}

class AppStateLoginSuccess extends AppStateHttpData {}

class AppStateTasks extends AppStateHttpData{}

class AppEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class AppEventHttpQuery<T extends AppStateHttpData> extends AppEvent {
  final String route;
  final Map<String, dynamic> params;
  final T state ;
  AppEventHttpQuery(this.route, this.state, this.params);

}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(super.initialState)  {
    on<AppEvent>((event, emit) => emit(AppState()));
  }
  
  void httpQuery(AppEventHttpQuery e) async {
    emit(AppStateLoading());
    final result = await HttpQuery(e.route).request(e.params);
    e.state.error = result['status'] != 1;
    e.state.data = result['data'];
    emit(e.state);
  }
}