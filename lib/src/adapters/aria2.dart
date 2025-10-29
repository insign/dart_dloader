import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dloader/src/dloader_adapter.dart';
import 'package:executable/executable.dart';
import 'package:path/path.dart' as path;

/// This class implements the [DloaderAdapter] interface and is used to download files using the `aria2c` executable.
class Aria2Adapter implements DloaderAdapter {
  /// The [Executable] object representing the `aria2c` executable.
  @override
  Executable executable = Executable('aria2c');

  /// Whether the aria2c executable is available on the system.
  @override
  late final bool isAvailable;

  /// The path to the aria2c executable.
  @override
  late final String executablePath;

  /// Constructor that initializes the [isAvailable] flag.
  Aria2Adapter() {
    isAvailable = executable.existsSync();
  }

  /// Downloads a file with Aria2.
  ///
  /// - url: The URL of the file to download.
  /// - [destination]: The destination file.
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
    executablePath = (await executable.find())!;
    final filename = path.basename(destination.path);
    final directory = path.dirname(destination.path);

    final process = await Process.start(executablePath, [
      '--max-connection-per-server=$segments',
      '--split=$segments',
      '--min-split-size=1M',
      '--dir=$directory',
      '--out=$filename',
      '--file-allocation=falloc',
      userAgent != null ? '--user-agent=$userAgent' : '',
      '--continue=true',
      '--auto-file-renaming=false',
      '--allow-overwrite=true',
      // '--download-result=full',
      '--human-readable=false',
      '--summary-interval=1',
      // '--log-level=info',
      // '--log=-',
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

  /// Parses the progress string output by the aria2c executable and returns a [Map] containing the progress information.
  Map<String, String> parseProgress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(
      r'\[#[a-f0-9]{6}\s(\d+(?:\.\d+)?[a-zA-Z]{1,3})/(\d+(?:\.\d+)?[a-zA-Z]{1,3})\((\d+)%\)\sCN:(\d+)\sDL:(\d+(?:\.\d+)?[a-zA-Z]{1,3})(?:\sETA:(\w+))?]',
    ).firstMatch(progressString);
    if (match != null && match.groupCount >= 5) {
      progress["downloaded"] = match.group(1)!;
      progress["totalSize"] = match.group(2)!;
      progress["percentComplete"] = match.group(3)!;
      progress["parts"] = match.group(4)!;
      progress["speed"] = match.group(5)!;
      if (match.group(6) != null) {
        progress["eta"] = match.group(6)!;
      }
    }

    return progress;
  }
}
