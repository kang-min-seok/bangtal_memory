// 패키지
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 값
import 'package:bangtal_memory/constants/constants.dart';
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

import 'edit_main_page.dart';

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

  String _selectedSorting = '최신순';

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
  bool _groupByStore = true;

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
                collapsedHeight: 96,
                backgroundColor: Theme.of(context).colorScheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.none,
                  titlePadding: EdgeInsets.zero,
                  title: Container(
                    height: 109,
                    padding: EdgeInsets.only(top: 5),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _isSearching
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(12, 10, 12, 3),
                                child: SizedBox(
                                  height: 43, // 텍스트 필드의 높이를 고정하여 일관성 유지
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      hintText: '검색어를 입력해주세요',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 1.0, horizontal: 12.0),
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
                                          printAllEscapeRecords();
                                          if (_searchController
                                              .text.isNotEmpty) {
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
                            : Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: SizedBox(
                                    height: 56,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _scrollController.animateTo(
                                              0.0,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxHeight: 45,
                                                          maxWidth: 100),
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                  print(
                                                      "정렬기준: $_selectedSorting");
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
                                ),
                              ),
                        const SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              _buildFilterChip(
                                context: context,
                                label: _groupByStore ? "매장별" : "테마별",
                                value: null,
                                onTap: () {
                                  setState(() {
                                    _groupByStore = !_groupByStore;
                                    _loadRecords();
                                  });
                                },
                                showIcon: false
                              ),
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
                        SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                // pinned: true,
                delegate: _HeaderDelegate(
                  totalRecords: records.length,
                  selectedSorting: _selectedSorting,
                  onSortingChanged: (newSorting) {
                    setState(() {
                      _selectedSorting = newSorting; // 새로운 값을 받으면 상태 업데이트
                    });
                  },
                ),
              ),
              records.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.memory_rounded,
                                size: 70, color: Colors.grey),
                            SizedBox(
                              height: 20,
                            ),
                            Text('방탈출 기록이 없습니다.',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                delegate: SliverChildListDelegate(
                  _groupByStore
                      ? _buildSliverListItemsByStore(records)
                      : _buildSliverListItemsAsList(records),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WriteMainPage()),
          ).then((result) {
            print("이거 돔?");
            if(result == true){
              print("마자 이거 돈다.");
              _loadRecords();
            }
          });

        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  // Chip 생성 로직
  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    String? value,
    required VoidCallback onTap,
    bool showIcon = true, // 아이콘 표시 여부에 대한 매개변수 추가
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
                constraints: const BoxConstraints(maxHeight: 18),
                // 텍스트의 최대 높이 설정
                child: AutoSizeText(
                  isSelected
                      ? (value!.length > 6 ? value.substring(0, 6) + '...' : value)
                      : label,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 60,
                  ),
                  maxLines: 1, // 한 줄로 제한
                  minFontSize: 10, // 최소 글자 크기
                  overflow: TextOverflow.ellipsis, // 텍스트가 넘칠 경우 생략부호 처리
                ),
              ),
              const SizedBox(width: 4),
              // 아이콘 대신 빈 공간을 추가하여 크기 일관성 유지
              showIcon
                  ? const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20.0,
              )
                  : const SizedBox( height: 20), // 아이콘 자리에 빈 공간
            ],
          ),
        ),
      ),
    );
  }

  // Hive 데이터를 기반으로 섹션과 리스트 아이템을 구성하는 부분
  List<Widget> _buildSliverListItemsByStore(List<EscapeRecord> records) {
    Map<String, List<EscapeRecord>> sections = {};

    // 데이터를 검색어에 따라 필터링
    List<EscapeRecord> filteredRecords = _searchQuery.isEmpty
        ? records
        : records.where((record) {
            return record.storeName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                record.themeName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
          }).toList();

    // storeName을 기준으로 데이터를 그룹화
    for (var record in filteredRecords) {
      if (!sections.containsKey(record.storeName)) {
        sections[record.storeName] = [];
      }
      sections[record.storeName]!.add(record);
    }

    // 각 그룹을 최신순 또는 오래된순으로 정렬
    List<MapEntry<String, List<EscapeRecord>>> sortedSections =
        sections.entries.toList();

    // 그룹을 정렬 (각 그룹에서 최신 날짜를 기준으로 정렬)
    sortedSections.sort((a, b) {
      DateTime? latestDateA = _getLatestValidDate(a.value);
      DateTime? latestDateB = _getLatestValidDate(b.value);

      if (latestDateA == null && latestDateB == null) return 0;
      if (latestDateA == null) return 1; // A 그룹의 날짜가 없으면 뒤로
      if (latestDateB == null) return -1; // B 그룹의 날짜가 없으면 뒤로

      if (_selectedSorting == '최신순') {
        return latestDateB.compareTo(latestDateA); // 최신순
      } else {
        return latestDateA.compareTo(latestDateB); // 오래된순
      }
    });

    List<Widget> slivers = [];

    // 정렬된 그룹을 기반으로 슬리버 리스트를 만듦
    for (var section in sortedSections) {
      String sectionTitle = section.key;
      List<EscapeRecord> items = section.value;

      // 그룹 내의 데이터를 최신순 또는 오래된순으로 정렬
      items.sort((a, b) {
        DateTime? dateA = _parseDate(a.date);
        DateTime? dateB = _parseDate(b.date);

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1; // A의 날짜가 없으면 뒤로
        if (dateB == null) return -1; // B의 날짜가 없으면 뒤로

        if (_selectedSorting == '최신순') {
          return dateB.compareTo(dateA); // 최신순
        } else {
          return dateA.compareTo(dateB); // 오래된순
        }
      });

      // 섹션 타이틀 추가
      slivers.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // 섹션 내 아이템 추가
      for (var item in items) {
        slivers.add(_buildListTile(item));
      }
    }

    return slivers;
  }

  // 가게별 그룹화하지 않고 리스트로 나열하는 함수
  List<Widget> _buildSliverListItemsAsList(List<EscapeRecord> records) {
    // 데이터를 검색어에 따라 필터링
    List<EscapeRecord> filteredRecords = _searchQuery.isEmpty
        ? records
        : records.where((record) {
      return record.storeName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          record.themeName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    // 날짜에 따라 정렬 (최신순 또는 오래된순)
    filteredRecords.sort((a, b) {
      DateTime? dateA = _parseDate(a.date);
      DateTime? dateB = _parseDate(b.date);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // A의 날짜가 없으면 뒤로
      if (dateB == null) return -1; // B의 날짜가 없으면 뒤로

      if (_selectedSorting == '최신순') {
        return dateB.compareTo(dateA); // 최신순
      } else {
        return dateA.compareTo(dateB); // 오래된순
      }
    });

    // 정렬된 데이터를 위젯 리스트로 변환
    return filteredRecords.map((record) => _buildListTile(record)).toList();
  }

// 유효한 날짜를 찾는 함수
  DateTime? _getLatestValidDate(List<EscapeRecord> records) {
    DateTime? latestDate;

    for (var record in records) {
      DateTime? parsedDate = _parseDate(record.date);
      if (parsedDate != null) {
        if (latestDate == null || parsedDate.isAfter(latestDate)) {
          latestDate = parsedDate;
        }
      }
    }

    return latestDate;
  }

  Widget _buildListTile(EscapeRecord record) {
    return GestureDetector(
      onLongPress: () {
        _showBottomSheetForRecord(record); // 꾹 눌렀을 때 BottomSheet 호출
      },
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

  void _showBottomSheetForRecord(EscapeRecord record) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
            child: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('수정하기'),
                onTap: () {
                  Navigator.pop(context); // BottomSheet 닫기
                  // 수정 후 결과를 기다림
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditMainPage(record: record),
                    ),
                  ).then((isEdited) {
                    // 수정 후 돌아왔을 때 업데이트 처리
                    if (isEdited == true) {
                      _loadRecords();
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('삭제하기'),
                onTap: () async {
                  await _deleteRecord(record); // 삭제 로직 실행
                  Navigator.pop(context); // BottomSheet 닫기
                  _loadRecords(); // 삭제 후 데이터를 다시 로드하여 UI 업데이트
                },
              ),
            ],
          ),
        ));
      },
    );
  }

  // 삭제 로직을 처리하는 함수
  Future<void> _deleteRecord(EscapeRecord record) async {
    var box = await Hive.openBox<EscapeRecord>('escape_records');
    await box.delete(record.key); // Hive에서 레코드 삭제
    print("Record deleted: ${record.themeName}"); // 삭제된 레코드 출력
  }

  void _loadRecords() {
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


  void printAllEscapeRecords() async {
    // Hive 박스 열기
    var box = await Hive.openBox<EscapeRecord>('escape_records');

    // 박스가 비어있는 경우 처리
    if (box.isEmpty) {
      print("저장된 데이터가 없습니다.");
      return;
    }

    // 저장된 모든 데이터를 가져옴
    List<EscapeRecord> records = box.values.toList();

    // 깔끔하게 로그 출력
    print("\n===== 저장된 EscapeRecord 목록 (${records.length}개) =====");
    for (int i = 0; i < records.length; i++) {
      EscapeRecord record = records[i];
      print('''
----------------------------------
#${i + 1}
ID: ${record.id}
날짜: ${record.date}
가게 이름: ${record.storeName}
테마 이름: ${record.themeName}
난이도: ${record.difficulty}
만족도: ${record.satisfaction}
장르: ${record.genre}
지역: ${record.region}
----------------------------------
    ''');
    }
  }


  String _getSatisfactionImage(String satisfaction) {
    switch (satisfaction) {
      case '흙길':
        return 'assets/images/dirt.png';
      case '흙풀길':
        return 'assets/images/dirtGrass.png';
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
        return 'assets/images/placeHolder.png'; // 기본 이미지 (만약 만족도 값이 설정되지 않은 경우)
    }
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
    _loadRecords();
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

    return allRecords.where((record) {
      // 날짜 파싱
      DateTime? recordDate = _parseDate(record.date);

      // isDateUnknown이 true일 경우 날짜가 ????.??.??이면 필터 통과
      if (!isDateUnknown && record.date.contains('????')) {
        // 필터 통과
      } else {
        // isDateUnknown이 false이거나 날짜가 유효할 경우 정상 필터링
        if (recordDate == null) {
          return false;
        }

        // 날짜 필터
        if (startDate != null && recordDate.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && recordDate.isAfter(endDate)) {
          return false;
        }
      }

      // 지역 필터
      if (selectedRegions != null && selectedRegions.isNotEmpty) {
        if (!selectedRegions.contains(record.region)) {
          return false;
        }
      }

      // 장르 필터
      if (selectedGenres != null && selectedGenres.isNotEmpty) {
        if (!selectedGenres.contains(record.genre)) {
          return false;
        }
      }

      // 만족도 필터
      if (selectedSatisfactions != null && selectedSatisfactions.isNotEmpty) {
        if (!selectedSatisfactions.contains(record.satisfaction)) {
          return false;
        }
      }

      // 난이도 필터
      if (selectedDifficulties != null && selectedDifficulties.isNotEmpty) {
        if (!selectedDifficulties.contains(record.difficulty) &&
            ['Easy', 'Normal', 'Hard'].contains(record.difficulty)) {
          return false;
        }
      }

      // 난이도(별점) 필터
      if (!['Easy', 'Normal', 'Hard'].contains(record.difficulty)) {
        double? recordRating = double.tryParse(record.difficulty);
        if (recordRating != null) {
          if (minRating != null && recordRating < minRating) {
            return false;
          }
          if (maxRating != null && recordRating > maxRating) {
            return false;
          }
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
  final String selectedSorting;
  final ValueChanged<String> onSortingChanged;

  _HeaderDelegate({
    required this.totalRecords,
    required this.selectedSorting,
    required this.onSortingChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // 텍스트와 드롭다운 높이 일치
        children: [
          // totalRecords 텍스트
          Text(
            "$totalRecords번",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 16,
            ),
          ),

          // DropdownButton의 높이를 고정하고 텍스트 크기를 제한
          SizedBox(
            height: 40, // DropdownButton과 텍스트의 동일한 높이를 지정
            child: DropdownButton<String>(
              underline: const SizedBox.shrink(),
              value: selectedSorting,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onSortingChanged(newValue); // 선택된 값이 변경되면 콜백 호출
                }
              },
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
              ),
              items: <String>['최신순', '오래된순']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 30), // 텍스트 높이 제한
                    child: AutoSizeText(
                      value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      maxLines: 1, // 한 줄로 제한
                      minFontSize: 12, // 최소 글자 크기
                      overflow: TextOverflow.ellipsis, // 글자가 넘칠 경우 생략
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 40.0; // SliverPersistentHeader의 최대 높이
  @override
  double get minExtent => 40.0; // SliverPersistentHeader의 최소 높이

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
