import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/screens/auth/registration_step_one.dart';
import 'package:talbna/screens/auth/registration_step_tree.dart';
import 'package:talbna/screens/auth/registration_step_two.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}
class RegistrationData {
  String email = '';
  String userName = '';
  String password = '';
  String phone = '';
  String whatsApp = '';
  String city = '';
  String gender = '';
  double latitude = 0.0;
  double longitude = 0.0;
  File? selectedImage; // Add this line

}
class _RegistrationScreenState extends State<RegistrationScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late String email;
  late String userName;
  late String password;
  late String phone;
  late String whatsApp;
  late String city;
  late String gender;
  late double latitude;
  late double longitude;
  late RegistrationData registrationData; // Add this line

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    registrationData = RegistrationData(); // Initialize the registrationData

    _pages = [
      RegistrationStepOne(
        onNext: (formData) {
          setState(() {
            registrationData.email = formData['email']!;
            registrationData.userName = formData['username']!;
            registrationData.password = formData['password']!;
          });
          _nextPage();
        },
      ),
      RegistrationStepTwo(onNext: (formData) {
        setState(() {
          registrationData.phone = formData['phone']!;
          registrationData.whatsApp = formData['whatsApp']!;
          registrationData.city = formData['city']!;
          registrationData.gender = formData['gender']!;
          registrationData.latitude = double.parse(formData['latitude']!);
          registrationData.longitude = double.parse(formData['longitude']!);
        });
        _nextPage();
      }),
      RegistrationStepTree(onNext: (image) {
        setState(() {
          registrationData.selectedImage = image;
        });
        _nextPage();
      }),

    ];
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  void _submitRegistration() {
    context.read<AuthenticationBloc>().add(
          Register(
            name: userName,
            email: email,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: _previousPage,
                    child: const Text(
                      'Previous',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (_currentPage < _pages.length - 1)
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (_currentPage == _pages.length - 1)
                  ElevatedButton(
                    onPressed: _submitRegistration,
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
