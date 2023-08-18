import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.initLocation = const PlaceLocation(
      lat: 25.10235351700014,
      lng: 121.54849200004878,
    ),
    this.isSelecting = true,
  });
  final bool isSelecting;
  final PlaceLocation initLocation;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _markerLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? '請選擇地點' : widget.initLocation.address!),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () => Navigator.of(context).pop(_markerLocation),
              icon: const Icon(Icons.save_rounded),
            )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.initLocation.lat,
            widget.initLocation.lng,
          ),
          zoom: 16,
        ),
        onTap: widget.isSelecting
            ? (posi) {
                setState(() {
                  _markerLocation = posi;
                });
              }
            : null,
        markers: (_markerLocation != null || widget.isSelecting == false)
            ? {
                Marker(
                  markerId: const MarkerId('m1'),
                  position: _markerLocation ?? LatLng(widget.initLocation.lat, widget.initLocation.lng),
                ),
              }
            : {},
      ),
    );
  }
}
