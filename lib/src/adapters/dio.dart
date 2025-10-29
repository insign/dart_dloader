import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dloader/src/dloader_adapter.dart';
import 'package:executable/executable.dart';

/// This class implements the [DloaderAdapter] interface for downloading using [Dio].
class DioAdapter implements DloaderAdapter {
  /// The [Executable] object representing the `cp` executable, which is here just to satisfy the [DloaderAdapter] interface.
  @override
  Executable executable = Executable('cp');

  /// Whether the `cp` executable is available on the system, which is here just to satisfy the [DloaderAdapter] interface.
  @override
  late final bool isAvailable;

  /// The path to the `cp` executable, which is here just to satisfy the [DloaderAdapter] interface.
  @override
  late final String executablePath;

  /// Constructor that initializes the [isAvailable] flag.
  DioAdapter() {
    isAvailable = true;
  }

  /// Downloads a file with [Dio].
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
    final dio = Dio();
    if (userAgent != null) {
      dio.options.headers["User-Agent"] = userAgent;
    }
    try {
      await dio.download(
        url,
        destination.path,
        onReceiveProgress: (received, total) {
          final Map<String, String> progress = {};
          if (total != -1) {
            progress['percentComplete'] = (received / total * 100).toStringAsFixed(0);
            progress['downloaded'] = received.toString();
            progress['totalSize'] = total.toString();
            onProgress?.call(progress);
          }
        },
      );
    } catch (e) {
      throw Exception(e);
    }

    return destination;
  }
}
