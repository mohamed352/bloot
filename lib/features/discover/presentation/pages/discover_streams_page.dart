import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:bloot/config/routes/routes.dart';
import 'package:bloot/core/constants/app_radius.dart';
import 'package:bloot/core/constants/app_spacing.dart';
import 'package:bloot/core/di/injection.dart';
import 'package:bloot/core/style/colors.dart';
import 'package:bloot/features/discover/domain/entities/discover_stream.dart';
import 'package:bloot/features/room/domain/exceptions/room_exception.dart';
import 'package:bloot/features/room/domain/repositories/room_repository.dart';
import 'package:bloot/generated/locale_keys.g.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:bloot/features/discover/presentation/cubit/discover_state.dart';
import 'package:bloot/features/discover/presentation/widgets/stream_card.dart';

class DiscoverStreamsPage extends StatefulWidget {
  const DiscoverStreamsPage({super.key});

  @override
  State<DiscoverStreamsPage> createState() => _DiscoverStreamsPageState();
}

class _DiscoverStreamsPageState extends State<DiscoverStreamsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value.trim());
  }

  Future<void> _onSearchSubmitted() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _searching) return;

    setState(() => _searching = true);
    try {
      // Joining with a code should seat the user as a player whenever the
      // room is joinable; only rooms that can't take more players (full,
      // already playing, finished) fall through to the spectator path.
      final room = await getIt<RoomRepository>().joinRoomByCode(query);
      if (!mounted) return;
      setState(() => _searching = false);
      _clearSearch();
      context.pushNamed(
        RouteNames.roomLobby,
        pathParameters: {'id': room.id},
      );
      return;
    } on RoomException catch (e) {
      if (!mounted) return;
      if (e is! RoomNotFoundException && e is! RoomFullException) {
        // Wrong password, unauthenticated, or a real join failure: surface it
        // instead of silently dropping into spectator mode.
        setState(() => _searching = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        return;
      }
    }

    final streamId = await context.read<DiscoverCubit>().findStreamByCode(
      query,
    );
    if (!mounted) return;
    setState(() => _searching = false);

    if (streamId != null) {
      _clearSearch();
      context.pushNamed(
        RouteNames.watchStream,
        pathParameters: {'id': streamId},
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('no_live_for_code'.tr())));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  List<DiscoverStream> _filterStreams(List<DiscoverStream> streams) {
    if (_query.isEmpty) return streams;
    final lowerQuery = _query.toLowerCase();
    return streams.where((stream) {
      return stream.title.toLowerCase().contains(lowerQuery) ||
          stream.host.toLowerCase().contains(lowerQuery);
    }).toList();
  }

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
        final streams = _filterStreams(
          state is DiscoverStreamsLoaded ? state.streams : <DiscoverStream>[],
        );
        final selectedFilter = state is DiscoverStreamsLoaded
            ? state.selectedFilterIndex
            : 0;
        final filters = [
          'popular'.tr(),
          LocaleKeys.labelNew.tr(),
          'top_rated'.tr(),
          'voice_only'.tr(),
          'following'.tr(),
        ];

        return Scaffold(
          backgroundColor: ColorManager.darkCanvas,
          body: SafeArea(
            child: Column(
              children: [
                // Public rooms banner
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.md,
                  ),
                  child: GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.publicRooms),
                    child: Container(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: ColorManager.darkSurface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: ColorManager.darkBorderSoft),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: ColorManager.primary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.meeting_room_rounded,
                              color: ColorManager.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'public_rooms'.tr(),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ColorManager.darkTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'join_table'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ColorManager.darkTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: ColorManager.darkTextMuted,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
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
                        suffixIcon: _searching
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorManager.darkTextMuted,
                                  ),
                                ),
                              )
                            : _query.isNotEmpty
                            ? IconButton(
                                onPressed: _clearSearch,
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: ColorManager.darkTextMuted,
                                  size: 18,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onChanged: _onSearchChanged,
                      onSubmitted: (_) => _onSearchSubmitted(),
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
                        onTap: () {
                          // The shell keeps this page alive (IndexedStack), so
                          // clear the search before navigating out to ensure a
                          // clean state when the user comes back.
                          _clearSearch();
                          context.pushNamed(
                            RouteNames.watchStream,
                            pathParameters: {'id': stream.id},
                          );
                        },
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
