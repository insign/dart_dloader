import 'dart:io';
import 'package:test/test.dart';
import 'package:dloader/dloader.dart';

void main() {
  test('Test Dloader with CurlAdapter throws exception on invalid URL', () async {
    final adapter = CurlAdapter();
    if (!adapter.isAvailable) {
      print('Skipping test: curl not available');
      return;
    }
    final dloader = Dloader(adapter);
    final url = 'http://thisdomaindoesnotexist.local/file.dat';
    final destination = File('${Directory.systemTemp.path}/curl_fail.dat');

    expect(
      () => dloader.download(url: url, destination: destination),
      throwsException,
    );
  });

  test('Test Dloader with WgetAdapter throws exception on invalid URL', () async {
    final adapter = WgetAdapter();
    if (!adapter.isAvailable) {
      print('Skipping test: wget not available');
      return;
    }
    final dloader = Dloader(adapter);
    final url = 'http://thisdomaindoesnotexist.local/file.dat';
    final destination = File('${Directory.systemTemp.path}/wget_fail.dat');

    expect(
      () => dloader.download(url: url, destination: destination),
      throwsException,
    );
  });
}
