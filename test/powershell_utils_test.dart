import 'package:dloader/src/utils/powershell_utils.dart';
import 'package:test/test.dart';

void main() {
  test('escapeLiteral escapes single quotes', () {
    expect(PowerShellUtils.escapeLiteral("test"), "'test'");
    expect(PowerShellUtils.escapeLiteral("test's"), "'test''s'");
    expect(PowerShellUtils.escapeLiteral("hello \$world"), "'hello \$world'");
    expect(
      PowerShellUtils.escapeLiteral("C:\\My Files & Folder\\"),
      "'C:\\My Files & Folder\\'",
    );
  });
}
