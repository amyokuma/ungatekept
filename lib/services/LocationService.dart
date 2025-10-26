// repositories/location_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Loaf/models/LocationModel.dart';
import 'dart:math';

class LocationService {
  final db = FirebaseFirestore.instance;

  // Distance threshold in meters (e.g., 50 meters)
  static const double distanceThreshold = 50.0;

  /// Find nearby locations within a radius
  /// Returns list of locations sorted by distance
  Future<List<LocationWithDistance>> findNearbyLocations(
    GeoPoint userLocation, {
    int maxResults = 5,
  }) async {
    try {
      // Get all locations (in production, use geohashing for better performance)
      final snapshot = await db.collection('locations').get();

      final locationsWithDistance = <LocationWithDistance>[];

      for (var doc in snapshot.docs) {
        final location = LocationModel.fromJson(doc.data());
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          location.coords.latitude,
          location.coords.longitude,
        );

        // Only include if within threshold
        if (distance <= distanceThreshold) {
          locationsWithDistance.add(
            LocationWithDistance(location: location, distance: distance),
          );
        }
      }

      // Sort by distance and return top k
      locationsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
      return locationsWithDistance.take(maxResults).toList();
    } catch (e) {
      throw Exception('Failed to find nearby locations: $e');
    }
  }

  /// Create a new location
  Future<LocationModel> addLocation({
    required String name,
    required GeoPoint coords,
    required List<String> tags,
    required String description,
  }) async {
    try {
      final docRef = db.collection('locations').doc();

      final location = LocationModel(
        id: docRef.id,
        name: name,
        coords: coords,
        tags: tags,
        description: description,
      );

      // Use location ID as document ID for easy lookups
      await docRef.set(location.toJson());
      print(location.toJson());
      return location;
    } catch (e) {
      throw Exception('Failed to create location: $e');
    }
  }

  /// Get location by ID
  Future<LocationModel?> getLocation(String locationId) async {
    try {
      final doc = await db.collection('locations').doc(locationId).get();

      if (!doc.exists) return null;

      return LocationModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  /// Update location name
  Future<void> updateLocationName(String locationId, String newName) async {
    try {
      await db.collection('locations').doc(locationId).update({
        'name': newName,
      });
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Delete location
  Future<void> deleteLocation(String locationId) async {
    try {
      await db.collection('locations').doc(locationId).delete();
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }

  /// Calculate distance between two coords using Haversine formula
  /// Returns distance in meters
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000; // Earth's radius in meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}

/// Helper class to store location with its distance
class LocationWithDistance {
  final LocationModel location;
  final double distance; // in meters

  LocationWithDistance({required this.location, required this.distance});

  String get distanceFormatted {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }
}
