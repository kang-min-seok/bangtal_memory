/// services/genre_service.dart
///
/// 단순 헬퍼가 아닌 “앱 전역에서 장르 데이터를 제공·관리”하는 싱글턴.
///
/// 사용 예)
///   await GenreService.init();                // main() 초기화
///   final genres = GenreService.genres;       // ['공포', …]
///   final color = GenreService.colors['공포']; // Color(...)
///   await GenreService.addGenre('추가', Colors.lime);

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/constants.dart';
import '../hive/genre_list.dart';

class GenreService {
  // ──────────────────────────────────────────────────────────────
  static const _boxName  = 'genreLists';            // <GenreList> Box
  static late Box<GenreList> _box;                  // 최초 1 회만 open

  /// main.dart 에서 runApp 전에 호출
  static Future<void> init() async {
    // Hive.initFlutter()·Adapter 등록은 main() 측에서 한 번만!
    _box = Hive.box<GenreList>(_boxName);

    // 앱 첫 실행 또는 배열→Hive 마이그레이션 직후
    if (_box.isEmpty) {
      for (var i = 0; i < defaultGenreList.length; i++) {
        final name  = defaultGenreList[i];
        final color = defaultGenreColorMap[name]!;
        await _box.add(GenreList(id: i, genre: name, colorValue: color.value));
      }
    }
  }

  // ─────────────────── getters ───────────────────
  /// id 오름차순 정렬된 장르 문자열 목록
  static List<String> get genres =>
      _box.values.toList()
          .map((e) => e.genre)
          .toList(growable: false);

  /// {장르: Color} 맵
  static Map<String, Color> get colors => {
    for (final g in _box.values) g.genre: Color(g.colorValue),
  };

  // ────────────────── mutators ──────────────────
  /// 새 장르 추가 (이미 존재하면 no-op)
  static Future<void> addGenre(String name, Color color) async {
    // 중복 방지
    if (_box.values.any((g) => g.genre == name)) return;

    final nextId = _box.values.isEmpty
        ? 0
        : (_box.values.map((g) => g.id).reduce((a, b) => a > b ? a : b) + 1);

    await _box.add(
      GenreList(id: nextId, genre: name, colorValue: color.value),
    );
  }

  /// 특정 장르의 색상만 변경
  static Future<void> updateColor(String name, Color newColor) async {
    final target =
    _box.values.firstWhere((g) => g.genre == name, orElse: () => throw Exception('장르 없음'));
    target.colorValue = newColor.value;
    await target.save();
  }

  /// 장르 삭제 (필요 시)
  static Future<void> removeGenre(String name) async {
    final targetKey =
    _box.keys.firstWhere((k) => _box.get(k)!.genre == name, orElse: () => null);
    if (targetKey != null) await _box.delete(targetKey);
  }
}
