import 'dart:io';

import 'package:executable/executable.dart';

/// Abstract class for the download adapter used by [Dloader].
abstract class DloaderAdapter {
  /// Executable of the adapter.
  late final Executable executable;

  /// Flag indicating if the adapter is available or not.
  late final bool isAvailable;

  /// Path to the executable.
  late final String executablePath;

  /// Downloads the file from the given `url` to the specified `destination` file.
  ///
  /// `segments` (optional) specifies the number of segments to download in parallel.
  /// `onProgress` (optional) is a callback that receives progress information during the download.
  Future<File> download({
    required String url,
    required File destination,
    int? segments,
    Function(Map<String, dynamic>)? onProgress,
  });
}
