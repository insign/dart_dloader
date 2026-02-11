import 'dart:io';

import 'package:dloader/dloader.dart';
import 'package:test/test.dart';

void main() {
  test('Test Dloader.auto() selects an available adapter', () {
    final dloader = Dloader.auto();
    expect(dloader.adapter, isNotNull);
    expect(dloader.adapter.isAvailable, isTrue);
    print('Selected adapter: ${dloader.adapter.runtimeType}');
  });

  test('Test Dloader.auto() download', () async {
    final dloader = Dloader.auto();
    final url = 'https://proof.ovh.net/files/1Mb.dat';
    final destination = File('${Directory.systemTemp.path}/1Mb_auto.dat');

    // Ensure cleanup
    if (destination.existsSync()) {
      destination.deleteSync();
    }

    try {
      final file = await dloader.download(
        url: url,
        destination: destination,
        onProgress: (progress) {
          // print('Percent complete: ${progress['percentComplete']}%');
        },
      );

      expect(file.existsSync(), true);
      expect(file.lengthSync(), 1048576);
    } finally {
      if (destination.existsSync()) {
        destination.deleteSync();
      }
    }
  });
}
