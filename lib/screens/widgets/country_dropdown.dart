import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/repositories/countries_repository.dart';
import 'package:talbna/data/models/countries.dart';

class CountryCityDropdown extends StatefulWidget {
  final Country? initialCountry;
  final City? initialCity;
  final Function(Country?) onCountryChanged;
  final Function(City?) onCityChanged;
  final Function(String) updateCountryCode;
  final String? initialPhoneNumber;
  final String? initialWhatsappNumber;
  final Function(String) onPhoneNumberChanged;
  final Function(String) onWhatsAppNumberChanged;

  const CountryCityDropdown({
    Key? key,
    this.initialCountry,
    this.initialCity,
    required this.onCountryChanged,
    required this.onCityChanged,
    required this.updateCountryCode,
    this.initialPhoneNumber,
    this.initialWhatsappNumber,
    required this.onPhoneNumberChanged,
    required this.onWhatsAppNumberChanged,
  }) : super(key: key);

  @override
  _CountryCityDropdownState createState() => _CountryCityDropdownState();
}

class _CountryCityDropdownState extends State<CountryCityDropdown> {
  List<Country> _countries = [];
  List<City> _cities = [];
  Country? _selectedCountry;
  City? _selectedCity;
  final TextEditingController _selectedCountryCode = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  RegExp phonePattern = RegExp(r'^[0-9]{5,}$');
  RegExp whatsappPattern = RegExp(r'^[0-9]{5,}$');
  @override
  void initState() {
    super.initState();
    _fetchCountries();
    phoneController.text = widget.initialPhoneNumber ?? "";
    whatsappController.text = widget.initialWhatsappNumber ?? "";

    phoneController.addListener(() {
      widget.onPhoneNumberChanged(phoneController.text);
    });

    whatsappController.addListener(() {
      widget.onWhatsAppNumberChanged(whatsappController.text);
    });
    if (widget.initialCountry != null) {
      _selectedCountry = widget.initialCountry;
      _selectedCountryCode.text = widget.initialCountry!.countryCode;
    }
    if (widget.initialCity != null) {
      _selectedCity = widget.initialCity;
    }
  }

  void _fetchCountries() async {
    try {
      CountriesRepository repository = CountriesRepository();
      _countries = await repository.getCountries();
      if (widget.initialCountry != null) {
        _selectedCountry = _countries.firstWhere(
                (country) => country.id == widget.initialCountry!.id,
            orElse: () => _countries.first);
        _fetchCities(_selectedCountry!.id);
      }
      setState(() {});
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  void _fetchCities(int? countryId) async {
    try {
      CountriesRepository repository = CountriesRepository();
      _cities = await repository.getCities(countryId!);
      if (widget.initialCity != null) {
        _selectedCity = _cities.firstWhere(
                (city) => city.id == widget.initialCity!.id,
            orElse: () => _cities.first);
      } else {
        _selectedCity = _cities.first;
      }
      setState(() {});
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Card(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.lightForegroundColor
              : AppTheme.darkForegroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<Country>(
              value: _selectedCountry,
              decoration: const InputDecoration(
                labelText: 'الدولة',
                border: InputBorder.none,
              ),
              dropdownColor: AppTheme.primaryColor,
              items: _countries.map((country) {
                return DropdownMenuItem<Country>(
                  value: country,
                  child: Text(country.name ,style:  TextStyle(color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,),),
                );
              }).toList(),
              onChanged: (Country? newCountry) {
                if (newCountry != null) {
                  setState(() {
                    _selectedCountry = newCountry;
                    _selectedCountryCode.text = newCountry.countryCode;
                  });
                  _fetchCities(newCountry.id);
                  widget.onCountryChanged(newCountry);
                  widget.updateCountryCode(_selectedCountryCode.text);
                }
              },
            ),
          ),
        ),
        if (_selectedCountry != null)
          Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.lightForegroundColor
                : AppTheme.darkForegroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: DropdownButtonFormField<City>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'المدينة',
                  border: InputBorder.none,
                ),
                dropdownColor: AppTheme.primaryColor,
                items: _cities.map((city) {
                  return DropdownMenuItem<City>(
                    value: city,
                    child: Text(city.name ,style: TextStyle(color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,),),
                  );
                }).toList(),
                onChanged: (City? newCity) {
                  if (newCity != null) {
                    setState(() {
                      _selectedCity = newCity;
                    });
                    widget.onCityChanged(newCity);
                  }
                },
              ),
            ),
          ),
        Row(
          children: [
            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightForegroundColor
                  : AppTheme.darkForegroundColor,
              child: SizedBox(
                height: 46,
                width: 80,
                child: Center(
                  child: TextFormField(
                    readOnly: true,
                    controller: _selectedCountryCode,
                    decoration: const InputDecoration(
                      labelText: 'code',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.lightForegroundColor
                    : AppTheme.darkForegroundColor,
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 9, // Set maximum length to 9 digits
                  minLines: 1,

                  onChanged: (value) {
                    if (value.isNotEmpty && !value.startsWith('0')) {
                      widget.onPhoneNumberChanged(value);
                    }
                  },
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
                  decoration:  const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    counterText: '', // Remove the counter text
                    counterStyle: TextStyle(fontSize: 0), // Set the counter font size to 0
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.lightForegroundColor
                  : AppTheme.darkForegroundColor,
              child: SizedBox(
                height: 46,
                width: 80,
                child: Center(
                  child: TextFormField(
                    readOnly: true,
                    controller: _selectedCountryCode,
                    decoration: const InputDecoration(
                      labelText: 'code',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.lightForegroundColor
                    : AppTheme.darkForegroundColor,
                child: TextFormField(
                  controller: whatsappController,
                  keyboardType: TextInputType.number,
                  maxLength: 9, // Set maximum length to 9 digits
                  minLines: 1,
                  onChanged: (value) {
                    if (value.isNotEmpty && !value.startsWith('0')) {
                      widget.onWhatsAppNumberChanged(value);
                    }
                  },
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
                  decoration: const InputDecoration(
                    labelText: 'رقم الواتساب',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    counterText: '', // Remove the counter text
                    counterStyle: TextStyle(fontSize: 0), // Set the counter font size to 0
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
