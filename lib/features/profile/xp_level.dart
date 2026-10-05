/// مستوى اللاعب من نقاط XP (كل 100 نقطة = مستوى)
int xpLevel(int xp) => xp ~/ 100 + 1;
double xpProgress(int xp) => (xp % 100) / 100;

/// تاريخ اليوم بتوقيت بغداد (UTC+3) بصيغة yyyy-MM-dd
String baghdadToday([DateTime? now]) {
  final d = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 3));
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
