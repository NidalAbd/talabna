import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/widgets/user_avatar.dart';
import 'package:talbna/utils/constants.dart';
import 'package:geocoding/geocoding.dart';

class UserCard extends StatefulWidget {
  final User follower;
  const UserCard({Key? key, required this.follower}) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  String? city;

  @override
  void initState() {
    super.initState();
    _getCityName();
  }

  Future<void> _getCityName() async {
    if (widget.follower.locationLatitudes != null &&
        widget.follower.locationLongitudes != null) {
      double lat = double.tryParse(widget.follower.locationLatitudes.toString()) ?? 0.0;
      double lng = double.tryParse(widget.follower.locationLongitudes.toString()) ?? 0.0;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final Placemark placemark = placemarks.first;
          setState(() {
            city = placemark.locality ?? placemark.administrativeArea;
            print(city);
          });
        } else {

        }
      } catch (e) {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String avatarUrl = 'https://example.com/default-avatar.png'; // Provide a default avatar URL
    if (widget.follower.photos!.isNotEmpty) {
      avatarUrl = widget.follower.photos![0].src;
    }

    return Card(
      child: ListTile(
          title: Text(widget.follower.userName!),
          subtitle: Text(city ?? 'no city', style: const TextStyle(color: Colors.white)),
          leading: UserAvatar(userId: widget.follower.id, imageUrl: '${Constants.apiBaseUrl}/storage/${widget.follower.photos![0].src}', radius: 16,)
      ),
    );
  }
}

