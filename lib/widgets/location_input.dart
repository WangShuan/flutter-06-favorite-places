import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../main.dart';
import '../providers/location_provider.dart';
import '../screens/map_screen.dart';

final buttonStyle = FilledButton.styleFrom(backgroundColor: colorScheme.primary.withOpacity(0.7));

class LocationInput extends ConsumerStatefulWidget {
  const LocationInput(this.setLocation, {super.key});
  final void Function(double lat, double long, String address) setLocation;

  @override
  ConsumerState<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends ConsumerState<LocationInput> {
  final googleApiKey = FlutterConfig.get('GOOGLE_API_KEY');
  String? img;

  Future<void> _getUserLocation() async {
    LocationData locaData;
    try {
      locaData = await ref.read(locationProvider.notifier).getUserLocation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('無法取得當前位置。')));
      return;
    }

    final lat = locaData.latitude;
    final long = locaData.longitude;

    if (lat == null || long == null) return;

    _setAddressAndShowImg(lat, long);
  }

  Future<void> _selectOnMap() async {
    LatLng locaData;
    try {
      locaData = await Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const MapScreen(
          isSelecting: true,
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('無法取得位置資訊。')));
      return;
    }

    _setAddressAndShowImg(locaData.latitude, locaData.longitude);
  }

  void _setAddressAndShowImg(lat, long) async {
    final address = await ref.read(locationProvider.notifier).getAddress(lat, long);

    setState(() {
      img = 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&scale=2&zoom=15&size=400x300&key=$googleApiKey&markers=color:red%7Clabel:%7C$lat%2C$long';
    });

    widget.setLocation(lat, long, address);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.3),
        border: Border.all(color: colorScheme.primary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (img != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/location-placeholder.gif',
                image: img!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                style: buttonStyle,
                onPressed: _getUserLocation,
                icon: const Icon(Icons.my_location_outlined),
                label: const Text('我的位置'),
              ),
              Text(
                '或',
                style: TextStyle(color: colorScheme.primary),
              ),
              FilledButton.icon(
                style: buttonStyle,
                onPressed: _selectOnMap,
                icon: const Icon(Icons.map_rounded),
                label: const Text('從地圖中選擇'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
