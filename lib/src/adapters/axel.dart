import 'dart:convert';
import 'dart:io';
import 'package:dloader/dloader.dart';
import 'package:executable/executable.dart';

/// This class implements [DloaderAdapter] for downloading using axel.
class AxelAdapter implements DloaderAdapter {
  /// The [Executable] object representing the `axel` executable.
  @override
  Executable executable = Executable('axel');

  /// Whether the axel executable is available on the system.
  @override
  late final bool isAvailable;

  /// The path to the axel executable.
  @override
  late final String executablePath;

  /// Constructor that initializes the [isAvailable] flag.
  AxelAdapter() {
    isAvailable = executable.existsSync();
  }

  /// Downloads a file with Axel.
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

    if (destination.existsSync()) {
      destination.deleteSync();
    }

    return Process.start(executablePath, [
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

      return destination;
    });
  }

  /// Parses the progress string from axel and returns a [Map] with the progress information.
  Map<String, dynamic> parseAxelProgress(String progressString) {
    final Map<String, String> progress = {};
    if (int.tryParse(progressString) != null) {
      progress["percentComplete"] = progressString;
    }
    return progress;
  }
}
