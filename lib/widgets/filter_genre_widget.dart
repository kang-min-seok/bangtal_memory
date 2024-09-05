import 'package:flutter/material.dart';

import '../constants/constants.dart';


class GenreFilterOptions extends StatefulWidget {
  const GenreFilterOptions({super.key});
  @override
  _GenreFilterOptionsState createState() => _GenreFilterOptionsState();
}

class _GenreFilterOptionsState extends State<GenreFilterOptions> {
  static List<String> selectedGenres = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "장르 필터 선택",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: genreColorMap.keys.map((genre) {
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
    );
  }
}
