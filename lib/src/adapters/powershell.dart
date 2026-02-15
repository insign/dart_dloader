import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:executable/executable.dart';

import '../dloader_adapter.dart';

/// This class implements [DloaderAdapter] for downloading using powershell.
class PowerShellAdapter implements DloaderAdapter {
  /// The [Executable] object representing the `powershell` executable.
  @override
  Executable executable = Executable('powershell');

  /// Whether the powershell executable is available on the system.
  @override
  late final bool isAvailable;

  /// The path to the powershell executable.
  @override
  String? executablePath;

  /// Constructor that initializes the [isAvailable] flag.
  PowerShellAdapter() {
    isAvailable = executable.existsSync();
  }

  /// Downloads a file with PowerShell.
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
  }) async {
    if (headers != null && headers.isNotEmpty) {
      print(
        'Warning: Custom headers are not supported by PowerShellAdapter (Start-BitsTransfer). They will be ignored.',
      );
    }
    executablePath ??= (await executable.find())!;
    final process = await Process.start(executablePath!, [
      '-Command',
      'Start-BitsTransfer -Source $url -Destination ${destination.path} ${userAgent != null ? "-UserAgent $userAgent" : ""}}',
    ]);

    await for (var data in process.stdout.transform(utf8.decoder)) {
      final lines = data.split('\n');
      for (final line in lines) {
        onProgress?.call(parseProgress(line));
      }
    }

    return destination;
  }

  /// Parses the progress string from the powershell output.
  Map<String, String> parseProgress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(r'\d+%').firstMatch(progressString);
    if (match != null) {
      progress['percentComplete'] = match.group(0)!;
    }
    return progress;
  }
}
