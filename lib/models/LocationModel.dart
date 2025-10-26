import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String id;
  final String name;
  final GeoPoint coords;
  final List<String> tags;
  final String description;

  LocationModel({
    required this.id,
    required this.name,
    required this.coords,
    required this.tags,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'coords': coords};
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      coords: json['coords'] as GeoPoint,
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] as String? ?? '',
    );
  }
}
