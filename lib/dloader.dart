/// A library for downloading files from the internet.
library dloader;

/// The [Dloader] class.
export 'src/dloader_base.dart';

/// The [DloaderAdapter] class.
export 'src/dloader_adapter.dart';

/// The adapters for the [Dloader] class.
export 'src/adapters/aria2.dart';
export 'src/adapters/axel.dart';
export 'src/adapters/curl.dart';
export 'src/adapters/dio.dart';
export 'src/adapters/powershell.dart';
export 'src/adapters/wget.dart';
