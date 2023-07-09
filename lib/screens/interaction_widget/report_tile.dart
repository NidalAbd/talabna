import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/report/report_bloc.dart';
import 'package:talbna/blocs/report/report_event.dart';
import 'package:talbna/blocs/report/report_state.dart';
import 'package:talbna/screens/widgets/loading_widget.dart';
import 'package:talbna/screens/widgets/success_widget.dart';

class ReportTile extends StatefulWidget {
  const ReportTile({super.key, required this.type, required this.userId});
  final String type;
  final int userId;
  @override
  State<ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<ReportTile> {
  late ReportBloc _reportBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reportBloc = BlocProvider.of<ReportBloc>(context);
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc , ReportState>(
      listener: (context,state){
        print(state);
        if(state is ReportInProgress){
          const LoadingWidget();
        }
        else if(state is ReportSuccess){
          return SuccessWidget.show(context, 'reported success');
        }
      },
      child: BlocBuilder< ReportBloc , ReportState >(
       builder: (context, state) {
         return Container(
           color: AppTheme.primaryColor,
           child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: <Widget>[
                       ListTile(
                         leading: const Icon(Icons.report, color: Colors.white,),
                         title: const Text('Spam',style: TextStyle(color: Colors.white,),),
                         onTap: () {
                           _reportBloc.add(ReportRequested(user: widget.userId, type: widget.type, reason: '1'));
                           Navigator.pop(context); // Dismiss the bottom sheet
                         },
                       ),
                       ListTile(
                         leading: const Icon(Icons.report, color: Colors.white,),
                         title: const Text('Inappropriate content',style: TextStyle(color: Colors.white,),),
                         onTap: () {
                           _reportBloc.add(ReportRequested(user: widget.userId, type: widget.type, reason: '2'));
                           Navigator.pop(context); // Dismiss the bottom sheet

                         },
                       ),
                       ListTile(
                         leading: const Icon(Icons.report, color: Colors.white,),
                         title: const Text('Harassment',style: TextStyle(color: Colors.white,),),
                         onTap: () {
                           _reportBloc.add(ReportRequested(user: widget.userId, type: widget.type, reason: '3'));
                           Navigator.pop(context); // Dismiss the bottom sheet

                         },
                       ),
                       ListTile(
                         leading: const Icon(Icons.report, color: Colors.white,),
                         title: const Text('False information',style: TextStyle(color: Colors.white,),),
                         onTap: () {
                           _reportBloc.add(ReportRequested(user: widget.userId, type: widget.type, reason: '4'));
                           Navigator.pop(context); // Dismiss the bottom sheet
                         },
                       ),
                     ],
                   ),
         );


       }
      ),
    );
  }
}
