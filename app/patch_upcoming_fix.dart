import 'dart:io';

void main() {
  final file = File('lib/screens/match/upcoming_fixtures_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  // Cut everything above first instance of class _FixturesData
  final lines = content.split('\n');
  final newLines = <String>[];
  bool inFixtureDataOrBelow = false;
  int deleteMatchesFound = 0;
  
  for (int i = 0; i < lines.length; i++) {
     final line = lines[i];
     
     if (line.contains('class _FixturesData {')) {
       inFixtureDataOrBelow = true;
     }

     if (line.contains('Future<void> _handleDeleteMatch')) {
        deleteMatchesFound++;
        if (deleteMatchesFound > 1) {
           // Skip everything until the next Widget _buildHeader
           while (i < lines.length && !lines[i].contains('Widget _buildHeader(BuildContext context) {')) {
             i++;
           }
           continue; // Skip the duplicate header too
        }
     }
     
     if (!inFixtureDataOrBelow || line.trim().isNotEmpty || (inFixtureDataOrBelow && line.trim().isEmpty)) {
       newLines.add(line);
     }
  }

  // Rewrite just the broken _TeamBadge explicitly at the end
  var finalStr = newLines.join('\n');
  final teamBadgeIndex = finalStr.indexOf('class _TeamBadge extends StatelessWidget {');
  if (teamBadgeIndex != -1) {
      finalStr = finalStr.substring(0, teamBadgeIndex);
      finalStr += '''class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFF334155),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.flag, color: AppPalette.textMuted, size: 28),
        ),
      ),
    );
  }
}
''';
  }
  
  file.writeAsStringSync(finalStr);
  print('Fixed upcoming_fixtures_screen.dart syntax');
}
