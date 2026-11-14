String formatClock(DateTime time) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
}

String formatLastSeen(DateTime time, {DateTime? now}) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  final reference = now ?? DateTime.now();
  final clock = '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  final isToday =
      time.year == reference.year && time.month == reference.month && time.day == reference.day;
  if (isToday) return 'de hoje às $clock';
  return 'de ${twoDigits(time.day)}/${twoDigits(time.month)} às $clock';
}
