import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../hive/genre_list.dart';
import 'genre_add_page.dart';

class GenreManagePage extends StatefulWidget {
  const GenreManagePage({super.key});

  @override
  State<GenreManagePage> createState() => _GenreManagePageState();
}

class _GenreManagePageState extends State<GenreManagePage> {
  late final Box<GenreList> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<GenreList>('genreLists');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        scrolledUnderElevation: 0,
        title: const Text('장르 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GenreAddPage()),
              );
              setState(() {});              // 추가 후 목록 갱신
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _box.listenable(),
        builder: (context, Box<GenreList> box, _) {
          final genres = box.values.toList()
            ..sort((a, b) => a.id.compareTo(b.id));

          if (genres.isEmpty) {
            return const Center(child: Text('등록된 장르가 없습니다.'));
          }

          return ListView.builder(
            itemCount: genres.length,
            itemBuilder: (_, i) {
              final g = genres[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(g.colorValue),
                ),
                title: Text(g.genre),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () async {
                    await _box.delete(g.key);
                    setState(() {}); // 삭제 후 목록 갱신
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
