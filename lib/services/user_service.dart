import 'package:Loaf/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'users';

  // Create - Add a new user
  Future<void> createUser(UserModel user) async {
    try {
      final userJson = user.toJson();
      print(userJson);
      await _firestore.collection(_collectionName).doc(user.id).set(userJson);
    } catch (e) {
      print(e);
    }
  }

  // Read - Get a single user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection(_collectionName).doc(userId).get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  // Read - Get all users
  Future<List<UserModel>> getAllUsers() async {
    final querySnapshot = await _firestore.collection(_collectionName).get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  // Read - Stream a single user (real-time updates)
  Stream<UserModel?> streamUser(String userId) {
    return _firestore.collection(_collectionName).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Read - Stream all users (real-time updates)
  Stream<List<UserModel>> streamAllUsers() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map((doc) => UserModel.fromJson(doc.data()))
              .toList(),
        );
  }

  // Update - Update entire user
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(_collectionName)
        .doc(user.id)
        .update(user.toJson());
  }

  // Update - Update specific fields
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    await _firestore.collection(_collectionName).doc(userId).update(fields);
  }

  // Delete - Delete a user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_collectionName).doc(userId).delete();
  }

  // Query example - Get users by email
  Future<List<UserModel>> getUsersByEmail(String email) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  // Query example - Get users with name containing a string
  Future<List<UserModel>> searchUsersByName(String searchTerm) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }
}
