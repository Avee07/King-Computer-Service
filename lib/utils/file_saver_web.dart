import 'dart:typed_data';
import 'dart:html' as html;

Future<void> saveFile(String fileName, List<int> fileBytes) async {
  final blob = html.Blob([Uint8List.fromList(fileBytes)],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
