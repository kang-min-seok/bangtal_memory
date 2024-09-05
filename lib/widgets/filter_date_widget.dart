import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DateFilterOptions extends StatefulWidget {
  const DateFilterOptions({super.key});
  @override
  _DateFilterOptionsState createState() => _DateFilterOptionsState();
}

class _DateFilterOptionsState extends State<DateFilterOptions> {
  static DateTime? startDate;
  static DateTime? endDate;
  static bool isDateUnknown = false;

  // CupertinoDatePicker로 날짜 선택 후 버튼 색상 업데이트
  Future<void> _selectDate(
      BuildContext context, bool isStart, DateTime? initialDate) async {
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = initialDate ?? DateTime.now(); // 초기값 설정
        return Container(
          height: 250,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  onDateTimeChanged: (DateTime date) {
                    selectedDate = date;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedDate);
                },
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  bool _isCurrentYear() {
    final now = DateTime.now();
    return startDate == DateTime(now.year, 1, 1) &&
        endDate == DateTime(now.year, 12, 31);
  }

  bool _isLastYear() {
    final now = DateTime.now();
    return startDate == DateTime(now.year - 1, 1, 1) &&
        endDate == DateTime(now.year - 1, 12, 31);
  }

  bool _isTwoYearsAgo() {
    final now = DateTime.now();
    return startDate == DateTime(now.year - 2, 1, 1) &&
        endDate == DateTime(now.year - 2, 12, 31);
  }

  void _toggleYearRange({required int year}) {
    final selectedStartDate = DateTime(year, 1, 1);
    final selectedEndDate = DateTime(year, 12, 31);

    // 동일한 연도를 다시 선택하면 필터를 초기화
    if (startDate == selectedStartDate && endDate == selectedEndDate) {
      setState(() {
        startDate = null;
        endDate = null;
      });
    } else {
      setState(() {
        startDate = selectedStartDate;
        endDate = selectedEndDate;
      });
    }
  }

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
            "날짜 필터 선택",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    _selectDate(context, true, startDate); // 시작 날짜 선택
                  },
                  decoration: InputDecoration(
                    hintText: startDate != null
                        ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}"
                        : "시작 날짜",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text("~"),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    _selectDate(context, false, endDate); // 종료 날짜 선택
                  },
                  decoration: InputDecoration(
                    hintText: endDate != null
                        ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
                        : "종료 날짜",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _toggleYearRange(year: DateTime.now().year);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCurrentYear()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                  ),
                  child: const Text("올해"),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _toggleYearRange(year: DateTime.now().year - 1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLastYear()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                  ),
                  child: const Text("작년"),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _toggleYearRange(year: DateTime.now().year - 2);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTwoYearsAgo()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                  ),
                  child: const Text("재작년"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Checkbox(
                value: isDateUnknown,
                onChanged: (bool? value) {
                  setState(() {
                    isDateUnknown = value ?? false;
                  });
                },
              ),
              const Text('날짜 모름 미포함'),
            ],
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity, // 버튼의 너비를 부모 위젯의 최대 너비로 설정
            child: ElevatedButton(
              onPressed: () {
                print("현재 설정 날짜: $startDate ~ $endDate");
                // 선택된 날짜 범위 및 날짜 모름 체크 처리
                Navigator.pop(context, {
                  'startDate': startDate,
                  'endDate': endDate,
                  'isDateUnknown': isDateUnknown,
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
