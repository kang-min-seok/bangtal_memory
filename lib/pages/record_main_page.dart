import 'dart:convert';
import 'package:bangtal_memory/pages/setting_main_page.dart';
import 'package:bangtal_memory/pages/write_main_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class RecordMainPage extends StatefulWidget {
  const RecordMainPage({super.key});

  @override
  _RecordMainPageState createState() => _RecordMainPageState();
}

class _RecordMainPageState extends State<RecordMainPage> {
  // List<Map<String, dynamic>> _data = [];
  // bool _isLoading = false;
  // late Box _box;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _box = Hive.box('escapeRoomData');
  //   _loadDataFromHive();
  // }
  //
  // void _loadDataFromHive() {
  //   final hiveData = _box.get('data') as List<dynamic>?;
  //
  //   if (hiveData != null) {
  //     setState(() {
  //       _data = hiveData.map((item) => Map<String, dynamic>.from(item)).toList();
  //     });
  //   } else {
  //     _crawlDataFromWeb();
  //   }
  // }
  //
  // Future<void> _crawlDataFromWeb() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   var url = 'https://colory.mooo.com/bba/catalogue';
  //   try {
  //     var response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       var document = parse(response.body);
  //       var themesInfo = document.querySelector('.themes-info');
  //       List<Map<String, dynamic>> data = [];
  //
  //       if (themesInfo != null) {
  //         for (int i = 1; i <= 34; i++) {
  //           var buttonClass = '#theme-button-$i';
  //           var button = themesInfo.querySelector(buttonClass);
  //
  //           if (button != null) {
  //             var regionName = button.querySelector('h5')?.text ?? 'No region name';
  //             var table = button.querySelector('table');
  //             if (table != null) {
  //               var rows = table.querySelectorAll('tbody tr');
  //               String storeName = '';
  //               for (var row in rows) {
  //                 var storeElement = row.querySelector('.info-1');
  //                 if (storeElement != null) {
  //                   storeName = storeElement.text;
  //                 }
  //                 var themeName = row.querySelector('.info-2')?.text ?? 'No theme name';
  //                 var rating = row.querySelector('.info-3')?.text ?? 'No rating';
  //                 var difficulty = row.querySelector('.info-4')?.text ?? 'No difficulty';
  //                 var reviews = row.querySelector('.info-5')?.text ?? 'No reviews';
  //
  //                 data.add({
  //                   'region': regionName,
  //                   'store': storeName,
  //                   'theme': themeName,
  //                   'rating': rating,
  //                   'difficulty': difficulty,
  //                   'reviews': reviews,
  //                 });
  //               }
  //             }
  //           }
  //         }
  //       } else {
  //         print('No themes-info found');
  //       }
  //
  //       setState(() {
  //         _data = data;
  //       });
  //
  //       // Hive에 데이터 저장
  //       _box.put('data', _data);
  //     } else {
  //       print('Failed to load page');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            scrolledUnderElevation: 0,
            floating: true,
            backgroundColor: Theme.of(context).colorScheme.background,
            title: _isSearching
                ? TextField(
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
                  )
                : GestureDetector(
                    onTap: () {
                      _scrollController.animateTo(
                        0.0, // 최상단으로 스크롤
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      '방탈기억',
                      style: TextStyle(
                        fontFamily: "Tenada", // 원하는 폰트 패밀리 설정
                        fontSize: 28, // 폰트 크기 설정
                        height: 1.2, // 텍스트의 높이를 조절하여 상하 여백 조정
                      ),
                    ),
                  ),
            // 검색 모드가 아닐 때 타이틀 표시
            actions: [
              if (!_isSearching)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              if (!_isSearching)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingMainPage()),
                      );
                    });
                  },
                ),
            ],
          ),
          SliverPersistentHeader(
            delegate: _FilterHeaderDelegate(),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              _buildSliverListItems(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WriteMainPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 얘는 임시임
  List<Widget> _buildSliverListItems() {
    final sections = {
      '비트포비아 홍대던전3': [
        '그달동네',
        '그달동네',
        '그달동네',
        '그달동네',
        '그달동네',
        '그달동네',
      ],
      '방탈출, 단편선': [
        '그림자없는 상자',
        '그림자없는 상자',
        '그림자없는 상자',
        '그림자없는 상자',
        '그림자없는 상자',
        '그림자없는 상자',
      ],
    };

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

  Widget _buildListTile(String title) {
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600, // weight를 살짝 두껍게 설정
                      ),
                    ),
                    const SizedBox(width: 8), // 타이틀과 칩 사이 간격
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Text("Easy"),
                    ),
                    const SizedBox(width: 4), // 칩 간 간격
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20)),
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Text("공포"),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  "비트포비아 홍대던전3",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8), // Subtitle과 날짜 간의 간격
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "홍대 - 2024.09.02",
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
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // 아이콘과 텍스트를 가운데 정렬
          children: [
            for (var filter in ["인생테마", "꽃밭길", "꽃길", "풀꽃길", "풀길", "흙풀길", "흙길"])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                // 요소 간 간격 설정
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // 텍스트를 수직으로 가운데 정렬
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Image.network(
                        width: 50,
                        height: 50,
                        "https://picsum.photos/200/200",
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(height: 5), // 이미지와 텍스트 간 간격
                    Text(filter),
                  ],
                ),
              ),
          ],
        ),
      ),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 5),
              for (var filter in ["날짜", "지역", "장르", "만족도", "난이도"])
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  // 요소 간 간격 설정
                  child: Chip(
                    label: Text(filter),
                    deleteIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.0, // 아이콘 크기 조절
                    ),
                    onDeleted: () {},
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
          ))
    ]);
  }

  @override
  double get maxExtent => 140.0;

  @override
  double get minExtent => 140.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
