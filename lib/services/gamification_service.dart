import 'package:hive/hive.dart';

class GamificationState {
  final int totalXp;
  final int level;
  final int streak;
  final List<String> badges;
  final Map<String, double> progress;
  final DateTime? lastActivityDay;

  const GamificationState({
    required this.totalXp,
    required this.level,
    required this.streak,
    required this.badges,
    required this.progress,
    this.lastActivityDay,
  });

  int get xpInLevel => totalXp - GamificationService.levelStartXp(level);
  int get xpForNextLevel => GamificationService.xpForNextLevel(level);
  double get levelProgress {
    if (level >= GamificationService.maxLevel) return 1.0;
    return (xpInLevel / xpForNextLevel).clamp(0.0, 1.0);
  }

  factory GamificationState.empty() {
    return const GamificationState(
      totalXp: 0,
      level: 1,
      streak: 0,
      badges: [],
      progress: {},
    );
  }
}

class GamificationReward {
  final GamificationState previous;
  final GamificationState current;
  final int xpGained;
  final List<String> newBadges;
  final bool leveledUp;

  const GamificationReward({
    required this.previous,
    required this.current,
    required this.xpGained,
    required this.newBadges,
    required this.leveledUp,
  });
}

class GamificationService {
  static const String boxName = 'gamification';
  static const int maxLevel = 5;

  static const String _totalXpKey = 'total_xp';
  static const String _levelKey = 'level';
  static const String _streakKey = 'streak';
  static const String _badgesKey = 'badges';
  static const String _lastActivityKey = 'last_activity_day';
  static const String _progressKey = 'progress';

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(boxName)) {
      return Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Future<GamificationState> load() async {
    final box = await _box;
    return _stateFromBox(box);
  }

  Future<GamificationReward> recordSession({
    required int score,
    required int total,
    required bool passed,
    String? themeId,
  }) async {
    final box = await _box;
    final previous = _stateFromBox(box);
    final xpGained = _xpForSession(score: score, passed: passed);
    final totalXp = previous.totalXp + xpGained;
    final level = levelForXp(totalXp);
    final streak = _nextStreak(previous);
    final progress = Map<String, double>.from(previous.progress);

    if (themeId != null && themeId.isNotEmpty && total > 0) {
      final ratio = (score / total).clamp(0.0, 1.0);
      final current = progress[themeId] ?? 0.0;
      if (ratio > current) progress[themeId] = ratio;
    }

    final badges = {...previous.badges};
    if (total > 0 && score == total) badges.add('perfect');
    if (passed) badges.add('first_pass');
    if (streak >= 3) badges.add('streak_3');
    if (streak >= 7) badges.add('streak_7');
    if (level >= 5) badges.add('level_5');
    if (totalXp >= 1000) badges.add('xp_1000');

    final newBadges =
        badges.where((badge) => !previous.badges.contains(badge)).toList();
    final today = _today();

    await box.put(_totalXpKey, totalXp);
    await box.put(_levelKey, level);
    await box.put(_streakKey, streak);
    await box.put(_badgesKey, badges.toList());
    await box.put(_lastActivityKey, today.toIso8601String());
    await box.put(_progressKey, progress);

    final current = GamificationState(
      totalXp: totalXp,
      level: level,
      streak: streak,
      badges: badges.toList(),
      progress: progress,
      lastActivityDay: today,
    );

    return GamificationReward(
      previous: previous,
      current: current,
      xpGained: xpGained,
      newBadges: newBadges,
      leveledUp: level > previous.level,
    );
  }

  int _xpForSession({required int score, required bool passed}) {
    return (score * 10) + (passed ? 50 : 0);
  }

  static int levelForXp(int xp) {
    if (xp >= 1000) return 5;
    if (xp >= 600) return 4;
    if (xp >= 300) return 3;
    if (xp >= 100) return 2;
    return 1;
  }

  static int levelStartXp(int level) {
    switch (level) {
      case 2:
        return 100;
      case 3:
        return 300;
      case 4:
        return 600;
      case 5:
        return 1000;
      default:
        return 0;
    }
  }

  static int nextLevelStartXp(int level) {
    switch (level) {
      case 1:
        return 100;
      case 2:
        return 300;
      case 3:
        return 600;
      case 4:
        return 1000;
      default:
        return 1000;
    }
  }

  static int xpForNextLevel(int level) {
    if (level >= maxLevel) return 0;
    return nextLevelStartXp(level) - levelStartXp(level);
  }

  int _nextStreak(GamificationState previous) {
    final last = previous.lastActivityDay;
    if (last == null) return 1;

    final diff = _today().difference(_normalize(last)).inDays;
    if (diff <= 0) return previous.streak == 0 ? 1 : previous.streak;
    if (diff == 1) return previous.streak + 1;
    return 1;
  }

  GamificationState _stateFromBox(Box box) {
    final rawBadges = box.get(_badgesKey, defaultValue: <String>[]);
    final rawProgress = box.get(_progressKey, defaultValue: <String, double>{});
    final rawLastActivity = box.get(_lastActivityKey);
    final totalXp = _readInt(box.get(_totalXpKey));

    return GamificationState(
      totalXp: totalXp,
      level: levelForXp(totalXp),
      streak: _readInt(box.get(_streakKey)),
      badges: rawBadges is List
          ? rawBadges.map((item) => item.toString()).toList()
          : <String>[],
      progress: rawProgress is Map
          ? rawProgress.map(
              (key, value) => MapEntry(key.toString(), _readDouble(value)),
            )
          : <String, double>{},
      lastActivityDay:
          rawLastActivity is String ? DateTime.tryParse(rawLastActivity) : null,
    );
  }

  DateTime _today() {
    return _normalize(DateTime.now());
  }

  DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int _readInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  double _readDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
