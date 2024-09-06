import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class EscapeDataService {
  late Box _box;

  Future<void> initializeHive() async {
    _box = await Hive.openBox('escapeRoomData');
  }

  Future<void> loadData() async {
    final hiveData = _box.get('data') as List<dynamic>?;
    if (hiveData == null || hiveData.isEmpty) {
      print("데이터 없어서 크롤링 시작함.");
      await _crawlDataFromWeb();
    } else {
      print("데이터 있음.");
    }
  }

  Future<void> _crawlDataFromWeb() async {
    var url = 'https://colory.mooo.com/bba/catalogue';
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
              var regionName =
                  button.querySelector('h5')?.text ?? 'No region name';
              var table = button.querySelector('table');
              if (table != null) {
                var rows = table.querySelectorAll('tbody tr');
                String storeName = '';
                for (var row in rows) {
                  var storeElement = row.querySelector('.info-1');
                  if (storeElement != null) {
                    storeName = storeElement.text;
                  }
                  var themeName =
                      row.querySelector('.info-2')?.text ?? 'No theme name';
                  var rating =
                      row.querySelector('.info-3')?.text ?? 'No rating';
                  var difficulty =
                      row.querySelector('.info-4')?.text ?? 'No difficulty';
                  var reviews =
                      row.querySelector('.info-5')?.text ?? 'No reviews';

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

        // Hive에 데이터 저장
        await _box.put('data', data);
        print("크롤링 성공하여 데이터 저장됨.");
      } else {
        print('Failed to load page');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
