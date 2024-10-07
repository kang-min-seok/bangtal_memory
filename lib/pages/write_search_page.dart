import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../hive/escape_data_service.dart';

class WriteSearchPage extends StatefulWidget {
  const WriteSearchPage({super.key});

  @override
  _WriteSearchPageState createState() => _WriteSearchPageState();
}

class _WriteSearchPageState extends State<WriteSearchPage> {
  String _searchQuery = '';  // 검색어 저장
  TextEditingController _searchController = TextEditingController();

  late EscapeDataService _dataService;
  late SharedPreferences _prefs;

  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = []; // 필터링된 데이터를 저장하는 리스트
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    var box = await Hive.openBox('escapeRoomData');

    List<dynamic> hiveData = box.get('data', defaultValue: []);

    if (hiveData.isEmpty) {
      await _downloadData();
      hiveData = box.get('data', defaultValue: []);
    }

    setState(() {
      _allData = hiveData.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      _filteredData = hiveData.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

    });
  }

  Future<void> _downloadData() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoConnectionDialog(context);
      return;
    }

    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
    });

    _dataService = EscapeDataService();
    await _dataService.initializeHive();

    await _dataService.loadData().then((_) async {
      await _prefs.setBool('isDataLoaded', true);
      print('데이터 로드 완료');
    });

    setState(() {
      _isLoading = false; // 다운로드 완료 후 로딩 상태 false로 변경
    });
  }

  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('인터넷 연결이 없음'),
          content: Text('테마 정보를 저장하려면 셀룰러 데이터를 켜거나 Wi-Fi를 사용하십시오.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredData = _allData; // 검색어가 비어있으면 전체 데이터를 보여줌
      } else {
        _filteredData = _allData.where((item) {
          return item['store'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item['theme'].toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '테마 혹은 매장을 입력해주세요',
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
                _searchController.clear();
                _filterData('');  // 검색어를 초기화하고 전체 데이터를 다시 로드
              },
            ),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          onChanged: (value) {
            _filterData(value);  // 타이핑할 때마다 데이터를 필터링
          },
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(), // 로딩 중일 때 스피너 표시
      )
          : _filteredData.isEmpty
          ? Center(
        child: Text('검색 결과가 없습니다.'),
      )
          : ListView.builder(
        itemCount: _filteredData.length,
        itemBuilder: (context, index) {
          var item = _filteredData[index];
          return ListTile(
            title: Text(
              item['theme'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            shape: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.surface, // 경계선 색상
                width: 1.0, // 경계선 두께
              ),
            ),
            subtitle: Text('${item['store']}'),
            trailing: Text(
              '${item['region']}',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            onTap: () {
              // 선택된 데이터를 이전 페이지로 전달
              Navigator.pop(context, item);
            },
          );
        },
      ),
    );
  }
}