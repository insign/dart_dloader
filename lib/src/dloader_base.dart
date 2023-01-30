import 'dart:io';

import 'package:dloader/src/dloader_adapter.dart';

class Dloader {
  static String userAgent =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36';

  Function(double, int)? onProgress;
  DloaderAdapter adapter;

  Dloader(this.adapter);

  Future<File> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress}) async {
    if (!adapter.isAvailable) {
      throw Exception(
          'Dloader adapter ${adapter.executable.cmd} not available');
    }

    segments = (segments ?? 1).abs();

    if (url.isEmpty) {
      throw Exception('URL not provided');
    }
    return await adapter.download(
        url: url,
        destination: destination,
        segments: segments,
        onProgress: onProgress);
  }
}
