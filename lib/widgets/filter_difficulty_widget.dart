import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // 사용 중인 별점 패키지 import

class DifficultyFilterOptions extends StatefulWidget {
  const DifficultyFilterOptions({super.key});

  @override
  _DifficultyFilterOptionsState createState() =>
      _DifficultyFilterOptionsState();
}

class _DifficultyFilterOptionsState extends State<DifficultyFilterOptions> {
  static List<String> selectedDifficulties = [];
  static double minRating = 0.0;
  static double maxRating = 5.0;

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
            "난이도 필터 선택",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          // 난이도 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildDifficultyButton(
                  'Easy',
                  selectedDifficulties.contains('Easy'),
                  () {
                    setState(() {
                      if (selectedDifficulties.contains('Easy')) {
                        selectedDifficulties.remove('Easy');
                      } else {
                        selectedDifficulties.add('Easy');
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDifficultyButton(
                  'Normal',
                  selectedDifficulties.contains('Normal'),
                  () {
                    setState(() {
                      if (selectedDifficulties.contains('Normal')) {
                        selectedDifficulties.remove('Normal');
                      } else {
                        selectedDifficulties.add('Normal');
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDifficultyButton(
                  'Hard',
                  selectedDifficulties.contains('Hard'),
                  () {
                    setState(() {
                      if (selectedDifficulties.contains('Hard')) {
                        selectedDifficulties.remove('Hard');
                      } else {
                        selectedDifficulties.add('Hard');
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          // 별점 범위 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Column(
                  children: [
                    const Text('최소 난이도'),
                    FittedBox(  // FittedBox를 사용하여 크기 조절
                      child: RatingBar.builder(
                        initialRating: minRating,
                        minRating: 0,
                        maxRating: 5,
                        itemSize: 30,  // 기본 크기 설정
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            minRating = rating;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Column(
                children: [
                  Text(""),
                  Text("~"),
                ],
              ),
              Flexible(
                child: Column(
                  children: [
                    const Text('최대 난이도'),
                    FittedBox(  // FittedBox로 크기 조절
                      child: RatingBar.builder(
                        initialRating: maxRating,
                        minRating: 0,
                        maxRating: 5,
                        itemSize: 30,  // 기본 크기 설정
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            maxRating = rating;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity, // 버튼의 너비를 부모 위젯의 최대 너비로 설정
            child: ElevatedButton(
              onPressed: () {
                // 선택된 난이도와 별점 범위를 처리하는 로직 추가
                Navigator.pop(context, {
                  'difficulties': selectedDifficulties,
                  'minRating': minRating,
                  'maxRating': maxRating,
                });
              },
              child: const Text('선택 완료'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(
      String label, bool isSelected, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface, // 선택 여부에 따라 색상 변경
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: Text(label),
    );
  }
}
