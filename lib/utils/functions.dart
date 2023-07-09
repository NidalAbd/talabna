import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_bloc.dart';
import 'package:talbna/blocs/purchase_request/purchase_request_state.dart';
import 'package:talbna/screens/widgets/error_widget.dart';

void checkBadgeAndShowMessage(BuildContext context, String selectedHaveBadge, int selectedBadgeDuration) {
  // Check if the selected badge requires a minimum balance
  final int haveBadge = selectedHaveBadge == 'ذهبي' ? 2 : selectedHaveBadge == 'ماسي' ? 10 : 0;
  final int minBalance = selectedBadgeDuration * haveBadge;
  final userProfileState = context.read<PurchaseRequestBloc>().state;
  if (userProfileState is UserPointLoadSuccess) {
    final int balance = userProfileState.pointBalance.totalPoint;
    if (balance < minBalance) {
      final message = 'لا يوجد رصيد كافي لتمييز النشر بـ $selectedHaveBadge لمدة $selectedBadgeDuration يوم';
      ErrorCustomWidget.show(context,  message: message);
    }
  }
}
