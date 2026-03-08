import 'dart:io';

void main() {
  final file = File('lib/screens/match/scoreliveupdate.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // 1. ADD STATE VARIABLES
  final oldStateVars = '''  bool _hasEnsuredLiveStatus = false;
  bool _hasInitializedSession = false;''';
  final newStateVars = '''  bool _hasEnsuredLiveStatus = false;
  bool _hasInitializedSession = false;
  
  // Batsman Selection State
  bool _isOpeningBatsmanPickerVisible = false;
  bool _isIncomingBatsmanPickerVisible = false;
  int? _tempOpeningStrikerIndex;
  int? _tempOpeningNonStrikerIndex;''';
  content = content.replaceFirst(oldStateVars, newStateVars);


  // 2. TRIGGER OPENING PICKER ON START
  final oldFetchPlayers = '''          debugPrint('=== _fetchBattingTeamPlayers COMPLETE ===');
        });
        if (_bowlerIndex < 0 && bowlingPlayers.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showBowlerSelectionDialog(force: true);
          });
        }''';

  final newFetchPlayers = '''          debugPrint('=== _fetchBattingTeamPlayers COMPLETE ===');
        });
        
        // If this is the start of an innings, trigger the opening batsman picker
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
  content = content.replaceFirst(oldFetchPlayers, newFetchPlayers);


  // 3. REMOVE AUTOMATIC ROTATION ON WICKET
  final oldWicketFinalize = '''        _playerStats[dismissedPlayer.id]!['out'] = true;
        _partnershipRuns = 0;
        _partnershipBalls = 0;
        _bringNextBatterIn(dismissedBatsmanIndex);
      } else if (!isWicket && runDelta.isOdd) {
        _switchStrike();
      }''';
  final newWicketFinalize = '''        _playerStats[dismissedPlayer.id]!['out'] = true;
        _partnershipRuns = 0;
        _partnershipBalls = 0;
        
        if (dismissedBatsmanIndex == _strikerIndex) _strikerIndex = -1;
        if (dismissedBatsmanIndex == _nonStrikerIndex) _nonStrikerIndex = -1;
        
        if (_wickets < _maxWickets) {
           _isIncomingBatsmanPickerVisible = true;
        }
      } else if (!isWicket && runDelta.isOdd) {
        _switchStrike();
      }''';
  content = content.replaceFirst(oldWicketFinalize, newWicketFinalize);


  // 4. REMOVE ROTATION FALLBACKS
  final oldFallbackRotations = '''      if (_strikerIndex >= _battingTeamPlayers.length) {
        _strikerIndex = 0;
      }
      if (_nonStrikerIndex >= _battingTeamPlayers.length) {
        _nonStrikerIndex = _battingTeamPlayers.length > 1 ? 1 : 0;
      }
      if (_strikerIndex == _nonStrikerIndex && _battingTeamPlayers.length > 1) {
        final fallback = _strikerIndex == 0 ? 1 : 0;
        if (fallback < _battingTeamPlayers.length) {
          _nonStrikerIndex = fallback;
        }
      }''';
  final newFallbackRotations = '''      // Manual selection replaces automatic routing''';
  content = content.replaceFirst(oldFallbackRotations, newFallbackRotations);


  // 5. BLOCK SCORING WITHOUT BATSMEN
  final oldBuildKeypad = '''  Widget _buildKeypad() {
    final canScore =
        _bowlerIndex >= 0 && _bowlerIndex < _bowlingTeamPlayers.length;''';
  final newBuildKeypad = '''  Widget _buildKeypad() {
    final hasBowler = _bowlerIndex >= 0 && _bowlerIndex < _bowlingTeamPlayers.length;
    final hasBatsmen = _strikerIndex >= 0 && _nonStrikerIndex >= 0;
    final canScore = hasBowler && hasBatsmen;''';
  content = content.replaceFirst(oldBuildKeypad, newBuildKeypad);
  
  final oldBuildKeypadPrompt = '''        children: [
          if (!canScore)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Select bowler to start scoring',
                style: TextStyle(color: AppPalette.textMuted),
              ),
            ),''';
  final newBuildKeypadPrompt = '''        children: [
          if (!hasBatsmen)
             const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Select batsmen to start scoring',
                style: TextStyle(color: AppPalette.textMuted),
              ),
            )
          else if (!hasBowler)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Select bowler to start scoring',
                style: TextStyle(color: AppPalette.textMuted),
              ),
            ),''';
  content = content.replaceFirst(oldBuildKeypadPrompt, newBuildKeypadPrompt);

  
  // 6. RENDER THE OVERLAYS
  final oldBuildOverlays = '''          if (_isBowlerPickerVisible) _buildBowlerPickerOverlay(),
        ],
      ),
    );
  }''';
  final newBuildOverlays = '''          if (_isBowlerPickerVisible) _buildBowlerPickerOverlay(),
          if (_isOpeningBatsmanPickerVisible) _buildOpeningBatsmanPickerOverlay(),
          if (_isIncomingBatsmanPickerVisible) _buildIncomingBatsmanPickerOverlay(),
        ],
      ),
    );
  }

  Widget _buildOpeningBatsmanPickerOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: AppPalette.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.cardStroke),
            ),
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Opening Batsmen',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                   'Select Striker first, then Non-Striker',
                   style: TextStyle(color: AppPalette.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: _battingTeamPlayers.length,
                    separatorBuilder: (_, __) => const Divider(color: AppPalette.cardStroke, height: 1),
                    itemBuilder: (_, index) {
                      final player = _battingTeamPlayers[index];
                      final isSelectedStriker = index == _tempOpeningStrikerIndex;
                      final isSelectedNonStriker = index == _tempOpeningNonStrikerIndex;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelectedStriker 
                              ? AppPalette.accent 
                              : (isSelectedNonStriker ? Colors.green : AppPalette.textMuted),
                          child: Icon(
                            isSelectedStriker || isSelectedNonStriker 
                                ? Icons.check 
                                : Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: isSelectedStriker 
                            ? const Text('Striker', style: TextStyle(color: AppPalette.accent, fontWeight: FontWeight.bold))
                            : isSelectedNonStriker 
                                ? const Text('Non-Striker', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                : null,
                        onTap: () {
                          setState(() {
                             if (_tempOpeningStrikerIndex == null) {
                               _tempOpeningStrikerIndex = index;
                             } else if (_tempOpeningNonStrikerIndex == null && index != _tempOpeningStrikerIndex) {
                               _tempOpeningNonStrikerIndex = index;
                             } else if (index == _tempOpeningStrikerIndex) {
                               _tempOpeningStrikerIndex = null;
                             } else if (index == _tempOpeningNonStrikerIndex) {
                               _tempOpeningNonStrikerIndex = null;
                             }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_tempOpeningStrikerIndex != null && _tempOpeningNonStrikerIndex != null) 
                        ? () {
                            setState(() {
                              _strikerIndex = _tempOpeningStrikerIndex!;
                              _nonStrikerIndex = _tempOpeningNonStrikerIndex!;
                              _isOpeningBatsmanPickerVisible = false;
                            });
                            
                            // Immediately ask for bowler after batting selection opens innings
                            if (_bowlerIndex < 0) {
                              _showBowlerSelectionDialog(force: true);
                            } else {
                              _syncScore();
                            }
                        }
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppPalette.accent,
                      disabledBackgroundColor: AppPalette.cardStroke,
                    ),
                    child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingBatsmanPickerOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: AppPalette.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.cardStroke),
            ),
            constraints: const BoxConstraints(maxHeight: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Incoming Batsman',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    itemCount: _battingTeamPlayers.length,
                    separatorBuilder: (_, __) => const Divider(color: AppPalette.cardStroke, height: 1),
                    itemBuilder: (_, index) {
                      final player = _battingTeamPlayers[index];
                      final isOut = _playerStats[player.id]?['out'] == true;
                      final isBatting = index == _strikerIndex || index == _nonStrikerIndex;
                      
                      if (isOut || isBatting) return const SizedBox.shrink();
                      
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppPalette.textMuted,
                          child: Icon(Icons.person, color: Colors.white, size: 16),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                             if (_strikerIndex == -1) {
                               _strikerIndex = index;
                             } else {
                               _nonStrikerIndex = index;
                             }
                             _isIncomingBatsmanPickerVisible = false;
                          });
                          _syncScore();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }''';
  content = content.replaceFirst(oldBuildOverlays, newBuildOverlays);


  file.writeAsStringSync(content);
  print('Patch applied successfully.');
}
