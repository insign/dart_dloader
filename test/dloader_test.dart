import 'dart:io';
import 'package:test/test.dart';
import 'package:dloader/dloader.dart';

/// Tests for the [Dloader] class.
void main() {
  test('Test Dloader with DioAdapter and valid URL', () async {
    final dloader = Dloader(DioAdapter());
    final url = 'https://proof.ovh.net/files/1Mb.dat';
    final destination = File('${Directory.systemTemp.path}/1Mb.dat');

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
      final destination = File('${Directory.systemTemp.path}/file.dat');

      await dloader.download(
        url: url,
        destination: destination,
        onProgress: (progress) {
          print('Percent complete: ${progress['percentComplete']}%');
        },
      );
    }, throwsException);
  });

  test('Test Dloader reuse CurlAdapter', () async {
    final adapter = CurlAdapter();
    if (!adapter.isAvailable) {
      print('Skipping test: curl not available');
      return;
    }
    final dloader = Dloader(adapter);
    final url = 'https://www.google.com';
    final destination1 = File('test_1.html');
    final destination2 = File('test_2.html');

    try {
      await dloader.download(
        url: url,
        destination: destination1,
      );
      expect(destination1.existsSync(), true);

      await dloader.download(
        url: url,
        destination: destination2,
      );
      expect(destination2.existsSync(), true);
    } finally {
      if (destination1.existsSync()) destination1.deleteSync();
      if (destination2.existsSync()) destination2.deleteSync();
    }
  });

  test('Test Dloader with DioAdapter reports speed and ETA', () async {
    final dloader = Dloader(DioAdapter());
    final url = 'https://proof.ovh.net/files/1Mb.dat';
    final destination = File('${Directory.systemTemp.path}/1Mb.dat');

    bool hasSpeed = false;
    bool hasEta = false;

    try {
      await dloader.download(
        url: url,
        destination: destination,
        onProgress: (progress) {
          if (progress.containsKey('speed')) hasSpeed = true;
          if (progress.containsKey('eta')) hasEta = true;
        },
      );
    } finally {
      if (destination.existsSync()) destination.deleteSync();
    }

    expect(hasSpeed, true);
    expect(hasEta, true);
  });
}
