import 'dart:io';

import 'package:dio/dio.dart';
import 'package:executable/executable.dart';

import '../dloader_adapter.dart';

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
  String? executablePath;

  /// Constructor that initializes the [isAvailable] flag.
  DioAdapter() {
    isAvailable = true;
  }

  /// Downloads a file with [Dio].
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
    final dio = Dio();
    final requestHeaders = Map<String, dynamic>.from(headers ?? {});
    if (userAgent != null) {
      requestHeaders["User-Agent"] = userAgent;
    }

    try {
      await dio.download(
        url,
        destination.path,
        options: Options(headers: requestHeaders),
        onReceiveProgress: (received, total) {
          final Map<String, String> progress = {};
          if (total != -1) {
            progress['percentComplete'] = (received / total * 100)
                .toStringAsFixed(0);
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
