import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:simpletony_dart_common/sdk/azblob/image_uploader.dart';
import 'package:test/test.dart';
import 'package:azblob/azblob.dart';

/// tests for AzureBlobImageUploader
void main() {
  const azureBlobBaseUrl = 'https://simpletonytwiskdev.blob.core.windows.net';
  const base64AzureBlobConnectionString =
      'RGVmYXVsdEVuZHBvaW50c1Byb3RvY29sPWh0dHBzO0FjY291bnROYW1lPXNpbXBsZXRvbnl0d2lza2RldjtBY2NvdW50S2V5PTZhS25uMWFyOWtUOUIwWkYybTcvenhYNUp2WXVMQ25yZFdZMUVqbmlVRExydFFMU3ZwalZuaG1FU2ZQRU0wZVpqaGljK3JYRi9NVmkrQVN0cDZJeTR3PT07RW5kcG9pbnRTdWZmaXg9Y29yZS53aW5kb3dzLm5ldA==';
  final azureBlobConnectionString =
      String.fromCharCodes(base64Decode(base64AzureBlobConnectionString));
  group(AzureBlobImageUploader, () {
    test('test uploadProfileImage', () async {
      final userId = '58IBmu21Qk';
      final pathContext = AzureBlobImageUploader.pathContext;
      final storage = AzureStorage.parse(azureBlobConnectionString);
      final uploader = AzureBlobImageUploader(storage, azureBlobBaseUrl);
      const imageFileName = 'hailin_profile.jpg';
      final imageFilePath =
          pathContext.join('test', 'resources', imageFileName);
      final imageFile = File(imageFilePath);
      final url = await uploader.uploadProfileImage(imageFile, userId);
      final expectedUrl = pathContext.join(
          azureBlobBaseUrl,
          AzureBlobImageUploader.imageContainerName,
          AzureBlobImageUploader.profileImageFolder,
          userId,
          imageFileName);
      expect(url == expectedUrl, true,
          reason: 'Uploaded URL should match expected URL');
    });
    test('test uploadPostImage', () async {
      final postId = 'rkqJnSIsB8';
      final pathContext = AzureBlobImageUploader.pathContext;
      final storage = AzureStorage.parse(azureBlobConnectionString);
      final uploader = AzureBlobImageUploader(storage, azureBlobBaseUrl);
      const imageFileName = 'beauty.jpg';
      final imageFilePath =
          pathContext.join('test', 'resources', imageFileName);
      final imageFile = File(imageFilePath);
      final url = await uploader.uploadPostImage(imageFile, postId);
      final expectedUrl = pathContext.join(
          azureBlobBaseUrl,
          AzureBlobImageUploader.imageContainerName,
          AzureBlobImageUploader.postImageFolder,
          postId,
          imageFileName);
      expect(url == expectedUrl, true,
          reason: 'Uploaded URL should match expected URL');
    });

    test('test deleteImage', () async {
      final storage = AzureStorage.parse(azureBlobConnectionString);
      final uploader = AzureBlobImageUploader(storage, azureBlobBaseUrl);
      const imageUrl =
          'https://simpletonytwiskdev.blob.core.windows.net/images/post_images/2r5b-f4Tnh/Screenshot_20250818_112105_com.pursuit.flutter_custom_painter.jpg';

      await uploader.deleteImage(imageUrl);
    });

    test('test isImageOversize', () async {
      final pathContext = AzureBlobImageUploader.pathContext;
      const imageFileName = 'beauty.jpg';
      final imageFilePath =
          pathContext.join('test', 'resources', imageFileName);
      final imageFile = File(imageFilePath);

      expect(AzureBlobImageUploader.isImageOversize(imageFile), false,
          reason: 'Small image should not be judged as oversize');
    });

    test('test isSupportedImageType', () async {
      final pathContext = AzureBlobImageUploader.pathContext;
      const imageFileName = 'beauty.jpg';
      final imageFilePath =
          pathContext.join('test', 'resources', imageFileName);
      final imageFile = File(imageFilePath);

      expect(AzureBlobImageUploader.isSupportedImageType(imageFile), true,
          reason: 'Supported image type should be recognized');
    });
  });
}
