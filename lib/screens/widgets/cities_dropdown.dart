import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/countries.dart';
import 'package:talbna/data/repositories/countries_repository.dart';
import '../../provider/language.dart';

class CitiesDropdown extends StatefulWidget {
  final Country? selectedCountry;
  final Function(City) onCitySelected;
  final City? initialCity;
  final String language; // Add language parameter

  const CitiesDropdown({
    Key? key,
    required this.selectedCountry,
    required this.onCitySelected,
    this.initialCity,
    required this.language, // Pass language to widget
  }) : super(key: key);

  @override
  _CitiesDropdownState createState() => _CitiesDropdownState();
}

class _CitiesDropdownState extends State<CitiesDropdown> {
  List<City> _cities = [];
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    _fetchCities(widget.selectedCountry?.id);
    if (widget.initialCity != null) {
      _selectedCity = widget.initialCity;
    }
  }

  @override
  void didUpdateWidget(covariant CitiesDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCountry != null && oldWidget.selectedCountry != widget.selectedCountry) {
      _fetchCities(widget.selectedCountry!.id);
    }
  }

  void _fetchCities(int? countryId) async {
    try {
      CountriesRepository repository = CountriesRepository();
      _cities = await repository.getCities(countryId!);
      setState(() {
        _selectedCity = _cities.first;
      });
      widget.onCitySelected(_selectedCity!);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<City>(
      value: _selectedCity,
      decoration: InputDecoration(
        labelText: 'المدينة',
      ),
      dropdownColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.lightPrimaryColor.withOpacity(0.8)
          : AppTheme.darkPrimaryColor.withOpacity(0.8),
      items: _cities
          .map((city) => DropdownMenuItem<City>(
        value: city,
        child: Text(
          city.getName(widget.language), // Dynamically fetch city name based on language
        ),
      ))
          .toList(),
      onChanged: (City? newCity) {
        if (newCity != null) {
          setState(() {
            _selectedCity = newCity;
          });
          widget.onCitySelected(newCity);
        }
      },
    );
  }
}
