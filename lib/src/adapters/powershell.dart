import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dloader/dloader.dart';
import 'package:executable/executable.dart';

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
  late final String executablePath;

  /// Constructor that initializes the [isAvailable] flag.
  PowerShellAdapter() {
    isAvailable = executable.existsSync();
  }

  /// Downloads a file with PowerShell.
  /// - url: The URL of the file to download.
  /// - destination: The destination file.
  /// - segments: The number of segments to download the file with.
  /// - onProgress: A function that is called with the download progress.

  @override
  Future<File> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress}) async {
    executablePath = (await executable.find())!;
    Process.start(executablePath, [
      '-Command',
      'Start-BitsTransfer -Source $url -Destination ${destination.path} -UserAgent ${Dloader.userAgent}'
    ]).then((Process process) {
      process.stderr.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        for (final line in lines) {
          onProgress?.call(parsePowerShellProgress(line));
        }
      });
    });

    return destination;
  }

  /// Parses the progress string from the powershell output.
  Map<String, String> parsePowerShellProgress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(r'\d+%').firstMatch(progressString);
    if (match != null) {
      progress['percentComplete'] = match.group(0)!;
    }
    return progress;
  }
}
