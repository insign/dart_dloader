import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dloader/dloader.dart';
import 'package:dloader/src/dloader_adapter.dart';
import 'package:executable/executable.dart';

class PowerShellAdapter implements DloaderAdapter {
  @override
  Executable executable = Executable('powershell');

  @override
  late final bool isAvailable;

  @override
  late final String executablePath;

  PowerShellAdapter() {
    isAvailable = executable.existsSync();
  }

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

  Map<String, String> parsePowerShellProgress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(r'\d+%').firstMatch(progressString);
    if (match != null) {
      progress['percentComplete'] = match.group(0)!;
    }
    return progress;
  }
}
