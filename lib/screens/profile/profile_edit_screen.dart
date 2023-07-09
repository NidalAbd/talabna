import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/error_widget.dart';
import 'package:talbna/screens/widgets/location_picker.dart';
import 'package:talbna/screens/widgets/success_widget.dart';
import 'package:talbna/screens/widgets/user_avatar_profile.dart';
import 'package:talbna/utils/constants.dart';
import 'package:talbna/utils/fcm_handler.dart';

class UpdateUserProfile extends StatefulWidget {
  final int userId;
  const UpdateUserProfile({Key? key, required this.userId}) : super(key: key);
  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  late UserProfileBloc _userProfileBloc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  late  String _selectedPhoneCountryCode = '00970' ;
  late  String deviceToken = '' ;
  final FCMHandler _fcmHandler = FCMHandler(); // Initialize FCMHandler
  final TextEditingController _whatsAppController = TextEditingController();
  String _selectedCity = '';
  String _gender = '';
  TextEditingController _dateOfBirthController = TextEditingController();
  double _locationLatitudes = 0.0;
  double _locationLongitudes = 0.0;
  late ValueNotifier<DateTime> _dateOfBirthNotifier;
  late ValueNotifier<DateTime> _selectedDateNotifier;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _updateUserProfile(BuildContext context, User user) async {
    if (kDebugMode) {
      print('Data to update: ${user.toJson()}');
    } // Add this line to print the data
    context.read<UserProfileBloc>().add(UserProfileUpdated(user: user));
  }

