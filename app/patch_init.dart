import 'dart:io';

void main() {
  final file = File('lib/screens/match/scoreliveupdate.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // 1. Move the opening batsman trigger out of _fetchBattingTeamPlayers
  final oldFetchPlayers = '''        // If this is the start of an innings, trigger the opening batsman picker
        if (_runs == 0 && _wickets == 0 && _legalBallsBowled == 0) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             setState(() {
               _isOpeningBatsmanPickerVisible = true;
               _strikerIndex = -1;
               _nonStrikerIndex = -1;
               _tempOpeningStrikerIndex = null;
               _tempOpeningNonStrikerIndex = null;
             });
           });
        } else if (_bowlerIndex < 0 && bowlingPlayers.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showBowlerSelectionDialog(force: true);
          });
        }''';

  final newFetchPlayers = '''        // Bowler selection will be handled after initialization logic determines if we restored data or not.''';
  content = content.replaceFirst(oldFetchPlayers, newFetchPlayers);


  // 2. Put the initialization trigger where it belongs, inside _restoreOrInitializeLiveScore
  final oldRestoreInit = '''  Future<void> _restoreOrInitializeLiveScore() async {
    final restored = await _restoreExistingLiveScore();
    if (!restored) {
      await _syncScore();
    }
  }''';

  final newRestoreInit = '''  Future<void> _restoreOrInitializeLiveScore() async {
    final restored = await _restoreExistingLiveScore();
    if (!restored) {
      // Net-new match or newly started innings. Trigger opening manual selection.
      if (mounted) {
        setState(() {
          _isOpeningBatsmanPickerVisible = true;
          _strikerIndex = -1;
          _nonStrikerIndex = -1;
          _tempOpeningStrikerIndex = null;
          _tempOpeningNonStrikerIndex = null;
        });
      }
      await _syncScore();
    }
  }''';
  content = content.replaceFirst(oldRestoreInit, newRestoreInit);
  
  
  // 3. Make the 2nd Innings restart invoke the opening batsmen picker
  final oldStartSecond = '''      // Reset scoring state
      _runs = 0;
      _wickets = 0;
      _overs = 0.0;
      _legalBallsBowled = 0;
      _target = _firstInningsRuns + 1;
      _recentBalls.clear();
      _currentOverBalls.clear();
      _history.clear();
      _strikerIndex = 0;
      _nonStrikerIndex = 1;
      _bowlerIndex = -1;
      _partnershipRuns = 0;
      _partnershipBalls = 0;

      // Clear player stats for second innings teams
      _playerStats.clear();
      _playersLoaded = false;
    });
    _fetchBattingTeamPlayers().then((_) {
      // if fetch returns empty, UI will show message
    });
    _syncScore();''';
    
  final newStartSecond = '''      // Reset scoring state
      _runs = 0;
      _wickets = 0;
      _overs = 0.0;
      _legalBallsBowled = 0;
      _target = _firstInningsRuns + 1;
      _recentBalls.clear();
      _currentOverBalls.clear();
      _history.clear();
      
      _isOpeningBatsmanPickerVisible = true;
      _strikerIndex = -1;
      _nonStrikerIndex = -1;
      _tempOpeningStrikerIndex = null;
      _tempOpeningNonStrikerIndex = null;
      _bowlerIndex = -1;
      _partnershipRuns = 0;
      _partnershipBalls = 0;

      // Clear player stats for second innings teams
      _playerStats.clear();
      _playersLoaded = false;
    });
    _fetchBattingTeamPlayers().then((_) {
      // if fetch returns empty, UI will show message
    });
    _syncScore();''';
  content = content.replaceFirst(oldStartSecond, newStartSecond);


  file.writeAsStringSync(content);
  print('Patch applied successfully.');
}
