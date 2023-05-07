import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/data/models/purchase_request.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
class AddPointScreen extends StatefulWidget {
  final int fromUserID;
  final int toUserId;

  const AddPointScreen({Key? key, required this.fromUserID, required this.toUserId})
      : super(key: key);

  @override
  _AddPointScreenState createState() => _AddPointScreenState();
}

class _AddPointScreenState extends State<AddPointScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pointsController = TextEditingController();
  late PurchaseRequestBloc _purchaseRequestBloc;
  @override
  void initState() {
    super.initState();
    _purchaseRequestBloc = context.read<PurchaseRequestBloc>();
  }
  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  Widget _buildRequestList(List<PurchaseRequest> requests, PurchaseRequestBloc bloc) {
    return Expanded(
      child: Column(
        children: List.generate(requests.length, (index) {
          final request = requests[index];
          String statusText;
          IconData statusIcon;
          switch (request.status) {
            case 'approved':
              statusText = 'موافق';
              statusIcon = Icons.check_circle;
              break;
            case 'cancelled':
              statusText = 'ملغى';
              statusIcon = Icons.cancel;
              break;
            default:
              statusText = 'قيد الانتظار';
              statusIcon = Icons.cancel;
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Card(
              child: ListTile(
                title: Text('نقاط:  ${request.pointsRequested}, السعر: ${request.totalPrice}'),
                subtitle: Text(statusText),
                trailing: request.status == 'approved'
                    ? null
                    : IconButton(
                  icon: Icon(statusIcon),
                  onPressed: () {
                    bloc.add(CancelPurchaseRequest(requestId: request.id));
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحويل نقاط'),
        actions:  [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                PointBalance(userId: widget.fromUserID, showBalance: false, ),
              ],
            ),
          ),
        ],
      ),
      body: BlocListener<PurchaseRequestBloc, PurchaseRequestState>(
        bloc: _purchaseRequestBloc,
        listener: (context, state) {
          if (state is PurchaseRequestSuccess) {
            context.read<PurchaseRequestBloc>().add(FetchPurchaseRequests(userId: widget.fromUserID));
          }
        },
        child: BlocBuilder<PurchaseRequestBloc, PurchaseRequestState>(
          bloc: _purchaseRequestBloc,
          builder: (context, state) {
            if (state is PurchaseRequestInitial) {
              context
                  .read<PurchaseRequestBloc>()
                  .add(FetchPurchaseRequests(userId: widget.fromUserID));
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _pointsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'اضافة النقاط المطلوبة',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يجب تحديد عدد النقاط المطلوبة';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'يجب إدخال رقم صحيح لعدد النقاط المطلوبة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final points =
                                  int.parse(_pointsController.text);
                                  context
                                      .read<PurchaseRequestBloc>()
                                      .add(AddPointsForUser(
                                      request: points, fromUser: widget.fromUserID, toUser: widget.toUserId),);
                                  _pointsController.clear();
                                }
                              },
                              child: const Text('تحويل النقاط لهذا المستخدم'),
                            ),
                          ],
                        ),
                      ),
                ),
                if (state is PurchaseRequestsLoaded)
                  _buildRequestList(state.requests, context.read<PurchaseRequestBloc>()),
              ]
            );
          },
        ),
      ),
    );
  }
}