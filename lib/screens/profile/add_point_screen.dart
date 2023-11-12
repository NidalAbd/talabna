import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/data/models/purchase_request.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';

import '../../provider/language.dart';
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
  final Language _language = Language();
  //_language.tConvertPointsText()
  final _pointsController = TextEditingController();
  late PurchaseRequestBloc _purchaseRequestBloc;
  late int? currentUserId = 0;
  @override
  void initState() {
    super.initState();
    _purchaseRequestBloc = context.read<PurchaseRequestBloc>();
    initializeUserId();
  }
  void initializeUserId() {
    getUserId().then((userId) {
      setState(() {
        currentUserId = userId;
      });
    });
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
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
        title:  Text(_language.tConvertPointsText()),
        actions:  [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                PointBalance(userId: widget.fromUserID, showBalance: false,canClick: false, ),
              ],
            ),
          ),
        ],
      ),
      body: BlocListener<PurchaseRequestBloc, PurchaseRequestState>(
        bloc: _purchaseRequestBloc,
        listener: (context, state) {
          if (state is PurchaseRequestSuccess) {
            String message = 'You have transfer ${_pointsController.text} to ${widget.toUserId}';
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 2),
              ),
            );
            context.read<PurchaseRequestBloc>().add(FetchPurchaseRequests(userId: widget.fromUserID));
            _pointsController.clear();
          }else if(state is PurchaseRequestError){
            const message = 'You don\'t have balance on you account';
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(message),
                duration: Duration(seconds: 2),
              ),
            );
            _pointsController.clear();
            return print(state.message);
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
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextFormField(
                                controller: _pointsController,
                                keyboardType: TextInputType.number,
                                decoration:  InputDecoration(
                                  labelText: _language.getAddRequiredPointsText(),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return _language.getRequiredPointsText();
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'يجب إدخال رقم صحيح لعدد النقاط المطلوبة';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            FractionallySizedBox(
                              widthFactor: 1.0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          5), // Adjust the radius as per your requirement
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final points =
                                    int.parse(_pointsController.text);
                                    context
                                        .read<PurchaseRequestBloc>()
                                        .add(AddPointsForUser(
                                        request: points, fromUser: widget.fromUserID, toUser: widget.toUserId),);
                                  }
                                },
                                child:  Text( _language.tConvertPointsText()),
                              ),
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