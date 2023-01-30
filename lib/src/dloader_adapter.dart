import 'dart:io';

import 'package:executable/executable.dart';

abstract class DloaderAdapter {
  late final Executable executable;
  late final bool isAvailable;
  late final String executablePath;

  Future<File> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress});
}
