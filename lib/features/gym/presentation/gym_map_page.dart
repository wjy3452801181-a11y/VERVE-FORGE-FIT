import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/gym_model.dart';
import '../providers/gym_provider.dart';
import 'widgets/gym_card.dart';
import 'widgets/gym_filter_bar.dart';

/// 训练馆地图页 — 高德地图暂时替换为占位（SDK 无模拟器 arm64 支持）
class GymMapPage extends ConsumerStatefulWidget {
  const GymMapPage({super.key});

  @override
  ConsumerState<GymMapPage> createState() => _GymMapPageState();
}

class _GymMapPageState extends ConsumerState<GymMapPage> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gymsAsync = ref.watch(nearbyGymsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 地图占位
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 64, color: Color(0xFF888888)),
                SizedBox(height: 12),
                Text('地图功能需要真机运行',
                    style: TextStyle(color: Color(0xFF888888))),
              ],
            ),
          ),

          // 顶部安全区 + 筛选栏
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: const GymFilterBar(),
          ),

          // 底部可拉起列表
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.15,
            minChildSize: 0.1,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            context.l10n.gymNearby,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.list, size: 20),
                            onPressed: () {
                              context.push(AppRoutes.gymList);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: gymsAsync.when(
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (e, _) => EmptyStateWidget(
                          icon: Icons.error_outline,
                          title: context.l10n.commonError,
                          actionText: context.l10n.commonRetry,
                          onAction: () => ref.invalidate(nearbyGymsProvider),
                        ),
                        data: (gyms) {
                          if (gyms.isEmpty) {
                            return EmptyStateWidget(
                              icon: Icons.location_searching,
                              title: context.l10n.commonEmpty,
                            );
                          }
                          return ListView.builder(
                            controller: scrollController,
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
