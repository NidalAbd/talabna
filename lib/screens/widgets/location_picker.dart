import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationPicked;

  const LocationPicker({super.key, required this.onLocationPicked});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _pickedLocation;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check if location permissions are granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    locationData = await location.getLocation();
    setState(() {
      _pickedLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });
    widget.onLocationPicked(_pickedLocation!);
  }
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      ],
    );
  }
}
