import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/style/colors.dart';

class TournamentListPage extends StatefulWidget {
  const TournamentListPage({super.key});

  @override
  State<TournamentListPage> createState() => _TournamentListPageState();
}

class _TournamentListPageState extends State<TournamentListPage> {
  int _selectedFilter = 0;
  final _filters = ['all'.tr(), 'active'.tr(), 'upcoming'.tr(), 'completed'.tr(), 'my_tournaments'.tr()];

  final List<Map<String, dynamic>> _tournaments = [
    {
      'name': 'gulf_champions_cup'.tr(),
      'prize': '10,000',
      'participants': '23/64',
      'status': 'Live',
      'date': 'now'.tr(),
      'isPremium': true,
      'isJoined': true,
    },
    {
      'name': 'weekend_baloot_bash'.tr(),
      'prize': '5,000',
      'participants': '12/32',
      'status': 'upcoming'.tr(),
      'date': 'Tomorrow',
      'isPremium': false,
      'isJoined': false,
    },
    {
      'name': 'riyadh_open'.tr(),
      'prize': 'free_entry'.tr(),
      'participants': '45/128',
      'status': 'upcoming'.tr(),
      'date': 'sat_6pm'.tr(),
      'isPremium': false,
      'isJoined': false,
    },
    {
      'name': 'pro_league_s1'.tr(),
      'prize': '25,000',
      'participants': '64/64',
      'status': 'completed'.tr(),
      'date': 'last_week'.tr(),
      'isPremium': true,
      'isJoined': true,
    },
    {
      'name': 'ramadan_tournament'.tr(),
      'prize': '15,000',
      'participants': '30/64',
      'status': 'upcoming'.tr(),
      'date': 'next_friday'.tr(),
      'isPremium': true,
      'isJoined': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'tournaments'.tr(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 16,
                          color: ColorManager.secondary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '2,450',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Filters
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorManager.primary
                            : ColorManager.darkSurface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? ColorManager.primary
                              : ColorManager.darkBorderSoft,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? ColorManager.darkTextPrimary
                              : ColorManager.darkTextSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                itemCount: _tournaments.length,
                itemBuilder: (context, index) {
                  final t = _tournaments[index];
                  return _TournamentListCard(
                    data: t,
                    onTap: () => context.pushNamed(
                      RouteNames.tournamentDetail,
                      pathParameters: {'id': 'tournament_$index'},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentListCard extends StatelessWidget {
  const _TournamentListCard({required this.data, required this.onTap});

  final Map<String, dynamic> data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPremium = data['isPremium'] as bool;
    final status = data['status'] as String;
    final statusColor = status == 'Live'
        ? ColorManager.live
        : status == 'upcoming'.tr()
            ? ColorManager.primary
            : ColorManager.darkTextMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPremium
                ? ColorManager.secondary.withValues(alpha: 0.4)
                : ColorManager.darkBorderSoft,
            width: isPremium ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isPremium
                        ? ColorManager.secondary.withValues(alpha: 0.3)
                        : ColorManager.primary.withValues(alpha: 0.2),
                    ColorManager.darkSurface,
                  ],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 56,
                      color: (isPremium ? ColorManager.secondary : ColorManager.primary)
                          .withValues(alpha: 0.15),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  if (isPremium)
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: ColorManager.secondary,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 16,
                        color: ColorManager.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        data['prize'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.secondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: ColorManager.darkTextMuted.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data['date'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.people_rounded,
                        size: 14,
                        color: ColorManager.darkTextMuted.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data['participants'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (data['isJoined'] == true)
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ColorManager.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'joined'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ColorManager.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}