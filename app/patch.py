import re

file_path = "lib/screens/match/scoreliveupdate.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _pastInnings and _fallOfWickets
content = content.replace(
    "final List<Map<String, dynamic>> _history = [];",
    "final List<Map<String, dynamic>> _pastInnings = [];\n  final List<Map<String, dynamic>> _fallOfWickets = [];\n  final List<Map<String, dynamic>> _history = [];"
)

# 2. Add helper methods before _syncScore
helpers = """
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
          overs: '$overs.$balls',
          maidens: '0', 
          runs: (stats['runs'] ?? 0).toString(),
          wickets: (stats['wickets'] ?? 0).toString(),
          econ: (stats['economy'] ?? '0.0').toString(),
        ).toJson());
      }
    }
    return list;
  }

  Future<void> _syncScore() async {"""

content = content.replace("Future<void> _syncScore() async {", helpers, 1)

# 3. Update summary = ScoreSummary(
old_summary = """battingTeam: _battingTeamName ?? 'Batting Team',
    );"""
new_summary = """battingTeam: _battingTeamName ?? 'Batting Team',
      pastInnings: _pastInnings,
      allBatsmen: _buildAllBatsmen(),
      allBowlers: _buildAllBowlers(),
      fow: _fallOfWickets,
    );"""
content = content.replace(old_summary, new_summary)


# 4. _restoreExistingLiveScore
old_restore = """final restoredInnings =
          summary.inningsName.toLowerCase().contains('2nd') ? 2 : 1;"""
new_restore = """final restoredInnings =
          summary.inningsName.toLowerCase().contains('2nd') ? 2 : 1;
      final restoredPastInnings = (summary.pastInnings ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
      final restoredFow = (summary.fow ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();"""
content = content.replace(old_restore, new_restore)

old_restore_state = """_battingTeamName = summary.battingTeam ?? _battingTeamName;"""
new_restore_state = """_battingTeamName = summary.battingTeam ?? _battingTeamName;
        _pastInnings.clear();
        _pastInnings.addAll(restoredPastInnings);
        _fallOfWickets.clear();
        _fallOfWickets.addAll(restoredFow);"""
content = content.replace(old_restore_state, new_restore_state)


# 5. _applyBall Wicket FOW
old_apply = """if (isWicket && dismissedBatsmanIndex != null) {
        final dismissedPlayer = _battingTeamPlayers[dismissedBatsmanIndex];
        _playerStats.putIfAbsent("""
new_apply = """if (isWicket && dismissedBatsmanIndex != null) {
        final dismissedPlayer = _battingTeamPlayers[dismissedBatsmanIndex];
        
        _fallOfWickets.add({
          'score': '$_runs/$_wickets',
          'overs': _oversStringFromBalls(_legalBallsBowled),
          'player': dismissedPlayer.name,
        });

        _playerStats.putIfAbsent("""
content = content.replace(old_apply, new_apply)

# 6. _startSecondInnings pastInnings save
old_second_in = """// Save first innings total"""
new_second_in = """// Save FULL first innings scorecard before clearing
      _pastInnings.add({
        'innings': '1st Innings',
        'total': '$_runs/$_wickets (${_oversStringFromBalls(_legalBallsBowled)})',
        'batting': _buildAllBatsmen(),
        'bowling': _buildAllBowlers(),
        'fow': List<Map<String, dynamic>>.from(_fallOfWickets),
      });
      _fallOfWickets.clear();

      // Save first innings total"""
content = content.replace(old_second_in, new_second_in, 1)

# 7. _saveHistory
old_save_hist = """void _saveHistory() {
    _history.add({
      'runs': _runs,"""
new_save_hist = """void _saveHistory() {
    _history.add({
      'fallOfWickets': List<Map<String, dynamic>>.from(_fallOfWickets),
      'runs': _runs,"""
content = content.replace(old_save_hist, new_save_hist)

# 8. _undo
old_undo = """_legalBallsBowled = (last['legalBallsBowled'] ?? 0) as int;
      _recentBalls.clear();"""
new_undo = """_legalBallsBowled = (last['legalBallsBowled'] ?? 0) as int;
      _fallOfWickets.clear();
      _fallOfWickets.addAll((last['fallOfWickets'] as List?)?.cast<Map<String, dynamic>>() ?? []);
      _recentBalls.clear();"""
content = content.replace(old_undo, new_undo)


with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Patch applied successfully.")
