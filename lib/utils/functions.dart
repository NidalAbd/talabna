import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import '../blocs/user_profile/user_profile_bloc.dart';
import '../blocs/user_profile/user_profile_state.dart';

void checkBadgeAndShowMessage(BuildContext context, String selectedHaveBadge, int selectedBadgeDuration) {
  // Check if the selected badge requires a minimum balance
  final int haveBadge = selectedHaveBadge == 'ذهبي' ? 2 : selectedHaveBadge == 'ماسي' ? 10 : 0;
  final int minBalance = selectedBadgeDuration * haveBadge;
  final userProfileState = context.read<PurchaseRequestBloc>().state;
  if (userProfileState is UserPointLoadSuccess) {
    final int balance = userProfileState.pointBalance.totalPoint;
    if (balance < minBalance) {
      final message = 'لا يوجد رصيد كافي لتمييز النشر بـ $selectedHaveBadge لمدة $selectedBadgeDuration يوم';
      ErrorCustomWidget.show(context, message);
    }
  }
}
Future<bool> _checkDataCompletion() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userName = prefs.getString('userName');
  String? phones = prefs.getString('phones');
  String? watsNumber = prefs.getString('watsNumber');
  String? city = prefs.getString('city');
  String? gender = prefs.getString('gender');
  String? dobString = prefs.getString('dob');

  return userName != null &&
      phones != null &&
      watsNumber != null &&
      city != null &&
      gender != null &&
      dobString != null;
}
