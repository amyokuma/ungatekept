import 'dart:io';
import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path;

class StorageService {
  Future<String?> uploadPicture(File imageFile) async {
    try {
      final credentials = ServiceAccountCredentials.fromJson(
        File('/Users/amyokuma/Desktop/Projects/Calhacks/ungatekept/assets/service-account.json').readAsStringSync(),
      );

      final httpClient = await clientViaServiceAccount(
        credentials, 
        [StorageApi.devstorageFullControlScope]
      );

      final storage = StorageApi(httpClient);

      // Generate a unique filename
      final fileName = path.basename(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final picturePath = 'uploads/$timestamp-$fileName';

      // Determine content type based on file extension
      final contentType = _getContentType(fileName);

      final fileContent = await imageFile.readAsBytes();

      final bucketObject = Object(
        name: picturePath, 
        contentType: contentType
      );
      
      final resp = await storage.objects.insert(
        bucketObject,
        'calhacks-picture-bucket',
        uploadMedia: Media(
          Stream<List<int>>.fromIterable([fileContent]), 
          fileContent.length,
          contentType: contentType  // ADD THIS LINE
        ),
      );

      httpClient.close();

      // Return the public URL or path
      return 'gs://calhacks-picture-bucket/$picturePath';
      
    } catch (e) {
      print('Error uploading picture: $e');
      return null;
    }
  }

  String _getContentType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }
}