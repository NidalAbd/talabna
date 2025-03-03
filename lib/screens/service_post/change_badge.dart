import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_event.dart';
import 'package:talbna/blocs/service_post/service_post_state.dart';
import 'package:talbna/data/models/service_post.dart';
import 'package:talbna/screens/interaction_widget/point_balance.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';
import 'package:talbna/screens/widgets/success_widget.dart';

import '../../provider/language.dart';

class ChangeBadge extends StatefulWidget {
  const ChangeBadge(
      {super.key, required this.userId, required this.servicePostId, required this.haveBadge, required this.badgeDuration});
  final int userId;
  final int servicePostId;
  final String? haveBadge;
  final int? badgeDuration;
  @override
  State<ChangeBadge> createState() => _ChangeBadgeState();
}

class _ChangeBadgeState extends State<ChangeBadge> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedHaveBadge = 'عادي';
  late int _selectedBadgeDuration = _selectedHaveBadge == 'عادي' ? 0 : 1;
  late int _calculatedPoints = 0;
  late bool balanceOut = false;
  final Language _language = Language();
  //_language.tConvertPointsText()
  Future<void> _submitForm() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      final servicePost = ServicePost(
        id: widget.servicePostId,
        haveBadge: _selectedHaveBadge,
        badgeDuration: _selectedBadgeDuration,
      );
      context
          .read<ServicePostBloc>()
          .add(ServicePostBadgeUpdateEvent(servicePost, widget.servicePostId));
    }
  }

  void _updateCalculatedPoints() {
    final int haveBadge = _selectedHaveBadge == 'ذهبي'
        ? 2
        : _selectedHaveBadge == 'ماسي'
            ? 10
            : 0;
    _calculatedPoints = _selectedBadgeDuration * haveBadge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(_language.tChangeBadgeText()),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PointBalance(
                  userId: widget.userId,
                  showBalance: true, canClick: true,
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocListener<ServicePostBloc, ServicePostState>(
        listener: (context, state) {
          print(state);
          if (state is ServicePostOperationSuccess) {
            showCustomSnackBar(context, 'success', type: SnackBarType.success);
            Navigator.of(context).pop();
          } else if (state is ServicePostOperationFailure) {
            bool balance =
                state.errorMessage.contains('Your Balance Point not enough');
            if (balance) {
              setState(() {
                balanceOut = balance;
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Error: Your Balance Point not enough'),
              ));
            } else {
              showCustomSnackBar(context, 'error', type: SnackBarType.error);
            }
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              DropdownButtonFormField<String>(
                decoration:  InputDecoration(
                  labelText: _language.tFeaturedText(),
                ),
                value: _selectedHaveBadge,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHaveBadge = newValue!;
                    if (_selectedHaveBadge == 'عادي') {
                      _selectedBadgeDuration = 0;
                    } else if (_selectedBadgeDuration == 0) {
                      _selectedBadgeDuration =
                          1; // Set the default value for ذهبي or ماسي
                    }
                    _updateCalculatedPoints();
                  });
                },
                items: <String>['عادي', 'ذهبي', 'ماسي']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,),
                  );
                }).toList(),
                dropdownColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkPrimaryColor
                    : AppTheme.lightPrimaryColor,
              ),
              Visibility(
                visible: _selectedHaveBadge != 'عادي',
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'المدة',
                  ),
                  value: _selectedBadgeDuration,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedBadgeDuration = newValue!;
                      _updateCalculatedPoints();
                    });
                  },
                  items: <int>[0, 1, 2, 3, 4, 5, 6, 7].where((int value) {
                    return _selectedHaveBadge == 'عادي' ? true : value != 0;
                  }).map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('يوم $value'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16.0),
              Visibility(
                visible: _selectedHaveBadge != 'عادي',
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'ستخصم $_calculatedPoints من رصيد نقاطك عند تمييز النشر بـ $_selectedHaveBadge لمدة $_selectedBadgeDuration يوم',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child:  Text(
                    _language.tChangeBadgeText(),
                ),
              ),
              if (balanceOut)const Text('ليس لديك رصيد نقاط كافي , يمكنك شراء النقاط من هنا'),
              if (balanceOut)
                ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PurchaseRequestScreen(
                          userID: widget.userId,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'اضافة نقاط',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
