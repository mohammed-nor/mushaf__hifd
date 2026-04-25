import 'dart:io';

void main() {
  final file = File('lib/src/pages/settings_page.dart');
  var content = file.readAsStringSync();
  
  // Find all instances of const Icon(...) containing settings.primaryColor
  content = content.replaceAllMapped(RegExp(r'const\s+Icon\(([^)]*?settings\.primaryColor[^)]*?)\)', dotAll: true), (match) {
    return 'Icon(${match.group(1)})';
  });
  
  file.writeAsStringSync(content);
}
