import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}

class ReportRequested extends ReportEvent {
  final int user;
  final String type;
  final String reason;
  const ReportRequested({required this.user ,required this.type, required this.reason, });
}

