import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';

class PointBalance extends StatefulWidget {
  const PointBalance({Key? key, required this.userId,}) : super(key: key);
  final int userId;

  @override
  State<PointBalance> createState() => _PointBalanceState();
}

class _PointBalanceState extends State<PointBalance> {
  late PurchaseRequestBloc _purchaseRequestBloc;

  @override
  void initState() {
    super.initState();
    _purchaseRequestBloc = context.read<PurchaseRequestBloc>();
    initUserId();
  }

  void initUserId() async {
    _purchaseRequestBloc.add(FetchUserPointsBalance( userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseRequestBloc, PurchaseRequestState>(
      bloc: _purchaseRequestBloc,
      builder: (context, state) {
        if (state is UserPointLoadSuccess) {
          final pointBalance = state.pointBalance;
          return Directionality(
            textDirection: TextDirection.rtl,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) =>
                        PurchaseRequestScreen(
                          userID: widget.userId,
                        ),
                  ),
                );
              },
              icon: const Icon(Icons.paid , color: Colors.white,),
              label: Text(pointBalance.totalPoint.toString() ,style: const TextStyle( color: Colors.white,),),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          );
        } else if (state is UserPointLoadFailure) {
          return ErrorWidget(state.error);
        }else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
