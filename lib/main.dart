import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hive/escape_data_service.dart';
import 'hive/escape_record.dart';
import 'theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/theme_custom.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bangtal_memory/pages/record_main_page.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업을 위한 초기화

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

  await Hive.openBox<EscapeRecord>('escapeRecords');

  initializeDateFormatting().then((_) => runApp(MyApp(themeMode: themeMode)));
}

class MyApp extends StatefulWidget {
  final ThemeMode themeMode;

  const MyApp({super.key, required this.themeMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late EscapeDataService _dataService;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,  // 내비게이션 바 투명화
    ));
    _initializeData(); // 백그라운드에서 데이터를 로드
  }

  Future<void> _initializeData() async {
    _dataService = EscapeDataService();
    await _dataService.initializeHive();
    _prefs = await SharedPreferences.getInstance();

    bool isDataLoaded = _prefs.getBool('isDataLoaded') ?? false;
    if (!isDataLoaded) {
      // 백그라운드에서 데이터를 로드하고 완료되면 SharedPreferences에 상태를 저장
      _dataService.loadData().then((_) {
        _prefs.setBool('isDataLoaded', true);
        print('데이터 로드 완료');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(initThemeMode: widget.themeMode),
          ),
        ],
        builder: (context, _) {
          return MaterialApp(
              title: '방탈기억',
              themeMode: Provider.of<ThemeProvider>(context).themeMode,
              theme: ThemeCustom.lightTheme,
              darkTheme: ThemeCustom.darkTheme,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ko', '')],
              debugShowCheckedModeBanner: false,
              home: const RecordMainPage());
        });
  }
}
