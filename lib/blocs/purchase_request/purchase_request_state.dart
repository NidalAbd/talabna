import 'package:talbna/data/models/point_balance.dart';
import 'package:talbna/data/models/purchase_request.dart';

abstract class PurchaseRequestState {}

class PurchaseRequestInitial extends PurchaseRequestState {}

class PurchaseRequestLoading extends PurchaseRequestState {}

class PurchaseRequestsLoaded extends PurchaseRequestState {
  final List<PurchaseRequest> requests;

  PurchaseRequestsLoaded(this.requests);
}
class UserPointLoadSuccess extends PurchaseRequestState {
  final PointBalance pointBalance;

   UserPointLoadSuccess({required this.pointBalance});

  List<Object> get props => [pointBalance];
}
class PurchaseRequestSuccess extends PurchaseRequestState {

} // Add this line

class PurchaseRequestError extends PurchaseRequestState {
  final String message;

  PurchaseRequestError(this.message);
  List<Object> get props => [message];
}

class UserPointLoadFailure extends PurchaseRequestState {
  final String error;

   UserPointLoadFailure({required this.error});

  List<Object> get props => [error];
}