import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// VerveForge 帧性能监控器
///
/// 【性能优化 Step 3】仅在 debug / profile 模式下激活
/// 功能：
/// 1. 逐帧监控 — 超过 16ms（60fps 阈值）的慢帧实时输出警告
/// 2. 连续丢帧检测 — 连续 3 帧以上超标时输出严重警告，帮助定位卡顿段
/// 3. 定时汇总报告 — 每 10 秒输出一次统计摘要（总帧数、慢帧数、最大耗时）
///
/// 使用方式：在 main() 中调用 [FrameMonitor.start()]
class FrameMonitor {
  FrameMonitor._();

  /// 60fps 单帧预算（毫秒）
  static const int _kFrameBudgetMs = 16;

  /// 连续慢帧告警阈值
  static const int _kJankStreakThreshold = 3;

  /// 汇总报告间隔
  static const Duration _kReportInterval = Duration(seconds: 10);

  // ---- 统计状态 ----
  static int _totalFrames = 0;
  static int _slowFrames = 0;
  static int _jankStreak = 0;
  static int _maxBuildMs = 0;
  static int _maxRasterMs = 0;
  static int _maxTotalMs = 0;
  static DateTime _lastReportTime = DateTime.now();

  /// 启动帧监控（release 模式下自动跳过）
  static void start() {
    if (kReleaseMode) return;

    _lastReportTime = DateTime.now();

    SchedulerBinding.instance.addTimingsCallback(_onTimings);

    developer.log(
      '帧性能监控已启动 | 阈值: ${_kFrameBudgetMs}ms | 报告间隔: ${_kReportInterval.inSeconds}s',
      name: 'FrameMonitor',
    );
  }

  /// 帧回调处理
  static void _onTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildMs = timing.buildDuration.inMilliseconds;
      final rasterMs = timing.rasterDuration.inMilliseconds;
      final totalMs = timing.totalSpan.inMilliseconds;

      _totalFrames++;

      // 更新峰值记录
      if (buildMs > _maxBuildMs) _maxBuildMs = buildMs;
      if (rasterMs > _maxRasterMs) _maxRasterMs = rasterMs;
      if (totalMs > _maxTotalMs) _maxTotalMs = totalMs;

      if (totalMs > _kFrameBudgetMs) {
        // 慢帧
        _slowFrames++;
        _jankStreak++;

        // 单帧慢帧警告
        developer.log(
          '⚠ 慢帧: build=${buildMs}ms, raster=${rasterMs}ms, total=${totalMs}ms',
          name: 'FrameMonitor',
        );

        // 连续丢帧严重警告 — 帮助定位持续卡顿的操作段落
        if (_jankStreak >= _kJankStreakThreshold) {
          developer.log(
            '🔴 连续丢帧: 已连续 $_jankStreak 帧超标！请检查当前页面/动画',
            name: 'FrameMonitor',
          );
        }
      } else {
        // 正常帧，重置连续计数
        _jankStreak = 0;
      }
    }

    // 定时输出汇总报告
    final now = DateTime.now();
    if (now.difference(_lastReportTime) >= _kReportInterval) {
      _printReport();
      _resetCounters();
      _lastReportTime = now;
    }
  }

  /// 输出汇总报告
  static void _printReport() {
    if (_totalFrames == 0) return;

    final slowRate = (_slowFrames / _totalFrames * 100).toStringAsFixed(1);

    developer.log(
      '📊 帧性能报告 (${_kReportInterval.inSeconds}s)\n'
      '   总帧数: $_totalFrames | 慢帧: $_slowFrames ($slowRate%)\n'
      '   峰值耗时: build=${_maxBuildMs}ms, raster=${_maxRasterMs}ms, total=${_maxTotalMs}ms',
      name: 'FrameMonitor',
    );
  }

  /// 重置统计计数器（每个报告周期后）
  static void _resetCounters() {
    _totalFrames = 0;
    _slowFrames = 0;
    _jankStreak = 0;
    _maxBuildMs = 0;
    _maxRasterMs = 0;
    _maxTotalMs = 0;
  }
}
