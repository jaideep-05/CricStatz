import 'dart:ui';

import 'package:cricstatz/config/assets.dart';
import 'package:cricstatz/config/palette.dart';
import 'package:cricstatz/config/routes.dart';
import 'package:cricstatz/widgets/app_bottom_nav_bar.dart';
import 'package:cricstatz/widgets/app_header.dart';
import 'package:flutter/material.dart';

class UpcomingFixturesScreen extends StatelessWidget {
  const UpcomingFixturesScreen({super.key});

  static const _fixtures = [
    _FixtureData(
      time: 'Tomorrow, 14:00',
      teamA: 'INDIA',
      teamB: 'AUSTRALIA',
      teamAFlag: AppAssets.flagInd,
      teamBFlag: AppAssets.flagAus,
      venue: 'Narendra Modi Stadium, Ahmedabad',
      format: 'T20',
      formatColor: Color(0xFF0A1F43),
      hasStartMatch: true,
    ),
    _FixtureData(
      time: 'Sat, 24 June • 09:30',
      teamA: 'ENGLAND',
      teamB: 'SOUTH AFRICA',
      teamAFlag: AppAssets.flagEng,
      teamBFlag: AppAssets.flagRsa,
      venue: "Lord's Cricket Ground, London",
      format: 'ODI',
      formatColor: Color(0xFF334155),
      hasStartMatch: false,
    ),
    _FixtureData(
      time: 'Sun, 25 June • 11:00',
      teamA: 'NEW ZEALAND',
      teamB: 'PAKISTAN',
      teamAFlag: AppAssets.flagNzl,
      teamBFlag: AppAssets.flagPak,
      venue: 'Hagley Oval, Christchurch',
      format: 'TEST',
      formatColor: Color(0xFFDC2626),
      hasStartMatch: false,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'International Fixtures',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppPalette.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppPalette.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'T20 WORLD CUP',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppPalette.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._fixtures.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _FixtureCard(data: f),
                        )),
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
                        icon: const Icon(Icons.calendar_today_outlined,
                            color: AppPalette.textPrimary, size: 20),
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
                        icon: const Icon(Icons.filter_list,
                            color: AppPalette.textPrimary, size: 20),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _QuickTabs(),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTabs extends StatelessWidget {
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
          _TabItem(label: 'Upcoming', isSelected: true, onTap: () {}),
          _TabItem(
              label: 'Results',
              isSelected: false,
              onTap: () => Navigator.push(context, AppRoutes.buildResultsRoute())),
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

class _FixtureData {
  const _FixtureData({
    required this.time,
    required this.teamA,
    required this.teamB,
    required this.teamAFlag,
    required this.teamBFlag,
    required this.venue,
    required this.format,
    required this.formatColor,
    required this.hasStartMatch,
  });

  final String time;
  final String teamA;
  final String teamB;
  final String teamAFlag;
  final String teamBFlag;
  final String venue;
  final String format;
  final Color formatColor;
  final bool hasStartMatch;
}

class _FixtureCard extends StatelessWidget {
  const _FixtureCard({required this.data});

  final _FixtureData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C2431),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D3748)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppPalette.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      data.time.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppPalette.textMuted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: data.formatColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    data.format,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2D3748)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TeamBadge(assetPath: data.teamAFlag),
                      const SizedBox(height: 6),
                      Text(
                        data.teamA,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPalette.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    'VS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppPalette.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TeamBadge(assetPath: data.teamBFlag),
                      const SizedBox(height: 6),
                      Text(
                        data.teamB,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPalette.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppPalette.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.venue,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPalette.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: data.hasStartMatch
                            ? () => Navigator.pushNamed(context, AppRoutes.toss)
                            : () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reminder set!'))),
                        icon: Icon(
                          data.hasStartMatch
                              ? Icons.play_arrow
                              : Icons.notifications_outlined,
                          size: data.hasStartMatch ? 14 : 16,
                        ),
                        label: Text(data.hasStartMatch
                            ? 'Start Match'
                            : 'Set Reminder'),
                        style: FilledButton.styleFrom(
                          backgroundColor: data.hasStartMatch
                              ? AppPalette.accent
                              : AppPalette.accent.withValues(alpha: 0.2),
                          foregroundColor: data.hasStartMatch
                              ? AppPalette.bgSecondary
                              : AppPalette.accent,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppPalette.textPrimary,
                        side: const BorderSide(color: Color(0xFF2D3748)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 17, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(Icons.flag, color: AppPalette.textMuted, size: 28),
        ),
      ),
    );
  }
}
