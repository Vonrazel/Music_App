// upload_stub.dart
void saveToWebBlob(List<int> bytes) {
  // No-op on non-web platforms
}

String createWebBlobUrl(List<int> bytes) {
  // Return empty string on non-web platforms
  return '';
} 