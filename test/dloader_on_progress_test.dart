import 'dart:io';
import 'package:dloader/dloader.dart';
import 'package:executable/executable.dart';
import 'package:test/test.dart';

class MockAdapter implements DloaderAdapter {
  @override
  Executable executable = Executable('mock');

  @override
  bool isAvailable = true;

  @override
  String? executablePath = '/bin/mock';

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
    // Simulate progress
    if (onProgress != null) {
      onProgress({
        'percentComplete': '50',
        'downloaded': '100',
        'totalSize': '200',
      });
    }
    return destination;
  }
}

void main() {
  test('Dloader uses instance onProgress as fallback', () async {
    final adapter = MockAdapter();
    final dloader = Dloader(adapter);
    bool instanceProgressCalled = false;

    dloader.onProgress = (Map<String, dynamic> progress) {
      instanceProgressCalled = true;
      expect(progress['percentComplete'], '50');
    };

    await dloader.download(
      url: 'http://example.com',
      destination: File('test_file'),
    );

    expect(
      instanceProgressCalled,
      isTrue,
      reason: 'Instance onProgress should be called',
    );
  });

  test('Dloader uses passed onProgress over instance onProgress', () async {
    final adapter = MockAdapter();
    final dloader = Dloader(adapter);
    bool instanceProgressCalled = false;
    bool argProgressCalled = false;

    dloader.onProgress = (Map<String, dynamic> progress) {
      instanceProgressCalled = true;
    };

    await dloader.download(
      url: 'http://example.com',
      destination: File('test_file'),
      onProgress: (progress) {
        argProgressCalled = true;
      },
    );

    expect(
      argProgressCalled,
      isTrue,
      reason: 'Argument onProgress should be called',
    );
    expect(
      instanceProgressCalled,
      isFalse,
      reason: 'Instance onProgress should NOT be called',
    );
  });
}
