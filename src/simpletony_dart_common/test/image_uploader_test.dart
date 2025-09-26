import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:simpletony_dart_common/sdk/azblob/image_uploader.dart';
import 'package:test/test.dart';
import 'package:azblob/azblob.dart';

/// tests for AzureBlobImageUploader
void main() {
  const azureBlobBaseUrl = "https://twiskdev.blob.core.windows.net";
  const base64AzureBlobConnectionString =
      "RGVmYXVsdEVuZHBvaW50c1Byb3RvY29sPWh0dHBzO0FjY291bnROYW1lPXR3aXNrZGV2O0FjY291bnRLZXk9VzhVWnN4c09rY0Y0WjRtc1IraUZWOEI1YnNpcWtpUmpLeUMzOVc5V0ljeWVOcUYyQmFTd2IvSFhZQ25iVW5NTjZCeVFVTmd1Q0hxNitBU3RNUDVRVUE9PTtFbmRwb2ludFN1ZmZpeD1jb3JlLndpbmRvd3MubmV0";
  final azureBlobConnectionString = String.fromCharCodes(base64Decode(base64AzureBlobConnectionString));
  group(AzureBlobImageUploader, () {
    test('test uploadProfileImage', () async {
      final userId = "58IBmu21Qk";
      final pathContext = AzureBlobImageUploader.pathContext;
      final storage = AzureStorage.parse(azureBlobConnectionString);
      final uploader = AzureBlobImageUploader(storage, azureBlobBaseUrl);
      const imageFileName = "hailin_profile.jpg";
      final imageFilePath = pathContext.join("test", "resources", imageFileName);
      final imageFile = File(imageFilePath);
      final url = await uploader.uploadProfileImage(imageFile, userId);
      final expectedUrl = pathContext.join(
          azureBlobBaseUrl,
          AzureBlobImageUploader.imageContainerName,
          AzureBlobImageUploader.profileImageFolder,
          userId,
          imageFileName);
      expect(url == expectedUrl, true,
          reason: "Uploaded URL should match expected URL"
      );
    });
    test('test uploadPostImage', () async {
      final postId = "rkqJnSIsB8";
      final pathContext = AzureBlobImageUploader.pathContext;
      final storage = AzureStorage.parse(azureBlobConnectionString);
      final uploader = AzureBlobImageUploader(storage, azureBlobBaseUrl);
      const imageFileName = "beauty.jpg";
      final imageFilePath = pathContext.join("test", "resources", imageFileName);
      final imageFile = File(imageFilePath);
      final url = await uploader.uploadPostImage(imageFile, postId);
      final expectedUrl = pathContext.join(
          azureBlobBaseUrl,
          AzureBlobImageUploader.imageContainerName,
          AzureBlobImageUploader.postImageFolder,
          postId,
          imageFileName);
      expect(url == expectedUrl, true,
          reason: "Uploaded URL should match expected URL"
      );
    });
  });
}
