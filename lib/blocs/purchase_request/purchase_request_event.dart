import 'package:talbna/data/models/purchase_request.dart';

abstract class PurchaseRequestEvent {}

class FetchPurchaseRequests extends PurchaseRequestEvent {
  final int userId;

  FetchPurchaseRequests({required this.userId});
}
class FetchUserPointsBalance extends PurchaseRequestEvent {
  final int userId;

   FetchUserPointsBalance({required this.userId});

  List<Object> get props => [userId];
}
class CreatePurchaseRequest extends PurchaseRequestEvent {
  final PurchaseRequest request;

  CreatePurchaseRequest({required this.request});
}
class AddPointsForUser extends PurchaseRequestEvent {
  final int request;
  final int fromUser;
  final int toUser;

  AddPointsForUser({required this.request , required this.fromUser, required this.toUser,});
}
class CancelPurchaseRequest extends PurchaseRequestEvent {
  final int? requestId;

  CancelPurchaseRequest({required this.requestId});
}
