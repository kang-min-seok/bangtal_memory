import 'package:flutter/material.dart';

class WriteMainPage extends StatefulWidget {
  const WriteMainPage({super.key});

  @override
  _WriteMainPageState createState() => _WriteMainPageState();
}

class _WriteMainPageState extends State<WriteMainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기억 작성'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: const Center(
        child: Text('기억 작성 페이지임'),
      ),
    );
  }

}
