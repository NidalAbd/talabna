import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_event.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/data/models/purchase_request.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:talbna/screens/profile/user_seller.dart';

import '../../app_theme.dart';
import '../../provider/language.dart';

class PurchaseRequestScreen extends StatefulWidget {
  final int userID;

  const PurchaseRequestScreen({super.key, required this.userID});

  @override
  State<PurchaseRequestScreen> createState() => PurchaseRequestScreenState();
}

class PurchaseRequestScreenState extends State<PurchaseRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pointsController = TextEditingController();
  late PurchaseRequestBloc _purchaseRequestBloc;
  final Language _language = Language();
  int _selectedPoints = 100;
  final List<int> _predefinedPoints = [5, 10, 50, 100, 200, 500];

  // Purchase process step tracking
  int _currentStep = 0;

  // History visibility
  bool _historyExpanded = true;

  @override
  void initState() {
    super.initState();
    _purchaseRequestBloc = context.read<PurchaseRequestBloc>();
    _pointsController.text = _selectedPoints.toString();

    // Fetch requests immediately on screen load
    _purchaseRequestBloc.add(FetchPurchaseRequests(userId: widget.userID));
    print("Fetching purchase requests for user ID: ${widget.userID}");
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          _language.tPurchasePointsText(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onBackground,
        ),
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
        child: BlocConsumer<PurchaseRequestBloc, PurchaseRequestState>(
          bloc: _purchaseRequestBloc,
          listenWhen: (previous, current) => current is PurchaseRequestSuccess,
          listener: (context, state) {
            if (state is PurchaseRequestSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _language.getLanguage() == 'ar'
                        ? 'تم إنشاء طلب النقاط بنجاح'
                        : 'Points request created successfully',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(12),
                ),
              );
              // Refresh requests immediately after successful submission
              _purchaseRequestBloc.add(FetchPurchaseRequests(userId: widget.userID));
            }
          },
          buildWhen: (previous, current) =>
          current is PurchaseRequestInitial ||
              current is PurchaseRequestsLoaded ||
              current is PurchaseRequestLoading,
          builder: (context, state) {
            if (state is PurchaseRequestLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }

            if (state is PurchaseRequestInitial) {
              return Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              );
            }

            if (state is PurchaseRequestsLoaded) {
              print("Loaded ${state.requests.length} requests");
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Always show requests history at the top
                    _buildRequestsHistory(state.requests),

                    const SizedBox(height: 16),

                    // Purchase process section
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepIndicator(),
                          _buildStepTitle(),
                          _buildStepContent(),
                          _buildPurchaseNavigation(context),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Fallback for any other state
            return Center(
              child: Text(
                _language.getLanguage() == 'ar'
                    ? 'حدث خطأ ما. يرجى المحاولة مرة أخرى.'
                    : 'Something went wrong. Please try again.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  void _setClipboardData(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _language.getLanguage() == 'ar'
              ? 'تم نسخ الرقم التعريفي: $text'
              : 'ID copied: $text',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 2) _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  void _resetProcess() {
    setState(() {
      _currentStep = 0;
      _selectedPoints = _predefinedPoints[3]; // Reset to 100
      _pointsController.text = _selectedPoints.toString();
    });
  }

  Widget _buildStepIndicator() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final outlineColor = Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  color: i < _currentStep
                      ? primaryColor
                      : outlineColor.withOpacity(0.3),
                ),
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < _currentStep
                    ? primaryColor
                    : (i == _currentStep
                        ? primaryColor.withOpacity(0.2)
                        : Theme.of(context).colorScheme.surface),
                border: Border.all(
                  color: i <= _currentStep
                      ? primaryColor
                      : outlineColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: i < _currentStep
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == _currentStep
                              ? primaryColor
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepTitle() {
    String title;
    switch (_currentStep) {
      case 0:
        title = _language.getLanguage() == 'ar'
            ? 'اختر قيمة النقاط'
            : 'Select Points Value';
        break;
      case 1:
        title = _language.getLanguage() == 'ar'
            ? 'تأكيد معلومات الطلب'
            : 'Confirm Request Details';
        break;
      case 2:
        title = _language.getLanguage() == 'ar'
            ? 'التواصل مع البائع'
            : 'Connect with Seller';
        break;
      default:
        title = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  Widget _buildPointSelector() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode
        ? AppTheme.darkBackgroundColor
        : AppTheme.lightBackgroundColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
          child: Text(
            _language.getLanguage() == 'ar'
                ? 'اختر قيمة النقاط:'
                : 'Select points value:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: primaryColor,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          childAspectRatio: 1.3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: _predefinedPoints.map((points) {
            final isSelected = _selectedPoints == points;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPoints = points;
                  _pointsController.text = points.toString();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$points',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _language.getLanguage() == 'ar'
                          ? '${(points * 7.5).toStringAsFixed(0)} شيكل'
                          : '${(points * 7.5).toStringAsFixed(0)} ILS',
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.8)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomPointsInput() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final secondaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightSecondaryColor;

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _language.getLanguage() == 'ar'
                  ? 'أو أدخل قيمة مخصصة:'
                  : 'Or enter custom value:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: primaryColor,
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
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                suffixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.star,
                    color: secondaryColor,
                    size: 24,
                  ),
                ),
                counterText: '',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _language.getLanguage() == 'ar'
                        ? 'السعر الإجمالي:'
                        : 'Total Price:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _language.getLanguage() == 'ar'
                        ? '${_calculateTotalPrice()} شيكل'
                        : '${_calculateTotalPrice()} ILS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
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

  Widget _buildPurchaseNavigation(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: primaryColor,
                ),
                label: Text(
                  _language.getLanguage() == 'ar' ? 'السابق' : 'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_currentStep == 0) {
                  if (_formKey.currentState!.validate()) {
                    _nextStep();
                  }
                } else if (_currentStep == 1) {
                  // Submit the request
                  final points = int.parse(_pointsController.text);
                  final request = PurchaseRequest(
                    userId: widget.userID,
                    pointsRequested: points,
                    pricePerPoint: 7.5,
                    totalPrice: points * 7.5,
                    status: 'pending',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  _purchaseRequestBloc
                      .add(CreatePurchaseRequest(request: request));
                  _nextStep();
                  // Make sure to expand the history after submitting
                  setState(() {
                    _historyExpanded = true;
                  });
                } else if (_currentStep == 2) {
                  _resetProcess();
                }
              },
              icon: Icon(
                _currentStep == 2 ? Icons.check : Icons.arrow_forward,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: Text(
                _currentStep == 0
                    ? (_language.getLanguage() == 'ar' ? 'التالي' : 'Next')
                    : _currentStep == 1
                        ? (_language.getLanguage() == 'ar'
                            ? 'تأكيد الطلب'
                            : 'Confirm Order')
                        : (_language.getLanguage() == 'ar'
                            ? 'طلب جديد'
                            : 'New Request'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointSelector(),
            _buildCustomPointsInput(),
          ],
        );

      case 1:
        return _buildOrderSummary();

      case 2:
        return _buildSellerConnect();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOrderSummary() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final secondaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightSecondaryColor;

    final points = int.parse(_pointsController.text);
    final totalPrice = points * 7.5;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  _language.getLanguage() == 'ar'
                      ? 'ملخص الطلب'
                      : 'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Order details
                _buildOrderDetailRow(
                  _language.getLanguage() == 'ar'
                      ? 'النقاط المطلوبة'
                      : 'Requested Points',
                  '$points',
                  isHighlighted: true,
                ),
                const SizedBox(height: 12),
                _buildOrderDetailRow(
                  _language.getLanguage() == 'ar'
                      ? 'سعر النقطة'
                      : 'Price per Point',
                  '7.5 ILS',
                ),
                const SizedBox(height: 12),
                _buildOrderDetailRow(
                  _language.getLanguage() == 'ar'
                      ? 'السعر الإجمالي'
                      : 'Total Price',
                  '${totalPrice.toStringAsFixed(2)} ILS',
                  isHighlighted: true,
                ),

                const Divider(height: 32),

                // User ID
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _language.getLanguage() == 'ar'
                          ? 'الرقم التعريفي الخاص بك:'
                          : 'Your ID:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.userID}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () =>
                                  _setClipboardData(widget.userID.toString()),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.content_copy_rounded,
                                      size: 18,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _language.getLanguage() == 'ar'
                                          ? 'نسخ'
                                          : 'Copy',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Instructions panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: secondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _language.getPurchaseInstructionText(),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value,
      {bool isHighlighted = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 16 : 15,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted
                ? primaryColor
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSellerConnect() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 24, top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _language.getLanguage() == 'ar'
                          ? 'تم تقديم طلبك بنجاح!'
                          : 'Your request has been submitted!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _language.getLanguage() == 'ar'
                          ? 'يمكنك التواصل مع أحد البائعين أدناه لإكمال عملية الشراء.'
                          : 'You can contact one of the sellers below to complete your purchase.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Text(
          _language.getLanguage() == 'ar'
              ? 'البائعين المتاحين:'
              : 'Available Sellers:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),

        const SizedBox(height: 16),

        // Seller list with adaptive height
        Container(
          constraints: const BoxConstraints(
            minHeight: 100,
            maxHeight: 500,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: UserSellerScreen(userID: widget.userID),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildRequestsHistory(List<PurchaseRequest> requests) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;

    if (requests.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 24, bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _language.getLanguage() == 'ar'
                  ? 'لا توجد طلبات سابقة'
                  : 'No previous requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Sort requests by creation date (newest first)
    final sortedRequests = List<PurchaseRequest>.from(requests)
      ..sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _historyExpanded
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          InkWell(
            onTap: () {
              setState(() {
                _historyExpanded = !_historyExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _language.getLanguage() == 'ar'
                        ? 'طلبات النقاط السابقة'
                        : 'Previous Requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Requests list
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedRequests.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) =>
                      _buildRequestItem(sortedRequests[index]),
                ),
              ],
            ),
          ),
        ],
      ),
      secondChild: InkWell(
        onTap: () {
          setState(() {
            _historyExpanded = !_historyExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.history,
                color: primaryColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                _language.getLanguage() == 'ar'
                    ? 'طلبات النقاط السابقة'
                    : 'Previous Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  sortedRequests.length.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestItem(PurchaseRequest request) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final secondaryColor =
        isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightSecondaryColor;
    final errorColor = Theme.of(context).colorScheme.error;

    IconData statusIcon;
    Color statusColor;
    String statusText;

    // Define status styling based on the status value
    switch (request.status) {
      case 'approved':
        statusIcon = Icons.check_circle_rounded;
        statusColor = primaryColor;
        statusText = _language.getLanguage() == 'ar' ? 'موافق' : 'Approved';
        break;
      case 'cancelled':
        statusIcon = Icons.cancel_rounded;
        statusColor = errorColor;
        statusText = _language.getLanguage() == 'ar' ? 'ملغى' : 'Cancelled';
        break;
      default:
        statusIcon = Icons.pending_rounded;
        statusColor = secondaryColor;
        statusText =
            _language.getLanguage() == 'ar' ? 'قيد الانتظار' : 'Pending';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(statusIcon, color: statusColor, size: 26),
        ),
        title: Text(
          _language.getLanguage() == 'ar'
              ? 'نقاط: ${request.pointsRequested}'
              : 'Points: ${request.pointsRequested}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            if (request.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _language.getLanguage() == 'ar'
                      ? 'تاريخ الطلب: ${_formatDate(request.createdAt!)}'
                      : 'Requested on: ${_formatDate(request.createdAt!)}',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: request.status == 'pending'
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: errorColor,
                ),
                tooltip: _language.getLanguage() == 'ar'
                    ? 'إلغاء الطلب'
                    : 'Cancel Request',
                onPressed: () {
                  _purchaseRequestBloc
                      .add(CancelPurchaseRequest(requestId: request.id));
                },
              )
            : null,
      ),
    );
  }
}
