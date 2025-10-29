import 'dart:io';
import 'package:dloader/dloader.dart';

void main() {
  final dloader = Dloader(CurlAdapter());

  final url = 'https://example.com/file.zip';
  final destination = File('/path/to/file.zip');

  dloader
      .download(
        url: url,
        destination: destination,
        onProgress: (progress) {
          print('Percent complete: ${progress['percentComplete']}%');
          print('Bytes downloaded: ${progress['downloaded']}');
          print('Bytes total size: ${progress['totalSize']}');
          print('Speed: ${progress['speed']}');
          print('Time remaining: ${progress['timeRemaining']}');
        },
      )
      .then((File file) {
        print('File downloaded to: ${file.path}');
      })
      .catchError((e) {
        print('Error downloading file: $e');
      });
}
