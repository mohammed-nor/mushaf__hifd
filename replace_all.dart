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
      
      // Replace kLightsColor which is an alias for kPrimaryTeal
      content = content.replaceAll('kLightsColor', 'Theme.of(context).primaryColor');
      
      // Replace kPrimaryTeal with Theme.of(context).primaryColor
      // Except in constants.dart (not in list) and where it shouldn't be
      content = content.replaceAllMapped(RegExp(r'const\s+SnackBar\((.*?)(backgroundColor:\s*)kPrimaryTeal(.*?)\)', dotAll: true), (match) {
        return 'SnackBar(${match.group(1)}${match.group(2)}Theme.of(context).primaryColor${match.group(3)})';
      });

      content = content.replaceAllMapped(RegExp(r'const\s+Icon\((.*?)(color:\s*)kPrimaryTeal(.*?)\)', dotAll: true), (match) {
        return 'Icon(${match.group(1)}${match.group(2)}Theme.of(context).primaryColor${match.group(3)})';
      });

      content = content.replaceAllMapped(RegExp(r'const\s+TextStyle\((.*?)(color:\s*)kPrimaryTeal(.*?)\)', dotAll: true), (match) {
        return 'TextStyle(${match.group(1)}${match.group(2)}Theme.of(context).primaryColor${match.group(3)})';
      });
      
      // Now safe general replace
      content = content.replaceAll('kPrimaryTeal', 'Theme.of(context).primaryColor');

      file.writeAsStringSync(content);
    }
  }
}
