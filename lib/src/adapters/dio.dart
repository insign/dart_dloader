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
  String? executablePath;

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

    final startTime = DateTime.now();

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

            final elapsed = DateTime.now().difference(startTime);
            if (elapsed.inMilliseconds > 0) {
              final speed = received / (elapsed.inMilliseconds / 1000);
              progress['speed'] = '${(speed / 1024 / 1024).toStringAsFixed(2)} MB/s';

              final remaining = total - received;
              final etaSeconds = (remaining / speed).ceil();
              final eta = Duration(seconds: etaSeconds);
              progress['eta'] = _formatDuration(eta);
            } else {
              progress['speed'] = '0.00 MB/s';
              progress['eta'] = '00:00:00';
            }

            onProgress?.call(progress);
          }
        },
      );
    } catch (e) {
      throw Exception(e);
    }

    return destination;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
