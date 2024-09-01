import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hive/escape_record.dart';
import 'theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/theme_custom.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:bangtal_memory/pages/record_main_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  ThemeMode themeMode = ThemeMode.system;
  final String? savedThemeMode = prefs.getString('themeMode');

  if (savedThemeMode == null) {
    themeMode = ThemeMode.system;
  } else if (savedThemeMode == "light") {
    themeMode = ThemeMode.light;
  } else if (savedThemeMode == "dark") {
    themeMode = ThemeMode.dark;
  } else if (savedThemeMode == "system") {
    themeMode = ThemeMode.system;
  }


  await Hive.initFlutter();
  Hive.registerAdapter(EscapeRecordAdapter());

  // 방탈출 정보와 기록을 위한 박스 열기
  await Hive.openBox('escapeRoomData');
  await Hive.openBox<EscapeRecord>('escapeRecords');

  initializeDateFormatting().then((_) => runApp(MyApp(themeMode: themeMode)));
}

class MyApp extends StatefulWidget {
  final themeMode;

  const MyApp({
    super.key,
    required this.themeMode,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ThemeProvider(initThemeMode: widget.themeMode)),
        ],
        builder: (context, _) {
          return MaterialApp(
              title: '방탈기억',
              themeMode: Provider.of<ThemeProvider>(context).themeMode,
              theme: ThemeCustom.lightTheme,
              darkTheme: ThemeCustom.darkTheme,
              debugShowCheckedModeBanner: false,
              home: const RecordMainPage());
        });
  }
}