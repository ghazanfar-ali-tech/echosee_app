import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static const String cloudName = 'dvc3xzozh';
  static const String uploadPreset = 'echosee_preset';

  // Cloudinary client (unsigned upload)
  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    cloudName,
    uploadPreset,
    cache: false,
  );

  /// Upload profile image
  static Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      print('Uploading profile image for user: $userId');

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'echosee/profiles',
        ),
      );

      print('Upload success: ${response.secureUrl}');
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary Exception: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  /// Upload general image
  static Future<String?> uploadImage({
    required File imageFile,
    String folder = 'echosee/general',
  }) async {
    try {
      print('Uploading image to folder: $folder');

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: folder,
        ),
      );

      print('Upload success: ${response.secureUrl}');
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary Exception: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }
}
