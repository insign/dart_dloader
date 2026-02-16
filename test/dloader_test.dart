import 'dart:convert';
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
      await dloader.download(url: url, destination: destination1);
      expect(destination1.existsSync(), true);

      await dloader.download(url: url, destination: destination2);
      expect(destination2.existsSync(), true);
    } finally {
      if (destination1.existsSync()) destination1.deleteSync();
      if (destination2.existsSync()) destination2.deleteSync();
    }
  });

  test('Test Dloader with CurlAdapter and valid URL with progress', () async {
    final adapter = CurlAdapter();
    if (!adapter.isAvailable) {
      print('Skipping test: curl not available');
      return;
    }
    final dloader = Dloader(adapter);
    final url = 'https://proof.ovh.net/files/1Mb.dat';
    final destination = File('${Directory.systemTemp.path}/curl_1Mb.dat');

    try {
      bool progressCalled = false;
      final file = await dloader.download(
        url: url,
        destination: destination,
        onProgress: (progress) {
          if (progress.containsKey('percentComplete')) {
            progressCalled = true;
            print('Curl Percent complete: ${progress['percentComplete']}%');
          }
        },
      );

      expect(file.existsSync(), true);
      expect(file.lengthSync(), 1048576);
      expect(progressCalled, true);
    } finally {
      if (destination.existsSync()) destination.deleteSync();
    }
  });

  test('Test Dloader.auto()', () async {
    final dloader = Dloader.auto();
    final url = 'https://proof.ovh.net/files/1Mb.dat';
    final destination = File('${Directory.systemTemp.path}/auto_1Mb.dat');

    print('Using adapter: ${dloader.adapter.runtimeType}');

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

  test('Test Dloader with custom headers', () async {
    final dloader = Dloader(DioAdapter());
    final url = 'https://httpbin.org/headers';
    final destination = File('${Directory.systemTemp.path}/headers.json');

    try {
      final file = await dloader.download(
        url: url,
        destination: destination,
        headers: {'X-Custom-Header': 'MyValue'},
      );

      expect(file.existsSync(), true);
      final content = await file.readAsString();
      final json = jsonDecode(content);
      expect(json['headers']['X-Custom-Header'], 'MyValue');
    } finally {
      if (destination.existsSync()) {
        destination.deleteSync();
      }
    }
  });

  test('Test Dloader with default onProgress', () async {
    final dloader = Dloader(DioAdapter());
    final url = 'https://proof.ovh.net/files/1Mb.dat';
    final destination = File('${Directory.systemTemp.path}/default_progress.dat');
    bool progressCalled = false;

    dloader.onProgress = (progress) {
      if (progress.containsKey('percentComplete')) {
        progressCalled = true;
      }
    };

    try {
      final file = await dloader.download(
        url: url,
        destination: destination,
      );

      expect(file.existsSync(), true);
      expect(file.lengthSync(), 1048576);
      expect(progressCalled, true);
    } finally {
      if (destination.existsSync()) {
        destination.deleteSync();
      }
    }
  });
}
