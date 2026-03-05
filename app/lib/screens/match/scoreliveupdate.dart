import 'dart:ui' show ImageFilter;
import 'package:cricstatz/config/palette.dart';
import 'package:cricstatz/config/routes.dart';
import 'package:cricstatz/models/match.dart';
import 'package:cricstatz/models/match_stats.dart';
import 'package:cricstatz/services/match_service.dart';
import 'package:cricstatz/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScoreLiveUpdateScreen extends StatefulWidget {
  const ScoreLiveUpdateScreen({super.key});

  @override
  State<ScoreLiveUpdateScreen> createState() => _ScoreLiveUpdateScreenState();
}

class _ScoreLiveUpdateScreenState extends State<ScoreLiveUpdateScreen> {
  Match? _match;
  String? _tossWinner;
  String? _decision;
  String? _battingTeamName;
  String? _teamA;
  String? _teamB;
  
  // Scoring state
  int _runs = 0;
  int _wickets = 0;
  double _overs = 0.0;
  int _oversLimit = 0;
  final List<String> _recentBalls = [];
  
  // History for Undo
  final List<Map<String, dynamic>> _history = [];
  int _innings = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _match = args['match'] as Match?;
      _tossWinner = args['tossWinner'] as String?;
      _decision = args['decision'] as String?;
      
