import 'dart:io';
import 'dart:typed_data';

import 'package:azblob/azblob.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class AzureBlobImageUploader {
  static const String imageContainerName = 'images';
  static const String profileImageFolder = 'user_profiles';
  static const String postImageFolder = 'post_images';
  static const int maxImageSizeInKb = 512;
  static const int maxImageSizeInBytes = maxImageSizeInKb * 1024; // 512 KB

  static const String jpegMimeType = 'image/jpeg';
  static const String pngMimeType = 'image/png';
  static const String webpMimeType = 'image/webp';
  static const String gifMimeType = 'image/gif';
  static const List<String> supportedImageTypes = [
    jpegMimeType,
    pngMimeType,
    webpMimeType,
    gifMimeType
  ];
  static final pathContext = Context(style: Style.posix);

  final AzureStorage _storage;
  final String _baseUrl;
  AzureBlobImageUploader(this._storage, this._baseUrl);

  static bool isImageOversize(File imageFile) =>
      imageFile.lengthSync() > maxImageSizeInBytes;

  static bool isImageBytesOversize(Uint8List bytes) =>
      bytes.length > maxImageSizeInBytes;

  static bool isSupportedImageType(File imageFile) {
    final fileName = pathContext.basename(imageFile.path);
    final mimeType = lookupMimeType(fileName);
    return mimeType != null && supportedImageTypes.contains(mimeType);
  }

  static bool isSupportedImageFileName(String fileName) {
    final mimeType = lookupMimeType(fileName);
    return mimeType != null && supportedImageTypes.contains(mimeType);
  }

  static void assertImageSize(bool isImageUnderMaxSize) {
    assert(isImageUnderMaxSize,
        'Image size exceeds the maximum limit of $maxImageSizeInBytes bytes.');
  }

  static void assertImageFileName(String fileName) {
    assert(isSupportedImageFileName(fileName),
        'Unsupported image type. Supported types are: $supportedImageTypes');
  }

  Future<String> uploadImage(File imageFile, String folder,
      {String? extraFolder = null}) async {
    assertImageSize(
      !isImageOversize(imageFile),
    );
    // Just in case we are running in Windows
    final filePath = imageFile.path.replaceAll('\\', '/');
    final fileName = pathContext.basename(filePath);
    assertImageFileName(fileName);
    final bytes = await imageFile.readAsBytes();
    return upload(fileName, bytes, folder, extraFolder: extraFolder);
  }

  Future<String> uploadImageAsBytes(
      String fileName, Uint8List bytes, String folder,
      {String? extraFolder = null}) async {
    assertImageSize(!isImageBytesOversize(bytes));
    assertImageFileName(fileName);
    return upload(fileName, bytes, folder, extraFolder: extraFolder);
  }

  Future<String> upload(String fileName, Uint8List bytes, String folder,
      {String? extraFolder = null}) async {
    final relativePath = extraFolder != null && extraFolder.isNotEmpty
        ? pathContext.join(imageContainerName, folder, extraFolder, fileName)
        : pathContext.join(imageContainerName, folder, fileName);
    // Azure Blob path should start with '/'
    final blobPath = pathContext.join('/', relativePath);
    final mimeType = lookupMimeType(fileName);
    await _storage.putBlob(blobPath, bodyBytes: bytes, contentType: mimeType);

    return pathContext.join(_baseUrl, relativePath);
  }

  Future<String> uploadProfileImage(File imageFile, String userId) async =>
      await uploadImage(imageFile, profileImageFolder, extraFolder: userId);

  Future<String> uploadProfileImageAsBytes(
          String fileName, Uint8List bytes, String userId) async =>
      await uploadImageAsBytes(fileName, bytes, profileImageFolder,
          extraFolder: userId);

  Future<String> uploadPostImage(File imageFile, String postId) async =>
      await uploadImage(imageFile, postImageFolder, extraFolder: postId);

  Future<String> uploadPostImageAsBytes(
          String fileName, Uint8List bytes, String postId) async =>
      await uploadImageAsBytes(fileName, bytes, postImageFolder,
          extraFolder: postId);

  Future<void> deleteImage(String imageUrl) async {
    if (!imageUrl.startsWith(_baseUrl)) {
      throw ArgumentError(
          'Image URL does not belong to the configured base URL.');
    }

    final relativePath = imageUrl.substring(_baseUrl.length);
    await _storage.deleteBlob(relativePath);
  }
}
