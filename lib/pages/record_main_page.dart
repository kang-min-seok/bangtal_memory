import 'package:auto_size_text/auto_size_text.dart';
import 'package:bangtal_memory/pages/setting_main_page.dart';
import 'package:bangtal_memory/pages/write_main_page.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:bangtal_memory/constants/constants.dart';
import '../hive/escape_record.dart';

class RecordMainPage extends StatefulWidget {
  const RecordMainPage({super.key});

  @override
  _RecordMainPageState createState() => _RecordMainPageState();
}

class _RecordMainPageState extends State<RecordMainPage> {
  List<Map<String, dynamic>> _data = [];
  late Box _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('escapeRoomData');
    _loadDataFromHive();
  }

  void _loadDataFromHive() {
    final hiveData = _box.get('data') as List<dynamic>?;

    if (hiveData != null && hiveData.isNotEmpty) {
      // Hive에 데이터가 있는 경우 로드
      setState(() {
        _data =
            hiveData.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } else {
      // Hive에 데이터가 없거나 비어있는 경우 웹 크롤링 실행
      _crawlDataFromWeb();
    }
  }

  Future<void> _crawlDataFromWeb() async {

    var url = 'https://colory.mooo.com/bba/catalogue';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var document = parse(response.body);
        var themesInfo = document.querySelector('.themes-info');
        List<Map<String, dynamic>> data = [];

        if (themesInfo != null) {
          for (int i = 1; i <= 34; i++) {
            var buttonClass = '#theme-button-$i';
            var button = themesInfo.querySelector(buttonClass);

            if (button != null) {
              var regionName =
                  button.querySelector('h5')?.text ?? 'No region name';
              var table = button.querySelector('table');
              if (table != null) {
                var rows = table.querySelectorAll('tbody tr');
                String storeName = '';
                for (var row in rows) {
                  var storeElement = row.querySelector('.info-1');
                  if (storeElement != null) {
                    storeName = storeElement.text;
                  }
                  var themeName =
                      row.querySelector('.info-2')?.text ?? 'No theme name';
                  var rating =
                      row.querySelector('.info-3')?.text ?? 'No rating';
                  var difficulty =
                      row.querySelector('.info-4')?.text ?? 'No difficulty';
                  var reviews =
                      row.querySelector('.info-5')?.text ?? 'No reviews';

                  data.add({
                    'region': regionName,
                    'store': storeName,
                    'theme': themeName,
                    'rating': rating,
                    'difficulty': difficulty,
                    'reviews': reviews,
                  });
                }
              }
            }
          }
        } else {
          print('No themes-info found');
        }

        setState(() {
          _data = data;
        });

        // Hive에 데이터 저장
        _box.put('data', _data);
      } else {
        print('Failed to load page');
      }
    } catch (e) {
      print('Error: $e');
    } finally {

    }
  }

  bool _isSearching = false; // 검색 모드 여부
  String _searchQuery = ''; // 검색어 저장
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

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
        future: _getRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("오류 발생: ${snapshot.error}"));
          }
          //
          // if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //   return Center(child: Text("저장된 데이터가 없습니다."));
          // }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                floating: true,
                collapsedHeight: 106, // 높이를 조금 줄임
                backgroundColor: Theme.of(context).colorScheme.background,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.none, // 텍스트 투명도 문제 해결
                  titlePadding: EdgeInsets.zero,
                  title: Container(
                    height: 106, // 높이를 줄여서 간격 조정
                    padding: EdgeInsets.only(top: 5), // 패딩 조정
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _isSearching
                            ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
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
                              fillColor: Theme.of(context).colorScheme.surface,
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
                                color: Theme.of(context).colorScheme.onSurface),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value; // 검색어 업데이트
                              });
                            },
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _scrollController.animateTo(
                                    0.0, // 최상단으로 스크롤
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12), // 여기에서 패딩 추가
                                  child: Text(
                                    '방탈기억',
                                    style: TextStyle(
                                      fontFamily: "Tenada", // 원하는 폰트 패밀리 설정
                                      fontSize: 28, // 폰트 크기 설정
                                      color: Theme.of(context).primaryColor, // 텍스트 색상 명시
                                    ),
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
                                              const SettingMainPage()),
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5), // 간격을 더 좁게 설정
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 5),
                              for (var filter in ["날짜", "지역", "장르", "만족도", "난이도"])
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Chip(
                                    label: Text(filter),
                                    deleteIcon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 20.0, // 아이콘 크기 조절
                                    ),
                                    onDeleted: () {
                                      _showFilterOptions(context, filter);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25.0), // 완전히 둥근 테두리
                                    ),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.surface, // 테두리 색상
                                      width: 1.0, // 테두리 두께
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // SliverPersistentHeader(
              //   delegate: _FilterHeaderDelegate(),
              // ),
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
              // 화면을 리로드하여 업데이트된 데이터를 표시합니다.
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, String filter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0)), // 위쪽에 borderRadius 적용
      ),
      builder: (BuildContext context) {
        switch (filter) {
          case "날짜":
            return _buildDateFilterOptions();
          case "지역":
            return _buildRegionFilterOptions();
          case "장르":
            return _buildGenreFilterOptions(context);
          case "만족도":
            return _buildSatisfactionFilterOptions(context);
          case "난이도":
            return _buildDifficultyFilterOptions(context);
          default:
            return Container();
        }
      },
    ).then((selectedGenres) {
      if (selectedGenres != null && selectedGenres.isNotEmpty) {
        // 선택된 장르를 처리하는 로직 추가
        print('Selected genres: $selectedGenres');
      }
    });
  }

  Widget _buildDateFilterOptions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("날짜 필터 선택"),
          // 날짜 필터 옵션 구현
        ],
      ),
    );
  }

  Widget _buildRegionFilterOptions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("지역 필터 선택"),
          // 지역 필터 옵션 구현
        ],
      ),
    );
  }

  Widget _buildGenreFilterOptions(BuildContext context) {
    // 선택된 장르를 저장하는 리스트
    List<String> selectedGenres = [];

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                        // 양옆 둥글게 설정
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
                      showCheckmark: false);
                }).toList(),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity, // 버튼의 너비를 부모 위젯의 최대 너비로 설정
                child: ElevatedButton(
                  onPressed: () {
                    // 선택된 장르를 처리하는 로직 추가
                    Navigator.pop(context, selectedGenres);
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

  Widget _buildSatisfactionFilterOptions(BuildContext context) {
    // 선택된 만족도를 저장하는 리스트
    List<String> selectedSatisfactions = [];

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "만족도 필터 선택",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: satisfactionList.map((satisfaction) {
                  return ChoiceChip(
                      label: Text(satisfaction),
                      selected: selectedSatisfactions.contains(satisfaction),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            selectedSatisfactions.add(satisfaction);
                          } else {
                            selectedSatisfactions.remove(satisfaction);
                          }
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        // 양옆 둥글게 설정
                        side: BorderSide(
                          color: selectedSatisfactions.contains(satisfaction)
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
                        color: selectedSatisfactions.contains(satisfaction)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onBackground,
                      ),
                      showCheckmark: false);
                }).toList(),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity, // 버튼의 너비를 부모 위젯의 최대 너비로 설정
                child: ElevatedButton(
                  onPressed: () {
                    // 선택된 만족도를 처리하는 로직 추가
                    Navigator.pop(context, selectedSatisfactions);
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

  Widget _buildDifficultyFilterOptions(BuildContext context) {
    // 선택된 난이도를 저장하는 리스트
    List<String> selectedDifficulties = [];

    double minRating = 0.0;
    double maxRating = 5.0;

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
      },
    );
  }

  Widget _buildDifficultyButton(String label, bool isSelected, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface, // 선택 여부에 따라 색상 변경
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: Text(label),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 (leading)
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
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
                        child: Text(
                          record.difficulty,
                          style: const TextStyle(color: Colors.white),
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
}