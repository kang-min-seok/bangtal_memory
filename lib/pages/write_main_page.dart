import 'package:bangtal_memory/pages/write_search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hive/hive.dart';
import 'package:bangtal_memory/constants/constants.dart';
import '../hive/escape_record.dart';

class WriteMainPage extends StatefulWidget {
  const WriteMainPage({super.key});

  @override
  _WriteMainPageState createState() => _WriteMainPageState();
}

class _WriteMainPageState extends State<WriteMainPage> {
  final TextEditingController _themeNameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // 날짜 아는지 모르는지 상태
  bool isDateUnknown = false;

  // 난이도 선택 상태
  String selectedDifficulty="";
  // 별점 선택 상태
  String selectedRating="0";
  String realDifficulty="";

  @override
  void dispose() {
    _themeNameController.dispose();
    _storeNameController.dispose();
    _regionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _selectDifficulty(String difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
      selectedRating = "0"; // 별점 초기화
      realDifficulty = difficulty;
    });
  }

  void _selectRating(String rating) {
    setState(() {
      selectedRating = rating;
      selectedDifficulty = ""; // 난이도 초기화
      realDifficulty = rating;
    });
  }

  String selectedGenre="";
  String selectedSatisfaction="";

  void _selectGenre(String genre) {
    if(genre == selectedGenre){
      setState(() {
        selectedGenre="";
      });
    }else{
      setState(() {
        selectedGenre = genre;
      });
    }

  }

  void _selectSatisfaction(String satisfaction) {
    if (satisfaction == selectedSatisfaction){
      setState(() {
        selectedSatisfaction="";
      });
    }else {
      setState(() {
        selectedSatisfaction = satisfaction;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now();
        return Container(
          height: 250,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (DateTime date) {
                    selectedDate = date;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedDate);
                },
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }


  void saveEscapeRecord({
    required String themeName,
    required String storeName,
    required String region,
    required String selectedGenre,
    required String selectedSatisfaction,
    required String selectedDifficulty,
    required String date,
  }) async {
    // Hive 박스 열기 (여기서는 "escape_records"라는 이름으로 박스를 엽니다.)
    var box = await Hive.openBox<EscapeRecord>('escape_records');

    // ID는 auto-increment가 가능하니 기존 레코드의 ID를 가져오고 없으면 1로 시작
    int id = box.isEmpty ? 1 : box.length + 1;

    themeName = themeName.trim().isEmpty ? "모름" : themeName;
    storeName = storeName.trim().isEmpty ? "모름" : storeName;
    region = region.trim().isEmpty ? "모름" : region;
    date = date.trim().isEmpty ? "????.??.??" : date;

    // EscapeRecord 인스턴스 생성
    var record = EscapeRecord(
      id: id,
      date: date,
      storeName: storeName,
      themeName: themeName,
      difficulty: realDifficulty,
      satisfaction: selectedSatisfaction,
      genre: selectedGenre,
      region: region,
    );

    // Hive 박스에 저장
    await box.put(id, record);

    print("데이터 저장 완료: $record");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('기억 작성'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.0),
                    const Text(
                      '플레이 한 테마를 찾아보세요',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    InkWell(
                      onTap: () async {
                        // WriteSearchPage로 데이터 전달 및 선택한 결과를 받아옴
                        final selectedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WriteSearchPage(), // Hive 데이터를 전달
                          ),
                        );

                        // 선택된 데이터를 각 컨트롤러에 설정
                        if (selectedData != null) {
                          _themeNameController.text = selectedData['theme'];
                          _storeNameController.text = selectedData['store'];
                          _regionController.text = selectedData['region'];
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 11.0, horizontal: 18.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            SizedBox(width: 25.0),
                            Text(
                              '테마 찾기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 28.0),
                  ],
                ),
              ),
              Divider(
                height: 5.0, // 나눔선의 높이를 설정
                thickness: 5.0, // 나눔선의 두께를 설정
                color: Theme.of(context).dividerColor, // 나눔선의 색상을 설정
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: buildTextField('테마', '테마 이름을 입력해주세요.', _themeNameController),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: buildTextField('매장', '매장 이름을 입력해주세요.', _storeNameController),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: buildTextField('지역', '지역을 입력해주세요.', _regionController),
              ),
              SizedBox(height: 20.0),
              Divider(
                height: 5.0, // 나눔선의 높이를 설정
                thickness: 5.0, // 나눔선의 두께를 설정
                color: Theme.of(context).dividerColor, // 나눔선의 색상을 설정
              ),
              SizedBox(height: 20.0),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '장르',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: genreList.map((genre) {
                          return ChoiceChip(
                              label: Text(genre),
                              selected: selectedGenre == genre,
                              onSelected: (selected) {
                                _selectGenre(genre);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                // 양옆 둥글게 설정
                                side: BorderSide(
                                  color: selectedGenre == genre
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.19),
                              labelStyle: TextStyle(
                                color: selectedGenre == genre
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onBackground,
                              ),
                              showCheckmark: false);
                        }).toList(),
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        '만족도',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: satisfactionList.map((satisfaction) {
                          return ChoiceChip(
                              label: Text(satisfaction),
                              selected: selectedSatisfaction == satisfaction,
                              onSelected: (selected) {
                                _selectSatisfaction(satisfaction);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                // 양옆 둥글게 설정
                                side: BorderSide(
                                  color: selectedSatisfaction == satisfaction
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.19),
                              labelStyle: TextStyle(
                                color: selectedSatisfaction == satisfaction
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onBackground,
                              ),
                              showCheckmark: false);
                        }).toList(),
                      ),
                    ],
                  )),
              SizedBox(height: 20.0),
              Divider(
                height: 5.0, // 나눔선의 높이를 설정
                thickness: 5.0, // 나눔선의 두께를 설정
                color: Theme.of(context).dividerColor, // 나눔선의 색상을 설정
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '난이도',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildDifficultyButton('Easy', Color(0xFF297FFF)),
                              SizedBox(width: 10),
                              buildDifficultyButton(
                                  'Normal', Color(0xFFDADA23)),
                              SizedBox(width: 10),
                              buildDifficultyButton('Hard', Color(0xFFFF2929)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBar.builder(
                  initialRating: double.parse(selectedRating),
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,  // 반개 선택 허용
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _selectRating(rating.toString());
                  },
                ),
                ]
              ),
              SizedBox(height: 20.0),
              Divider(
                height: 5.0, // 나눔선의 높이를 설정
                thickness: 5.0, // 나눔선의 두께를 설정
                color: Theme.of(context).dividerColor, // 나눔선의 색상을 설정
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '플레이 날짜',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        hintText: '날짜 선택',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      readOnly: true,
                      onTap: () {
                        if (!isDateUnknown) {
                          _selectDate(context);
                        }
                      },
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Checkbox(
                          value: isDateUnknown,
                          onChanged: (bool? value) {
                            setState(() {
                              isDateUnknown = value ?? false;
                              if (isDateUnknown) {
                                _dateController.clear();
                              }
                            });
                          },
                        ),
                        Text(
                          '날짜 모름',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              InkWell(
                onTap: () {
                  String themeName = _themeNameController.text;
                  String storeName = _storeNameController.text;
                  String region = _regionController.text;
                  String date = _dateController.text;

                  saveEscapeRecord(
                    themeName: themeName,
                    storeName: storeName,
                    region: region,
                    selectedGenre: selectedGenre,
                    selectedSatisfaction: selectedSatisfaction,
                    selectedDifficulty: realDifficulty,
                    date: date,
                  );
                  Navigator.pop(context, true);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 11.0, horizontal: 18.0),
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Center(
                    child: Text(
                      '작성 완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 8.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.surface,
                width: 1.0,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget buildDifficultyButton(String difficulty, Color selectedColor) {
    return Expanded(
        child: ElevatedButton(
      onPressed: () {
        _selectDifficulty(difficulty);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedDifficulty == difficulty
            ? selectedColor
            : Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: Text(difficulty),
    ));
  }
}
