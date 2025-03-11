import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../provider/language.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationPicked;

  const LocationPicker({super.key, required this.onLocationPicked});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _pickedLocation;
  Location location = Location();
  bool _isMounted = true;
  bool _isLoading = false;
  bool _permissionDenied = false;
  int _permissionRequestCount = 0;
  final Language _language = Language();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!_isMounted) return;

    setState(() {
      _isLoading = true;
      _permissionDenied = false;
    });

    try {
      bool serviceEnabled;
      PermissionStatus permissionGranted;
      LocationData locationData;

      // Check if location services are enabled
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (_isMounted) {
            setState(() {
              _isLoading = false;
            });
            _showLocationServicesDisabledDialog();
          }
          return;
        }
      }

      // Check if location permissions are granted
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        // Increment the permission request count
        _permissionRequestCount++;

        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          if (_isMounted) {
            setState(() {
              _isLoading = false;
              _permissionDenied = true;
            });

            // If the user has denied multiple times, show an explanation dialog
            if (_permissionRequestCount >= 2) {
              _showPermissionExplanationDialog();
            }
          }
          return;
        }
      }

      // Get the current location
      locationData = await location.getLocation();

      // Check if widget is still mounted before updating state
      if (!_isMounted) return;

      final newLocation = LatLng(locationData.latitude!, locationData.longitude!);

      setState(() {
        _pickedLocation = newLocation;
        _isLoading = false;
      });

      widget.onLocationPicked(newLocation);
    } catch (e) {
      // Handle any errors but don't update state if widget is unmounted
      print('Error getting location: $e');
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_language.tErrorGettingLocationText()))
        );
      }
    }
  }

  void _showLocationServicesDisabledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_language.tLocationServicesDisabledText()),
          content: Text(_language.tLocationServicesExplanationText()),
          actions: <Widget>[
            TextButton(
              child: Text(_language.tCancelText()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(_language.tRetryText()),
              onPressed: () {
                Navigator.of(context).pop();
                _getCurrentLocation();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionExplanationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_language.tPermissionDeniedText()),
          content: Text(_language.tLocationPermissionManualEnableText()),
          actions: <Widget>[
            TextButton(
              child: Text(_language.tOkText()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Set a manual location since we can't get the device location
  void _setManualLocation() {
    // Default location (e.g., city center)
    final LatLng defaultLocation = LatLng(31.9539, 35.2376); // Default to Amman, Jordan

    setState(() {
      _pickedLocation = defaultLocation;
      _permissionDenied = false;
    });

    widget.onLocationPicked(defaultLocation);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_language.tManualLocationSetText()))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isLoading)
          Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text(_language.tGettingYourLocationText()),
              ],
            ),
          ),
        if (_permissionDenied)
          Center(
            child: Column(
              children: [
                Icon(Icons.location_off, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _language.tLocationPermissionExplanationText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(height: 16),
                // Fix the overflow by using a Column instead of a Row
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200, // Constrain button width
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.location_on),
                        label: Text(_language.tTryAgainText()),
                        onPressed: _getCurrentLocation,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: 200, // Constrain button width
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.place),
                        label: Text(_language.tUseDefaultLocationText()),
                        onPressed: _setManualLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }
}