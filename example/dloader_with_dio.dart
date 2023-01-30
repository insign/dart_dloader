import 'dart:io';
import 'package:dloader/dloader.dart';
import 'package:dloader/src/adapters/dio.dart';

void main() {
  final dloader = Dloader(DioAdapter());

  final url = 'https://example.com/file.zip';
  final destination = File('/home/helio/file.zip');

  dloader
      .download(
          url: url,
          destination: destination,
          onProgress: (progress) {
            print('Percent complete: ${progress['percentComplete']}%');
          })
      .then((File file) {
    print('File downloaded to: ${file.path}');
  }).catchError((e) {
    print('Error downloading file: $e');
  });
}
