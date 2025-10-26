import 'package:cloud_firestore/cloud_firestore.dart';

class SpotModel {
  final String id;
  final String description;
  final GeoPoint location;
  final String pictures;
  final String place;
  final List<String> tags;
  final List<RatingModel>? ratings;

  SpotModel({
    required this.id,
    required this.description,
    required this.location,
    required this.pictures,
    required this.place,
    required this.tags,
    this.ratings,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'location': location,
      'pictures': pictures,
      'place': place,
      'tags': tags,
    };
  }
}

class RatingModel {
  final String id;
  final int rating;
  final DocumentReference who;

  RatingModel({required this.id, required this.rating, required this.who});

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'who': who};
  }
}
