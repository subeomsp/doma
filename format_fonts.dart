import 'dart:io';

void main() {
  final dir = Directory('lib/ui/screens');
  final files = dir.listSync().whereType<File>();
  for (var file in files) {
    String content = file.readAsStringSync();
    
    // Replace GoogleFonts.inter(...) with TextStyle(fontFamily: 'GowunDodum', ...)
    content = content.replaceAll(RegExp(r"GoogleFonts\.inter\(([^)]*)\)"), r"TextStyle(fontFamily: 'GowunDodum', \1)");
    
    // Replace GoogleFonts.playfairDisplay(...) with TextStyle(fontFamily: 'Hahmlet', ...)
    content = content.replaceAll(RegExp(r"GoogleFonts\.playfairDisplay\(([^)]*)\)"), r"TextStyle(fontFamily: 'Hahmlet', \1)");
    
    // Remove google_fonts import
    content = content.replaceAll("import 'package:google_fonts/google_fonts.dart';", "");
    
    file.writeAsStringSync(content);
  }
  
  // Also clean up lib/main.dart
  final mainFile = File('lib/main.dart');
  String mainContent = mainFile.readAsStringSync();
  mainContent = mainContent.replaceAll("import 'package:google_fonts/google_fonts.dart';", "");
  mainFile.writeAsStringSync(mainContent);
  
  print('Fonts replaced successfully.');
}
