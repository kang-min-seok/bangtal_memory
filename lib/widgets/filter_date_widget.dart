import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DateFilterOptions extends StatefulWidget {
  @override
  _DateFilterOptionsState createState() => _DateFilterOptionsState();
}

class _DateFilterOptionsState extends State<DateFilterOptions> {
  DateTime? startDate;
  DateTime? endDate;
  bool isDateUnknown = false;

  Future<void> _selectDate(BuildContext context, bool isStart, StateSetter setState, DateTime? initialDate) async {
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = initialDate ?? DateTime.now(); // TextField 값이 있으면 그 값을 초기값으로 사용
        return Container(
          height: 250,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate, // 초기값 설정
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
                    _selectDate(context, true, setState, startDate); // 시작 날짜 선택
                  },
                  decoration: InputDecoration(
                    hintText: startDate != null
                        ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}"
                        : "시작 날짜",
                    border: OutlineInputBorder(),
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
                    _selectDate(context, false, setState, endDate); // 종료 날짜 선택
                  },
                  decoration: InputDecoration(
                    hintText: endDate != null
                        ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
                        : "종료 날짜",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final now = DateTime.now();
                    startDate = DateTime(now.year, 1, 1);
                    endDate = DateTime(now.year, 12, 31);
                  });
                },
                child: const Text("올해"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final now = DateTime.now();
                    startDate = DateTime(now.year - 1, 1, 1);
                    endDate = DateTime(now.year - 1, 12, 31);
                  });
                },
                child: const Text("작년"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    final now = DateTime.now();
                    startDate = DateTime(now.year - 2, 1, 1);
                    endDate = DateTime(now.year - 2, 12, 31);
                  });
                },
                child: const Text("재작년"),
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
              const Text('날짜 모름 포함'),
            ],
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity, // 버튼의 너비를 부모 위젯의 최대 너비로 설정
            child: ElevatedButton(
              onPressed: () {
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
