import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../gym/providers/gym_provider.dart';
import '../../gym/presentation/widgets/gym_card.dart';
import '../../gym/presentation/widgets/gym_filter_bar.dart';

/// 发现页 — Tab 2（训练馆发现入口：地图视图/列表视图切换）
class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    final gymsAsync = ref.watch(nearbyGymsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.discoverTitle),
        actions: [
          // 地图/列表切换
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map_outlined),
            onPressed: () {
              if (_isMapView) {
                setState(() => _isMapView = false);
              } else {
                // 进入全屏地图页
                context.push(AppRoutes.gymMap);
              }
            },
          ),
          // 搜索
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.gymList),
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选栏
          const GymFilterBar(),
          const SizedBox(height: 8),

          // 训练馆列表
          Expanded(
            child: gymsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: context.l10n.commonError,
                actionText: context.l10n.commonRetry,
                onAction: () => ref.invalidate(nearbyGymsProvider),
              ),
              data: (gyms) {
                if (gyms.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.fitness_center_outlined,
                    title: context.l10n.commonEmpty,
                    subtitle: context.l10n.gymNearby,
                    actionText: context.l10n.gymSubmit,
                    onAction: () => context.push(AppRoutes.gymSubmit),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(nearbyGymsProvider);
                  },
                  child: ListView.builder(
                    itemCount: gyms.length,
                    itemBuilder: (context, index) {
                      final gym = gyms[index];
                      return GymCard(
                        gym: gym,
                        onTap: () => context.push(
                          '${AppRoutes.gymDetail}/${gym.id}',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.gymSubmit),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
