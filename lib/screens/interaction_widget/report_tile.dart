import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/report/report_bloc.dart';
import 'package:talbna/blocs/report/report_event.dart';
import 'package:talbna/blocs/report/report_state.dart';
import 'package:talbna/screens/widgets/loading_widget.dart';

import '../../main.dart';
import '../../provider/language.dart';

class ReportTile extends StatefulWidget {
  const ReportTile({
    Key? key,
    required this.type,
    required this.userId
  }) : super(key: key);

  final String type;
  final int userId;

  @override
  State<ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<ReportTile> {
  late ReportBloc _reportBloc;
  final Language language = Language();


  @override
  void initState() {
    super.initState();
    _reportBloc = BlocProvider.of<ReportBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportInProgress) {
          const LoadingWidget();
        } else if (state is ReportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(language.tReportSuccess()),
            ),
          );
          Navigator.pop(context); // Dismiss the bottom sheet
        }
      },
      child: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  language.tReportTitle(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Report Reasons
              ListTile(
                leading: const Icon(Icons.report),
                title: Text(language.tReportSpam()),
                onTap: () {
                  _reportBloc.add(ReportRequested(
                      user: widget.userId,
                      type: widget.type,
                      reason: '1'
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: Text(language.tReportInappropriate()),
                onTap: () {
                  _reportBloc.add(ReportRequested(
                      user: widget.userId,
                      type: widget.type,
                      reason: '2'
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: Text(language.tReportHarassment()),
                onTap: () {
                  _reportBloc.add(ReportRequested(
                      user: widget.userId,
                      type: widget.type,
                      reason: '3'
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: Text(language.tReportFalseInfo()),
                onTap: () {
                  _reportBloc.add(ReportRequested(
                      user: widget.userId,
                      type: widget.type,
                      reason: '4'
                  ));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}