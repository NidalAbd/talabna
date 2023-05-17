import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:talbna/screens/widgets/location_picker.dart';

class RegistrationStepTwo extends StatefulWidget {
  final Function(Map<String, String>) onNext;

  const RegistrationStepTwo({Key? key, required this.onNext}) : super(key: key);

  @override
  State<RegistrationStepTwo> createState() => _RegistrationStepTwoState();
}

class _RegistrationStepTwoState extends State<RegistrationStepTwo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsAppController = TextEditingController();
  String _selectedCity = '';
  String _gender = '';
  double _locationLatitude = 0.0;
  double _locationLongitude = 0.0;
  final TextEditingController _dateOfBirthController = TextEditingController();
  late ValueNotifier<DateTime?> _dateOfBirthNotifier;
  late ValueNotifier<DateTime> _selectedDateNotifier;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  @override
  void initState() {
    super.initState();
    _dateOfBirthNotifier = ValueNotifier<DateTime?>(null);
    _selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'phone': _phoneController.text,
        'whatsApp': _whatsAppController.text,
        'city': _selectedCity,
        'gender': _gender,
        'latitude': _locationLatitude.toString(),
        'longitude': _locationLongitude.toString(),
      };
      widget.onNext(formData);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsAppController.dispose();
    _dateOfBirthNotifier.dispose();
    _selectedDateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LocationPicker(
                  onLocationPicked: (LatLng location) {
                    setState(() {
                      _locationLatitude = location.latitude;
                      _locationLongitude = location.longitude;
                    });
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _whatsAppController,
                  decoration:
                      const InputDecoration(labelText: 'WhatsApp Number'),
                  keyboardType: TextInputType.phone,
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
                    'اريحا',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCity = newValue ?? '';
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gender'),
                  value: _gender.isNotEmpty ? _gender : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      _gender = newValue ?? '';
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateOfBirthController, // Updated line
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    icon: Icon(Icons.date_range_rounded),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
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
                      setState(() {
                        _dateOfBirthController.text = dateFormat.format(selectedDate);
                      });
                    }
                  },
                ),
                ElevatedButton(
                    onPressed: _submitForm,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
