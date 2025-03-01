import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/data/models/purchase_request.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:talbna/screens/profile/user_seller.dart';

import '../../provider/language.dart';

class PurchaseRequestScreen extends StatefulWidget {
  final int userID;

  const PurchaseRequestScreen({Key? key, required this.userID}) : super(key: key);

  @override
  PurchaseRequestScreenState createState() => PurchaseRequestScreenState();
}

class PurchaseRequestScreenState extends State<PurchaseRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pointsController = TextEditingController();
  late PurchaseRequestBloc _purchaseRequestBloc;
  final Language _language = Language();
  int _selectedPoints = 100;
  final List<int> _predefinedPoints = [100, 200, 500, 1000, 2000];

  @override
  void initState() {
    super.initState();
    _purchaseRequestBloc = context.read<PurchaseRequestBloc>();
    _pointsController.text = _selectedPoints.toString();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  void _setClipboardData(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _language.getLanguage() == 'ar'
                ? 'تم نسخ الرقم التعريفي: $text'
                : 'ID copied: $text'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPointSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
          child: Text(
            _language.getLanguage() == 'ar' ? 'اختر قيمة النقاط:' : 'Select points value:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _predefinedPoints.map((points) {
              final isSelected = _selectedPoints == points;
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPoints = points;
                      _pointsController.text = points.toString();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$points',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isSelected
                                ? Theme.of(context).primaryTextTheme.titleLarge?.color
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _language.getLanguage() == 'ar'
                              ? '${(points * 7.5).toStringAsFixed(0)} شيكل'
                              : '${(points * 7.5).toStringAsFixed(0)} ILS',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Theme.of(context).primaryTextTheme.bodyMedium?.color?.withOpacity(0.7)
                                : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomPointsInput() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _language.getLanguage() == 'ar' ? 'أو أدخل قيمة مخصصة:' : 'Or enter custom value:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              maxLength: 5,
              decoration: InputDecoration(
                labelText: _language.getRequiredPointsText(),
                hintText: _language.getLanguage() == 'ar'
                    ? 'أدخل عدد النقاط المطلوبة'
                    : 'Enter required points',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                suffixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.star, color: Theme.of(context).colorScheme.secondary, size: 24),
                ),
                counterText: '',
              ),
              style: const TextStyle(fontSize: 16),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final points = int.tryParse(value);
                  if (points != null) {
                    setState(() {
                      if (_predefinedPoints.contains(points)) {
                        _selectedPoints = points;
                      } else {
                        _selectedPoints = -1; // Custom value
                      }
                    });
                  }
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _language.getLanguage() == 'ar'
                      ? 'يجب تحديد عدد النقاط المطلوبة'
                      : 'Please specify the required points';
                }
                if (int.tryParse(value) == null) {
                  return _language.getLanguage() == 'ar'
                      ? 'يجب إدخال رقم صحيح لعدد النقاط المطلوبة'
                      : 'Please enter a valid integer for points';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _language.getLanguage() == 'ar' ? 'السعر الإجمالي:' : 'Total Price:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  _language.getLanguage() == 'ar'
                      ? '${_calculateTotalPrice()} شيكل'
                      : '${_calculateTotalPrice()} ILS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotalPrice() {
    final points = int.tryParse(_pointsController.text) ?? 0;
    return (points * 7.5).toStringAsFixed(2);
  }

  Widget _buildPurchaseButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
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
            _purchaseRequestBloc.add(CreatePurchaseRequest(request: request));
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 24),
            const SizedBox(width: 8),
            Text(
              _language.tPurchasePointsText(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<PurchaseRequest> requests) {
    if (requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  _language.getLanguage() == 'ar' ? 'قائمة الطلبات السابقة' : 'Previous Requests',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length > 3 ? 3 : requests.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).dividerColor),
            itemBuilder: (context, index) {
              final request = requests[index];
              IconData statusIcon;
              Color statusColor;
              String statusText;

              // Status colors should come from theme but we need to represent states
              switch (request.status) {
                case 'approved':
                  statusIcon = Icons.check_circle;
                  statusColor = Theme.of(context).colorScheme.primary;
                  statusText = _language.getLanguage() == 'ar' ? 'موافق' : 'Approved';
                  break;
                case 'cancelled':
                  statusIcon = Icons.cancel;
                  statusColor = Theme.of(context).colorScheme.error;
                  statusText = _language.getLanguage() == 'ar' ? 'ملغى' : 'Cancelled';
                  break;
                default:
                  statusIcon = Icons.pending;
                  statusColor = Theme.of(context).colorScheme.secondary;
                  statusText = _language.getLanguage() == 'ar' ? 'قيد الانتظار' : 'Pending';
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor),
                ),
                title: Text(
                  _language.getLanguage() == 'ar'
                      ? 'نقاط: ${request.pointsRequested}'
                      : 'Points: ${request.pointsRequested}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      _language.getLanguage() == 'ar'
                          ? 'السعر: ${request.totalPrice?.toStringAsFixed(2)} شيكل'
                          : 'Price: ${request.totalPrice?.toStringAsFixed(2)} ILS',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: request.status == 'pending'
                    ? IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                  onPressed: () {
                    _purchaseRequestBloc.add(CancelPurchaseRequest(requestId: request.id));
                  },
                )
                    : null,
              );
            },
          ),
          if (requests.length > 3)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Show all requests
                  },
                  child: Text(
                    _language.getLanguage() == 'ar' ? 'عرض جميع الطلبات' : 'View all requests',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  _language.getLanguage() == 'ar' ? 'تعليمات الشراء' : 'Purchase Instructions',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _language.getPurchaseInstructionText(),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _language.getLanguage() == 'ar' ? 'الرقم التعريفي الخاص بك:' : 'Your ID:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.userID}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_copy, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _setClipboardData(widget.userID.toString()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _language.tPurchasePointsText(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PointBalance(
              userId: widget.userID,
              showBalance: true,
              canClick: false,
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<PurchaseRequestBloc, PurchaseRequestState>(
          bloc: _purchaseRequestBloc,
          listener: (context, state) {
            if (state is PurchaseRequestSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      _language.getLanguage() == 'ar'
                          ? 'تم إنشاء طلب النقاط بنجاح'
                          : 'Points request created successfully'
                  ),
                ),
              );
              _purchaseRequestBloc.add(FetchPurchaseRequests(userId: widget.userID));
            }
          },
          child: BlocBuilder<PurchaseRequestBloc, PurchaseRequestState>(
            bloc: _purchaseRequestBloc,
            builder: (context, state) {
              if (state is PurchaseRequestInitial) {
                _purchaseRequestBloc.add(FetchPurchaseRequests(userId: widget.userID));
                return const Center(child: CircularProgressIndicator());
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildPointSelector(),
                    _buildCustomPointsInput(),
                    _buildPurchaseButton(),
                    if (state is PurchaseRequestsLoaded) _buildRequestsList(state.requests),
                    _buildInstructionsCard(),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      constraints: BoxConstraints(
                        minHeight: 100, // Set a minimum height
                        maxHeight: 500, // Set a maximum height
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: UserSellerScreen(userID: widget.userID),
                        ),
                      ),
                    )                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}