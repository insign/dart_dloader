import 'dart:convert';
import 'dart:io';
import 'package:dloader/dloader.dart';
import 'package:dloader/src/dloader_adapter.dart';
import 'package:executable/executable.dart';

class AxelAdapter implements DloaderAdapter {
  @override
  Executable executable = Executable('axel');

  @override
  late final bool isAvailable;

  @override
  late final String executablePath;

  AxelAdapter() {
    isAvailable = executable.existsSync();
  }

  @override
  Future<File> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress}) async {
    executablePath = (await executable.find())!;

    if (destination.existsSync()) {
      destination.deleteSync();
    }

    Process.start(executablePath, [
      url,
      '--num-connections=$segments',
      '--output=${destination.path}',
      '--percentage',
      '--user-agent=${Dloader.userAgent}',
    ]).then((Process process) {
      process.stdout.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        for (final line in lines) {
          onProgress?.call(parseAxelProgress(line));
        }
      });
    });

    return destination;
  }

  Map<String, dynamic> parseAxelProgress(String progressString) {
    final Map<String, String> progress = {};
    if (int.tryParse(progressString) != null) {
      progress["percentComplete"] = progressString;
    }
    return progress;
  }
}
