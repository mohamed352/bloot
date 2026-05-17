import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/style/colors.dart';

class DiscoverStreamsPage extends StatefulWidget {
  const DiscoverStreamsPage({super.key});

  @override
  State<DiscoverStreamsPage> createState() => _DiscoverStreamsPageState();
}

class _DiscoverStreamsPageState extends State<DiscoverStreamsPage> {
  int _selectedFilter = 0;
  final _filters = ['popular'.tr(), 'new'.tr(), 'top_rated'.tr(), 'tournaments'.tr(), 'voice_only'.tr(), 'following'.tr()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.darkCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorManager.darkSectionGray,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ColorManager.darkBorderSoft,
                  ),
                ),
                child: TextField(
                  style: const TextStyle(
                    color: ColorManager.darkTextPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'search_streams_players'.tr(),
                    hintStyle: const TextStyle(
                      color: ColorManager.darkTextMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: ColorManager.darkTextMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsetsDirectional.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            // Filter chips
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
            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  final streams = [
                    ('Ahmed & Khalid vs Faisal', 'Ahmed', 1240, 'Baloot'),
                    ('Pro League Finals', 'SaadTV', 856, 'Competitive'),
                    ('Late Night Session', 'Khaled', 342, 'Streaming'),
                    ('Morning Baloot', 'Omar', 128, 'Baloot'),
                    ('Weekend Tournament', 'BlootOfficial', 2100, 'Tournament'),
                    ('Voice Only Table', 'Faisal', 45, 'Voice'),
                    ('Casual Play', 'Nasser', 89, 'Baloot'),
                    ('Training Room', 'CoachAli', 156, 'Training'),
                  ];
                  final stream = streams[index];
                  return _DiscoverStreamCard(
                    title: stream.$1,
                    host: stream.$2,
                    viewers: stream.$3,
                    type: stream.$4,
                    onTap: () => context.pushNamed(
                      RouteNames.watchStream,
                      pathParameters: {'id': 'stream_$index'},
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

class _DiscoverStreamCard extends StatelessWidget {
  const _DiscoverStreamCard({
    required this.title,
    required this.host,
    required this.viewers,
    required this.type,
    required this.onTap,
  });

  final String title;
  final String host;
  final int viewers;
  final String type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorManager.darkBorderSoft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.primary.withValues(alpha: 0.2 + (viewers % 3) * 0.1),
                      ColorManager.darkSurface,
                    ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.videocam_rounded,
                        size: 40,
                        color: ColorManager.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.live.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 5,
                              color: ColorManager.darkTextPrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'live'.tr(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: ColorManager.darkTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility_rounded,
                              size: 10,
                              color: ColorManager.darkTextPrimary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$viewers',
                              style: const TextStyle(
                                fontSize: 10,
                                color: ColorManager.darkTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=${viewers % 70}',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        host,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ColorManager.darkTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 9,
                            color: ColorManager.primary,
                            fontWeight: FontWeight.w600,
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