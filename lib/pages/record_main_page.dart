import 'dart:convert';
import 'package:bangtal_memory/pages/setting_main_page.dart';
import 'package:bangtal_memory/pages/write_main_page.dart';
import 'package:flutter/material.dart';
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
  String _searchQuery = '';  // 검색어 저장
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '검색어를 입력해주세요',
            contentPadding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            suffixIcon: IconButton(
              icon: Icon(Icons.close),
              color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
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
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;  // 검색어 업데이트
            });
          },
        )
            : const Text('방탈기억'), // 검색 모드가 아닐 때 타이틀 표시
        actions: [
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (!_isSearching)
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingMainPage()),
                );
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Text(_searchQuery.isEmpty ? '메인 페이지임' : _searchQuery),  // 입력된 검색어 표시
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
}
