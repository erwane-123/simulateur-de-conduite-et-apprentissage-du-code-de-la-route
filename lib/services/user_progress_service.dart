import 'package:code_route_flutter/services/firebase/firestore_service.dart';
import 'package:code_route_flutter/services/firebase/auto_ecole_service.dart';
import 'package:code_route_flutter/services/gamification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermitStats {
  final int testsCount;
  final int successRate;
  final int mistakesCount;
  final int streakCount;
  final int xp;
  final int level;

  const PermitStats({
    required this.testsCount,
    required this.successRate,
    required this.mistakesCount,
    required this.streakCount,
    required this.xp,
    required this.level,
  });

  factory PermitStats.fromMap(Map<String, dynamic> map) {
    final xp = _readInt(map['xp']);
    return PermitStats(
      testsCount: _readInt(map['testsCount']),
      successRate: _readInt(map['successRate']),
      mistakesCount: _readInt(map['mistakesCount']),
      streakCount: _readInt(map['streakCount']),
      xp: xp,
      level: GamificationService.levelForXp(xp),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testsCount': testsCount,
      'successRate': successRate,
      'mistakesCount': mistakesCount,
      'streakCount': streakCount,
      'xp': xp,
      'level': level,
    };
  }

  static int _readInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}

class UserProgressService {
  static const String selectedPermitKey = 'selected_permis_category';
  final FirestoreService _firestoreService = FirestoreService();
  final AutoEcoleService _autoEcoleService = AutoEcoleService();
  final GamificationService _gamificationService = GamificationService();

