import 'package:Loaf/models/ReviewModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final db = FirebaseFirestore.instance;

  /// Create a new review
  Future<ReviewModel> addReview({
    required String userId,
    required String locationId,
    String? pictureUrl,
    required int rating,
    String? description,
    List<String> tags = const [],
  }) async {
    try {
      final docRef = db.collection('reviews').doc();

      final review = ReviewModel(
        userId: userId,
        locationId: locationId,
        pictureUrl: pictureUrl,
        rating: rating,
        description: description,
        tags: tags,
      );

      await docRef.set(review.toJson());
      print(review.toJson());

      return review;
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Get all reviews for a location
  Future<List<ReviewModel>> getReviewsForLocation(String locationId) async {
    try {
      final snapshot = await db
          .collection('reviews')
          .where('locationId', isEqualTo: locationId)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get reviews: $e');
    }
  }

  /// Get all reviews by a user
  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    try {
      final snapshot = await db
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user reviews: $e');
    }
  }

  /// Get reviews stream for real-time updates
  Stream<List<ReviewModel>> getReviewsStream(String locationId) {
    return db
        .collection('reviews')
        .where('locationId', isEqualTo: locationId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromJson(doc.data()))
              .toList();
        });
  }

  /// Update review
  Future<void> updateReview(ReviewModel review) async {
    try {
      await db.collection('reviews').doc(review.userId).update(review.toJson());
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await db.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  String getNextID() {
    try {
      return db.collection('reviews').doc().id;
    } catch (e) {
      throw Exception('Could not get unique id');
    }
  }

  /// Search reviews by tags
  Future<List<ReviewModel>> searchByTags(List<String> tags) async {
    try {
      final snapshot = await db
          .collection('reviews')
          .where('tags', arrayContainsAny: tags)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search reviews: $e');
    }
  }
}
