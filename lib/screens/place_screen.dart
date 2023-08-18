import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import '../main.dart';
import '../models/place.dart';
import 'map_screen.dart';

class PlaceScreen extends StatelessWidget {
  const PlaceScreen(this.place, {super.key});
  final Place place;

  @override
  Widget build(BuildContext context) {
    final googleApiKey = FlutterConfig.get('GOOGLE_API_KEY');
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Hero(
            tag: place.id,
            child: Image.file(
              place.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => MapScreen(
                        isSelecting: false,
                        initLocation: PlaceLocation(lat: place.location.lat, lng: place.location.lng, address: place.location.address),
                      ),
                    )),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(
                          'https://maps.googleapis.com/maps/api/staticmap?center=${place.location.lat},${place.location.lng}&scale=2&zoom=15&size=400x300&key=$googleApiKey&markers=color:red%7Clabel:%7C${place.location.lat}%2C${place.location.lng}'),
                    ),
                  ),
                  Text(
                    place.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
                  ),
                  Text(
                    place.location.address!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.secondary, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
