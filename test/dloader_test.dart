import 'dart:io';
import 'package:test/test.dart';
import 'package:dloader/dloader.dart';

/// Tests for the [Dloader] class.
void main() {
  test('Test Dloader with DioAdapter and valid URL', () async {
    final dloader = Dloader(DioAdapter());
    final url = 'https://proof.ovh.net/files/1Mb.dat';
    final destination = File('/tmp/1Mb.dat');

    final file = await dloader.download(
      url: url,
      destination: destination,
      onProgress: (progress) {
        print('Percent complete: ${progress['percentComplete']}%');
      },
    );

    expect(file.existsSync(), true);
    expect(file.lengthSync(), 1048576);
  });

  test('Test Dloader with DioAdapter and invalid URL', () async {
    expect(() async {
      final dloader = Dloader(DioAdapter());
      final url = 'https://invalid.supersite/file.dat';
      final destination = File('/tmp/file.dat');

      await dloader.download(
        url: url,
        destination: destination,
        onProgress: (progress) {
          print('Percent complete: ${progress['percentComplete']}%');
        },
      );
    }, throwsException);
  });
}
