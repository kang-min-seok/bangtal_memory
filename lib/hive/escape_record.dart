import 'package:hive/hive.dart';

part 'escape_record.g.dart';

@HiveType(typeId: 0)
class EscapeRecord extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String date;

  @HiveField(2)
  String storeName;

  @HiveField(3)
  String themeName;

  @HiveField(4)
  String difficulty;

  @HiveField(5)
  String satisfaction;

  @HiveField(6)
  String genre;

  @HiveField(7)
  String region;

  @HiveField(8)
  String? review;

  @HiveField(9)
  List<String>? imagePaths;

  EscapeRecord({
    required this.id,
    required this.date,
    required this.storeName,
    required this.themeName,
    required this.difficulty,
    required this.satisfaction,
    required this.genre,
    required this.region,
    this.review,
    List<String>? imagePaths,
  }): imagePaths = imagePaths ?? [];

  List<String> get safeImages => imagePaths ?? [];
  String get safeReview => review ?? '';

  @override
  String toString() {
    return 'EscapeRecord(id: $id, date: $date, storeName: $storeName, themeName: $themeName, difficulty: $difficulty, satisfaction: $satisfaction, genre: $genre, region: $region, review:$review, imagePaths:$imagePaths)';
  }
}
