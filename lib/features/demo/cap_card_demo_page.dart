import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/cap_card.dart';

/// CapCard 卡片预览演示页
/// 展示 Step / Quote / Capability 三种卡片类型
class CapCardDemoPage extends StatelessWidget {
  const CapCardDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Cap Card Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Step Cards
            _sectionLabel(context, 'STEP CARD 步骤卡'),
            CapCard(
              type: CapCardType.step,
              stepIndex: 1,
              totalSteps: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '热身阶段',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '完成 5 分钟动态拉伸，包括股四头肌、腿筋和臀部的活动度练习。保持心率在 Zone 1 区间。',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            CapCard(
              type: CapCardType.step,
              stepIndex: 3,
              totalSteps: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '高强度间歇',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '8 组 Tabata 协议：20秒全力输出 + 10秒休息。运动包括波比跳、壶铃摆荡和 Box Jump。',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Section: Quote Card
            _sectionLabel(context, 'QUOTE CARD 引用卡'),
            CapCard(
              type: CapCardType.quote,
              quoteAuthor: 'HYROX World Championship',
              child: Text(
                'The body achieves what the mind believes. 每一次训练都是对自己极限的一次重新定义。',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section: Capability Cards
            _sectionLabel(context, 'CAPABILITY CARD 能力卡'),
            CapCard(
              type: CapCardType.capability,
              icon: Icons.bolt,
              title: '爆发力训练',
              child: Text(
                '通过奥林匹克举重衍生动作和增强式训练提升你的速度-力量输出。系统化的周期编排确保安全且持续的进步。',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            CapCard(
              type: CapCardType.capability,
              icon: Icons.favorite,
              title: '心肺耐力',
              child: Text(
                '结合 Zone 2 有氧基础训练和 VO2max 间歇，全面提升你的有氧系统效率。支持 Apple HealthKit 实时数据同步。',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            CapCard(
              type: CapCardType.capability,
              icon: Icons.fitness_center,
              title: '功能性力量',
              child: Text(
                '以复合动作为核心的力量体系——深蹲、硬拉、卧推、引体向上。每个训练计划都根据你的体能水平动态调整。',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}
