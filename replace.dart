import 'dart:io';

void main() {
  final file = File('lib/src/pages/settings_page.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r'const\s+Icon\(([^)]*?)color:\s*kPrimaryTeal(.*?)\)'), r'Icon($1color: settings.primaryColor$2)');
  content = content.replaceAll('kPrimaryTeal', 'settings.primaryColor');
  
  file.writeAsStringSync(content);
}
