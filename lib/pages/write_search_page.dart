import 'package:flutter/material.dart';

class WriteSearchPage extends StatefulWidget {
  const WriteSearchPage({super.key});

  @override
  _WriteSearchPageState createState() => _WriteSearchPageState();
}

class _WriteSearchPageState extends State<WriteSearchPage> {

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
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;  // 검색어 업데이트
            });
          },
        ),
      ),
      body: const Center(
        child: Text('검색 페이지임'),
      ),
    );
  }

}
