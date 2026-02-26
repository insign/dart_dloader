import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:executable/executable.dart';

import '../dloader_adapter.dart';

/// This class implements [DloaderAdapter] for downloading using wget.
class WgetAdapter implements DloaderAdapter {
  /// The [Executable] object representing the `wget` executable.
  @override
  Executable executable = Executable('wget');

  /// Whether the wget executable is available on the system.
  @override
  late final bool isAvailable;

  /// The path to the wget executable.
  @override
  String? executablePath;

  /// Constructor that initializes the [isAvailable] flag.
  WgetAdapter() {
    isAvailable = executable.existsSync();
  }

  /// Downloads a file with Wget.
  /// - url: The URL of the file to download.
  /// - destination: The destination file.
  /// - headers: Map of custom HTTP headers to include in the request.
  /// - segments: The number of segments to download the file with.
  /// - onProgress: A function that is called with the download progress.
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
    executablePath ??= (await executable.find())!;
    final args = [
      '--continue',
      '--output-document=${destination.path}',
      if (userAgent != null) '--user-agent=$userAgent',
      if (timeout != null)
        '--timeout=${(timeout.inMilliseconds / 1000).ceil()}',
      '--progress=bar:force',
    ];

    if (headers != null) {
      headers.forEach((key, value) {
        args.add('--header=$key: $value');
      });
    }

    args.add(url);

    final process = await Process.start(executablePath!, args);

    await for (var data in process.stdout.transform(utf8.decoder)) {
      final lines = data.split('\n');
      for (final line in lines) {
        onProgress?.call(parseProgress(line));
      }
    }

    return destination;
  }

  /// Parses the progress string from wget.
  Map<String, String> parseProgress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(
      r'.+\s+(\d+)%[^\]]+\]\s+([\w,]+)\s+([\w,]+/s)\s+(?:eta\s([\w\s]+))?',
    ).firstMatch(progressString);
    if (match != null && match.groupCount >= 3) {
      progress["percentComplete"] = match.group(1)!;
      progress["downloaded"] = match.group(2)!;
      progress["speed"] = match.group(3)!;
      if (match.group(4) != null) {
        progress["eta"] = match.group(4)!.trim();
      }
    }

    return progress;
  }
}
