import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/countries.dart';
import '../../data/repositories/countries_repository.dart';
import '../../main.dart';
import '../../provider/language.dart';
import '../../app_theme.dart';

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
  final Language _language = Language();
  List<Country> _countries = [];
  List<City> _cities = [];
  Country? _selectedCountry;
  City? _selectedCity;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    _phoneController.text = widget.initialPhoneNumber ?? "";
    _whatsappController.text = widget.initialWhatsappNumber ?? "";

    if (widget.initialCountry != null) {
      _selectedCountry = widget.initialCountry;
      await _fetchCities(widget.initialCountry!.id);
    }
    await _fetchCountries();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchCountries() async {
    try {
      final repository = CountriesRepository();
      _countries = await repository.getCountries();

      if (widget.initialCountry != null) {
        _selectedCountry = _countries.firstWhere(
              (country) => country.id == widget.initialCountry!.id,
          orElse: () => _countries.first,
        );
        await _fetchCities(_selectedCountry!.id);
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> _fetchCities(int countryId) async {
    try {
      final repository = CountriesRepository();
      _cities = await repository.getCities(countryId);

      if (widget.initialCity != null) {
        _selectedCity = _cities.firstWhere(
              (city) => city.id == widget.initialCity!.id,
          orElse: () => _cities.first,
        );
      } else {
        _selectedCity = _cities.isNotEmpty ? _cities.first : null;
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  Widget _buildDropdownField({
    required String label,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPhoneInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Country Code Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[50],
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                border: Border(
                  right: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedCountry?.countryCode ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Phone Number Input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 9,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                    counterText: '',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  onChanged: (value) {
                    // Remove this condition to allow updates for all values
                    onChanged(value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (value.length != 9) {
                      return 'Number should be 9 digits';
                    }
                    if (value.startsWith('0')) {
                      return 'Number cannot start with 0';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Dropdown
        _buildDropdownField(
          label: _language.tCountryText(),
          child: DropdownButtonFormField<Country>(
            value: _selectedCountry,
            decoration: InputDecoration(
              labelText: _language.tCountryText(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
            ),
            dropdownColor: isDark ? Colors.grey[850] : Colors.white,
            items: _countries.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Text(
                  country.getName(language),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              );
            }).toList(),
            onChanged: (Country? newCountry) async {
              if (newCountry != null) {
                setState(() {
                  _selectedCountry = newCountry;
                  _selectedCity = null;
                });
                await _fetchCities(newCountry.id);
                widget.onCountryChanged(newCountry);
                widget.updateCountryCode(newCountry.countryCode);
              }
            },
          ),
        ),

        // City Dropdown
        if (_selectedCountry != null)
          _buildDropdownField(
            label: _language.tCityText(),
            child: DropdownButtonFormField<City>(
              value: _selectedCity,
              decoration: InputDecoration(
                labelText: _language.tCityText(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              dropdownColor: isDark ? Colors.grey[850] : Colors.white,
              items: _cities.map((city) {
                return DropdownMenuItem<City>(
                  value: city,
                  child: Text(
                    city.getName(language),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (City? newCity) {
                if (newCity != null) {
                  setState(() => _selectedCity = newCity);
                  widget.onCityChanged(newCity);
                }
              },
            ),
          ),

        const SizedBox(height: 16),

        // Phone Inputs Section
        if (_selectedCountry != null) ...[
          _buildPhoneInput(
            controller: _phoneController,
            label: _language.tPhoneNumberText(),
            icon: Icons.phone_outlined,
            onChanged: widget.onPhoneNumberChanged,
          ),

          _buildPhoneInput(
            controller: _whatsappController,
            label: _language.tWhatsappNumberText(),
            icon: Icons.chat,
            onChanged: widget.onWhatsAppNumberChanged,
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
}