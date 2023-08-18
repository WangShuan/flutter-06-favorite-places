import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

import '../models/place.dart';

Future<sql.Database> _getDb() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute('CREATE TABLE places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
  return db;
}

class PlacesNotifier extends StateNotifier<List<Place>> {
  PlacesNotifier() : super([]);

  Future<void> removePlace(Place place) async {
    final db = await _getDb();
    db.delete('places', where: 'id = ?', whereArgs: [place.id]);
    if (state.contains(place)) {
      state = state.where((element) => element.id != place.id).toList();
    }
  }

  Future<void> addPlace(Place place) async {
    final db = await _getDb();

    db.insert('places', {
      'id': place.id,
      'title': place.title,
      'image': place.image.path,
      'lat': place.location.lat,
      'lng': place.location.lng,
      'address': place.location.address,
    });

    state = [place, ...state];
  }

  Future<void> getData() async {
    final db = await _getDb();
    final data = await db.query('places');
    final p = data
        .map(
          (e) => Place(
            id: e['id'] as String,
            title: e['title'] as String,
            image: File(e['image'] as String),
            location: PlaceLocation(
              lat: e['lat'] as double,
              lng: e['lng'] as double,
              address: e['address'] as String,
            ),
          ),
        )
        .toList();

    state = p;
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>(
  (ref) {
    return PlacesNotifier();
  },
);
