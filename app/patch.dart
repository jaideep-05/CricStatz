import 'dart:io';

void main() {
  final file = File('lib/screens/match/scoreliveupdate.dart');
  var content = file.readAsStringSync();
  
  // Normalize line endings to make strict replace operations work
  content = content.replaceAll('\r\n', '\n');
  
  // 1. Add _pastInnings and _fallOfWickets
  content = content.replaceFirst(
      'final List<Map<String, dynamic>> _history = [];',
      'final List<Map<String, dynamic>> _pastInnings = [];\n  final List<Map<String, dynamic>> _fallOfWickets = [];\n  final List<Map<String, dynamic>> _history = [];'
  );

  // 2. Add helper methods before _syncScore
  final helpers = '''
  List<Map<String, dynamic>> _buildAllBatsmen() {
    final list = <Map<String, dynamic>>[];
    for (var i = 0; i < _battingTeamPlayers.length; i++) {
      final p = _battingTeamPlayers[i];
      final stats = _playerStats[p.id] ?? {};
      final runs = (stats['runs'] ?? 0) as int;
      final balls = (stats['balls'] ?? 0) as int;
      final isOut = (stats['out'] ?? false) as bool;
      final isMiddle = i == _strikerIndex || i == _nonStrikerIndex;
      
      if (runs > 0 || balls > 0 || isOut || isMiddle) {
        list.add(BatsmanScore(
          name: p.name,
          runs: runs.toString(),
          balls: balls.toString(),
          fours: (stats['fours'] ?? 0) as int,
          sixes: (stats['sixes'] ?? 0) as int,
          sr: (stats['sr'] ?? '0.0').toString(),
          isActive: isMiddle,
        ).toJson());
      }
    }
    return list;
  }

  List<Map<String, dynamic>> _buildAllBowlers() {
    final list = <Map<String, dynamic>>[];
    for (var i = 0; i < _bowlingTeamPlayers.length; i++) {
      final p = _bowlingTeamPlayers[i];
      final stats = _playerStats[p.id] ?? {};
      final ballsBowled = (stats['balls_bowled'] ?? 0) as int;
      
      if (ballsBowled > 0) {
        final overs = ballsBowled ~/ 6;
        final balls = ballsBowled % 6;
        list.add(BowlerScore(
          name: p.name,
          overs: '\$overs.\$balls',
          maidens: '0', 
          runs: (stats['runs'] ?? 0).toString(),
          wickets: (stats['wickets'] ?? 0).toString(),
          econ: (stats['economy'] ?? '0.0').toString(),
        ).toJson());
      }
    }
    return list;
  }

  Future<void> _syncScore() async {''';

  content = content.replaceFirst('Future<void> _syncScore() async {', helpers);

  // 3. Update summary = ScoreSummary(
  final oldSummary = '''battingTeam: _battingTeamName ?? 'Batting Team',
    );''';
  final newSummary = '''battingTeam: _battingTeamName ?? 'Batting Team',
      pastInnings: _pastInnings,
      allBatsmen: _buildAllBatsmen(),
      allBowlers: _buildAllBowlers(),
      fow: _fallOfWickets,
    );''';
  content = content.replaceFirst(oldSummary, newSummary);

  // 4. _restoreExistingLiveScore
  final oldRestore = '''final restoredInnings =
          summary.inningsName.toLowerCase().contains('2nd') ? 2 : 1;''';
  final newRestore = '''final restoredInnings =
          summary.inningsName.toLowerCase().contains('2nd') ? 2 : 1;
      final restoredPastInnings = (summary.pastInnings ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final restoredFow = (summary.fow ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();''';
  content = content.replaceFirst(oldRestore, newRestore);

  final oldRestoreState = """_battingTeamName = summary.battingTeam ?? _battingTeamName;""";
  final newRestoreState = """_battingTeamName = summary.battingTeam ?? _battingTeamName;
        _pastInnings.clear();
        _pastInnings.addAll(restoredPastInnings);
        _fallOfWickets.clear();
        _fallOfWickets.addAll(restoredFow);""";
  content = content.replaceFirst(oldRestoreState, newRestoreState);

  // 5. _applyBall Wicket FOW
  final oldApply = """if (isWicket && dismissedBatsmanIndex != null) {
        final dismissedPlayer = _battingTeamPlayers[dismissedBatsmanIndex];
        _playerStats.putIfAbsent(""";
  final newApply = """if (isWicket && dismissedBatsmanIndex != null) {
        final dismissedPlayer = _battingTeamPlayers[dismissedBatsmanIndex];
        
        _fallOfWickets.add({
          'score': '\$_runs/\$_wickets',
          'overs': _oversStringFromBalls(_legalBallsBowled),
          'player': dismissedPlayer.name,
        });

        _playerStats.putIfAbsent(""";
  content = content.replaceFirst(oldApply, newApply);

  // 6. _startSecondInnings pastInnings save
  final oldSecondIn = """// Save first innings total""";
  final newSecondIn = """// Save FULL first innings scorecard before clearing
      _pastInnings.add({
        'innings': '1st Innings',
        'total': '\$_runs/\$_wickets (\${_oversStringFromBalls(_legalBallsBowled)})',
        'batting': _buildAllBatsmen(),
        'bowling': _buildAllBowlers(),
        'fow': List<Map<String, dynamic>>.from(_fallOfWickets),
      });
      _fallOfWickets.clear();

      // Save first innings total""";
  content = content.replaceFirst(oldSecondIn, newSecondIn);

  // 7. _saveHistory
  final oldSaveHist = """void _saveHistory() {
    _history.add({
      'runs': _runs,""";
  final newSaveHist = """void _saveHistory() {
    _history.add({
      'fallOfWickets': List<Map<String, dynamic>>.from(_fallOfWickets),
      'runs': _runs,""";
  content = content.replaceFirst(oldSaveHist, newSaveHist);

  // 8. _undo
  final oldUndo = """_legalBallsBowled = (last['legalBallsBowled'] ?? 0) as int;
      _recentBalls.clear();""";
  final newUndo = """_legalBallsBowled = (last['legalBallsBowled'] ?? 0) as int;
      _fallOfWickets.clear();
      _fallOfWickets.addAll((last['fallOfWickets'] as List?)?.cast<Map<String, dynamic>>() ?? []);
      _recentBalls.clear();""";
  content = content.replaceFirst(oldUndo, newUndo);

  file.writeAsStringSync(content);
  print('Patch applied successfully.');
}
