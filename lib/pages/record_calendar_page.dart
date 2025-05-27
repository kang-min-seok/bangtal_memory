import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:auto_size_text/auto_size_text.dart';
import '../constants/constants.dart';
import '../hive/genre_service.dart';

import '../hive/escape_record.dart';

class RecordCalendarPage extends StatefulWidget {
  const RecordCalendarPage({Key? key}) : super(key: key);

  @override
  State<RecordCalendarPage> createState() => _RecordCalendarPageState();
}

class _RecordCalendarPageState extends State<RecordCalendarPage> {
  late final Box<EscapeRecord> _box;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<EscapeRecord>('escape_records');
    _selectedDay = _focusedDay;
  }

  /// 날짜별 플레이 수·리스트 맵 계산
  Map<DateTime, List<EscapeRecord>> _groupByDay(Box<EscapeRecord> box) {
    final map = <DateTime, List<EscapeRecord>>{};
    for (final r in box.values) {
      final date = _tryParseDate(r.date);
      if (date == null) continue;                        // 날짜 없는 기록 제외
      final day = DateTime(date.year, date.month, date.day);
      map.putIfAbsent(day, () => []).add(r);
    }
    return map;
  }

  DateTime? _tryParseDate(String s) {
    if (s.contains('????') || s.isEmpty) return null;
    try {
      final p = s.split('-');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('캘린더'),
      ),
      body: Column(
          children: [
            // ───────── 달력 영역 ─────────
            ValueListenableBuilder(
              valueListenable: _box.listenable(),
              builder: (_, Box<EscapeRecord> box, __) {
                final grouped = _groupByDay(box);

                return TableCalendar(
                  locale: locale,
                  rowHeight: 60,
                  daysOfWeekHeight: 22,
                  firstDay: DateTime.utc(2010, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                  onDaySelected: (sel, foc) {
                    setState(() {
                      if (isSameDay(_selectedDay, sel)) {
                        _selectedDay = null;           // 두 번 탭 시 해제
                      } else {
                        _selectedDay = sel;
                        _focusedDay = foc;
                      }
                    });
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                    leftChevronIcon : Icon(Icons.chevron_left_rounded,
                        color: Theme.of(context).colorScheme.onSurface),
                    rightChevronIcon: Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (ctx, day, _) =>
                        _buildDayCell(ctx, day, grouped),
                    todayBuilder: (ctx, day, _) => _buildDayCell(
                      ctx, day, grouped,
                      isToday: true,
                    ),
                    selectedBuilder: (ctx, day, _) => _buildDayCell(
                      ctx, day, grouped,
                      isSelected: true,
                    ),
                  ),
                );
              },
            ),

            // ───────── 선택한 날짜 기록 리스트 ─────────
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _box.listenable(),
                builder: (_, Box<EscapeRecord> box, __) {
                  /* (1) 오늘 또는 선택된 날짜의 기록 모으기 */
                  final raw = _selectedDay ??
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                  final key = DateTime(raw.year, raw.month, raw.day);
                  final dayRecords = _groupByDay(box)[key] ?? [];

                  if (dayRecords.isEmpty) {
                    return const Center(child: Text('기록이 없습니다.'));
                  }

                  /* (2) 매장별 그룹핑 & 최신순 정렬 */
                  final sections = <String, List<EscapeRecord>>{};
                  for (final r in dayRecords) {
                    (sections[r.storeName] ??= []).add(r);
                  }
                  final sortedSections = sections.entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key));      // 매장 이름순 ↑

                  /* (3) 리스트 위젯 만들기 ― 메인 페이지와 같은 타일 사용 */
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    children: [
                      for (final sec in sortedSections) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                          child: Text(sec.key,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),

                        // 1️⃣ 매장별 리스트 복사 후 정렬
                        ...(() {
                          final sorted = [...sec.value]        // 복사본
                            ..sort((a, b) => a.themeName.compareTo(b.themeName));
                          // 2️⃣ Widget 으로 변환한 Iterable 을 spread
                          return sorted.map(_buildListTile);
                        })(),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
    );
  }

  /// 날짜 셀 공통 빌더
  Widget _buildDayCell(BuildContext ctx, DateTime day,
      Map<DateTime, List<EscapeRecord>> grouped,
      {bool isToday = false, bool isSelected = false}) {
    final list = grouped[DateTime(day.year, day.month, day.day)] ?? [];
    final count = list.length;

    final baseDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: isSelected
          ? Theme.of(ctx).colorScheme.primary
          : isToday
          ? Theme.of(ctx).colorScheme.primary.withOpacity(0.2)
          : null,
    );

    final textColor = isSelected
        ? Colors.white
        : Theme.of(ctx).colorScheme.onBackground;

    int dotCnt   = count.clamp(0, 3);      // 최대 3개
    bool hasMore = count > 3;

    return Container(
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.only(top: 4),
      decoration: baseDecoration,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 날짜 숫자
          Text('${day.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              )),

          if (count > 0) ...[
            const SizedBox(height: 10),

            // 점(●) 마커
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < dotCnt; i++)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(ctx).colorScheme.primary,
                    ),
                  ),

              ],
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildListTile(EscapeRecord record) {
    return GestureDetector(
      // onLongPress: () {
      //   _showBottomSheetForRecord(record); // 꾹 눌렀을 때 BottomSheet 호출
      // },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 이미지 (leading)
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // 원형으로 자르기 위한 반경
              child: Image.asset(
                _getSatisfactionImage(record.satisfaction),
                width: MediaQuery.of(context).size.height * 0.085, // 이미지의 너비
                height: MediaQuery.of(context).size.height * 0.085, // 이미지의 높이
                fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
              ),
            ),
            const SizedBox(width: 12), // 이미지와 텍스트 간의 간격
            // 텍스트 및 칩
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: AutoSizeText(
                          record.themeName,
                          style: const TextStyle(
                            fontSize: 18, // 기본 글자 크기
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          // 텍스트를 한 줄로 제한
                          minFontSize: 12,
                          // 최소 글자 크기
                          stepGranularity: 1.0,
                          // 글자 크기를 줄이는 단위
                          overflow: TextOverflow
                              .ellipsis, // 글자 크기가 줄어도 텍스트가 너무 길 경우 '...'로 처리
                        ),
                      ),
                      const SizedBox(width: 8), // 타이틀과 칩 사이 간격
                      if (record.difficulty != "")
                        Container(
                          decoration: BoxDecoration(
                              color: _getDifficultyColor(record.difficulty),
                              borderRadius: BorderRadius.circular(20)),
                          padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                          child: Row(
                            children: [
                              if (double.tryParse(record.difficulty) !=
                                  null) // double로 변환 가능할 때 별 아이콘 추가
                                Icon(Icons.star_rounded,
                                    color: Colors.white, size: 16),
                              SizedBox(
                                  width:
                                  double.tryParse(record.difficulty) != null
                                      ? 4
                                      : 0), // 아이콘이 있을 때만 간격 추가
                              AutoSizeText(
                                record.difficulty,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 1,
                                minFontSize: 12,
                                stepGranularity: 1.0,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 4), // 칩 간 간격
                      if (record.genre != "")
                        Container(
                          decoration: BoxDecoration(
                            color: _getGenreColor(record.genre),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                          child: Text(
                            record.genre,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    record.storeName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8), // Subtitle과 날짜 간의 간격
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "${record.region} - ${record.date}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    // 우선 difficulty 값을 double로 변환 시도
    double? difficultyValue = double.tryParse(difficulty);

    if (difficultyValue != null) {
      // double 변환에 성공한 경우
      if (difficultyValue >= 0.0 && difficultyValue < 3.0) {
        return Colors.green; // 0.0 ~ 3.0: Easy
      } else if (difficultyValue >= 3.0 && difficultyValue < 4.0) {
        return Colors.orange; // 3.0 ~ 4.0: Normal
      } else if (difficultyValue >= 4.0 && difficultyValue <= 5.0) {
        return Colors.red; // 4.0 ~ 5.0: Hard
      } else {
        return Colors.grey; // 범위를 벗어난 경우 기본 색상
      }
    }

    // 변환 실패 시 기존 문자열 기준 색상 반환
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Normal':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey; // 알 수 없는 경우 기본 색상
    }
  }

  Color _getGenreColor(String genre) {
    // Hive에 저장된 색(A) → 없으면 기본값(B) → 그래도 없으면 회색(C)
    return GenreService.colors[genre] ??
        defaultGenreColorMap[genre] ??   // 선택 사항: constants.dart 기본값
        Colors.grey;
  }


  String _getSatisfactionImage(String satisfaction) {
    switch (satisfaction) {
      case '흙길':
        return 'assets/images/dirt.jpg';
      case '흙풀길':
        return 'assets/images/dirtGrass.jpg';
      case '풀길':
        return 'assets/images/grass.jpg';
      case '풀꽃길':
        return 'assets/images/grassFlower.jpg';
      case '꽃길':
        return 'assets/images/flower.jpg';
      case '꽃밭길':
        return 'assets/images/flowerGarden.jpg';
      case '인생테마':
        return 'assets/images/life.jpg';
      default:
        return 'assets/images/placeHolder.png'; // 기본 이미지 (만약 만족도 값이 설정되지 않은 경우)
    }
  }

}
