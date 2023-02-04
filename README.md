A simple and versatile library for downloading files with support for adapters including dio, curl, wget, powershell, aria2 and axel. Feel free to create new adapters.

## Getting started

```dart
dart pub add dloader
```
## Usage

```dart
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
          })
      .then((File file) {
    print('File downloaded to: ${file.path}');
  }).catchError((e) {
    print('Error downloading file: $e');
  });
}
```

## LICENSE

[BSD 3-Clause License](./LICENSE)

## CONTRIBUTE
If you have an idea for a new feature or have found a bug, just do a pull request (PR).