  @override
  void initState() {
    super.initState();
    _selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());
    _dateOfBirthNotifier = ValueNotifier<DateTime>(DateTime.now());
    _userProfileBloc = context.read<UserProfileBloc>()..add(UserProfileRequested(id: widget.userId));
    _dateOfBirthController = TextEditingController(text: ''); // Change this line
    initializeFCM();
  }
  void _updateDateOfBirthController(DateTime value) {
    if (DateFormat('yyyy-MM-dd').format(value) != _dateOfBirthController.text) {
      _dateOfBirthController.value = TextEditingValue(
        text: DateFormat('yyyy-MM-dd').format(value),
        selection: TextSelection.fromPosition(
          TextPosition(offset: _dateOfBirthController.text.length),
        ),
      );
    }
  }
  Future<File?> _convertToJpeg(File imageFile) async {
    final String outputPath = '${imageFile.path}.jpeg';
    final Uint8List? result = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minWidth: 480, // You can adjust the output image width
      minHeight: 480, // You can adjust the output image height
      quality: 80, // You can adjust the output image quality
      format: CompressFormat.jpeg,
    );
    if (result != null) {
      return File(outputPath)..writeAsBytesSync(result);
    } else {
      return null;
    }
  }

  Future<File?> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final File? jpegFile = await _convertToJpeg(imageFile);
      return jpegFile;
    } else {
      return null;
    }
  }

  Future<void> _saveDataToSharedPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', user.userName!);
    prefs.setString('phones', user.phones!);
    prefs.setString('watsNumber', user.watsNumber!);
    prefs.setString('city', user.city!);
    prefs.setString('gender', user.email);
    prefs.setString('dob', user.email);
  }
  Future<void> initializeFCM() async {
    await _fcmHandler.initializeFCM(); // Initialize FCMHandler
    deviceToken = await _fcmHandler.getDeviceToken(); // Retrieve device token

  }
  Future<void> _setValues(User user) async {
    if (user.phones != null && user.phones!.length >= 5) {
      _phoneController.text = user.phones!.substring(5);
    } else {
      _phoneController.text = user.phones ?? '';
    }

    if (user.watsNumber != null && user.watsNumber!.length >= 5) {
      _whatsAppController.text = user.watsNumber!.substring(5);
    } else {
      _whatsAppController.text = user.watsNumber ?? '';
    }
    _selectedCity = _selectedCity.isEmpty ? user.city! : _selectedCity;
    _gender = _gender.isEmpty ? user.gender! : _gender;
    _locationLatitudes = user.locationLatitudes ?? 0;
    _locationLongitudes = user.locationLongitudes ?? 0;
    _dateOfBirthNotifier.value = user.dateOfBirth ?? DateTime.now();
    _selectedDateNotifier = ValueNotifier<DateTime>(user.dateOfBirth ?? DateTime.now());
    _dateOfBirthNotifier = ValueNotifier<DateTime>(user.dateOfBirth ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل البيانات'),
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        bloc: _userProfileBloc,
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            // Re-request user data after a successful update
            BlocProvider.of<UserProfileBloc>(context)
                .add(UserProfileRequested(id: widget.userId));
            _saveDataToSharedPreferences(state.user);
            SuccessWidget.show(context, 'Profile updated successfully.');
          }else if(state is UserProfileUpdateFailure){
            BlocProvider.of<UserProfileBloc>(context)
                .add(UserProfileRequested(id: widget.userId));
            ErrorCustomWidget.show(context,  message: 'Profile updated failed.');
          }else if (state is UserProfileLoadFailure) {
            ErrorCustomWidget.show(context,  message: 'Profile load failed , refresh the page');            }
        },
        builder: (context, state) {
          if (state is UserProfileLoadSuccess) {
            final user = state.user;
            _dateOfBirthController.text = dateFormat.format(user.dateOfBirth ?? DateTime.now()); // Add this line
            _setValues(state.user); // Call the _setValues function here
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      LocationPicker(
                        onLocationPicked: (LatLng location) {
                          setState(() {
                            _locationLatitudes = location.latitude;
                            _locationLongitudes = location.longitude;
                          });
                        },
                      ),
                      Stack(
                        children: [
                          UserAvatarProfile(
                            imageUrl: '${Constants.apiBaseUrl}/storage/${user.photos?.first.src}',
                            radius: 100,
                            toUser: user.id, canViewProfile: false, fromUser: user.id,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                                onPressed: () async {
                                  File? imageFile = await _pickImageFromGallery();
                                  if (imageFile != null) {
                                    // Assuming you have access to the bloc instance, you can replace "yourBloc" with your actual bloc instance
                                    BlocProvider.of<UserProfileBloc>(context)
                                        .add(UpdateUserProfilePhoto(user: user, photo: imageFile));
                                  }
                                },
                              ),

                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 30,),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: DropdownButtonFormField<String>(
                        value: _selectedPhoneCountryCode,
                        onChanged: (value) {
                          setState(() {
                            _selectedPhoneCountryCode = value!;
                          });
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: '00970',
                            child: Text('00970'),
                          ),
                          DropdownMenuItem<String>(
                            value: '00972',
                            child: Text('00972'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Country Code',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Add some spacing between the dropdown and the phone input field
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          if (value.length < 9 || value.length > 9) {
                            return 'Phone number should be 9 digits';
                          }
                          if (value.startsWith('0')) {
                            return 'Phone number cannot start with 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                      const SizedBox(height: 16),
                Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 3,
                            child: DropdownButtonFormField<String>(
                              value: _selectedPhoneCountryCode,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPhoneCountryCode = value!;
                                });
                              },
                              items: const [
                                DropdownMenuItem<String>(
                                  value: '00970',
                                  child: Text('00970'),
                                ),
                                DropdownMenuItem<String>(
                                  value: '00972',
                                  child: Text('00972'),
                                ),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Country Code',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Add some spacing between the dropdown and the phone input field
                          Expanded(
                            child: TextFormField(
                              controller: _whatsAppController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a phone number';
                                }
                                if (value.length < 9 || value.length > 9) {
                                  return 'Phone number should be 9 digits';
                                }
                                if (value.startsWith('0')) {
                                  return 'Phone number cannot start with 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedCity.isNotEmpty ? _selectedCity : null,
                        hint: const Text('Select a city'),
                        items: [
                          'القدس',
                          'شمال غزة',
                          'غزة',
                          'دير البلح',
                          'خان يونس',
                          'رفح',
                          'رام الله',
                          'الخليل',
                          'بيت لحم',
                          'نابلس',
                          'جنين',
                          'سلفيت',
                          'عسقلان',
                          'بئر السبع',
                          'طبريا',
                          'الناصرة',
                          'صفد',
                          'بيسان',
                          'اللد',
                          'الرملة',
                          'طولكرم',
                          'قلقيلية',
                          'عكا',
                          'حيفا',
                          'يافا',
                          'اريحا'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCity = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a city';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      DropdownButtonFormField<String?>(
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                        ),
                        value: _gender.isNotEmpty ? _gender : null,
                        onChanged: (String? newValue) { // updated parameter type
                          setState(() {
                            _gender = newValue!;
                          });
                        },
                        items: <String>['ذكر', 'انثى']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _selectedDateNotifier,
                        builder: (BuildContext context, DateTime value, Widget? child) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _updateDateOfBirthController(value);
                          });
                          return TextFormField(
                            controller: _dateOfBirthController,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              icon: Icon(Icons.date_range_rounded),
                            ),
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode()); // Hide the keyboard
                              DateTime? oldDate = _dateOfBirthController.text.isNotEmpty
                                  ? DateFormat('yyyy-MM-dd').parse(_dateOfBirthController.text)
                                  : null;
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: oldDate ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (selectedDate != null) {
                                _selectedDateNotifier.value = selectedDate;
                                _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your date of birth';
                              }
                              DateTime currentDate = DateTime.now();
                              DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(value);
                              DateTime minimumDate = currentDate.subtract(const Duration(days: 18 * 365));
                              if (selectedDate.isAfter(minimumDate)) {
                                return 'You must be at least 18 years old';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            DateTime? parsedDateOfBirth;
                            try {
                              parsedDateOfBirth = dateFormat.parse(_dateOfBirthController.text);
                            } catch (e) {
                              if (kDebugMode) {
                                print('Error parsing date: $e');
                              }
                            }
                            String countryPhoneCode = _selectedPhoneCountryCode;
                            String phoneNumber = _phoneController.text;
                            String fullPhoneNumber = countryPhoneCode + phoneNumber;
                            String countryWhatsCode = _selectedPhoneCountryCode;
                            String whatsNumber = _whatsAppController.text;
                            String fullWhatsNumber = countryWhatsCode + whatsNumber;

                            // Create a new user object with updated information
                            User updatedUser = User(
                              id: user.id,
                              userName: user.userName,
                              name: user.name,
                              gender: user.gender,
                              city: _selectedCity,
                              device_token: deviceToken,
                              dateOfBirth: parsedDateOfBirth,
                              locationLatitudes: _locationLatitudes,
                              locationLongitudes: _locationLongitudes,
                              phones: fullPhoneNumber,
                              watsNumber: fullWhatsNumber,
                              email: user.email,
                              emailVerifiedAt: user.emailVerifiedAt,
                              isActive: user.isActive,
                              createdAt: user.createdAt,
                              updatedAt: user.updatedAt,
                              followingCount: user.followingCount,
                              followersCount: user.followersCount,
                              servicePostsCount: user.servicePostsCount,
                              pointsBalance: user.pointsBalance,
                              photos: user.photos,
                            );
                            _updateUserProfile(context, updatedUser);
                          }
                        },
                        child: const Text('Save Changes',style: TextStyle(color: Colors.white),),
                      ),

                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
