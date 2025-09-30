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
    'image/webp',
    'image/gif'
  ];
  static final pathContext = Context(style: Style.posix);

  final AzureStorage _storage;
  final String _baseUrl;
  AzureBlobImageUploader(this._storage, this._baseUrl);

  static bool isImageOversize(File imageFile) {
    return imageFile.lengthSync() > maxImageSizeInBytes;
  }

  static bool isSupportedImageType(File imageFile) {
    final fileName = pathContext.basename(imageFile.path);
    final mimeType = lookupMimeType(fileName);
    return mimeType != null && supportedImageTypes.contains(mimeType);
  }

  Future<String> uploadImage(File imageFile, String folder,
      {String? extraFolder = null}) async {
    assert(!isImageOversize(imageFile),
        "Image size exceeds the maximum limit of $maxImageSizeInBytes bytes.");
    final fileName = pathContext.basename(imageFile.path);
    assert(isSupportedImageType(imageFile),
        "Unsupported image type. Supported types are: $supportedImageTypes");
    final bytes = await imageFile.readAsBytes();
    final relativePath =
        pathContext.join(imageContainerName, folder, extraFolder, fileName);
    // Azure Blob path should start with '/'
    final blobPath = pathContext.join('/', relativePath);
    await _storage.putBlob(blobPath, bodyBytes: bytes, contentType: mimeType);

    return pathContext.join(_baseUrl, relativePath);
  }

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    return await uploadImage(imageFile, profileImageFolder,
        extraFolder: userId);
  }

  Future<String> uploadPostImage(File imageFile, String postId) async {
    return await uploadImage(imageFile, postImageFolder, extraFolder: postId);
  }

  Future<void> deleteImage(String imageUrl) async {
    if (!imageUrl.startsWith(_baseUrl)) {
      throw ArgumentError(
          "Image URL does not belong to the configured base URL.");
    }

    final relativePath = imageUrl.substring(_baseUrl.length);
    await _storage.deleteBlob(relativePath);
  }
}
