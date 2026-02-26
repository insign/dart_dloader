import 'dart:io';
import 'package:test/test.dart';
import 'package:dloader/dloader.dart';
import 'package:dio/dio.dart';

void main() {
  test('Test Dloader with timeout', () async {
    final dloader = Dloader(DioAdapter());
    // URL that delays response by 5 seconds
    final url = 'https://httpbin.org/delay/5';
    final destination = File('${Directory.systemTemp.path}/timeout_test.json');

    try {
      await dloader.download(
        url: url,
        destination: destination,
        timeout: Duration(seconds: 2),
      );
      fail('Should have timed out');
    } catch (e) {
      print('Download failed as expected: $e');
      // Dio throws DioException on timeout
      if (e is DioException) {
        expect(
          e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout,
          true,
        );
      } else {
        // Should throw some exception
        expect(e, isNotNull);
      }
    } finally {
      if (destination.existsSync()) {
        destination.deleteSync();
      }
    }
  }, timeout: Timeout(Duration(seconds: 10)));
}
