import 'package:hive/hive.dart';

part 'genre_list.g.dart';

@HiveType(typeId: 1)
class GenreList extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String genre;

  @HiveField(2)
  int colorValue;


  GenreList({
    required this.id,
    required this.genre,
    required this.colorValue,
  });

  @override
  String toString() {
    return 'EscapeRecord(id: $id, genre: $genre, color: $colorValue)';
  }
}
