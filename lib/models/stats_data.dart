import 'dashboard_data.dart';

class MonthPoint {
  const MonthPoint({required this.month, required this.volume});

  final String month;
  final double volume;

  factory MonthPoint.fromJson(Map<String, dynamic> j) => MonthPoint(
        month: j['month'] as String,
        volume: (j['volume'] as num).toDouble(),
      );
}

class StrengthPoint {
  const StrengthPoint({required this.date, required this.topR, required this.topL});

  final String date;
  final double topR;
  final double topL;

  factory StrengthPoint.fromJson(Map<String, dynamic> j) => StrengthPoint(
        date: j['date'] as String,
        topR: (j['topR'] as num).toDouble(),
        topL: (j['topL'] as num).toDouble(),
      );
}

class FatiguePoint {
  const FatiguePoint({required this.date, required this.fatigue});

  final String date;
  final int fatigue;

  factory FatiguePoint.fromJson(Map<String, dynamic> j) => FatiguePoint(
        date: j['date'] as String,
        fatigue: j['fatigue'] as int,
      );
}

class GroupSlice {
  const GroupSlice({
    required this.groupId,
    required this.name,
    required this.color,
    required this.count,
  });

  final String groupId;
  final String name;
  final String color;
  final int count;

  factory GroupSlice.fromJson(Map<String, dynamic> j) => GroupSlice(
        groupId: j['groupId'] as String,
        name: j['name'] as String,
        color: j['color'] as String,
        count: j['count'] as int,
      );
}

class StatsData {
  const StatsData({
    required this.weeklyTonnage,
    required this.monthlyTonnage,
    required this.selectedExerciseId,
    required this.strengthProgression,
    required this.fatigueTrend,
    required this.groupDistribution,
  });

  final List<WeekPoint> weeklyTonnage;
  final List<MonthPoint> monthlyTonnage;
  final String selectedExerciseId;
  final List<StrengthPoint> strengthProgression;
  final List<FatiguePoint> fatigueTrend;
  final List<GroupSlice> groupDistribution;

  factory StatsData.fromJson(Map<String, dynamic> j) => StatsData(
        weeklyTonnage: (j['weeklyTonnage'] as List)
            .map((e) => WeekPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        monthlyTonnage: (j['monthlyTonnage'] as List)
            .map((e) => MonthPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        selectedExerciseId: j['selectedExerciseId'] as String,
        strengthProgression: (j['strengthProgression'] as List)
            .map((e) => StrengthPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        fatigueTrend: (j['fatigueTrend'] as List)
            .map((e) => FatiguePoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        groupDistribution: (j['groupDistribution'] as List)
            .map((e) => GroupSlice.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
