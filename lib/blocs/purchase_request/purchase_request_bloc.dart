import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/data/repositories/purchase_request_repository.dart';

class PurchaseRequestBloc extends Bloc<PurchaseRequestEvent, PurchaseRequestState> {
  final PurchaseRequestRepository repository;

  PurchaseRequestBloc({required this.repository}) : super(PurchaseRequestInitial()) {
    print('PurchaseRequestBloc created: ${this.hashCode}');

    on<FetchPurchaseRequests>((event, emit) async {
      emit(PurchaseRequestLoading());
      try {
        final requests = await repository.fetchPurchaseRequests(event.userId);
        emit(PurchaseRequestsLoaded(requests));
      } catch (e) {
        emit(PurchaseRequestError(e.toString()));
      }
    });

    on<CreatePurchaseRequest>((event, emit) async {
      try {
        await repository.createPurchaseRequest(event.request);
        emit(PurchaseRequestSuccess());
      } catch (e) {
        emit(PurchaseRequestError(e.toString()));
      }
    });
    on<AddPointsForUser>((event, emit) async {
      try {
        print(event);
        await repository.addPointsForUsers(pointsRequested: event.request, fromUser: event.fromUser, toUser: event.toUser);
        emit(PurchaseRequestSuccess());
      } catch (e) {
        emit(PurchaseRequestError(e.toString()));
      }
    });
    on<FetchUserPointsBalance>((event, emit) async {
      emit(PurchaseRequestLoading());
      try {
        final pointsBalance = await repository.getUserPointsBalance(userId: event.userId);
        emit(UserPointLoadSuccess(pointBalance: pointsBalance,));
      } catch (e) {
        emit(UserPointLoadFailure(error: e.toString()));
      }
    });
    on<CancelPurchaseRequest>((event, emit) async {
      try {
        await repository.cancelPurchaseRequest(event.requestId!);
        emit(PurchaseRequestSuccess());
      } catch (e) {
        emit(PurchaseRequestError(e.toString()));
      }
    });
  }
}