      if (_match != null) {
        _oversLimit = _match!.oversLimit;
        _teamA = _match!.teamAId;
        _teamB = _match!.teamBId;
        if (_battingTeamName == null) {
          final teamA = _teamA!;
          final teamB = _teamB!;
          _battingTeamName = _decision == 'BAT'
              ? _tossWinner
              : (_tossWinner == teamA ? teamB : teamA);
          // Initial sync to create live_scores record
          _syncScore();
        }
      }
    }
  }

  Future<void> _syncScore() async {
    if (_match == null) return;

    final summary = ScoreSummary(
      inningsName: _innings == 1 ? '1st Innings' : '2nd Innings',
      runs: _runs.toString(),
      wickets: _wickets.toString(),
      overs: _overs.toStringAsFixed(1),
      crr: _overs > 0 ? (_runs / (_overs.floor() + (_overs - _overs.floor()) * 1.6666)).toStringAsFixed(1) : '0.0',
      battingTeam: _battingTeamName ?? 'Batting Team',
    );

    // Using dummy batsman and bowler for now, but following the model
    final batsmen = [
      BatsmanScore(name: 'S. Gopi', runs: (_runs ~/ 2).toString(), balls: '12', fours: 2, sixes: 1, sr: '200.0', isActive: true),
      BatsmanScore(name: 'R. Sharma', runs: (_runs - (_runs ~/ 2)).toString(), balls: '15', fours: 1, sixes: 0, sr: '120.0', isActive: true),
    ];

    const bowler = BowlerScore(
      name: 'M. Starc',
      overs: '2.0',
      maidens: '0',
      runs: '14',
      wickets: '1',
      econ: '7.0',
    );

    try {
      await MatchService.updateLiveScore(
        matchId: _match!.id,
        summary: summary,
        batsmen: batsmen,
        bowler: bowler,
      );
    } catch (e) {
      AppLogger.error('Error syncing score', tag: 'Scoring', error: e);
    }
  }

  void _saveHistory() {
    _history.add({
      'runs': _runs,
      'wickets': _wickets,
      'overs': _overs,
      'recentBalls': List<String>.from(_recentBalls),
    });
    if (_history.length > 20) _history.removeAt(0);
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final last = _history.removeLast();
      _runs = last['runs'] as int;
      _wickets = last['wickets'] as int;
      _overs = last['overs'] as double;
      _recentBalls.clear();
      _recentBalls.addAll(last['recentBalls'] as List<String>);
    });
    _syncScore();
    HapticFeedback.mediumImpact();
  }

  bool get _canBowlNextLegalBall =>
      _oversLimit == 0 || _overs < _oversLimit;

  void _applyBall({
    required String label,
    int runDelta = 0,
    bool isLegal = true,
    bool isWicket = false,
  }) {
    // For legal balls, respect overs limit and innings transitions.
    if (isLegal && !_canBowlNextLegalBall) {
      _handleInningsOrMatchComplete();
      return;
    }

    _saveHistory();

    setState(() {
      _runs += runDelta;
      if (isWicket) _wickets++;

      _recentBalls.insert(0, label);
      if (_recentBalls.length > 6) _recentBalls.removeLast();

      if (isLegal) {
        _overs = double.parse((_overs + 0.1).toStringAsFixed(1));
        if (_overs.toString().endsWith('.6')) {
          _overs = _overs.floorToDouble() + 1.0;
        }
      }
    });

    _syncScore();
  }

  void _startSecondInnings() {
    if (_teamA == null || _teamB == null || _battingTeamName == null) return;
    setState(() {
      _innings = 2;
      // Swap batting side
      _battingTeamName =
          _battingTeamName == _teamA ? _teamB : _teamA;
      // Reset scoring state
      _runs = 0;
      _wickets = 0;
      _overs = 0.0;
      _recentBalls.clear();
      _history.clear();
    });
    _syncScore();
  }

  void _handleInningsOrMatchComplete() {
    if (_innings == 1) {
      // Ask user to start second innings.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppPalette.bgSecondary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'End 1st Innings?',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Overs limit reached. Start scoring for the second team?',
            style: TextStyle(color: AppPalette.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: AppPalette.textMuted),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _startSecondInnings();
              },
              style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.accent),
              child: const Text(
                'START 2ND INNINGS',
                style: TextStyle(
                    color: AppPalette.bgSecondary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      // Second innings also finished -> mark match complete and go to results.
      if (_match == null) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppPalette.accent),
        ),
      );
      MatchService.completeMatch(_match!.id).then((_) {
        if (!mounted) return;
        Navigator.pop(context); // close loader
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.results,
          (route) => false,
        );
      }).catchError((_) {
        if (!mounted) return;
        Navigator.pop(context); // close loader
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark match as completed'),
          ),
        );
      });
    }
  }

  void _addRun(int run, {bool isExtra = false, String? label}) {
    final ballLabel = label ?? run.toString();
    final countsAsLegalBall =
        !isExtra || ballLabel == 'NB' || ballLabel == 'LB' || ballLabel == 'B';

    _applyBall(
      label: ballLabel,
      runDelta: run,
      isLegal: countsAsLegalBall,
    );
    HapticFeedback.lightImpact();
  }

  void _addExtra(String type) {
    final isLegal = type == 'LB' || type == 'B';
    _applyBall(
      label: type,
      runDelta: 1,
      isLegal: isLegal,
    );
    HapticFeedback.selectionClick();
  }

  void _onWicket() {
    _showWicketPopup();
  }

  void _showWicketPopup() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withAlpha((0.95 * 255).toInt()),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppPalette.live.withAlpha((0.3 * 255).toInt())),
              boxShadow: [
                BoxShadow(color: AppPalette.live.withAlpha((0.1 * 255).toInt()), blurRadius: 40, spreadRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppPalette.live.withAlpha((0.1 * 255).toInt())),
                  child: const Icon(Icons.gavel_rounded, color: AppPalette.live, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('WICKET!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                const Text('Select Wicket Type', style: TextStyle(color: AppPalette.textMuted, fontSize: 14)),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _WicketTypeButton(label: 'Bowled', onTap: () => _confirmWicket('Bowled')),
                    _WicketTypeButton(label: 'Caught', onTap: () => _confirmWicket('Caught')),
                    _WicketTypeButton(label: 'LBW', onTap: () => _confirmWicket('LBW')),
                    _WicketTypeButton(label: 'Run Out', onTap: () => _confirmWicket('Run Out')),
                    _WicketTypeButton(label: 'Stumped', onTap: () => _confirmWicket('Stumped')),
                    _WicketTypeButton(label: 'Hit Wicket', onTap: () => _confirmWicket('Hit Wicket')),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL', style: TextStyle(color: AppPalette.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmWicket(String type) {
    Navigator.pop(context); // Close type selection
    
    // Step 2: Select which batsman is out
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withAlpha((0.95 * 255).toInt()),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppPalette.accent.withAlpha((0.2 * 255).toInt())),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('WHO IS OUT?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 24),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: AppPalette.accent, child: Text('SG', style: TextStyle(color: Colors.white))),
                  title: const Text('S. Gopi (Striker)', style: TextStyle(color: Colors.white)),
                  onTap: () => _finalizeWicket(type, 'S. Gopi'),
                ),
                const Divider(color: AppPalette.cardStroke),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: AppPalette.textMuted, child: Text('RS', style: TextStyle(color: Colors.white))),
                  title: const Text('R. Sharma (Non-Striker)', style: TextStyle(color: Colors.white)),
                  onTap: () => _finalizeWicket(type, 'R. Sharma'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _finalizeWicket(String type, String playerName) {
    Navigator.pop(context); // Close player selection

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('WICKET! - $type ($playerName)', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppPalette.live,
        duration: const Duration(seconds: 1),
      ),
    );
    _applyBall(
      label: 'W',
      runDelta: 0,
      isLegal: true,
      isWicket: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppPalette.surfaceGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 16),
                    _buildScoreCard(),
                    const SizedBox(height: 24),
                    _buildBatsmanStats(),
                    const SizedBox(height: 16),
                    _buildBowlerStats(),
                    const SizedBox(height: 24),
                    _buildRecentBalls(),
                  ],
                ),
              ),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final teamA = _teamA ?? _match?.teamAId ?? 'Team A';
    final teamB = _teamB ?? _match?.teamBId ?? 'Team B';

    // Primary source of truth for who is currently batting.
    final battingTeam = _battingTeamName ??
        (_decision == 'BAT'
            ? _tossWinner
            : (_tossWinner == teamA ? teamB : teamA)) ??
        teamA;

    final inningsLabel = _innings == 1 ? '1st Innings' : '2nd Innings';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xCC111721),
        border: Border(bottom: BorderSide(color: AppPalette.cardStroke)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: AppPalette.textPrimary, size: 20),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$teamA vs $teamB',
                  style: const TextStyle(color: AppPalette.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '$battingTeam Batting • $inningsLabel',
                  style: const TextStyle(color: AppPalette.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withAlpha((0.3 * 255).toInt()),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.accent.withAlpha((0.2 * 255).toInt())),
        gradient: LinearGradient(
          colors: [
            AppPalette.accent.withAlpha((0.1 * 255).toInt()),
            const Color(0xFF1E293B).withAlpha((0.1 * 255).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$_runs',
                          style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -1),
                        ),
                        TextSpan(
                          text: '-$_wickets',
                          style: TextStyle(color: Colors.white.withAlpha((0.6 * 255).toInt()), fontSize: 32, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _oversLimit > 0
                        ? 'Overs: ${_overs.toStringAsFixed(1)} / $_oversLimit'
                        : 'Overs: ${_overs.toStringAsFixed(1)}',
                    style: TextStyle(
                      color:
                          AppPalette.textMuted.withAlpha((0.8 * 255).toInt()),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('CRR', style: TextStyle(color: AppPalette.textMuted, fontSize: 12)),
                  Text(
                    _overs > 0 ? (_runs / (_overs.floor() + (_overs - _overs.floor()) * 1.6666)).toStringAsFixed(2) : '0.00',
                    style: const TextStyle(color: AppPalette.accent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatsmanStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.bgSecondary.withAlpha((0.5 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.cardStroke),
      ),
      child: Column(
        children: [
          _StatsRow(name: 'S. Gopi*', runs: (_runs ~/ 2).toString(), balls: '12', sr: '200.0', isStriker: true),
          const Divider(color: AppPalette.cardStroke, height: 24),
          _StatsRow(name: 'R. Sharma', runs: (_runs - (_runs ~/ 2)).toString(), balls: '15', sr: '120.0', isStriker: false),
        ],
      ),
    );
  }

  Widget _buildBowlerStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.bgSecondary.withAlpha((0.5 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.cardStroke),
      ),
      child: const _BowlerRow(name: 'M. Starc', figures: '2-0-14-1', econ: '7.0'),
    );
  }

  Widget _buildRecentBalls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECENT BALLS', style: TextStyle(color: AppPalette.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _recentBalls.map((b) => _BallCircle(label: b)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppPalette.cardStroke)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KeyButton(label: '0', onTap: () => _addRun(0)),
              _KeyButton(label: '1', onTap: () => _addRun(1)),
              _KeyButton(label: '2', onTap: () => _addRun(2)),
              _KeyButton(label: '3', onTap: () => _addRun(3)),
              _KeyButton(label: '4', onTap: () => _addRun(4), isHighlight: true),
              _KeyButton(label: '6', onTap: () => _addRun(6), isHighlight: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KeyButton(label: 'WD', onTap: () => _addExtra('WD'), isSpecial: true),
              _KeyButton(label: 'NB', onTap: () => _addExtra('NB'), isSpecial: true),
              _KeyButton(label: 'LB', onTap: () => _addExtra('LB'), isSpecial: true),
              _KeyButton(label: 'B', onTap: () => _addExtra('B'), isSpecial: true),
              _KeyButton(label: 'W', onTap: _onWicket, isAlert: true),
              _KeyButton(icon: Icons.undo, onTap: _undo, isSpecial: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.name, required this.runs, required this.balls, required this.sr, required this.isStriker});
  final String name, runs, balls, sr;
  final bool isStriker;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(color: isStriker ? Colors.white : AppPalette.textMuted, fontWeight: isStriker ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        _StatItem(label: 'R', value: runs),
        _StatItem(label: 'B', value: balls),
        _StatItem(label: 'SR', value: sr, width: 50),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.width = 30});
  final String label, value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppPalette.textMuted, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _BowlerRow extends StatelessWidget {
  const _BowlerRow({required this.name, required this.figures, required this.econ});
  final String name, figures, econ;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(name, style: const TextStyle(color: Colors.white))),
        _StatItem(label: 'O-M-R-W', value: figures, width: 80),
        _StatItem(label: 'ECON', value: econ, width: 40),
      ],
    );
  }
}

