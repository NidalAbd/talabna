import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/user_profile/user_profile_bloc.dart';
import '../../blocs/user_profile/user_profile_event.dart';
import '../../blocs/user_profile/user_profile_state.dart';
import '../../data/models/countries.dart';
import '../../data/models/user.dart';
import '../../provider/language.dart';
import '../../utils/constants.dart';
import '../../utils/fcm_handler.dart';
import '../widgets/country_dropdown.dart';
import '../widgets/location_picker.dart';

class UpdateUserProfile extends StatefulWidget {
  final int userId;
  final User user;

  const UpdateUserProfile({
    Key? key,
    required this.userId,
    required this.user
  }) : super(key: key);

  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  // Form Controllers and Keys
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _whatsAppController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '');

  // BLoC and Services
  late final UserProfileBloc _userProfileBloc;
  final FCMHandler _fcmHandler = FCMHandler();

  // State Variables
  late String _deviceToken = '';
  City? _selectedCity;
  Country? _selectedCountry;
  City? _newCitySelected;
  Country? _newCountrySelected;
  String _gender = '';
  DateTime? _selectedDate;
  double _locationLatitudes = 0.0;
  double _locationLongitudes = 0.0;
  final _phoneFocusNode = FocusNode();
  final _whatsAppFocusNode = FocusNode();

  // Flags and Utilities
  final _dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isMounted = true;
  final _language = Language();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Initialize BLoC
      _userProfileBloc = context.read<UserProfileBloc>()
        ..add(UserProfileRequested(id: widget.userId));

      // Initialize FCM
      _deviceToken = await _fcmHandler.getDeviceToken();

      // Set initial values
      _setInitialValues(widget.user);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(_language.errorInitializingText());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setInitialValues(User user) {
    if (!mounted) return;

    // Phone numbers
    if ((user.phones?.length ?? 0) >= 5) {
      setState(() {
        _phoneController.text = user.phones!.substring(5);
      });
    }

    if ((user.watsNumber?.length ?? 0) >= 5) {
      setState(() {
        _whatsAppController.text = user.watsNumber!.substring(5);
      });
    }

    // Location and country data
    _selectedCity = user.city;
    _selectedCountry = user.country;
    _countryCodeController.text = user.country?.countryCode ?? '00970';

    // Date and gender
    if (user.dateOfBirth != null) {
      _selectedDate = user.dateOfBirth;
      _dateOfBirthController.text = _dateFormat.format(user.dateOfBirth!);
    }
    _gender = user.gender ?? '';

    // Location
    _locationLatitudes = user.locationLatitudes ?? 0.0;
    _locationLongitudes = user.locationLongitudes ?? 0.0;
  }

  Future<bool> _validateForm() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar(_language.completeAllFieldsText());
      return false;
    }

    // Check country and city
    if ((_newCountrySelected ?? _selectedCountry) == null) {
      _showErrorSnackBar(_language.selectCountryText());
      return false;
    }

    if ((_newCitySelected ?? _selectedCity) == null) {
      _showErrorSnackBar(_language.selectCityText());
      return false;
    }

    // Check gender
    if (_gender.isEmpty) {
      _showErrorSnackBar(_language.selectGenderText());
      return false;
    }

    // Check date of birth
    if (_selectedDate == null) {
      _showErrorSnackBar(_language.selectDateText());
      return false;
    }

    // Check phone numbers
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar(_language.tPhoneNumberText());
      return false;
    }

    if (_whatsAppController.text.isEmpty) {
      _showErrorSnackBar(_language.tWhatsappNumberText());
      return false;
    }

    return true;
  }

  Future<void> _updateProfile() async {
    if (!await _validateForm()) {
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final updatedUser = User(
        id: widget.user.id,
        userName: widget.user.userName,
        name: widget.user.name,
        gender: _gender,
        country: _newCountrySelected ?? _selectedCountry,
        city: _newCitySelected ?? _selectedCity,
        deviceToken: _deviceToken,
        dateOfBirth: _selectedDate ?? widget.user.dateOfBirth,
        locationLatitudes: _locationLatitudes,
        locationLongitudes: _locationLongitudes,
        phones: '${_countryCodeController.text}${_phoneController.text}',
        watsNumber: '${_countryCodeController.text}${_whatsAppController.text}',
        email: widget.user.email,
        emailVerifiedAt: widget.user.emailVerifiedAt,
        isActive: widget.user.isActive,
        createdAt: widget.user.createdAt,
        updatedAt: widget.user.updatedAt,
        followingCount: widget.user.followingCount,
        followersCount: widget.user.followersCount,
        servicePostsCount: widget.user.servicePostsCount,
        pointsBalance: widget.user.pointsBalance,
        photos: widget.user.photos,
      );

      // Pass context to the event for localization
      context.read<UserProfileBloc>().add(UserProfileUpdated(
        user: updatedUser,
        context: context,
      ));
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(_language.updateFailedText());
        print('Error updating profile: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    if (!mounted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      final File imageFile = File(image.path);
      final compressedImage = await _compressImage(imageFile);

      if (compressedImage != null && mounted) {
        context.read<UserProfileBloc>().add(
          UpdateUserProfilePhoto(
            user: widget.user,
            photo: compressedImage,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(_language.errorUploadingImageText());
        print('Error picking/uploading image: $e');
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.path,
        minWidth: 480,
        minHeight: 480,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final compressedFile = File('${file.path}_compressed.jpg')
          ..writeAsBytesSync(result);
        return compressedFile;
      }
    } catch (e) {
      print('Error compressing image: $e');
    }
    return null;
  }

  // UI Components
  Widget _buildProfileImage(User user) {
    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: (user.photos != null && user.photos!.isNotEmpty)
                ? Image.network(
              '${Constants.apiBaseUrl}/storage/${user.photos?.first.src}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )
                : _buildDefaultAvatar(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            elevation: 4,
            shape: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.person,
        size: 80,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDateField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: _showDatePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? _dateFormat.format(_selectedDate!)
                    : _language.tDateOfBirthText(),
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDate != null
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    if (!mounted) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate && mounted) {
      setState(() {
        _selectedDate = pickedDate;
        _dateOfBirthController.text = _dateFormat.format(pickedDate);
        _hasChanges = true;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container();

    return Scaffold(
      appBar: AppBar(
        title: Text(_language.tUpdateInfoText()),
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: Text(_language.tSaveText()),
            ),
        ],
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        bloc: _userProfileBloc,
        listener: (context, state) {
          if (!mounted) return;

          if (state is UserProfileUpdateSuccess) {
            _userProfileBloc.add(UserProfileRequested(id: widget.userId));
            _showSuccessSnackBar(_language.profileUpdatedSuccessText());
            setState(() {
              _isLoading = false;
              _hasChanges = false;
            });

            // After successful update, update the profile completion status
            _markProfileAsCompleted();
          } else if (state is UserProfileUpdateFailure) {
            setState(() => _isLoading = false);
            _showErrorSnackBar(state.error);
          } else if (state is UserProfileUniqueConstraintFailure) {
            setState(() => _isLoading = false);
            _showErrorSnackBar(state.error);

            // Focus on the field that caused the error
            if (state.field == 'phones') {
              FocusScope.of(context).requestFocus(_phoneFocusNode);
              _phoneController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _phoneController.text.length,
              );
            } else if (state.field == 'WatsNumber') {
              FocusScope.of(context).requestFocus(_whatsAppFocusNode);
              _whatsAppController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: _whatsAppController.text.length,
              );
            }
          }
        },
        builder: (context, state) {
          if (!mounted) return Container();

          if (state is UserProfileLoadSuccess) {
            return _buildForm(state.user);
          } else if (state is UserProfileLoadInProgress || state is UserProfileUpdateInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoadFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_language.loadFailedText()),
                  ElevatedButton(
                    onPressed: () => _userProfileBloc.add(
                      UserProfileRequested(id: widget.userId),
                    ),
                    child: Text(_language.retryText()),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _markProfileAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileCompleted', true);
    print('Profile marked as completed');
  }

  Widget _buildForm(User user) {
    if (!mounted) return Container();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        onChanged: () {
          if (!_hasChanges && mounted) setState(() => _hasChanges = true);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _buildProfileImage(user)),
            const SizedBox(height: 24),

            // Location Picker with elevation
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LocationPicker(
                  onLocationPicked: (LatLng location) {
                    if (mounted) {
                      setState(() {
                        _locationLatitudes = location.latitude;
                        _locationLongitudes = location.longitude;
                        _hasChanges = true;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Country and City Dropdown
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CountryCityDropdown(
                  initialCountry: _selectedCountry,
                  initialCity: _selectedCity,
                  initialPhoneNumber: _phoneController.text,
                  initialWhatsappNumber: _whatsAppController.text,
                  onCountryChanged: (country) {
                    if (mounted) {
                      setState(() {
                        _newCountrySelected = country;
                        _countryCodeController.text = country?.countryCode ?? '';
                        _selectedCountry = _newCountrySelected;
                        _hasChanges = true;
                      });
                    }
                  },
                  onCityChanged: (city) {
                    if (mounted) {
                      setState(() {
                        _newCitySelected = city;
                        _selectedCity = _newCitySelected;
                        _hasChanges = true;
                      });
                    }
                  },
                  updateCountryCode: (code) {
                    if (mounted) {
                      setState(() {
                        _countryCodeController.text = code;
                        _hasChanges = true;
                      });
                    }
                  },
                  onPhoneNumberChanged: (newPhoneValue) {
                    if (mounted) {
                      setState(() {
                        _phoneController.text = newPhoneValue;
                        _hasChanges = true;
                      });
                    }
                  },
                  onWhatsAppNumberChanged: (newWhatsAppValue) {
                    if (mounted) {
                      setState(() {
                        _whatsAppController.text = newWhatsAppValue;
                        _hasChanges = true;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _language.tGenderText(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _gender.isNotEmpty ? _gender : null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      items: ['ذكر', 'انثى'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null && mounted) {
                          setState(() {
                            _gender = newValue;
                            _hasChanges = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date of Birth Field
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _language.tDateOfBirthText(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDateField(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Update Button
            if (_hasChanges)
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(_language.tUpdateInfoText()),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    _phoneController.dispose();
    _whatsAppController.dispose();
    _dateOfBirthController.dispose();
    _countryCodeController.dispose();
    _phoneFocusNode.dispose();
    _whatsAppFocusNode.dispose();
    super.dispose();
  }
}

// Add these extension methods for better code organization
extension DateTimeFormatting on DateTime {
  String toFormattedString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }
}

extension UserPreferences on User {
  Future<void> saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Save user data
    await prefs.setString('userName', userName ?? '');
    await prefs.setString('phones', phones ?? '');
    await prefs.setString('watsNumber', watsNumber ?? '');
    await prefs.setString('gender', gender ?? '');
    await prefs.setString('dateOfBirth', dateOfBirth?.toFormattedString() ?? '');

    // Set profile completion flag to true
    await prefs.setBool('profileCompleted', true);

    // Print for debugging
    print('Saved userName: ${prefs.getString('userName')}');
    print('Saved phones: ${prefs.getString('phones')}');
    print('Saved watsNumber: ${prefs.getString('watsNumber')}');
    print('Saved gender: ${prefs.getString('gender')}');
    print('Saved dateOfBirth: ${prefs.getString('dateOfBirth')}');
    print('Profile completion status: ${prefs.getBool('profileCompleted')}');


  }

  // Helper method to get all saved preferences
  static Future<Map<String, dynamic>> getAllSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName'),
      'phones': prefs.getString('phones'),
      'watsNumber': prefs.getString('watsNumber'),
      'gender': prefs.getString('gender'),
      'dateOfBirth': prefs.getString('dateOfBirth'),
      'profileCompleted': prefs.getBool('profileCompleted') ?? false,
    };
  }
}