  Future<String> getSelectedPermitCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedPermitKey) ?? 'B';
  }

  Future<void> setSelectedPermitCode(String permitCode) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedPermit = permitCode.toUpperCase();
    await prefs.setString(selectedPermitKey, normalizedPermit);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.saveSelectedPermit(
        uid: user.uid,
        permitCode: normalizedPermit,
      );
    } catch (_) {
      // The local selection remains available if Firestore is unreachable.
    }
  }

  Future<PermitStats> getStatsForPermit([String? permitCode]) async {
    final prefs = await SharedPreferences.getInstance();
    final permit = (permitCode ?? await getSelectedPermitCode()).toUpperCase();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final remoteStats = await _firestoreService.getUserPermitStats(
          uid: user.uid,
          permitCode: permit,
        );

        if (remoteStats != null) {
          final stats = PermitStats.fromMap(remoteStats);
          await _cacheStatsForPermit(
            prefs: prefs,
            permit: permit,
            stats: stats,
          );
          return stats;
        }
      } catch (_) {
        // Firestore can be unavailable offline; keep using the local cache.
      }
    }

    return _localStatsForPermit(prefs, permit);
  }

  PermitStats _localStatsForPermit(SharedPreferences prefs, String permit) {
    return PermitStats(
      testsCount: prefs.getInt(_key('stat_tests_count', permit)) ??
          prefs.getInt('stat_tests_count') ??
          0,
      successRate: prefs.getInt(_key('stat_success_rate', permit)) ??
          prefs.getInt('stat_success_rate') ??
          0,
      mistakesCount: prefs.getInt(_key('stat_mistakes_count', permit)) ??
          prefs.getInt('stat_mistakes_count') ??
          0,
      streakCount: prefs.getInt(_key('stat_streak_count', permit)) ??
          prefs.getInt('stat_streak_count') ??
          0,
      xp: prefs.getInt(_key('user_xp', permit)) ?? prefs.getInt('user_xp') ?? 0,
      level: GamificationService.levelForXp(
        prefs.getInt(_key('user_xp', permit)) ?? prefs.getInt('user_xp') ?? 0,
      ),
    );
  }

  Future<GamificationReward?> recordTestResult({
    required int score,
    required int total,
    required bool passed,
    required String permitCode,
    String? themeId,
  }) async {
    if (total <= 0) return null;
    final prefs = await SharedPreferences.getInstance();
    final permit = permitCode.toUpperCase();
    final reward = await _gamificationService.recordSession(
      score: score,
      total: total,
      passed: passed,
      themeId: themeId,
    );
    final currentStats = await getStatsForPermit(permit);

    final int currentTests = currentStats.testsCount;
    final int currentRate = currentStats.successRate;
    final int currentMistakes = currentStats.mistakesCount;
    final int currentXp = currentStats.xp;
    final int previousLevel = GamificationService.levelForXp(currentXp);

    final int percentage = ((score / total) * 100).round();
    final int updatedTests = currentTests + 1;
    final int updatedRate =
        ((currentRate * currentTests) + percentage) ~/ updatedTests;
    final int updatedMistakes = currentMistakes + (total - score);

    final int xpGain = (score * 10) + (passed ? 50 : 0);
    final int updatedXp = currentXp + xpGain;
    final int updatedLevel = GamificationService.levelForXp(updatedXp);

    final int updatedStreak = await _calculateStreakForPermit(permit);

    final updatedStats = PermitStats(
      testsCount: updatedTests,
      successRate: updatedRate,
      mistakesCount: updatedMistakes,
      streakCount: updatedStreak,
      xp: updatedXp,
      level: updatedLevel,
    );

    await _cacheStatsForPermit(
      prefs: prefs,
      permit: permit,
      stats: updatedStats,
    );

    if (themeId != null && themeId.isNotEmpty) {
      await updateThemeProgressWithScore(
        themeId: themeId,
        permitCode: permit,
        scoreRatio: score / total,
      );
    }

    final selectedPermit = await getSelectedPermitCode();
    if (selectedPermit.toUpperCase() == permit) {
      await _syncLegacyKeys(
        tests: updatedTests,
        rate: updatedRate,
        mistakes: updatedMistakes,
        streak: updatedStreak,
        xp: updatedXp,
        level: updatedLevel,
      );
    }

    if (updatedLevel > previousLevel) {
      await prefs.setInt('last_level_up', updatedLevel);
    }

    await _saveStatsForCurrentUser(
      permitCode: permit,
      stats: updatedStats,
    );

    await _syncAutoEcoleStudentProgress(updatedStats);
    return reward;
  }

  Future<double> getThemeProgress({
    required String themeId,
    String? permitCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final permit = (permitCode ?? await getSelectedPermitCode()).toUpperCase();
    return prefs.getDouble(_themeProgressKey(permit, themeId)) ??
        prefs.getDouble(_legacyThemeKey(themeId)) ??
        0.0;
  }

  Future<Map<String, double>> getThemeProgressMap(
    List<String> themeIds, {
    String? permitCode,
  }) async {
    final map = <String, double>{};
    for (final id in themeIds) {
      map[id] = await getThemeProgress(themeId: id, permitCode: permitCode);
    }
    return map;
  }

  Future<void> updateThemeProgressWithScore({
    required String themeId,
    required String permitCode,
    required double scoreRatio,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _themeProgressKey(permitCode.toUpperCase(), themeId);
    final currentProgress = prefs.getDouble(key) ??
        prefs.getDouble(_legacyThemeKey(themeId)) ??
        0.0;
    final updated = scoreRatio.clamp(0.0, 1.0) > currentProgress
        ? scoreRatio.clamp(0.0, 1.0)
        : currentProgress;
    await prefs.setDouble(key, updated);

    final selectedPermit = await getSelectedPermitCode();
    if (selectedPermit.toUpperCase() == permitCode.toUpperCase()) {
      await prefs.setDouble(_legacyThemeKey(themeId), updated);
    }

    await _saveThemeProgressForCurrentUser(
      permitCode: permitCode,
      themeId: themeId,
      progress: updated,
    );
  }

  Future<void> _cacheStatsForPermit({
    required SharedPreferences prefs,
    required String permit,
    required PermitStats stats,
  }) async {
    await prefs.setInt(_key('stat_tests_count', permit), stats.testsCount);
    await prefs.setInt(_key('stat_success_rate', permit), stats.successRate);
    await prefs.setInt(
        _key('stat_mistakes_count', permit), stats.mistakesCount);
    await prefs.setInt(_key('stat_streak_count', permit), stats.streakCount);
    await prefs.setInt(_key('user_xp', permit), stats.xp);
    await prefs.setInt(_key('user_level', permit), stats.level);
  }

  Future<void> _saveStatsForCurrentUser({
    required String permitCode,
    required PermitStats stats,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.saveUserPermitStats(
        uid: user.uid,
        permitCode: permitCode,
        stats: stats.toMap(),
        displayName: user.displayName ?? user.email?.split('@').first,
      );
    } catch (_) {
      // Keep the local cache intact if the network is unavailable.
    }
  }

  Future<void> _syncAutoEcoleStudentProgress(PermitStats stats) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _autoEcoleService.syncStudentProgress(
        uid: user.uid,
        stats: stats.toMap(),
      );
    } catch (_) {
      // Auto-ecole dashboards can catch up on the next successful save.
    }
  }

  Future<void> _saveThemeProgressForCurrentUser({
    required String permitCode,
    required String themeId,
    required double progress,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.saveUserThemeProgress(
        uid: user.uid,
        permitCode: permitCode,
        themeId: themeId,
        progress: progress,
      );
    } catch (_) {
      // Local progress remains available even when Firestore cannot be reached.
    }
  }

  Future<int> _calculateStreakForPermit(String permit) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key('stat_last_day', permit);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final raw = prefs.getString(key);
    final current = prefs.getInt(_key('stat_streak_count', permit)) ?? 0;

    int nextStreak;
    if (raw == null) {
      nextStreak = 1;
    } else {
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) {
        nextStreak = 1;
      } else {
        final normalizedLast = DateTime(parsed.year, parsed.month, parsed.day);
        final diffDays = normalizedToday.difference(normalizedLast).inDays;
        if (diffDays <= 0) {
          nextStreak = current == 0 ? 1 : current;
        } else if (diffDays == 1) {
          nextStreak = current + 1;
        } else {
          nextStreak = 1;
        }
      }
    }

    await prefs.setString(key, normalizedToday.toIso8601String());
    return nextStreak;
  }

  Future<void> _syncLegacyKeys({
    required int tests,
    required int rate,
    required int mistakes,
    required int streak,
    required int xp,
    required int level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stat_tests_count', tests);
    await prefs.setInt('stat_success_rate', rate);
    await prefs.setInt('stat_mistakes_count', mistakes);
    await prefs.setInt('stat_streak_count', streak);
    await prefs.setInt('user_xp', xp);
    await prefs.setInt('user_level', level);
  }

  String _key(String base, String permitCode) =>
      '${base}_${permitCode.toUpperCase()}';

  String _themeProgressKey(String permitCode, String themeId) =>
      'prog_${permitCode.toUpperCase()}_$themeId';

  String _legacyThemeKey(String themeId) {
    switch (themeId) {
      case '1':
        return 'prog_circulation';
      case '2':
        return 'prog_conductor';
      case '3':
        return 'prog_road';
      default:
        return 'prog_theme_$themeId';
    }
  }
}
