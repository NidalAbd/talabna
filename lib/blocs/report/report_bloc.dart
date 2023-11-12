import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/report/report_event.dart';
import 'package:talbna/blocs/report/report_state.dart';
import 'package:talbna/data/repositories/report_repository.dart';


class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;

  ReportBloc({required ReportRepository repository})
      : _repository = repository,
        super(ReportInitial()) {
    on<ReportRequested>((event, emit) async {
      print('ReportRequested');
      emit(ReportInProgress());
      try {
        final success = await _repository.makeReport(
          id: event.user,
          type: event.type,
          reason: event.reason,
        );
        if (success) {
          print('ReportSuccess');
          emit(ReportSuccess());
        } else {
          print('ReportFailure');
          emit(ReportFailure(error: 'Report operation failed'));
        }
      } catch (e) {
        print('ReportFailure with error: $e');
        emit(ReportFailure(error: e.toString()));
      }
    });
  }

}