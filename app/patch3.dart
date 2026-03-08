import 'dart:io';

void main() {
  final file = File('lib/screens/match/scoreboard.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // UPDATE _InningsSection
  final oldInnings = '''              // Dummy generic fallback until fall of wickets is implemented deeply
              const _FallOfWickets(),''';
  final newInnings = '''              if ((widget.inningsData['fow'] as List<dynamic>? ?? []).isNotEmpty) ...[
                _FallOfWickets(
                  fowData: (widget.inningsData['fow'] as List<dynamic>)
                      .map((e) => e as Map<String, dynamic>)
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],''';
              
  content = content.replaceFirst(oldInnings, newInnings);


  // UPDATE _FallOfWickets
  final oldFow = '''class _FallOfWickets extends StatelessWidget {
  const _FallOfWickets();''';
  final newFow = '''class _FallOfWickets extends StatelessWidget {
  final List<Map<String, dynamic>> fowData;
  const _FallOfWickets({required this.fowData});''';
  
  content = content.replaceFirst(oldFow, newFow);
  
  final oldFowBody = '''          Row(
            children: [
              chip('1-30', 'Gill', '4.2 ov'),
              const SizedBox(width: 10),
              chip('2-76', 'Rohit', '9.4 ov'),
              const SizedBox(width: 10),
              chip('3-81', 'Iyer', '10.2 ov'),
              const SizedBox(width: 10),
              chip('4-148', 'Kohli', '23.0 ov'),
            ],
          ),''';
  
  final newFowBody = '''          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(fowData.length, (index) {
                final fow = fowData[index];
                return Padding(
                  padding: EdgeInsets.only(right: index == fowData.length - 1 ? 0 : 10.0),
                  child: chip(
                    fow['score'] as String? ?? '',
                    fow['player'] as String? ?? '',
                    '\${fow['overs'] as String? ?? ''} ov',
                  ),
                );
              }),
            ),
          ),''';

  content = content.replaceFirst(oldFowBody, newFowBody);

  file.writeAsStringSync(content);
  print('Patch 3 applied successfully.');
}
