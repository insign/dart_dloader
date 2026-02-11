import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../dloader_adapter.dart';
import 'package:executable/executable.dart';

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
  /// - segments: The number of segments to download the file with.
  /// - onProgress: A function that is called with the download progress.
  @override
  Future<File> download({
    required String url,
    required File destination,
    String? userAgent,
    int? segments,
    Function(Map<String, dynamic>)? onProgress,
  }) async {
    executablePath ??= (await executable.find())!;
    final process = await Process.start(executablePath!, [
      '--continue',
      '--output-document=${destination.path}',
      userAgent != null ? '--user-agent=$userAgent' : '',
      '--progress=bar:force',
      url,
    ]);

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
