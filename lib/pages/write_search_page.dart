import 'package:flutter/material.dart';

class WriteSearchPage extends StatefulWidget {
  const WriteSearchPage({super.key});

  @override
  _WriteSearchPageState createState() => _WriteSearchPageState();
}

class _WriteSearchPageState extends State<WriteSearchPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색'),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: const Center(
        child: Text('검색 페이지임'),
      ),
    );
  }

}
