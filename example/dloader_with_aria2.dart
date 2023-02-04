import 'dart:io';
import 'package:dloader/dloader.dart';

void main() {
  final dloader = Dloader(Aria2Adapter());

  final url = 'https://example.com/file.zip';
  final destination = File('/path/to/file.zip');

  dloader
      .download(
          url: url,
          destination: destination,
          onProgress: (progress) {
            print('Percent complete: ${progress['percentComplete']}%');
            print('Downloaded: ${progress['downloaded']}');
            print('Total size: ${progress['totalSize']}');
            print('Parts: ${progress['parts']}');
            print('Speed: ${progress['speed']}');
            if (progress.containsKey('eta')) {
              print('ETA: ${progress['eta']}');
            }
          })
      .then((File file) {
    print('File downloaded to: ${file.path}');
  }).catchError((e) {
    print('Error downloading file: $e');
  });
}
