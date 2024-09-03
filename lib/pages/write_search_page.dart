import 'package:flutter/material.dart';

class WriteSearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;  // 크롤링된 데이터를 전달받음

  const WriteSearchPage({super.key, required this.data});

  @override
  _WriteSearchPageState createState() => _WriteSearchPageState();
}

class _WriteSearchPageState extends State<WriteSearchPage> {
  String _searchQuery = '';  // 검색어 저장
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _filteredData = []; // 필터링된 데이터를 저장하는 리스트

  @override
  void initState() {
    super.initState();
    _filteredData = widget.data; // 초기에는 전체 데이터를 보여줌
  }

  void _filterData(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredData = widget.data; // 검색어가 비어있으면 전체 데이터를 보여줌
      } else {
        _filteredData = widget.data.where((item) {
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
      body: _filteredData.isEmpty
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
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
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
