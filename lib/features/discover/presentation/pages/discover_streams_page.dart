import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/generated/locale_keys.g.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_state.dart';
import 'package:bloot/features/discover/presentation/widgets/stream_card.dart';

class DiscoverStreamsPage extends StatelessWidget {
  const DiscoverStreamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoverCubit, DiscoverState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
        );
      },
      builder: (context, state) {
        final streams = state is DiscoverStreamsLoaded
            ? state.streams
            : <DiscoverStream>[];
        final selectedFilter = state is DiscoverStreamsLoaded
            ? state.selectedFilterIndex
            : 0;
        final filters = [
          'popular'.tr(),
          LocaleKeys.labelNew.tr(),
          'top_rated'.tr(),
          'tournaments'.tr(),
          'voice_only'.tr(),
          'following'.tr(),
        ];

        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          body: SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorManager.darkSectionGray,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ColorManager.darkBorderSoft),
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
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                // Filter chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final isSelected = index == selectedFilter;
                      return GestureDetector(
                        onTap: () =>
                            context.read<DiscoverCubit>().selectFilter(index),
                        child: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorManager.primary
                                : ColorManager.darkSurface,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(
                              color: isSelected
                                  ? ColorManager.primary
                                  : ColorManager.darkBorderSoft,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            filters[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
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
                const SizedBox(height: AppSpacing.md),
                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: streams.length,
                    itemBuilder: (context, index) {
                      final stream = streams[index];
                      return StreamCard(
                        stream: stream,
                        onTap: () => context.pushNamed(
                          RouteNames.watchStream,
                          pathParameters: {'id': stream.id},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
