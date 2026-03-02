import 'dart:ui';

import 'package:cricstatz/config/routes.dart';
import 'package:cricstatz/config/assets.dart';
import 'package:cricstatz/config/palette.dart';
import 'package:cricstatz/widgets/app_bottom_nav_bar.dart';
import 'package:cricstatz/widgets/app_header.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.toss),
        backgroundColor: AppPalette.accent,
        foregroundColor: AppPalette.bgSecondary,
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppPalette.surfaceGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: false,
                automaticallyImplyLeading: false,
                toolbarHeight:
                    111, // AppHeader (55) + QuickTabs (51) + buffer to avoid overflow
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xCC111721),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppHeader(
                            trailing: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppPalette.bgSecondary
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.notifications_none,
                                      color: AppPalette.textPrimary),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppPalette.live,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppPalette.bgPrimary,
                                          width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _QuickTabs(
                            selectedIndex: _selectedTab,
                            onTap: (int index) {
                              setState(() => _selectedTab = index);
                              if (index == 1) {
                                Navigator.push(
                                    context, AppRoutes.buildUpcomingRoute());
                              } else if (index == 2) {
                                Navigator.push(
                                    context, AppRoutes.buildResultsRoute());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _LiveMatchSection(),
                    const SizedBox(height: 18),
                    const _UpcomingMatchesSection(),
                    const SizedBox(height: 18),
                    const _RecentResultsSection(),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTabs extends StatelessWidget {
  const _QuickTabs({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 51,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppPalette.cardStroke)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _TabItem(
              label: 'Live',
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _TabItem(
              label: 'Upcoming',
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _TabItem(
              label: 'Results',
              isSelected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
            _TabItem(
              label: "My Matche's",
              isSelected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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

class _LiveMatchSection extends StatelessWidget {
  const _LiveMatchSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Live Match',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            const Icon(Icons.circle, color: AppPalette.live, size: 8),
            const SizedBox(width: 6),
            Text(
              'LIVE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppPalette.live,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0x660A1F43),
            border: Border.all(color: const Color(0x800A1F43)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x990A1F43),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "ICC MEN'S WORLD\nCUP",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFE2E8F0),
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Final • Narendra Modi\nStadium',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppPalette.textMuted,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TeamBadge(flag: 'IND', assetPath: AppAssets.flagInd),
                  _ScoreCenter(),
                  _TeamBadge(
                      flag: 'AUS', assetPath: AppAssets.flagAus, faded: true),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x0DFFFFFF)),
                ),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: const Color(0xFFCBD5E1)),
                        children: const [
                          TextSpan(text: 'India needs '),
                          TextSpan(
                              text: '42 runs',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          TextSpan(text: ' in '),
                          TextSpan(
                              text: '60 balls',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.85,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppPalette.progress),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scoreboard coming soon')),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: AppPalette.bgSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Full Scorecard',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 7, color: AppPalette.textPrimary),
              SizedBox(width: 4),
              Icon(Icons.circle_outlined, size: 7, color: AppPalette.textMuted),
              SizedBox(width: 4),
              Icon(Icons.circle_outlined, size: 7, color: AppPalette.textMuted),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge(
      {required this.flag, required this.assetPath, this.faded = false});

  final String flag;
  final String assetPath;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final double opacity = faded ? 0.55 : 1;
    return Opacity(
      opacity: opacity,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF475569), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                assetPath,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Center(
                    child: Text(
                      flag == 'IND' ? 'IN' : 'AU',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            flag,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCenter extends StatelessWidget {
  const _ScoreCenter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppPalette.textPrimary),
            children: [
              const TextSpan(
                  text: '342/5 ',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28)),
              TextSpan(
                text: '(40.0)',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppPalette.textSubtle),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'VS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingMatchesSection extends StatelessWidget {
  const _UpcomingMatchesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Upcoming Matches',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  Navigator.push(context, AppRoutes.buildUpcomingRoute()),
              child: const Text('View All'),
            ),
          ],
        ),
        SizedBox(
          height: 118,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _UpcomingCard(
                time: 'TOMORROW, 14:00',
                teamA: 'ENG',
                teamB: 'RSA',
                teamAFlag: AppAssets.flagEng,
                teamBFlag: AppAssets.flagRsa,
                subtitle: 'ODI Series • Lords, London',
                onTap: () =>
                    Navigator.push(context, AppRoutes.buildUpcomingRoute()),
              ),
              const SizedBox(width: 16),
              _UpcomingCard(
                time: '24 MAY, 19:30',
                teamA: 'NZL',
                teamB: 'PAK',
                teamAFlag: AppAssets.flagNzl,
                teamBFlag: AppAssets.flagPak,
                subtitle: 'T20 International • Auckland',
                onTap: () =>
                    Navigator.push(context, AppRoutes.buildUpcomingRoute()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.time,
    required this.teamA,
    required this.teamB,
    required this.subtitle,
    required this.teamAFlag,
    required this.teamBFlag,
    this.onTap,
  });

  final String time;
  final String teamA;
  final String teamB;
  final String subtitle;
  final String teamAFlag;
  final String teamBFlag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppPalette.cardOverlay.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPalette.cardStroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppPalette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FlagCircle(assetPath: teamAFlag),
                    const SizedBox(width: 8),
                    Text(
                      teamA,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                Text('vs',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppPalette.textMuted)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      teamB,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppPalette.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _FlagCircle(assetPath: teamBFlag),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(
                    color: AppPalette.textSubtle, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _FlagCircle extends StatelessWidget {
  const _FlagCircle({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 20,
        height: 20,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _RecentResultsSection extends StatelessWidget {
  const _RecentResultsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Results',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppPalette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        const _ResultCard(
          lineOne: 'SL 210/10 (48.2)',
          lineTwo: 'BAN 211/4 (44.5)',
          when: 'Yesterday',
          outcome: 'Bangladesh won by 6 wkts',
        ),
        const SizedBox(height: 12),
        const _ResultCard(
          lineOne: 'WI 189/2 (18.4)',
          lineTwo: 'AFG 188/8 (20.0)',
          when: '22 May',
          outcome: 'West Indies won by 8 wkts',
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard(
      {required this.lineOne,
      required this.lineTwo,
      required this.when,
      required this.outcome});

  final String lineOne;
  final String lineTwo;
  final String when;
  final String outcome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppPalette.cardOverlay.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.cardStroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(lineOne,
                  style: const TextStyle(
                      color: AppPalette.textPrimary,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(when,
                  style: const TextStyle(
                      color: AppPalette.textSubtle, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(lineTwo,
                  style: const TextStyle(
                      color: AppPalette.success, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(outcome,
                  style: const TextStyle(
                      color: AppPalette.textSubtle, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
