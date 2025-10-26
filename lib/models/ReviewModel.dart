class ReviewModel {
  final String userId;
  final String locationId;
  final String? pictureUrl;
  final int rating;
  final String? description;
  final List<String> tags;

  ReviewModel({
    required this.userId,
    required this.locationId,
    this.pictureUrl,
    required this.rating,
    this.description,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'locationId': locationId,
      'pictureUrl': pictureUrl,
      'rating': rating,
      'description': description,
      'tags': tags,
    };
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      userId: json['userId'] as String,
      locationId: json['locationId'] as String,
      pictureUrl: json['pictureUrl'] as String?,
      rating: json['rating'] as int,
      description: json['description'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
