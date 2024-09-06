// 패키지
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

// 값
import 'package:bangtal_memory/constants/constants.dart';
import '../hive/escape_data_service.dart';
import '../hive/escape_record.dart';

// 페이지
import 'package:bangtal_memory/pages/setting_main_page.dart';
import 'package:bangtal_memory/pages/write_main_page.dart';

// 위젯
import 'package:bangtal_memory/widgets/filter_date_widget.dart';
import 'package:bangtal_memory/widgets/filter_difficulty_widget.dart';
import 'package:bangtal_memory/widgets/filter_genre_widget.dart';
import 'package:bangtal_memory/widgets/filter_satisfaction_widget.dart';
import 'package:bangtal_memory/widgets/filter_region_widget.dart';

class RecordMainPage extends StatefulWidget {
  const RecordMainPage({super.key});

  @override
  _RecordMainPageState createState() => _RecordMainPageState();
}

class _RecordMainPageState extends State<RecordMainPage> {

  @override
  void initState() {
    super.initState();
    _filteredRecords = _getRecords();

  }


  bool _isSearching = false; // 검색 모드 여부
  String _searchQuery = ''; // 검색어 저장
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  Future<List<EscapeRecord>>? _filteredRecords;

  // 필터 변수
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isDateUnknown = false;
  List<String>? _selectedRegions;
  List<String>? _selectedGenres;
  List<String>? _selectedSatisfactions;
  List<String>? _selectedDifficulties;
  double? _minRating;
  double? _maxRating;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<EscapeRecord>> _getRecords() async {
    var box = await Hive.openBox<EscapeRecord>('escape_records');
    return box.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<EscapeRecord>>(
        future: _filteredRecords, // 필터링된 데이터를 가져옴
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          }

          final records = snapshot.data ?? [];

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                floating: true,
                collapsedHeight: 106,
                backgroundColor: Theme.of(context).colorScheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.none,
                  titlePadding: EdgeInsets.zero,
                  title: Container(
                    height: 106,
                    padding: EdgeInsets.only(top: 5),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _isSearching
                            ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                            height: 52, // 텍스트 필드의 높이를 고정하여 일관성 유지
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: '검색어를 입력해주세요',
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 7.0, horizontal: 10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor:
                                Theme.of(context).colorScheme.surface,
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.close),
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .hintStyle
                                      ?.color,
                                  onPressed: () {
                                    if (_searchController.text.isNotEmpty) {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    } else {
                                      setState(() {
                                        _isSearching = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value; // 검색어 업데이트
                                });
                              },
                            ),
                          ),
                        )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _scrollController.animateTo(
                                          0.0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxHeight: 40,
                                              ),
                                              child: AutoSizeText(
                                                '방탈기억',
                                                style: TextStyle(
                                                  fontFamily: "Tenada",
                                                  fontSize: 90, // 기본 글자 크기
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                maxLines: 1, // 한 줄로 제한
                                                minFontSize:
                                                    18, // 글자 크기의 최소값 설정
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.search),
                                          onPressed: () {
                                            setState(() {
                                              _isSearching = true;
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.settings),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SettingMainPage(),
                                                ),
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 5),
                              _buildFilterChip(
                                context: context,
                                label: "날짜",
                                value: _startDate != null && _endDate != null
                                    ? "${_startDate!.year}-${_endDate!.year}"
                                    : null,
                                onTap: () => _showFilterOptions(context, "날짜"),
                              ),
                              _buildFilterChip(
                                context: context,
                                label: "지역",
                                value: _selectedRegions != null &&
                                        _selectedRegions!.isNotEmpty
                                    ? _selectedRegions!.join(', ')
                                    : null,
                                onTap: () => _showFilterOptions(context, "지역"),
                              ),
                              _buildFilterChip(
                                context: context,
                                label: "장르",
                                value: _selectedGenres != null &&
                                        _selectedGenres!.isNotEmpty
                                    ? _selectedGenres!.join(', ')
                                    : null,
                                onTap: () => _showFilterOptions(context, "장르"),
                              ),
                              _buildFilterChip(
                                context: context,
                                label: "만족도",
                                value: _selectedSatisfactions != null &&
                                        _selectedSatisfactions!.isNotEmpty
                                    ? _selectedSatisfactions!.join(', ')
                                    : null,
                                onTap: () => _showFilterOptions(context, "만족도"),
                              ),
                              _buildFilterChip(
                                context: context,
                                label: "난이도",
                                value: _selectedDifficulties != null &&
                                        _selectedDifficulties!.isNotEmpty
                                    ? _selectedDifficulties!.join(', ')
                                    : null,
                                onTap: () => _showFilterOptions(context, "난이도"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                // pinned: true,
                delegate: _HeaderDelegate(
                  totalRecords: records.length,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  _buildSliverListItems(snapshot.data!),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WriteMainPage()),
          );

          if (result == true) {
            setState(() {
              _filteredRecords = _getRecords();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Chip 생성 로직
  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    bool isSelected = value != null && value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: onTap, // Chip을 클릭할 때 호출
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 텍스트
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 20), // 텍스트의 최대 높이 설정
                child: AutoSizeText(
                  isSelected
                      ? (value!.length > 6 ? value.substring(0, 6) + '...' : value)
                      : label,
                  style: Theme.of(context).textTheme.bodyText2,
                  maxLines: 1, // 한 줄로 제한
                  minFontSize: 10, // 최소 글자 크기
                  overflow: TextOverflow.ellipsis, // 텍스트가 넘칠 경우 생략부호 처리
                ),
              ),
              const SizedBox(width: 4),
              // 삭제 아이콘 (onTap으로 대체된 delete 기능)
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hive 데이터를 기반으로 섹션과 리스트 아이템을 구성하는 부분
  List<Widget> _buildSliverListItems(List<EscapeRecord> records) {
    Map<String, List<EscapeRecord>> sections = {};

    // storeName을 기준으로 데이터를 그룹화합니다.
    for (var record in records) {
      if (!sections.containsKey(record.storeName)) {
        sections[record.storeName] = [];
      }
      sections[record.storeName]!.add(record);
    }

    List<Widget> slivers = [];

    sections.forEach((sectionTitle, items) {
      slivers.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      for (var item in items) {
        slivers.add(_buildListTile(item));
      }
    });

    return slivers;
  }

  Widget _buildListTile(EscapeRecord record) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
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
                          child: AutoSizeText(
                            record.difficulty,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            minFontSize: 12,
                            stepGranularity: 1.0,
                            overflow: TextOverflow.ellipsis,
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
      );
  }

  String _getSatisfactionImage(String satisfaction) {
    switch (satisfaction) {
      case '흙길':
        return 'assets/images/dirt.png';
      case '흙풀길':
        return 'assets/images/grass.png';
      case '풀길':
        return 'assets/images/grass.png';
      case '풀꽃길':
        return 'assets/images/grassFlower.png';
      case '꽃길':
        return 'assets/images/flower.png';
      case '꽃밭길':
        return 'assets/images/flowerGarden.png';
      case '인생테마':
        return 'assets/images/life.png';
      default:
        return 'assets/images/grassFlower.png'; // 기본 이미지 (만약 만족도 값이 설정되지 않은 경우)
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green; // Easy에 대한 색상
      case 'Normal':
        return Colors.orange; // Normal에 대한 색상
      case 'Hard':
        return Colors.red; // Hard에 대한 색상
      default:
        return Colors.grey; // 알 수 없는 경우 기본 색상
    }
  }

  Color _getGenreColor(String genre) {
    return genreColorMap[genre] ??
        Colors.grey; // 장르에 맞는 색상을 반환하고, 없으면 기본값으로 회색 사용
  }

  void _showFilterOptions(BuildContext context, String filter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        switch (filter) {
          case "날짜":
            return const DateFilterOptions(); // 날짜 필터
          case "지역":
            return const RegionFilterOptions(); // 지역 필터
          case "장르":
            return const GenreFilterOptions(); // 장르 필터
          case "만족도":
            return const SatisfactionFilterOptions(); // 만족도 필터
          case "난이도":
            return const DifficultyFilterOptions(); // 난이도 필터
          default:
            return Container();
        }
      },
    ).then((filterResult) {
      if (filterResult != null) {
        _applyFilters(filterResult);
      }
    });
  }

  // 필터를 적용하는 함수
  Future<void> _applyFilters(Map<String, dynamic> filterResult) async {
    // 기존 필터 값을 유지하고 새로운 필터 값만 덮어씌우기
    if (filterResult.containsKey('startDate')) {
      _startDate = filterResult['startDate'];
    }
    if (filterResult.containsKey('endDate')) {
      _endDate = filterResult['endDate'];
    }
    _isDateUnknown = filterResult['isDateUnknown'] ?? _isDateUnknown;

    // List<String> 필터 값이 덮어씌워지지 않도록 새로운 값만 추가
    _selectedRegions = filterResult['selectedRegions'] ?? _selectedRegions;
    _selectedGenres = filterResult['selectedGenres'] ?? _selectedGenres;
    _selectedSatisfactions =
        filterResult['selectedSatisfactions'] ?? _selectedSatisfactions;
    _selectedDifficulties =
        filterResult['difficulties'] ?? _selectedDifficulties;

    _minRating = filterResult['minRating'] ?? _minRating;
    _maxRating = filterResult['maxRating'] ?? _maxRating;

    // 필터링된 데이터를 가져와서 _filteredRecords에 저장
    setState(() {
      _filteredRecords = _getFilteredRecords(
        startDate: _startDate,
        endDate: _endDate,
        isDateUnknown: _isDateUnknown,
        selectedRegions: _selectedRegions,
        selectedGenres: _selectedGenres,
        selectedSatisfactions: _selectedSatisfactions,
        selectedDifficulties: _selectedDifficulties,
        minRating: _minRating,
        maxRating: _maxRating,
      );
    });
  }

  Future<List<EscapeRecord>> _getFilteredRecords({
    DateTime? startDate,
    DateTime? endDate,
    bool isDateUnknown = false,
    List<String>? selectedRegions,
    List<String>? selectedGenres,
    List<String>? selectedSatisfactions,
    List<String>? selectedDifficulties,
    double? minRating,
    double? maxRating,
  }) async {
    var box = await Hive.openBox<EscapeRecord>('escape_records');
    List<EscapeRecord> allRecords = box.values.toList();

    print('Filtering records with the following conditions:');
    print(
        'Start date: $startDate, End date: $endDate, Is date unknown: $isDateUnknown');
    print('Selected regions: $selectedRegions');
    print('Selected genres: $selectedGenres');
    print('Selected satisfactions: $selectedSatisfactions');
    print('Selected difficulties: $selectedDifficulties');
    print('Min rating: $minRating, Max rating: $maxRating');

    return allRecords.where((record) {
      // 날짜 파싱
      DateTime? recordDate = _parseDate(record.date);

      // isDateUnknown이 true일 경우 날짜가 ????.??.??이면 필터 통과
      if (!isDateUnknown && record.date.contains('????')) {
        // print("유효하지 않은 날짜 기록 통과: ${record.date}");
      } else {
        // isDateUnknown이 false이거나 날짜가 유효할 경우 정상 필터링
        if (recordDate == null) {
          // print("유효한 날짜가 아님, 필터링 제외: ${record.date}");
          return false;
        }

        // 날짜 필터

        if (startDate != null && recordDate.isBefore(startDate)) {
          // print("날짜 필터 실패: $recordDate 가 $startDate 보다 이전입니다.");
          return false;
        } else {
          // print("날짜 필터1 통과: $recordDate 가 $startDate 보다 이후입니다.");
        }
        if (endDate != null && recordDate.isAfter(endDate)) {
          // print("날짜 필터 실패: $recordDate 가 $endDate 보다 이후입니다.");
          return false;
        } else {
          // print("날짜 필터2 통과: $recordDate 가 $endDate 보다 이전입니다.");
        }
      }

      // 지역 필터
      if (selectedRegions != null && selectedRegions.isNotEmpty) {
        if (!selectedRegions.contains(record.region)) {
          // print("지역 필터 실패: ${record.region} 는 선택된 지역 목록에 없습니다.");
          return false;
        } else {
          // print("지역 필터 통과: ${record.region} 가 선택된 지역 목록에 있습니다.");
        }
      } else {
        // print("지역 필터 설정 안함");
      }

      // 장르 필터
      if (selectedGenres != null && selectedGenres.isNotEmpty) {
        if (!selectedGenres.contains(record.genre)) {
          // print("장르 필터 실패: ${record.genre} 는 선택된 장르 목록에 없습니다.");
          return false;
        } else {
          // print("장르 필터 통과: ${record.genre} 가 선택된 장르 목록에 있습니다.");
        }
      } else {
        // print("장르 필터 설정 안함");
      }

      // 만족도 필터
      if (selectedSatisfactions != null && selectedSatisfactions.isNotEmpty) {
        if (!selectedSatisfactions.contains(record.satisfaction)) {
          // print("만족도 필터 실패: ${record.satisfaction} 는 선택된 만족도 목록에 없습니다.");
          return false;
        } else {
          // print("만족도 필터 통과: ${record.satisfaction} 가 선택된 만족도 목록에 있습니다.");
        }
      } else {
        // print("만족도 필터 설정 안함");
      }

      // 난이도 필터
      if (selectedDifficulties != null && selectedDifficulties.isNotEmpty) {
        if (!selectedDifficulties.contains(record.difficulty) &&
            ['Easy', 'Normal', 'Hard'].contains(record.difficulty)) {
          print("난이도 필터 실패: ${record.difficulty} 는 선택된 난이도 목록에 없습니다.");
          return false;
        } else {
          print("난이도 필터 통과: ${record.difficulty} 가 선택된 난이도 목록에 있습니다.");
        }
      } else {
        print("난이도 필터 설정 안함");
      }

      // 난이도(별점) 필터
      if (['Easy', 'Normal', 'Hard'].contains(record.difficulty)) {
        print("난이도가 Easy/Normal/Hard 이므로 별점 필터 적용 안함.");
      } else {
        double? recordRating = double.tryParse(record.difficulty);
        if (recordRating != null) {
          if (minRating != null && recordRating < minRating) {
            print("별점 필터 실패: $recordRating 가 최소 별점 $minRating 보다 낮습니다.");
            return false;
          } else {
            print("별점 필터 최소 통과: $recordRating 가 최소 별점 $minRating 보다 높습니다.");
          }
          if (maxRating != null && recordRating > maxRating) {
            print("별점 필터 실패: $recordRating 가 최대 별점 $maxRating 보다 높습니다.");
            return false;
          } else {
            print("별점 필터 최대 통과: $recordRating 가 최대 별점 $maxRating 보다 낮습니다.");
          }
        } else {
          print("난이도를 별점으로 변환할 수 없음: ${record.difficulty}");
        }
      }

      return true; // 모든 조건을 통과한 데이터 반환
    }).toList();
  }

  DateTime? _parseDate(String date) {
    try {
      // 날짜가 올바른 형식인지 확인 후 파싱
      if (date.contains("????") || date.isEmpty) {
        // print("날짜가 유효하지 않음: $date");
        return null; // ????.??.??와 같은 경우 null을 반환
      }

      // 수동으로 날짜를 파싱 (YYYY-MM-DD 형식이 아닌 경우 처리)
      List<String> parts = date.split('-');
      if (parts.length == 3) {
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1].padLeft(2, '0')); // 8 -> 08 처리
        int day = int.parse(parts[2].padLeft(2, '0')); // 9 -> 09 처리
        return DateTime(year, month, day);
      } else {
        // print("날짜 파싱 오류남: 잘못된 형식 $date");
        return null; // 잘못된 형식의 경우 null 반환
      }
    } catch (e) {
      // print("날짜 파싱 오류남: $e");
      return null; // 파싱 오류 시 null 반환
    }
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final int totalRecords;

  _HeaderDelegate({
    required this.totalRecords,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            "$totalRecords번",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 16,
            ),
          ),
        ),

        // DropdownButton<String>(
        //   value: _selectedOrder,
        //   onChanged: (String? newValue) {
        //     if (newValue != null) {
        //       _selectedOrder = newValue;
        //       // 상태를 업데이트하여 선택된 값을 반영 (StatefulWidget이 필요)
        //     }
        //   },
        //   items: <String>['최신순', '오래된순']
        //       .map<DropdownMenuItem<String>>((String value) {
        //     return DropdownMenuItem<String>(
        //       value: value,
        //       child: Text(value),
        //     );
        //   }).toList(),
        // ),
      ],
    );
  }

  @override
  double get maxExtent => 30.0;

  @override
  double get minExtent => 30.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
