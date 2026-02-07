import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dloader/src/dloader_adapter.dart';
import 'package:executable/executable.dart';

/// This class implements [DloaderAdapter] for downloading using curl.
class CurlAdapter implements DloaderAdapter {
  /// The [Executable] object representing the `curl` executable.
  @override
  Executable executable = Executable('curl');

  /// Whether the curl executable is available on the system.
  @override
  late final bool isAvailable;

  /// The path to the curl executable.
  @override
  String? executablePath;

  /// Constructor that initializes the [isAvailable] flag.
  CurlAdapter() {
    isAvailable = executable.existsSync();
  }

  /// Downloads a file with Curl.
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
      '--create-dirs',
      '--location',
      userAgent != null ? '--user-agent' : '',
      userAgent ?? '',
      '--output',
      destination.path,
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

  /// Parses the progress string from curl and returns a [Map] with the progress
  Map<String, String> parseProgress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(
      r'(\d+)\s+([\w.]+)\s+(\d+)\s+([\w.]+)\s+(\d+)\s+(\d+)\s+([\w.]+)\s+(\d+)\s+([0-9:]+)\s+([0-9:]+)\s+([0-9:]+)\s+([\w.]+)',
    ).firstMatch(progressString);
    if (match != null && match.groupCount == 12) {
      progress["percentComplete"] = match.group(1)!;
      progress["totalSize"] = match.group(2)!;
      progress["downloaded"] = match.group(3)!;
      progress["averageSpeed"] = match.group(7)!;
      progress["totalTime"] = match.group(9)!;
      progress["spentTime"] = match.group(10)!;
      progress["eta"] = match.group(11)!;
      progress["speed"] = match.group(12)!;
    }

    return progress;
  }
}
