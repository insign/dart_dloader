import 'dart:io';

/// Abstract class for the download adapter used by [Dloader].
abstract class DloaderAdapter {
  /// Flag indicating if the adapter is available or not.
  late final bool isAvailable;

  /// Downloads the file from the given [url] to the specified [destination] file.
  ///
  /// [url] is the URL of the file to download.
  /// [destination] is the destination file.
  /// [headers] (optional) is a map of custom HTTP headers to include in the request.
  /// [userAgent] (optional) is the user agent to use for the download.
  /// [segments] (optional) is the number of segments to download the file in.
  /// [onProgress] (optional) is a function that is called with the download progress.
  ///
  /// Returns a [Future] that completes with the downloaded file.
  Future<File> download({
    required String url,
    required File destination,
    Map<String, String>? headers,
    String? userAgent,
    int? segments,
    Function(Map<String, dynamic>)? onProgress,
  });
}
