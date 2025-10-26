// import 'package:Loaf/models/LocationModel.dart';
// import 'package:Loaf/models/ReviewModel.dart';
// import 'package:Loaf/services/LocationService.dart';
// import 'package:Loaf/services/ReviewServices.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AddLocationService {
//   final _locationRepo = LocationService();
//   final _reviewRepo = ReviewService();
//
//   /// Complete flow for adding a location and review
//   Future<AddLocationResult> addLocationAndReview({
//     required GeoPoint userCoords,
//     required String userId,
//     required int rating,
//     String? customLocationName,
//     int? selectedLocationId,
//     String? pictureUrl,
//     List<String> tags = const [],
//     String? description,
//   }) async {
//     try {
//       LocationModel location;
//       bool isNewLocation = false;
//
//       // Step 1: Check if location already exists nearby
//       final nearbyLocations = await _locationRepo.findNearbyLocations(
//         userCoords,
//       );
//
//       if (nearbyLocations.isNotEmpty && selectedLocationId == null) {
//         // Nearby locations found, but user hasn't selected one
//         return AddLocationResult.needsSelection(nearbyLocations);
//       }
//
//       // Step 2: Either use selected location or create new one
//       if (selectedLocationId != null) {
//         // User selected an existing location
//         final existingLocation = await _locationRepo.getLocation(
//           selectedLocationId,
//         );
//
//         if (existingLocation == null) {
//           throw Exception('Selected location not found');
//         }
//
//         location = existingLocation;
//       } else {
//         // No nearby locations OR user wants to create new one
//         if (customLocationName == null || customLocationName.trim().isEmpty) {
//           throw Exception('Location name is required for new locations');
//         }
//
//         location = await _locationRepo.addLocation(
//           name: customLocationName.trim(),
//           coords: userCoords,
//         );
//
//         isNewLocation = true;
//       }
//
//       // Step 3: Create the review
//       final review = await _reviewRepo.addReview(
//         userId: userId,
//         locationId: location.id,
//         pictureUrl: pictureUrl,
//         rating: rating,
//         description: description,
//         tags: tags,
//       );
//
//       return AddLocationResult.success(
//         location: location,
//         review: review,
//         isNewLocation: isNewLocation,
//       );
//     } catch (e) {
//       return AddLocationResult.error(e.toString());
//     }
//   }
// }
//
// /// Result class to handle different outcomes
// class AddLocationResult {
//   final AddLocationStatus status;
//   final List<LocationWithDistance>? nearbyLocations;
//   final LocationModel? location;
//   final ReviewModel? review;
//   final bool isNewLocation;
//   final String? errorMessage;
//
//   AddLocationResult._({
//     required this.status,
//     this.nearbyLocations,
//     this.location,
//     this.review,
//     this.isNewLocation = false,
//     this.errorMessage,
//   });
//
//   factory AddLocationResult.needsSelection(
//     List<LocationWithDistance> nearbyLocations,
//   ) {
//     return AddLocationResult._(
//       status: AddLocationStatus.needsSelection,
//       nearbyLocations: nearbyLocations,
//     );
//   }
//
//   factory AddLocationResult.success({
//     required LocationModel location,
//     required ReviewModel review,
//     required bool isNewLocation,
//   }) {
//     return AddLocationResult._(
//       status: AddLocationStatus.success,
//       location: location,
//       review: review,
//       isNewLocation: isNewLocation,
//     );
//   }
//
//   factory AddLocationResult.error(String message) {
//     return AddLocationResult._(
//       status: AddLocationStatus.error,
//       errorMessage: message,
//     );
//   }
// }
//
// enum AddLocationStatus { needsSelection, success, error }
