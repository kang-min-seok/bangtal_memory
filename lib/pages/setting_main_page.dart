import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../hive/escape_record.dart';
import 'setting_theme_page.dart';

class SettingMainPage extends StatefulWidget {
  const SettingMainPage({Key? key}) : super(key: key);

  @override
  State<SettingMainPage> createState() => _SettingMainPageState();
}

class _SettingMainPageState extends State<SettingMainPage> {
  static String themeText = "기기 테마";

  @override
  void initState() {
    getThemeText();
    super.initState();
  }

  void getThemeText() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedThemeMode = prefs.getString('themeMode');

    if (savedThemeMode == null) {
      setState(() {
        themeText = "기기 테마";
      });
    } else if (savedThemeMode == "light") {
      setState(() {
        themeText = "밝은 테마";
      });
    } else if (savedThemeMode == "dark") {
      setState(() {
        themeText = "어두운 테마";
      });
    } else if (savedThemeMode == "system") {
      setState(() {
        themeText = "기기 테마";
      });
    }
  }

  Future<void> _clearEscapeRecords() async {
    var box = await Hive.openBox<EscapeRecord>('escape_records');
    await box.clear();
    // 확인 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('방탈출 기록이 초기화되었습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("설정", style: Theme.of(context).textTheme.displayLarge),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              _SingleSection(
                title: "환경",
                children: [
                  _CustomListTile(
                    title: "테마",
                    icon: Icons.format_paint_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingThemePage()),
                      ).then((_) {
                        getThemeText();
                      });
                    },
                    trailing: Text(
                      themeText,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              _SingleSection(
                title: "데이터 관리",
                children: [
                  _CustomListTile(
                    title: "방탈출 기록 초기화",
                    icon: Icons.delete_forever,
                    onTap: () async {
                      bool? confirmed = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('초기화 확인'),
                            content: const Text('정말로 방탈출 기록을 초기화하시겠습니까?'),
                            actions: [
                              TextButton(
                                child: const Text('취소'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                              ),
                              TextButton(
                                child: const Text('확인'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true) {
                        _clearEscapeRecords();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _CustomListTile({
    Key? key,
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap, // onTap 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: trailing,
      onTap: onTap, // onTap 할당
    );
  }
}

class _SingleSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const _SingleSection({
    Key? key,
    this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Column(
          children: children,
        ),
      ],
    );
  }
}
