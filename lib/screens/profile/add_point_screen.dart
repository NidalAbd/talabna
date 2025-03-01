import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/data/models/purchase_request.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:intl/intl.dart';
import '../../provider/language.dart';

class AddPointScreen extends StatefulWidget {
  final int fromUserID;
  final int toUserId;

  const AddPointScreen({super.key, required this.fromUserID, required this.toUserId});

  @override
  _AddPointScreenState createState() => _AddPointScreenState();
}

class _AddPointScreenState extends State<AddPointScreen> {
  final _formKey = GlobalKey<FormState>();
  final Language _language = Language();
  final _pointsController = TextEditingController();
  late PurchaseRequestBloc _purchaseRequestBloc;
  late int? currentUserId = 0;
  bool _isLoading = false;

  // Quick selection points
  final List<int> _quickPoints = [50, 100, 200, 500];

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

  void _selectPoints(int points) {
    setState(() {
      _pointsController.text = points.toString();
    });
  }

  Widget _buildRequestList(List<PurchaseRequest> requests, PurchaseRequestBloc bloc) {
    // Get the current language from the Language class
    final currentLang = _language.getLanguage();

    if (requests.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                currentLang == "ar" ? 'لا توجد معاملات سابقة' : 'No previous transactions',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500
                ),
              )
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              currentLang == "ar" ? 'المعاملات السابقة' : 'Previous Transactions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                String statusText;
                Color statusColor;
                IconData statusIcon;

                switch (request.status) {
                  case 'approved':
                    statusText = currentLang == "ar" ? 'تمت الموافقة' : 'Approved';
                    statusIcon = Icons.check_circle;
                    statusColor = Colors.green;
                    break;
                  case 'cancelled':
                    statusText = currentLang == "ar" ? 'ملغاة' : 'Cancelled';
                    statusIcon = Icons.cancel;
                    statusColor = Colors.red;
                    break;
                  default:
                    statusText = currentLang == "ar" ? 'قيد الانتظار' : 'Pending';
                    statusIcon = Icons.pending;
                    statusColor = Colors.orange;
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.2),
                      child: Icon(statusIcon, color: statusColor),
                    ),
                    title: Row(
                      children: [
                        Text(
                          currentLang == "ar"
                              ? 'النقاط: ${request.pointsRequested}'
                              : 'Points: ${request.pointsRequested}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          currentLang == "ar"
                              ? 'السعر: ${request.totalPrice}'
                              : 'Price: ${request.totalPrice}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (request.status != 'approved' && request.status != 'cancelled')
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              icon: const Icon(Icons.close, size: 16),
                              label: Text(
                                currentLang == "ar" ? 'إلغاء' : 'Cancel',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                bloc.add(CancelPurchaseRequest(requestId: request.id));
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_language.tConvertPointsText()),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PointBalance(
              userId: widget.fromUserID,
              showBalance: false,
              canClick: false,
            ),
          ),
        ],
      ),
      body: BlocListener<PurchaseRequestBloc, PurchaseRequestState>(
        bloc: _purchaseRequestBloc,
        listener: (context, state) {
          if (state is PurchaseRequestLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });

            if (state is PurchaseRequestSuccess) {
              final currentLang = _language.getLanguage();
              String message = currentLang == "ar"
                  ? 'تم تحويل ${_pointsController.text} نقطة إلى المستخدم ${widget.toUserId}'
                  : 'Successfully transferred ${_pointsController.text} points to user ${widget.toUserId}';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green.shade700,
                ),
              );

              context.read<PurchaseRequestBloc>().add(
                FetchPurchaseRequests(userId: widget.fromUserID),
              );

              _pointsController.clear();
            } else if (state is PurchaseRequestError) {
              final currentLang = _language.getLanguage();
              final message = currentLang == "ar"
                  ? 'ليس لديك رصيد كافٍ في حسابك'
                  : 'You don\'t have enough balance in your account';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.red.shade700,
                ),
              );

              _pointsController.clear();
              print(state.message);
            }
          }
        },
        child: BlocBuilder<PurchaseRequestBloc, PurchaseRequestState>(
          bloc: _purchaseRequestBloc,
          builder: (context, state) {
            if (state is PurchaseRequestInitial) {
              context.read<PurchaseRequestBloc>().add(
                FetchPurchaseRequests(userId: widget.fromUserID),
              );
            }

            final currentLang = _language.getLanguage();
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and explanation
                        Text(
                          currentLang == "ar" ? 'تحويل النقاط' : 'Transfer Points',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentLang == "ar"
                              ? 'أدخل عدد النقاط التي تريد تحويلها إلى المستخدم.'
                              : 'Enter the number of points you want to transfer to the user.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Quick selection buttons
                        Text(
                          currentLang == "ar" ? 'اختيار سريع:' : 'Quick selection:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _quickPoints.map((points) =>
                              ElevatedButton(
                                onPressed: () => _selectPoints(points),
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                child: Text(points.toString()),
                              )
                          ).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Points input field
                        TextFormField(
                          controller: _pointsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: currentLang == "ar"
                                ? 'عدد النقاط'
                                : 'Number of Points',
                            hintText: currentLang == "ar"
                                ? 'أدخل عدد النقاط'
                                : 'Enter points amount',
                            prefixIcon: const Icon(Icons.star_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 2,
                              ),
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return currentLang == "ar"
                                  ? 'يرجى إدخال عدد النقاط'
                                  : 'Please enter the number of points';
                            }
                            if (int.tryParse(value) == null) {
                              return currentLang == "ar"
                                  ? 'يجب إدخال رقم صحيح'
                                  : 'Please enter a valid number';
                            }
                            if (int.parse(value) <= 0) {
                              return currentLang == "ar"
                                  ? 'يجب أن تكون النقاط أكبر من صفر'
                                  : 'Points must be greater than zero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Theme.of(context).primaryColor,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                final points = int.parse(_pointsController.text);
                                context.read<PurchaseRequestBloc>().add(
                                  AddPointsForUser(
                                    request: points,
                                    fromUser: widget.fromUserID,
                                    toUser: widget.toUserId,
                                  ),
                                );
                              }
                            },
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              currentLang == "ar" ? 'تحويل النقاط' : 'Transfer Points',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transactions list
                if (state is PurchaseRequestsLoaded)
                  _buildRequestList(state.requests, context.read<PurchaseRequestBloc>()),

                // Loading state
                if (state is PurchaseRequestLoading && !_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}