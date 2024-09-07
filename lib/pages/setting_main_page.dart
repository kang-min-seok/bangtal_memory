import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../hive/escape_record.dart';
import 'setting_theme_page.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class SettingMainPage extends StatefulWidget {
  const SettingMainPage({Key? key}) : super(key: key);

  @override
  State<SettingMainPage> createState() => _SettingMainPageState();
}

class _SettingMainPageState extends State<SettingMainPage> {
  static String themeText = "기기 테마";
  String? _lastUpdated; // 마지막 업데이트 시간 저장

  @override
  void initState() {
    getThemeText();
    _loadLastUpdatedTime();
    super.initState();
  }

  // 마지막 업데이트 시간을 SharedPreferences에서 로드
  Future<void> _loadLastUpdatedTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastUpdated = prefs.getString('lastUpdated');
    });
  }

  // 마지막 업데이트 시간을 SharedPreferences에 저장
  Future<void> _saveLastUpdatedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc().add(Duration(hours: 9));
    String formattedTime = "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}";
    await prefs.setString('lastUpdated', formattedTime);

    setState(() {
      _lastUpdated = formattedTime;
    });
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

  // 크롤링 후 데이터를 Hive에 덮어씌우는 함수
  Future<void> _updateCrawledData() async {
    var url = 'https://colory.mooo.com/bba/catalogue';
    var box = await Hive.openBox('escapeRoomData');

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var document = parse(response.body);
        var themesInfo = document.querySelector('.themes-info');
        List<Map<String, dynamic>> data = [];

        if (themesInfo != null) {
          for (int i = 1; i <= 34; i++) {
            var buttonClass = '#theme-button-$i';
            var button = themesInfo.querySelector(buttonClass);

            if (button != null) {
              var regionName = button.querySelector('h5')?.text ?? 'No region name';
              var table = button.querySelector('table');
              if (table != null) {
                var rows = table.querySelectorAll('tbody tr');
                String storeName = '';
                for (var row in rows) {
                  var storeElement = row.querySelector('.info-1');
                  if (storeElement != null) {
                    storeName = storeElement.text;
                  }
                  var themeName = row.querySelector('.info-2')?.text ?? 'No theme name';
                  var rating = row.querySelector('.info-3')?.text ?? 'No rating';
                  var difficulty = row.querySelector('.info-4')?.text ?? 'No difficulty';
                  var reviews = row.querySelector('.info-5')?.text ?? 'No reviews';

                  data.add({
                    'region': regionName,
                    'store': storeName,
                    'theme': themeName,
                    'rating': rating,
                    'difficulty': difficulty,
                    'reviews': reviews,
                  });
                }
              }
            }
          }
        } else {
          print('No themes-info found');
        }

        // Hive에 데이터 저장 (기존 데이터 덮어쓰기)
        await box.put('data', data);
        print("크롤링 성공하여 데이터 저장됨.");
        _saveLastUpdatedTime(); // 크롤링 후 업데이트 시간을 저장
      } else {
        print('Failed to load page');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("설정"),
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
                  _CustomListTile(
                    title: "테마 데이터 업데이트",
                    icon: Icons.update,
                    onTap: () async {
                      // 크롤링 데이터 업데이트 수행
                      await _updateCrawledData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('데이터 업데이트 완료')),
                      );
                    },
                    trailing: Text(
                      _lastUpdated != null ? '$_lastUpdated' : '업데이트 기록 없음',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
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
