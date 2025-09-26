import 'dart:io';

import 'package:azblob/azblob.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class AzureBlobImageUploader {
  static const String imageContainerName = "images";
  static const String profileImageFolder = "user_profiles";
  static const String postImageFolder = "post_images";
  static const int maxImageSizeInBytes = 512 * 1024; // 512 KB
  static const List<String> supportedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp'
  ];
  static final pathContext = Context(style: Style.posix);

  late AzureStorage _storage;
  late String _baseUrl;
  AzureBlobImageUploader(AzureStorage storage, String baseUrl) {
    _storage = storage;
    _baseUrl = baseUrl;
  }

  Future<String> uploadImage(File imageFile, String folder,
      {String? extraFolder = null}) async {

    assert(imageFile.lengthSync() <= maxImageSizeInBytes,
        "Image size exceeds the maximum limit of $maxImageSizeInBytes bytes.");
    var fileName = pathContext.basename(imageFile.path);
    var mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
    assert(supportedImageTypes.contains(mimeType),
        "Unsupported image type: $mimeType. Supported types are: $supportedImageTypes");
    var bytes = await imageFile.readAsBytes();
    var blobPath = pathContext.join("/$imageContainerName", folder, extraFolder, fileName);
    await _storage.putBlob(blobPath, bodyBytes: bytes, contentType: mimeType);

    return pathContext.join(_baseUrl, imageContainerName, folder, extraFolder, fileName);
  }

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    return await uploadImage(imageFile, profileImageFolder,
        extraFolder: userId);
  }

  Future<String> uploadPostImage(File imageFile, String postId) async {
    return await uploadImage(imageFile, postImageFolder, extraFolder: postId);
  }
}
