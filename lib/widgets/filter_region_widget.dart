import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../hive/escape_record.dart';

class RegionFilterOptions extends StatefulWidget {
  const RegionFilterOptions({super.key});
  @override
  _RegionFilterOptionsState createState() => _RegionFilterOptionsState();
}

class _RegionFilterOptionsState extends State<RegionFilterOptions> {
  // 선택된 지역을 저장하는 리스트
  static List<String> selectedRegions = [];

  Future<List<String>> _getUniqueRegions() async {
    // Hive 박스에서 EscapeRecord를 불러오고, 중복되지 않는 지역을 추출
    var box = await Hive.openBox<EscapeRecord>('escape_records');
    List<EscapeRecord> records = box.values.toList();

    // 중복되지 않는 지역 목록을 추출
    List<String> uniqueRegions = records
        .map((record) => record.region)
        .toSet() // 중복 제거
        .toList();

    return uniqueRegions;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getUniqueRegions(), // 유니크한 지역 값을 가져오는 함수
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('오류가 발생했습니다.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('데이터가 없습니다.'));
        } else {
          final regions = snapshot.data!; // 데이터가 있는 경우
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "지역 필터 선택",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: regions.map((region) {
                        return ChoiceChip(
                          label: Text(region),
                          selected: selectedRegions.contains(region),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedRegions.add(region);
                              } else {
                                selectedRegions.remove(region);
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            // 양옆 둥글게 설정
                            side: BorderSide(
                              color: selectedRegions.contains(region)
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
                            color: selectedRegions.contains(region)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onBackground,
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      width: double.infinity, // 버튼의 너비를 부모 위젯의 최대 너비로 설정
                      child: ElevatedButton(
                        onPressed: () {
                          // 선택된 지역을 처리하는 로직 추가
                          Navigator.pop(context, {
                            'selectedRegions': selectedRegions, // 지역을 Map으로 반환
                          });
                        },
                        child: const Text('선택 완료'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
