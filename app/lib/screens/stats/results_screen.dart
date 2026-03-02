import 'dart:ui';

import 'package:cricstatz/config/assets.dart';
import 'package:cricstatz/config/palette.dart';
import 'package:cricstatz/config/routes.dart';
import 'package:cricstatz/widgets/app_bottom_nav_bar.dart';
import 'package:cricstatz/widgets/app_header.dart';
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  static const _sections = [
    _ResultSection(
      date: 'September 24, 2023',
      matches: [
        _ResultData(
          format: 'ODI Match',
          status: 'Final Score',
          teamA: 'IND',
          teamB: 'AUS',
          teamAFlag: AppAssets.flagInd,
          teamBFlag: AppAssets.flagAus,
          scoreA: '352/7',
          scoreB: '254',
          outcome: 'India won by 98 runs',
        ),
      ],
    ),
    _ResultSection(
      date: 'September 22, 2023',
      matches: [
        _ResultData(
          format: 'T20 International',
          status: 'Final Score',
          teamA: 'ENG',
          teamB: 'RSA',
          teamAFlag: AppAssets.flagEng,
          teamBFlag: AppAssets.flagRsa,
          scoreA: '188/4',
          scoreB: '192/3',
          outcome: 'RSA won by 7 wickets',
        ),
        _ResultData(
          format: 'Test Match',
          status: 'Day 5 - Stumps',
          teamA: 'NZL',
          teamB: 'PAK',
          teamAFlag: AppAssets.flagNzl,
          teamBFlag: AppAssets.flagPak,
          scoreA: '245 & 312',
          scoreB: '298 & 150/2',
          outcome: 'Match Drawn',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppPalette.surfaceGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  children: [
                    for (final section in _sections) ...[
                      Text(
                        section.date.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppPalette.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.7,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...section.matches.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ResultCard(data: m),
                          )),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xCC111721),
            border: Border(bottom: BorderSide(color: AppPalette.cardStroke)),
          ),
          child: Column(
            children: [
              AppHeader(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppPalette.bgSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(AppAssets.iconCal,
                            width: 20, height: 20,
                            color: AppPalette.textPrimary),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppPalette.bgSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Image.asset(AppAssets.iconFil,
                            width: 20, height: 20,
                            color: AppPalette.textPrimary),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _ResultsQuickTabs(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsQuickTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 51,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppPalette.cardStroke)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TabItem(
              label: 'Live',
              isSelected: false,
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (r) => false)),
          _TabItem(
              label: 'Upcoming',
              isSelected: false,
              onTap: () =>
                  Navigator.push(context, AppRoutes.buildUpcomingRoute())),
          _TabItem(label: 'Results', isSelected: true, onTap: () {}),
          _TabItem(label: "My Matche's", isSelected: false, onTap: () {}),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem(
      {required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding:
            const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppPalette.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppPalette.accent : AppPalette.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
        ),
      ),
    );
  }
}

class _ResultSection {
  const _ResultSection({required this.date, required this.matches});
  final String date;
  final List<_ResultData> matches;
}

class _ResultData {
  const _ResultData({
    required this.format,
    required this.status,
    required this.teamA,
    required this.teamB,
    required this.teamAFlag,
    required this.teamBFlag,
    required this.scoreA,
    required this.scoreB,
    required this.outcome,
  });
  final String format;
  final String status;
  final String teamA;
  final String teamB;
  final String teamAFlag;
  final String teamBFlag;
  final String scoreA;
  final String scoreB;
  final String outcome;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.data});

  final _ResultData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x800F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.cardStroke),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppPalette.bgSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data.format.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppPalette.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                  ),
                ),
                Text(
                  data.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.textMuted,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _ResultTeamBadge(assetPath: data.teamAFlag),
                      const SizedBox(height: 8),
                      Text(
                        data.teamA,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppPalette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.scoreA,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppPalette.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'VS',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _ResultTeamBadge(assetPath: data.teamBFlag),
                      const SizedBox(height: 8),
                      Text(
                        data.teamB,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppPalette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.scoreB,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppPalette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppPalette.cardStroke),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data.outcome,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppPalette.success,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scoreboard coming soon')),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPalette.bgSecondary,
                    foregroundColor: AppPalette.textPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'View Scorecard',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
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

class _ResultTeamBadge extends StatelessWidget {
  const _ResultTeamBadge({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.flag, color: AppPalette.textMuted, size: 24),
        ),
      ),
    );
  }
}
