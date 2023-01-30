import 'dart:io';

import 'package:dloader/src/dloader_adapter.dart';

/// A class that allows downloading a file from a URL, with an adapter implementation
class Dloader {
  /// The User Agent string used in the download request
  static String userAgent =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36';

  /// The callback that will be called on every progress update
  Function(double, int)? onProgress;

  /// The adapter implementation that will perform the download
  DloaderAdapter adapter;

  /// Constructor for Dloader class
  Dloader(this.adapter);

  /// Downloads a file from the given URL to the specified destination, using the adapter implementation
  ///
  ///
  /// Throws an Exception if the URL is not provided, or if the adapter is not available.
  ///
  /// [url] URL of the file to download. Required.
  /// [destination] The file where the downloaded file will be stored. Required.
  /// [segments] The number of segments to download the file in.
  /// [onProgress] The callback that will be called on every progress update.
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
