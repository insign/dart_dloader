import 'dart:io';
import 'package:dloader/dloader.dart';
import 'package:executable/executable.dart';
import 'package:test/test.dart';

class FailingAdapter implements DloaderAdapter {
  int attempts = 0;
  final int failsCount;
  final File mockFile;

  FailingAdapter(this.failsCount, this.mockFile);

  @override
  Executable executable = Executable('fail');

  @override
  bool isAvailable = true;

  @override
  String? executablePath = '/bin/fail';

  @override
  Future<File> download({
    required String url,
    required File destination,
    Map<String, String>? headers,
    String? userAgent,
    int? segments,
    Function(Map<String, dynamic>)? onProgress,
    Duration? timeout,
  }) async {
    attempts++;
    if (attempts <= failsCount) {
      throw Exception('Simulated download failure (Attempt $attempts)');
    }
    // Simulate success
    await mockFile.create(recursive: true);
    return mockFile;
  }
}

void main() {
  final tempDir = Directory.systemTemp.createTempSync('dloader_retry_test');
  final mockFile = File('${tempDir.path}/downloaded_file.txt');

  tearDown(() {
    if (mockFile.existsSync()) {
      mockFile.deleteSync();
    }
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Dloader retries on failure and eventually succeeds', () async {
    final adapter = FailingAdapter(2, mockFile); // Fails 2 times
    final dloader = Dloader(adapter);

    // Should succeed on 3rd attempt (after 2 retries)
    await dloader.download(
      url: 'http://example.com',
      destination: mockFile,
      retries: 2,
    );

    expect(adapter.attempts, 3);
    expect(mockFile.existsSync(), isTrue);
  });

  test('Dloader fails if retries are exhausted', () async {
    final adapter = FailingAdapter(3, mockFile); // Fails 3 times
    final dloader = Dloader(adapter);

    // Should fail after 1 attempt + 1 retry = 2 attempts.
    try {
      await dloader.download(
        url: 'http://example.com',
        destination: mockFile,
        retries: 1,
      );
      fail('Should have thrown exception');
    } catch (e) {
      // expected
    }

    expect(adapter.attempts, 2);
  });
}
