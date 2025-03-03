import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/service_post/service_post_category.dart';
import 'package:talbna/screens/service_post/subcategory_grid_view.dart';

class MainMenuPostScreen extends StatefulWidget {
  final int category;
  final int userID;
  final User user;
  final bool showSubcategoryGridView;
  final ServicePostBloc servicePostBloc;

  const MainMenuPostScreen({
    super.key,
    required this.category,
    required this.userID,
    required this.servicePostBloc, required this.showSubcategoryGridView, required this.user,
  });

  @override
  MainMenuPostScreenState createState() => MainMenuPostScreenState();
}

class MainMenuPostScreenState extends State<MainMenuPostScreen> {
  bool isRealScreen = false;

  @override
  void initState() {
    super.initState();
    if(widget.category == 8){
      isRealScreen = true;
    }else{
      isRealScreen = false;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: widget.showSubcategoryGridView
              ? SubcategoryListView(
            categoryId: widget.category,
            userId: widget.userID,
            servicePostBloc: widget.servicePostBloc,
            userProfileBloc: BlocProvider.of<UserProfileBloc>(context), user: widget.user,
          )
              : ServicePostScreen(
            category: widget.category,
            userID: widget.userID,
            servicePostBloc: widget.servicePostBloc,
            showSubcategoryGridView: widget.showSubcategoryGridView, user: widget.user,
          ),
        ),
      ],
    );
  }
}

