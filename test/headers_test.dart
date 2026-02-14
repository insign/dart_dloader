import 'dart:io';
import 'package:test/test.dart';
import 'package:dloader/dloader.dart';

void main() {
  test('Test Dloader sends custom headers (DioAdapter)', () async {
    final dloader = Dloader(DioAdapter());
    // Use httpbin.org to echo headers
    final url = 'https://httpbin.org/headers';
    final destination = File('${Directory.systemTemp.path}/headers_dio.json');

    try {
      if (destination.existsSync()) {
        destination.deleteSync();
      }

      await dloader.download(
        url: url,
        destination: destination,
        headers: {'X-Dloader-Test': 'VerifyHeaderDio'},
      );

      expect(destination.existsSync(), true);
      final content = destination.readAsStringSync();
      print('Dio content: $content');
      // httpbin usually returns headers with the same casing or standard casing
      expect(content, contains('VerifyHeaderDio'));
    } finally {
      if (destination.existsSync()) {
        destination.deleteSync();
      }
    }
  });

  test('Test Dloader sends custom headers (CurlAdapter)', () async {
    final adapter = CurlAdapter();
    if (!adapter.isAvailable) {
      print('Skipping Curl test: curl not available');
      return;
    }
    final dloader = Dloader(adapter);
    final url = 'https://httpbin.org/headers';
    final destination = File('${Directory.systemTemp.path}/headers_curl.json');

    try {
      if (destination.existsSync()) {
        destination.deleteSync();
      }

      await dloader.download(
        url: url,
        destination: destination,
        headers: {'X-Dloader-Test': 'VerifyHeaderCurl'},
      );

      expect(destination.existsSync(), true);
      final content = destination.readAsStringSync();
      print('Curl content: $content');
      expect(content, contains('VerifyHeaderCurl'));
    } finally {
      if (destination.existsSync()) {
        destination.deleteSync();
      }
    }
  });
}
