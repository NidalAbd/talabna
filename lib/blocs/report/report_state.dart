import 'package:equatable/equatable.dart';
import 'package:talbna/data/models/report.dart';

abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportInProgress extends ReportState {}

class ReportSuccess extends ReportState {

}

class ReportFailure extends ReportState{
  final String error;
  const ReportFailure({ required this.error});
  @override
  List<Object> get props => [error];
}



