/// 运动专项成绩数据模型 — 根据 sportType 使用不同的 Metrics 子类
library;

/// HYROX 8 站成绩
class HyroxMetrics {
  /// 8 站标准名称
  static const List<String> stationNames = [
    'SkiErg',
    'Sled Push',
    'Sled Pull',
    'Burpee Broad Jump',
    'Row',
    'Farmers Carry',
    'Sandbag Lunges',
    'Wall Balls',
  ];

  final List<HyroxStation> stations;
  final int? totalTimeSec;

  const HyroxMetrics({
    this.stations = const [],
    this.totalTimeSec,
  });

  factory HyroxMetrics.fromJson(Map<String, dynamic> json) {
    final stationsList = (json['stations'] as List<dynamic>?)
            ?.map((e) => HyroxStation.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return HyroxMetrics(
      stations: stationsList,
      totalTimeSec: json['total_time_sec'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stations': stations.map((s) => s.toJson()).toList(),
      'total_time_sec': totalTimeSec,
    };
  }

  /// 总成绩显示（如 "1:10:23"）
  String get totalTimeDisplay {
    if (totalTimeSec == null) return '--:--';
    final hours = totalTimeSec! ~/ 3600;
    final minutes = (totalTimeSec! % 3600) ~/ 60;
    final seconds = totalTimeSec! % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class HyroxStation {
  final String name;
  final int? timeSec;

  const HyroxStation({required this.name, this.timeSec});

  factory HyroxStation.fromJson(Map<String, dynamic> json) {
    return HyroxStation(
      name: json['name'] as String,
      timeSec: json['time_sec'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time_sec': timeSec,
    };
  }

  /// 分站用时显示（如 "2:30"）
  String get timeDisplay {
    if (timeSec == null) return '--:--';
    final minutes = timeSec! ~/ 60;
    final seconds = timeSec! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// CrossFit WOD 成绩
class CrossFitMetrics {
  final String? wodName;
  final String? wodType; // for_time / amrap / emom
  final String? score;
  final List<String> movements;

  const CrossFitMetrics({
    this.wodName,
    this.wodType,
    this.score,
    this.movements = const [],
  });

  factory CrossFitMetrics.fromJson(Map<String, dynamic> json) {
    return CrossFitMetrics(
      wodName: json['wod_name'] as String?,
      wodType: json['wod_type'] as String?,
      score: json['score'] as String?,
      movements: (json['movements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wod_name': wodName,
      'wod_type': wodType,
      'score': score,
      'movements': movements,
    };
  }

  /// WOD 类型显示名
  static const Map<String, String> wodTypeLabels = {
    'for_time': 'For Time',
    'amrap': 'AMRAP',
    'emom': 'EMOM',
  };

  String get wodTypeDisplay => wodTypeLabels[wodType] ?? wodType ?? '';
}

/// 瑜伽 / 普拉提课程成绩
class YogaPilatesMetrics {
  final String? className;
  final List<String> focusAreas;
  final String? difficulty; // beginner / intermediate / advanced

  const YogaPilatesMetrics({
    this.className,
    this.focusAreas = const [],
    this.difficulty,
  });

  static const List<String> allFocusAreas = [
    'flexibility',
    'core',
    'balance',
    'strength',
    'meditation',
  ];

  static const Map<String, String> focusAreaLabels = {
    'flexibility': '柔韧性',
    'core': '核心',
    'balance': '平衡',
    'strength': '力量',
    'meditation': '冥想',
  };

  static const Map<String, String> difficultyLabels = {
    'beginner': '初级',
    'intermediate': '中级',
    'advanced': '高级',
  };

  factory YogaPilatesMetrics.fromJson(Map<String, dynamic> json) {
    return YogaPilatesMetrics(
      className: json['class_name'] as String?,
      focusAreas: (json['focus_areas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      difficulty: json['difficulty'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_name': className,
      'focus_areas': focusAreas,
      'difficulty': difficulty,
    };
  }

  String get difficultyDisplay =>
      difficultyLabels[difficulty] ?? difficulty ?? '';
}

/// 跑步成绩
class RunningMetrics {
  final double? distanceKm;
  final double? paceMinPerKm;
  final int? elevationM;

  const RunningMetrics({
    this.distanceKm,
    this.paceMinPerKm,
    this.elevationM,
  });

  factory RunningMetrics.fromJson(Map<String, dynamic> json) {
    return RunningMetrics(
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      paceMinPerKm: (json['pace_min_per_km'] as num?)?.toDouble(),
      elevationM: json['elevation_m'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance_km': distanceKm,
      'pace_min_per_km': paceMinPerKm,
      'elevation_m': elevationM,
    };
  }

  /// 配速显示（如 "5'30\""）
  String get paceDisplay {
    if (paceMinPerKm == null) return '--';
    final totalSec = (paceMinPerKm! * 60).round();
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }
}

/// 工厂方法：根据 sportType 自动构造对应 metrics 对象
class WorkoutMetrics {
  WorkoutMetrics._();

  static dynamic fromSportType(String sportType, Map<String, dynamic> json) {
    switch (sportType) {
      case 'hyrox':
        return HyroxMetrics.fromJson(json);
      case 'crossfit':
        return CrossFitMetrics.fromJson(json);
      case 'yoga':
      case 'pilates':
        return YogaPilatesMetrics.fromJson(json);
      case 'running':
        return RunningMetrics.fromJson(json);
      default:
        return json;
    }
  }

  /// 根据 sportType 和 metrics JSON 生成摘要文字
  static String displaySummary(String sportType, Map<String, dynamic> json) {
    if (json.isEmpty) return '';
    switch (sportType) {
      case 'hyrox':
        final m = HyroxMetrics.fromJson(json);
        return m.totalTimeDisplay;
      case 'crossfit':
        final m = CrossFitMetrics.fromJson(json);
        final parts = <String>[];
        if (m.wodName != null && m.wodName!.isNotEmpty) parts.add(m.wodName!);
        if (m.score != null && m.score!.isNotEmpty) parts.add(m.score!);
        return parts.join(' ');
      case 'yoga':
      case 'pilates':
        final m = YogaPilatesMetrics.fromJson(json);
        return m.className ?? '';
      case 'running':
        final m = RunningMetrics.fromJson(json);
        final parts = <String>[];
        if (m.distanceKm != null) parts.add('${m.distanceKm}km');
        if (m.paceMinPerKm != null) parts.add(m.paceDisplay);
        return parts.join(' ');
      default:
        return '';
    }
  }
}
