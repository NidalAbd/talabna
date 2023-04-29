import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'internet_event.dart';
import 'internet_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc() : super(NetworkInitial()) {
    on<NetworkObserve>(_observe);
    on<NetworkNotify>(_notifyStatus);
  }

  void _observe(NetworkObserve event, Emitter<NetworkState> emit) {
    InternetConnectionChecker().onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        emit(NetworkSuccess());
      } else {
        emit(NetworkFailure());
      }
    });
  }

  void _notifyStatus(NetworkNotify event, Emitter<NetworkState> emit) {}

  @override
  Future<void> close() {
    InternetConnectionChecker().hasConnection;
    return super.close();
  }
}
