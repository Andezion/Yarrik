import 'app_state.dart';
import 'session_view.dart';

class ArmBalance {
  const ArmBalance({required this.sumR, required this.sumL, required this.pctL});

  final double sumR;
  final double sumL;
  final int pctL;

  factory ArmBalance.fromJson(Map<String, dynamic> j) => ArmBalance(
        sumR: (j['sumR'] as num).toDouble(),
        sumL: (j['sumL'] as num).toDouble(),
        pctL: j['pctL'] as int,
      );
}

class RecoveryRow {
  const RecoveryRow({
    required this.groupId,
    required this.name,
    required this.color,
    required this.pct,
    required this.days,
  });

  final String groupId;
  final String name;
  final String color;
  final int pct;
  final int? days;

  factory RecoveryRow.fromJson(Map<String, dynamic> j) => RecoveryRow(
        groupId: j['groupId'] as String,
        name: j['name'] as String,
        color: j['color'] as String,
        pct: j['pct'] as int,
        days: j['days'] as int?,
      );
}

class WeekPoint {
  const WeekPoint({required this.weekStart, required this.volume});

  final String weekStart;
  final double volume;

  factory WeekPoint.fromJson(Map<String, dynamic> j) => WeekPoint(
        weekStart: j['weekStart'] as String,
        volume: (j['volume'] as num).toDouble(),
      );
}

class PrItem {
  const PrItem({
    required this.exId,
    required this.exerciseName,
    required this.arm,
    required this.weight,
    required this.date,
  });

  final String exId;
  final String exerciseName;
  final String arm;
  final double weight;
  final String date;

  factory PrItem.fromJson(Map<String, dynamic> j) => PrItem(
        exId: j['exId'] as String,
        exerciseName: j['exerciseName'] as String,
        arm: j['arm'] as String,
        weight: (j['weight'] as num).toDouble(),
        date: j['date'] as String,
      );
}

class DashboardData {
  const DashboardData({
    required this.name,
    required this.nextWorkoutIdx,
    required this.nextWorkoutName,
    required this.tourneyDate,
    required this.daysToTourney,
    required this.weekSessionsCount,
    required this.weekVolume,
    required this.weekSets,
    required this.streakWeeks,
    required this.armBalance,
    required this.recentPrs,
    required this.recovery,
    required this.bodyweight,
    required this.weeklyTonnage,
    required this.recentSessions,
  });

  final String name;
  final int nextWorkoutIdx;
  final String nextWorkoutName;
  final String tourneyDate;
  final int? daysToTourney;
  final int weekSessionsCount;
  final double weekVolume;
  final int weekSets;
  final int streakWeeks;
  final ArmBalance armBalance;
  final List<PrItem> recentPrs;
  final List<RecoveryRow> recovery;
  final List<Bodyweight> bodyweight;
  final List<WeekPoint> weeklyTonnage;
  final List<SessionView> recentSessions;

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        name: j['name'] as String,
        nextWorkoutIdx: j['nextWorkoutIdx'] as int,
        nextWorkoutName: j['nextWorkoutName'] as String,
        tourneyDate: (j['tourneyDate'] as String?) ?? '',
        daysToTourney: j['daysToTourney'] as int?,
        weekSessionsCount: j['weekSessionsCount'] as int,
        weekVolume: (j['weekVolume'] as num).toDouble(),
        weekSets: j['weekSets'] as int,
        streakWeeks: j['streakWeeks'] as int,
        armBalance: ArmBalance.fromJson(j['armBalance'] as Map<String, dynamic>),
        recentPrs: (j['recentPrs'] as List)
            .map((e) => PrItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        recovery: (j['recovery'] as List)
            .map((e) => RecoveryRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        bodyweight: (j['bodyweight'] as List)
            .map((e) => Bodyweight.fromJson(e as Map<String, dynamic>))
            .toList(),
        weeklyTonnage: (j['weeklyTonnage'] as List)
            .map((e) => WeekPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        recentSessions: (j['recentSessions'] as List)
            .map((e) => SessionView.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
