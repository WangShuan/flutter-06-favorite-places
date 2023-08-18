import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/places_provider.dart';
import '../models/place.dart';
import '../widgets/place_item.dart';
import './new_place_screen.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  late Future _placesFuture;
  @override
  void initState() {
    _placesFuture = ref.read(placesProvider.notifier).getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的所有秘密基地'),
        actions: [
          IconButton(
              onPressed: () async {
                final p = await Navigator.of(context).push<Place>(MaterialPageRoute(
                  builder: (context) => const NewPlaceScreen(),
                ));
                ref.read(placesProvider.notifier).addPlace(p!);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: _placesFuture,
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : places.isEmpty
                ? const Center(
                    child: Text('尚未添加任何地點。'),
                  )
                : ListView.builder(
                    itemBuilder: (context, index) => PlaceItem(places[index]),
                    itemCount: places.length,
                  ),
      ),
    );
  }
}
