class CalendarDay {
  const CalendarDay({required this.date, required this.workoutColors});

  final String date;
  final List<String> workoutColors;

  factory CalendarDay.fromJson(Map<String, dynamic> j) => CalendarDay(
        date: j['date'] as String,
        workoutColors: (j['workoutColors'] as List).cast<String>(),
      );
}

class CalendarData {
  const CalendarData({required this.year, required this.month, required this.days});

  final int year;
  final int month;
  final List<CalendarDay> days;

  factory CalendarData.fromJson(Map<String, dynamic> j) => CalendarData(
        year: j['year'] as int,
        month: j['month'] as int,
        days: (j['days'] as List)
            .map((e) => CalendarDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
