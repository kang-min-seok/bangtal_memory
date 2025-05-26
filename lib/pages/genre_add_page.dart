import 'dart:math' show Random;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../hive/genre_service.dart';

class GenreAddPage extends StatefulWidget {
  const GenreAddPage({super.key});

  @override
  State<GenreAddPage> createState() => _GenreAddPageState();
}

class _GenreAddPageState extends State<GenreAddPage> {
  final _controller = TextEditingController();
  Color _selectedColor = Colors.blue;          // 기본색

  void _pickRandomColor() {
    final r = Random();
    setState(() {
      _selectedColor =
      Colors.primaries[r.nextInt(Colors.primaries.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('장르 추가')
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1) 아이콘 선택
              GestureDetector(
                onTap: () async {
                  // 간단히 Material 색상 팔레트 다이얼로그
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('색상 선택'),
                      content: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Colors.primaries.map((c) {
                          return GestureDetector(
                            onTap: () => Navigator.pop(context, c),
                            child: CircleAvatar(backgroundColor: c),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                  if (color != null) {
                    setState(() => _selectedColor = color);
                  }
                },
                child: CircleAvatar(
                  backgroundColor: _selectedColor,
                  radius: 40,
                ),
              ),

              const SizedBox(height: 24),

              // 2) 이름 입력
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: '장르 이름',
                  border: UnderlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),


              // 4) 색상 랜덤 / 직접 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickRandomColor,
                      child: const Text('랜덤 색상', style: TextStyle( fontWeight: FontWeight.bold),),
                    ),
                  ),
                  SizedBox(width: 5,),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // 간단히 Material 색상 팔레트 다이얼로그
                        final color = await showDialog<Color>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('색상 선택'),
                            content: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: Colors.primaries.map((c) {
                                return GestureDetector(
                                  onTap: () => Navigator.pop(context, c),
                                  child: CircleAvatar(backgroundColor: c),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                        if (color != null) {
                          setState(() => _selectedColor = color);
                        }
                      },
                      child: const Text('색상 선택', style: TextStyle( fontWeight: FontWeight.bold)),
                    ),
                  )

                ],
              ),

              const Spacer(),

              // 5) 최종 저장
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _controller.text.trim();
                    if (name.isEmpty) return;
                    await GenreService.addGenre(name, _selectedColor);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('카테고리 생성', style: TextStyle( fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      )

    );
  }
}