class _BallCircle extends StatelessWidget {
  const _BallCircle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    bool isWicket = label == 'W';
    bool isBoundary = label == '4' || label == '6';
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isWicket ? AppPalette.live.withAlpha((0.2 * 255).toInt()) : (isBoundary ? AppPalette.accent.withAlpha((0.2 * 255).toInt()) : AppPalette.bgSecondary),
        border: Border.all(color: isWicket ? AppPalette.live : (isBoundary ? AppPalette.accent : AppPalette.cardStroke)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isWicket ? AppPalette.live : (isBoundary ? AppPalette.accent : Colors.white),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({this.label, this.icon, required this.onTap, this.isHighlight = false, this.isSpecial = false, this.isAlert = false});
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isHighlight, isSpecial, isAlert;

  @override
  Widget build(BuildContext context) {
    Color bg = isAlert ? AppPalette.live : (isHighlight ? AppPalette.accent : (isSpecial ? const Color(0xFF1E293B) : const Color(0xFF334155)));
    Color fg = (isHighlight || isAlert) ? AppPalette.bgSecondary : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: icon != null 
            ? Icon(icon, color: fg, size: 20)
            : Text(label!, style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 18)),
        ),
      ),
    );
  }
}

class _WicketTypeButton extends StatelessWidget {
  const _WicketTypeButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPalette.cardStroke),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
