import 'dart:ui';

import 'package:cricstatz/config/palette.dart';
import 'package:cricstatz/config/routes.dart';
import 'package:flutter/material.dart';

class MatchLiveScreen extends StatelessWidget {
  const MatchLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _ScoreBannerCard(),
                    const SizedBox(height: 16),
                    _CurrentPartnershipCard(),
                    const SizedBox(height: 16),
                    _BatsmenRow(),
                    const SizedBox(height: 16),
                    _BowlerCard(),
                    const SizedBox(height: 16),
                    _RecentBallsRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 72,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: const BoxDecoration(
            color: Color(0xF20A1F43),
            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppPalette.textPrimary, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'IND vs AUS, Final',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ODI World Cup 2023',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined,
                    color: AppPalette.textPrimary, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    const tabs = ['INFO', 'LIVE', 'SCORECARD', 'PLAYERS'];
    const selectedIndex = 1;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 51,
          decoration: const BoxDecoration(
            color: Color(0xF20A1F43),
            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isSelected = i == selectedIndex;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (i == selectedIndex) return;
                    if (i == 0) {
                      Navigator.pushNamed(context, AppRoutes.info);
                    } else if (i == 2) {
                      Navigator.pushNamed(context, AppRoutes.scoreboard);
                    } else if (i == 3) {
                      Navigator.pushNamed(context, AppRoutes.players);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              isSelected ? AppPalette.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      tabs[i],
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isSelected
                                ? AppPalette.accent
                                : AppPalette.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.6,
                          ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ScoreBannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1F44), Color(0xFF111827)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0DFFFFFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INDIA INNINGS',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppPalette.accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '284/4',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 36,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Overs: 42.3 •\nCRR: 6.68',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xCCFFFFFF),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: 320',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0x99FFFFFF),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'India needs 36 runs in\n45 balls',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: const Color(0x1AFFFFFF)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUSTRALIA (1ST INNINGS)',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0x99FFFFFF),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '319/10 (50.0)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: const Color(0x1AFFFFFF)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'REQUIRED RATE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0x99FFFFFF),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '4.80',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppPalette.accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentPartnershipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Column(
        children: [
          Text(
            'CURRENT PARTNERSHIP',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppPalette.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '45',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                '(32 balls)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppPalette.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatsmenRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget batterCard({
      required bool active,
      required String name,
      required String runs,
      required String balls,
      required String fours,
      required String sixes,
      required String sr,
    }) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.fromLTRB(active ? 20 : 17, 16, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: active
                ? const Border(
                    left: BorderSide(color: AppPalette.accent, width: 4),
                    top: BorderSide(color: Color(0x0DFFFFFF)),
                    right: BorderSide(color: Color(0x0DFFFFFF)),
                    bottom: BorderSide(color: Color(0x0DFFFFFF)),
                  )
                : Border.all(color: const Color(0x0DFFFFFF)),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color:
                              active ? Colors.white : const Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (active)
                    Icon(Icons.circle, size: 10, color: AppPalette.accent),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    runs,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($balls)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppPalette.textMuted,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '4s: $fours  6s: $sixes  SR: $sr',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppPalette.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        batterCard(
          active: true,
          name: 'V. Kohli*',
          runs: '82',
          balls: '54',
          fours: '6',
          sixes: '2',
          sr: '151.8',
        ),
        const SizedBox(width: 16),
        batterCard(
          active: false,
          name: 'KL Rahul',
          runs: '14',
          balls: '12',
          fours: '1',
          sixes: '0',
          sr: '116.6',
        ),
      ],
    );
  }
}

class _BowlerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0DFFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person_outline,
                color: AppPalette.textMuted, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'M. Starc',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '8.3 - 0 - 52 - 2',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppPalette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'THIS OVER',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppPalette.accent,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _MiniBallChip('1'),
                  SizedBox(width: 4),
                  _MiniBallChip('4'),
                  SizedBox(width: 4),
                  _MiniBallChip('0'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniBallChip extends StatelessWidget {
  const _MiniBallChip(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _RecentBallsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final over42 = ['1', '2', '0', '1', '4', 'W', '0', '1'];
    final over41 = ['0', '1lb', '6', '1', '1', '2'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT BALLS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VIEW ALL',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppPalette.accent.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: AppPalette.accent),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _OverChip(label: 'Ov 42', balls: over42),
              const SizedBox(width: 12),
              Opacity(
                opacity: 0.6,
                child: _OverChip(label: 'Ov 41', balls: over41),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverChip extends StatelessWidget {
  const _OverChip({required this.label, required this.balls});

  final String label;
  final List<String> balls;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotatedBox(
            quarterTurns: -1,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppPalette.textSubtle,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          ...balls.map((b) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _BallChip(value: b),
              )),
        ],
      ),
    );
  }
}

class _BallChip extends StatelessWidget {
  const _BallChip({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFF1E293B);
    Color fg = Colors.white;
    BoxBorder? border = Border.all(color: const Color(0x1AFFFFFF));

    if (value == '4' || value == '6') {
      bg = AppPalette.accent;
      fg = AppPalette.bgSecondary;
      border = null;
    } else if (value == 'W') {
      bg = AppPalette.live;
      fg = Colors.white;
      border = null;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
      ),
    );
  }
}

