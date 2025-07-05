import 'dart:html' as html;

void saveToWebBlob(List<int> bytes) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", "music.mp3")
    ..click();
  html.Url.revokeObjectUrl(url);
}

String createWebBlobUrl(List<int> bytes) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  return url;
} 