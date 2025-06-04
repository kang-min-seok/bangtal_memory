import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../hive/genre_list.dart';          // 모델
import '../hive/genre_service.dart';
import '../pages/genre_manage_page.dart';   // colors 맵 재사용


class GenreFilterOptions extends StatefulWidget {
  const GenreFilterOptions({super.key});
  @override
  _GenreFilterOptionsState createState() => _GenreFilterOptionsState();
}

class _GenreFilterOptionsState extends State<GenreFilterOptions> {
  static List<String> selectedGenres = [];
  late final Box<GenreList> _genreBox;

  @override
  void initState() {
    super.initState();
    _genreBox = Hive.box<GenreList>('genreLists');
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, {'selectedGenres': selectedGenres});
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('장르 필터 선택',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary, // 글자색 = primary
                            padding: EdgeInsets.zero,              // 불필요한 여백 최소화 (선택)
                            minimumSize: Size(0, 0),               // splash 영역 축소 (선택)
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GenreManagePage()),
                            );
                            setState(() {});   // 변경사항 반영
                          },
                          child: const Text('편집'),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  ValueListenableBuilder(
                    valueListenable: _genreBox.listenable(),
                    builder: (context, Box<GenreList> box, _) {
                      final genres = box.values.toList()
                        ..sort((a, b) => a.id.compareTo(b.id));

                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: genres.map((g) {
                          final String genre = g.genre;
                          return ChoiceChip(
                            label: Text(genre),
                            selected: selectedGenres.contains(genre),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedGenres.add(genre);
                                } else {
                                  selectedGenres.remove(genre);
                                }
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(
                                color: selectedGenres.contains(genre)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            backgroundColor: Colors.transparent,
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.19),
                            labelStyle: TextStyle(
                              color: selectedGenres.contains(genre)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onBackground,
                            ),
                            showCheckmark: false,
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'selectedGenres':selectedGenres,
                        });
                      },
                      child: const Text('선택 완료'),
                    ),
                  ),
                ],
              ),
            ),
        ),
    );
  }
}
