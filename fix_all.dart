import 'dart:io';

void main() {
  final files = [
    'lib/src/pages/home_page.dart',
    'lib/src/pages/learn2_page.dart',
    'lib/src/pages/learn_page.dart',
    'lib/src/pages/recite_page.dart',
    'lib/src/pages/splash_screen.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      // Only fix in these files since settings_page was handled separately
      content = content.replaceAll('themeSettingsNotifier.value.accentColor', 'themeSettingsNotifier.value.primaryColor');
      content = content.replaceAll('settings.accentColor', 'settings.primaryColor');
      file.writeAsStringSync(content);
    }
  }
}
