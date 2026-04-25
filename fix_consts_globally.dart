import 'dart:io';

void main() {
  final files = [
    'lib/src/pages/home_page.dart',
    'lib/src/pages/learn2_page.dart',
    'lib/src/pages/learn_page.dart',
    'lib/src/pages/recite_page.dart',
    'lib/src/pages/settings_page.dart',
    'lib/src/pages/splash_screen.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      
      content = content.replaceAllMapped(RegExp(r'const\s+SnackBar\((.*?Theme\.of\(context\)\.primaryColor.*?)\)', dotAll: true), (match) {
        return 'SnackBar(${match.group(1)})';
      });

      content = content.replaceAllMapped(RegExp(r'const\s+Icon\((.*?Theme\.of\(context\)\.primaryColor.*?)\)', dotAll: true), (match) {
        return 'Icon(${match.group(1)})';
      });

      content = content.replaceAllMapped(RegExp(r'const\s+TextStyle\((.*?Theme\.of\(context\)\.primaryColor.*?)\)', dotAll: true), (match) {
        return 'TextStyle(${match.group(1)})';
      });
      
      // Additional fixes for cases where `const` precedes `Theme.of(context)` directly
      content = content.replaceAll('const Theme.of(context)', 'Theme.of(context)');

      file.writeAsStringSync(content);
    }
  }
}
