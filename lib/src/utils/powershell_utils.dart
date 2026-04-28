/// Utility functions for PowerShell.
class PowerShellUtils {
  /// Escapes a string to be safely used as a literal string in PowerShell.
  /// It wraps the string in single quotes and escapes any internal single quotes by doubling them.
  static String escapeLiteral(String value) {
    final escaped = value.replaceAll("'", "''");
    return "'$escaped'";
  }
}
