import 'dart:io';

void main() {
  final file = File('lib/services/match_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final oldScoreboard = '''
    try {
      final liveScoreData = await getLiveScore(matchId);
      final summary = liveScoreData['summary'] as ScoreSummary?;
      final batsmen = liveScoreData['batsmen'] as List<BatsmanScore>? ?? [];
      final bowler = liveScoreData['bowler'] as BowlerScore?;

      if (summary != null || batsmen.isNotEmpty || bowler != null) {
        return [
          {
            'innings': summary?.inningsName ?? 'Innings',
            'total': '\${summary?.runs ?? "0"}/\${summary?.wickets ?? "0"} (\${summary?.overs ?? "0.0"})',
            'batting': batsmen,
            'bowling': bowler != null && bowler.name.isNotEmpty ? [bowler] : [],
          }
        ];
      }
    } catch (_) {
      // Return an empty list if there's no live score data yet for this match.
      return [];
    }
''';

  final newScoreboard = '''
    try {
      final liveScoreData = await getLiveScore(matchId);
      final summary = liveScoreData['summary'] as ScoreSummary?;
      final batsmen = liveScoreData['batsmen'] as List<BatsmanScore>? ?? [];
      final bowler = liveScoreData['bowler'] as BowlerScore?;

      final pastInnings = (summary?.pastInnings ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      if (summary != null || batsmen.isNotEmpty || bowler != null) {
        final currentInnings = {
          'innings': summary?.inningsName ?? 'Innings',
          'total': '\${summary?.runs ?? "0"}/\${summary?.wickets ?? "0"} (\${summary?.overs ?? "0.0"})',
          'batting': summary?.allBatsmen != null && summary!.allBatsmen!.isNotEmpty 
              ? summary.allBatsmen!
              : batsmen.map((b) => b.toJson()).toList(), // fallback to active only
          'bowling': summary?.allBowlers != null && summary!.allBowlers!.isNotEmpty 
              ? summary.allBowlers!
              : (bowler != null && bowler.name.isNotEmpty ? [bowler.toJson()] : []), // fallback to active only
          'fow': summary?.fow != null ? List<Map<String, dynamic>>.from(summary.fow!) : [],
        };
        
        final combined = [...pastInnings, currentInnings];
        
        return combined.map((innings) {
           final batRaw = innings['batting'] as List<dynamic>? ?? [];
           final bowlRaw = innings['bowling'] as List<dynamic>? ?? [];

           return {
             ...innings,
             'batting': batRaw.map((e) => e is BatsmanScore ? e : BatsmanScore.fromJson(e as Map<String, dynamic>)).toList(),
             'bowling': bowlRaw.map((e) => e is BowlerScore ? e : BowlerScore.fromJson(e as Map<String, dynamic>)).toList(),
           };
        }).toList();
      }
    } catch (_) {
      // Return an empty list if there's no live score data yet for this match.
      return [];
    }
''';

  content = content.replaceFirst(oldScoreboard, newScoreboard);
  file.writeAsStringSync(content);
  print('Patch 2 applied successfully.');
}
