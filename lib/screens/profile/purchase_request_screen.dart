import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/data/models/purchase_request.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:talbna/screens/profile/user_seller.dart';

class PurchaseRequestScreen extends StatefulWidget {
  final int userID;

  const PurchaseRequestScreen({Key? key, required this.userID})
      : super(key: key);

  @override
  PurchaseRequestScreenState createState() => PurchaseRequestScreenState();
}

class PurchaseRequestScreenState extends State<PurchaseRequestScreen> with SingleTickerProviderStateMixin{
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

  Widget _buildRequestList(
      List<PurchaseRequest> requests, PurchaseRequestBloc bloc) {
    return SizedBox(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'قائمة الطلبات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Column(
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.lightForegroundColor
                      : AppTheme.darkForegroundColor,
                  child: ListTile(
                    leading: const Icon(Icons.watch_later),
                    title: Text(
                        'نقاط:  ${request.pointsRequested}, السعر: ${request.totalPrice}'),
                    subtitle: Text(statusText),
                    trailing: request.status == 'approved'
                        ? null
                        : IconButton(
                            icon: Icon(statusIcon),
                            onPressed: () {
                              bloc.add(
                                  CancelPurchaseRequest(requestId: request.id));
                            },
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  void _setClipboardData(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات النقاط'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PointBalance(
                  userId: widget.userID,
                  showBalance: true, canClick: true,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: BlocListener<PurchaseRequestBloc, PurchaseRequestState>(
          bloc: _purchaseRequestBloc,
          listener: (context, state) {
            if (state is PurchaseRequestSuccess) {
              context
                  .read<PurchaseRequestBloc>()
                  .add(FetchPurchaseRequests(userId: widget.userID));
            }
          },
          child: BlocBuilder<PurchaseRequestBloc, PurchaseRequestState>(
            bloc: _purchaseRequestBloc,
            builder: (context, state) {
              if (state is PurchaseRequestInitial) {
                context
                    .read<PurchaseRequestBloc>()
                    .add(FetchPurchaseRequests(userId: widget.userID));
              }
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextFormField(
                            controller: _pointsController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            decoration: const InputDecoration(
                              labelText: 'النقاط المطلوبة',
                              hintText: 'أدخل عدد النقاط المطلوبة',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Customize the color here
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              suffixIcon: Icon(Icons.star, color: Colors.amber),
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
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final points = int.parse(_pointsController.text);
                              final request = PurchaseRequest(
                                userId: widget.userID,
                                pointsRequested: points,
                                pricePerPoint: 7.5,
                                totalPrice: points * 7.5,
                                status: 'pending',
                                createdAt: null,
                                updatedAt: null,
                              );
                              context
                                  .read<PurchaseRequestBloc>()
                                  .add(CreatePurchaseRequest(request: request));
                              _pointsController.clear();
                            }
                          },
                          child: const Text(
                            'طلب شراء نقاط',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is PurchaseRequestsLoaded)
                   _buildRequestList(state.requests, context.read<PurchaseRequestBloc>()),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Card(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.lightForegroundColor
                        : AppTheme.darkForegroundColor,
                    child:  ListTile(
                      contentPadding: const EdgeInsets.all(8),
                      leading: const Icon(Icons.info),
                      title: Text(
                        'بعد إرسال الطلب بعدد النقاط المطلوبة،قم بنسخ الرقم التعريفي (${widget.userID}) وتواصل مع فريق المبيعات لاتمام عملية الشراء ',
                        style:  const TextStyle(

                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      trailing: IconButton(
                          onPressed: () =>
                              _setClipboardData(widget.userID.toString()),
                          icon: const Icon(Icons.copy)),
                    ),
                  ),
                ),
                SizedBox(
                    height: 370,
                    width: double.infinity ,
                    child: UserSellerScreen(userID: widget.userID)),
              ]);
            },
          ),
        ),
      ),
    );
  }
}
