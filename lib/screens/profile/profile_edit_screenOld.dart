import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/countries.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/country_dropdown.dart';
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
  final TextEditingController countryCode = TextEditingController(text: '');
  late String deviceToken = '';
  final FCMHandler _fcmHandler = FCMHandler();
  final TextEditingController _whatsAppController = TextEditingController();
  City? _selectedCity;
  Country? _selectedCountry;
  String _gender = '';
  TextEditingController _dateOfBirthController = TextEditingController();
  double _locationLatitudes = 0.0;
  double _locationLongitudes = 0.0;
  late ValueNotifier<DateTime> _dateOfBirthNotifier;
  late ValueNotifier<DateTime> _selectedDateNotifier;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  late bool isCountryChanged = false;
  late bool isPhoneChanged = false;
  late bool isWatsChanged = false;
  late bool isLocationChanged = false;

  Future<void> _updateUserProfile(BuildContext context, User user) async {
    context.read<UserProfileBloc>().add(UserProfileUpdated(user: user));
  }

  @override
  void initState() {
    super.initState();
    _selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());
    _dateOfBirthNotifier = ValueNotifier<DateTime>(DateTime.now());
    _userProfileBloc = context.read<UserProfileBloc>()
      ..add(UserProfileRequested(id: widget.userId));
    _dateOfBirthController =
        TextEditingController(text: ''); // Change this line
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
      minWidth: 480,
      minHeight: 480,
      quality: 80,
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

  dynamic _onCountrySelected(Country? newCountry) {
    setState(() {
      _selectedCountry = newCountry;
      countryCode.text = newCountry!.countryCode; // Update countryCode
      isCountryChanged = true;
    });
  }

  dynamic _onCitySelected(City? newCity) {
    setState(() {
      _selectedCity = newCity;
      isCountryChanged = true;
    });
  }

  dynamic updateCountryCode(String? newCountryCode) {
    setState(() {
      countryCode.text = newCountryCode!;
    });
  }


  Future<void> _saveDataToSharedPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', user.userName!);
    prefs.setString('phones', user.phones!);
    prefs.setString('watsNumber', user.watsNumber!);
    prefs.setString('gender', user.email);
    prefs.setString('dob', user.email);
  }

  Future<void> initializeFCM() async {
    await _fcmHandler.initializeFCM();
    deviceToken = await _fcmHandler.getDeviceToken();
  }

  void _setValues(User user) {
    if (user.phones != null && user.phones!.length >= 5) {
      _phoneController.text = user.phones!.substring(5);
    }else {
      _phoneController.text = '';
    }
    if (user.watsNumber != null && user.watsNumber!.length >= 5) {
      _whatsAppController.text = user.watsNumber!.substring(5);
    }else {
      _whatsAppController.text = '';
    }
    _selectedCity = user.city;
    _selectedCountry = user.country;
    countryCode.text = _selectedCountry!.countryCode;
    _gender = _gender.isEmpty ? user.gender! : _gender;
    _dateOfBirthNotifier.value = user.dateOfBirth ?? DateTime.now();
    _selectedDateNotifier = ValueNotifier<DateTime>(user.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)));
    _dateOfBirthNotifier = ValueNotifier<DateTime>(user.dateOfBirth ?? DateTime.now());
  }

  void updatePhoneNumber(String newPhoneNumber) {
    setState(() {
      _phoneController.text = newPhoneNumber;
    });
  }

  void updateWhatsAppNumber(String newWhatsAppNumber) {
    setState(() {
      _whatsAppController.text = newWhatsAppNumber;
    });
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
            BlocProvider.of<UserProfileBloc>(context)
                .add(UserProfileRequested(id: widget.userId));
            _saveDataToSharedPreferences(state.user);
            SuccessWidget.show(context, 'Profile updated successfully.');
          } else if (state is UserProfileUpdateFailure) {
            BlocProvider.of<UserProfileBloc>(context)
                .add(UserProfileRequested(id: widget.userId));
            ErrorCustomWidget.show(context, message: 'Profile updated failed.');
          } else if (state is UserProfileLoadFailure) {
            ErrorCustomWidget.show(context,
                message: 'Profile load failed , refresh the page');
          }
        },
        builder: (context, state) {
          if (state is UserProfileLoadSuccess) {
            final user = state.user;
            _dateOfBirthController.text = dateFormat
                .format(user.dateOfBirth ?? DateTime.now()); // Add this line
            _setValues(state.user); // Call the _setValues function here
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                            imageUrl:
                                '${Constants.apiBaseUrl}/storage/${user.photos?.first.src}',
                            radius: 100,
                            toUser: user.id,
                            canViewProfile: false,
                            fromUser: user.id,
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
                                    offset: const Offset(
                                      0,
                                      2,
                                    ),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  File? imageFile =
                                      await _pickImageFromGallery();
                                  if (imageFile != null) {
                                    BlocProvider.of<UserProfileBloc>(context)
                                        .add(UpdateUserProfilePhoto(
                                      user: user,
                                      photo: imageFile,
                                    ));
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CountryCityDropdown(
                        initialCountry: _selectedCountry,
                        initialCity: _selectedCity,
                        initialPhoneNumber: _phoneController.text,
                        initialWhatsappNumber: _whatsAppController.text,
                        onCountryChanged: _onCountrySelected,
                        onCityChanged: _onCitySelected,
                        updateCountryCode: updateCountryCode,
                        onPhoneNumberChanged: (newPhoneValue) => updatePhoneNumber(newPhoneValue),
                        onWhatsAppNumberChanged: (newWhatsAppValue) => updateWhatsAppNumber(newWhatsAppValue),
                      ),
                      Card(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.lightForegroundColor
                            : AppTheme.darkForegroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButtonFormField<String?>(
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: InputBorder.none,
                            ),
                            value: _gender.isNotEmpty ? _gender : null,
                            onChanged: (String? newValue) {
                              setState(() {
                                _gender = newValue!;
                              });
                            },
                            items: <String>['ذكر', 'انثى']
                                .map<DropdownMenuItem<String?>>((String value) {
                              return DropdownMenuItem<String?>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _selectedDateNotifier,
                        builder: (
                          BuildContext context,
                          DateTime value,
                          Widget? child,
                        ) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _updateDateOfBirthController(value);
                          });
                          return Card(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.lightForegroundColor
                                    : AppTheme.darkForegroundColor,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: TextFormField(
                                controller: _dateOfBirthController,
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth',
                                  border: InputBorder.none,
                                  suffixIcon: Icon(Icons.date_range_rounded),
                                  suffixIconConstraints: BoxConstraints(
                                    minWidth: 40.0,
                                    minHeight: 40.0,
                                  ),
                                ),
                                onTap: () async {
                                  FocusScope.of(context).requestFocus(
                                    FocusNode(),
                                  );
                                  DateTime? oldDate =
                                      _dateOfBirthController.text.isNotEmpty
                                          ? DateFormat('yyyy-MM-dd').parse(
                                              _dateOfBirthController.text,
                                            )
                                          : null;
                                  DateTime? selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: oldDate ??
                                        DateTime.now().subtract(
                                          const Duration(days: 365 * 18),
                                        ),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                    builder: (
                                      BuildContext context,
                                      Widget? child,
                                    ) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: const ColorScheme.light()
                                              .copyWith(
                                            primary:
                                                Theme.of(context).primaryColor,
                                          ),
                                          textTheme: const TextTheme(
                                            bodyLarge: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        child: child ?? const SizedBox(),
                                      );
                                    },
                                  );
                                  if (selectedDate != null) {
                                    _selectedDateNotifier.value = selectedDate;
                                    _dateOfBirthController.text =
                                        DateFormat('yyyy-MM-dd')
                                            .format(selectedDate);
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your date of birth';
                                  }
                                  DateTime currentDate = DateTime.now();
                                  DateTime selectedDate =
                                      DateFormat('yyyy-MM-dd').parse(value);
                                  DateTime minimumDate = currentDate.subtract(
                                    const Duration(days: 365 * 18),
                                  );
                                  if (selectedDate.isAfter(minimumDate)) {
                                    return 'You must be at least 18 years old';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      FractionallySizedBox(
                        widthFactor: 1.0,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_selectedCountry == null ||
                                  _selectedCity == null) {
                                ErrorCustomWidget.show(context,
                                    message: 'select country and city');
                                return;
                              }
                              DateTime? parsedDateOfBirth;

                              try {
                                parsedDateOfBirth = dateFormat
                                    .parse(_dateOfBirthController.text);
                              } catch (e) {
                                if (kDebugMode) {
                                  print('Error parsing date: $e');
                                }
                              }
                              if (kDebugMode) {
                                print('full phone number ${countryCode.text + _phoneController.text}');
                                print('full whats number ${countryCode.text + _whatsAppController.text}');
                                print('country $_selectedCountry');
                                print('city $_selectedCity');
                              }
                              User updatedUser = User(
                                id: user.id,
                                userName: user.userName,
                                name: user.name,
                                gender: user.gender,
                                country: _selectedCountry,
                                city: _selectedCity,
                                device_token: deviceToken,
                                dateOfBirth: parsedDateOfBirth,
                                locationLatitudes: _locationLatitudes,
                                locationLongitudes: _locationLongitudes,
                                phones: countryCode.text + _phoneController.text,
                                watsNumber:  countryCode.text + _whatsAppController.text,
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
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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
