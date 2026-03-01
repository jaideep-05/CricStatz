import 'package:cricstatz/config/routes.dart';
import 'package:cricstatz/config/palette.dart';
import 'package:cricstatz/widgets/coin_flip_widget.dart';
import 'package:flutter/material.dart';

class TossScreen extends StatefulWidget {
  const TossScreen({super.key});

  @override
  State<TossScreen> createState() => _TossScreenState();
}

enum _TossPhase { selection, flipping, result }

class _TossScreenState extends State<TossScreen> with TickerProviderStateMixin {
  String? selectedTeam;
  _TossPhase _phase = _TossPhase.selection;
  bool _resultHeads = true;
  final _coinKey = GlobalKey<CoinFlipWidgetState>();

  late final AnimationController _resultCtrl;
  late final Animation<double> _resultFade;
  late final Animation<double> _resultScale;

  @override
  void initState() {
    super.initState();
    _resultCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _resultFade = CurvedAnimation(
      parent: _resultCtrl,
      curve: Curves.easeOut,
    );
    _resultScale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _resultCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _resultCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleFlipCoin() async {
    if (selectedTeam == null) return;

    setState(() => _phase = _TossPhase.flipping);

    _resultHeads = await _coinKey.currentState!.flip();

    if (mounted) {
      setState(() => _phase = _TossPhase.result);
      _resultCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResult = _phase == _TossPhase.result;
    final isFlipping = _phase == _TossPhase.flipping;
    final isSelection = _phase == _TossPhase.selection;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppPalette.surfaceGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          isSelection ? () => Navigator.pop(context) : null,
                      icon: const Icon(Icons.arrow_back,
                          color: AppPalette.textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        'MATCH TOSS',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppPalette.textPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Title ──
                Text(
                  isResult
                      ? 'Toss Result'
                      : selectedTeam == null
                          ? 'Who Won the Toss?'
                          : 'Toss For $selectedTeam',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppPalette.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),

                if (!isResult)
                  const Text(
                    'Select the team that called it correctly',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppPalette.textMuted, fontSize: 20),
                  ),
                const SizedBox(height: 24),

                // ── Team cards — fade during flip, collapse in result ──
                AnimatedOpacity(
                  opacity: isFlipping ? 0.3 : (isResult ? 0.0 : 1.0),
                  duration: const Duration(milliseconds: 400),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: isResult
                        ? const SizedBox.shrink()
                        : IgnorePointer(
                            ignoring: !isSelection,
                            child: _buildTeamCards(),
                          ),
                  ),
                ),

                const Spacer(),

                // ── Coin — SAME tree position in ALL phases ──
                Center(child: CoinFlipWidget(key: _coinKey)),

                const SizedBox(height: 16),

                // ── Result display ──
                if (isResult) _buildResultDisplay(),

                const Spacer(),

                // ── Button ──
                _buildButton(isSelection, isResult, isFlipping),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _buildTeamCards() {
    return Row(
      children: [
        Expanded(
          child: _TeamChoiceCard(
            label: 'TEAM A',
            selected: selectedTeam == 'Team A',
            onTap: () => setState(() => selectedTeam = 'Team A'),
            badgeLabel: 'A',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TeamChoiceCard(
            label: 'TEAM B',
            selected: selectedTeam == 'Team B',
            onTap: () => setState(() => selectedTeam = 'Team B'),
            badgeLabel: 'B',
          ),
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    final isHeads = _resultHeads;
    final glowColor =
        isHeads ? const Color(0xFFFFD700) : const Color(0xFFC0C0C0);

    return FadeTransition(
      opacity: _resultFade,
      child: ScaleTransition(
        scale: _resultScale,
        child: Column(
          children: [
            // HEADS / TAILS text with glow shadow
            Text(
              isHeads ? 'HEADS' : 'TAILS',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: glowColor,
                letterSpacing: 3.0,
                shadows: [
                  Shadow(
                    color: glowColor.withValues(alpha: 0.6),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Text(
              '$selectedTeam won the toss!',
              style: const TextStyle(
                color: AppPalette.textMuted,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(bool isSelection, bool isResult, bool isFlipping) {
    // During flip, show a disabled placeholder to hold layout space
    if (isFlipping) return const SizedBox(height: 56);

    if (isResult) {
      return FadeTransition(
        opacity: _resultFade,
        child: FilledButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.scoring),
          style: _buttonStyle(),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'START MATCH',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      );
    }

    return FilledButton(
      onPressed: selectedTeam == null ? null : _handleFlipCoin,
      style: _buttonStyle(withDisabled: true),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.autorenew, size: 20),
          SizedBox(width: 10),
          Text(
            'FLIP COIN',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle({bool withDisabled = false}) {
    return FilledButton.styleFrom(
      backgroundColor: const Color(0xFF0A2A62),
      disabledBackgroundColor:
          withDisabled ? const Color(0xFF233A64) : null,
      foregroundColor: AppPalette.textPrimary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

// ── Team Choice Card ────────────────────────────────────────

class _TeamChoiceCard extends StatelessWidget {
  const _TeamChoiceCard({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.badgeLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 20),
        decoration: BoxDecoration(
          color: const Color(0xAA0B1D3A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppPalette.accent : const Color(0xFF1F3352),
              width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF0B2C66), Color(0xFF243A5C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFF0E2B54),
                  alignment: Alignment.center,
                  child: Text(
                    badgeLabel,
                    style: const TextStyle(
                        color: Color(0xFFFACC15),
                        fontSize: 36,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
