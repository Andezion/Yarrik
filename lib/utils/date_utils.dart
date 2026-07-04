library;

const monShort = [
  'янв', 'фев', 'мар', 'апр', 'май', 'июн',
  'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
];

const monFull = [
  'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
  'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
];

const dowShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

DateTime parseIso(String s) {
  final p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String _pad2(int n) => n < 10 ? '0$n' : '$n';

String formatIso(DateTime d) => '${d.year}-${_pad2(d.month)}-${_pad2(d.day)}';

String todayIso() => formatIso(DateTime.now());

String fmtShort(String iso) {
  final d = parseIso(iso);
  return '${d.day} ${monShort[d.month - 1]}';
}

String fmtLong(String iso) {
  final d = parseIso(iso);
  return '${d.day} ${monShort[d.month - 1]} ${d.year}';
}

String fmtVol(double v) {
  if (v >= 1000) {
    return '${(v / 1000).toStringAsFixed(1)} т';
  }
  return '${v.round()} кг';
}

int daysBetween(String aIso, String bIso) {
  final a = parseIso(aIso);
  final b = parseIso(bIso);
  return b.difference(a).inDays;
}

String weekKey(DateTime d) {
  final dow = (d.weekday - 1) % 7; 
  final monday = d.subtract(Duration(days: dow));
  return formatIso(monday);
}

int clampInt(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);
