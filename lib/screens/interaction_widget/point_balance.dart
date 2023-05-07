import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';

class PointBalance extends StatefulWidget {
  const PointBalance({Key? key, required this.userId, required this.showBalance,}) : super(key: key);
  final int userId;
  final bool showBalance;
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PurchaseRequestScreen(
                          userID: widget.userId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 26,
                  ),
                  label: Visibility(
                    visible: widget.showBalance,
                    child: Text(
                      pointBalance.totalPoint.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 5,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
              ],
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

