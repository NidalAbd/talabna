import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';

class PointBalance extends StatefulWidget {
  const PointBalance({super.key, required this.userId, required this.showBalance, required this.canClick,});
  final int userId;
  final bool showBalance;
  final bool canClick;
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
               widget.canClick? Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PurchaseRequestScreen(
                      userID: widget.userId,
                    ),
                  ),
                ): null;
              },
              icon: const Icon(
                Icons.add_circle,
              ),
              label: widget.showBalance ?Text(
                pointBalance.totalPoint.toString(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ): const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '***',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ), // Set your desired background color
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

