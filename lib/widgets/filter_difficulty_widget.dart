import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart'; // 사용 중인 별점 패키지 import

class DifficultyFilterOptions extends StatefulWidget {
  @override
  _DifficultyFilterOptionsState createState() => _DifficultyFilterOptionsState();
}

class _DifficultyFilterOptionsState extends State<DifficultyFilterOptions> {
  List<String> selectedDifficulties = [];
  double minRating = 0.0;
  double maxRating = 5.0;

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
              _buildDifficultyButton(
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
              _buildDifficultyButton(
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
              _buildDifficultyButton(
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
            ],
          ),
          const SizedBox(height: 20.0),
          // 별점 범위 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text('최소 난이도'),
                  RatingBar(
                    initialRating: minRating,
                    maxRating: 5,
                    isHalfAllowed: true,
                    onRatingChanged: (rating) {
                      setState(() {
                        minRating = rating;
                      });
                    },
                    halfFilledIcon: Icons.star_half_rounded,
                    filledIcon: Icons.star_rounded,
                    emptyIcon: Icons.star_border_rounded,
                  ),
                ],
              ),
              const Column(
                children: [
                  Text(""),
                  Text("~"),
                ],
              ),
              Column(
                children: [
                  const Text('최대 난이도'),
                  RatingBar(
                    initialRating: maxRating,
                    maxRating: 5,
                    isHalfAllowed: true,
                    onRatingChanged: (rating) {
                      setState(() {
                        maxRating = rating;
                      });
                    },
                    halfFilledIcon: Icons.star_half_rounded,
                    filledIcon: Icons.star_rounded,
                    emptyIcon: Icons.star_border_rounded,
                  ),
                ],
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

  Widget _buildDifficultyButton(String label, bool isSelected, VoidCallback onTap) {
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
