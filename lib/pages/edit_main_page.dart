import 'package:bangtal_memory/pages/write_search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:hive/hive.dart';
import 'package:bangtal_memory/constants/constants.dart';
import '../hive/escape_record.dart';

class EditMainPage extends StatefulWidget {
  final EscapeRecord record; // record를 받아옴

  const EditMainPage({super.key, required this.record});

  @override
  _EditMainPageState createState() => _EditMainPageState();
}

class _EditMainPageState extends State<EditMainPage> {
  late TextEditingController _themeNameController;
  late TextEditingController _storeNameController;
  late TextEditingController _regionController;
  late TextEditingController _dateController;

  // 상태
  bool isDateUnknown = false;
  String selectedDifficulty = "";
  String selectedRating = "";
  String realDifficulty = "";
  String selectedGenre = "";
  String selectedSatisfaction = "";

  @override
  void initState() {
    super.initState();

    // 전달받은 데이터를 컨트롤러에 초기화
    _themeNameController = TextEditingController(text: widget.record.themeName);
    _storeNameController = TextEditingController(text: widget.record.storeName);
    _regionController = TextEditingController(text: widget.record.region);
    _dateController = TextEditingController(text: widget.record.date);

    // 선택된 상태 초기화
    selectedDifficulty = widget.record.difficulty;
    selectedGenre = widget.record.genre;
    selectedSatisfaction = widget.record.satisfaction;

    // 날짜 모름 여부 초기화
    isDateUnknown = widget.record.date == "????.??.??";
  }


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

  void _selectGenre(String genre) {
    setState(() {
      selectedGenre = genre;
    });
  }

  void _selectSatisfaction(String satisfaction) {
    setState(() {
      selectedSatisfaction = satisfaction;
    });
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


  void updateEscapeRecord({
    required int id, // 기존 레코드의 ID를 받음
    required String themeName,
    required String storeName,
    required String region,
    required String selectedGenre,
    required String selectedSatisfaction,
    required String selectedDifficulty,
    required String date,
  }) async {
    // Hive 박스 열기
    var box = await Hive.openBox<EscapeRecord>('escape_records');

    // ID에 해당하는 기존 레코드가 있는지 확인
    var existingRecord = box.get(id);

    if (existingRecord != null) {
      // 입력값 정리 (비어있으면 기본값 할당)
      themeName = themeName.trim().isEmpty ? "모름" : themeName;
      storeName = storeName.trim().isEmpty ? "모름" : storeName;
      region = region.trim().isEmpty ? "모름" : region;
      date = date.trim().isEmpty ? "????.??.??" : date;

      // 기존 레코드 값 수정
      existingRecord.themeName = themeName;
      existingRecord.storeName = storeName;
      existingRecord.region = region;
      existingRecord.genre = selectedGenre;
      existingRecord.satisfaction = selectedSatisfaction;
      existingRecord.difficulty = selectedDifficulty;
      existingRecord.date = date;

      // Hive 박스에 업데이트된 레코드를 저장 (put으로 덮어씀)
      await box.put(id, existingRecord);

      print("데이터 수정 완료: $existingRecord");
    } else {
      print("해당 ID($id)의 레코드를 찾을 수 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('기억 수정'),
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
              RatingBar(
                maxRating: 5,
                isHalfAllowed: true,
                halfFilledIcon: Icons.star_half_rounded,
                filledIcon: Icons.star_rounded,
                emptyIcon: Icons.star_border_rounded,
                onRatingChanged: (rating) {
                  _selectRating(rating.toString());
                },
                alignment: Alignment.center,
                size: 58, // 별점 크기를 키움
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

                  updateEscapeRecord(
                    id: widget.record.id,
                    themeName: themeName,
                    storeName: storeName,
                    region: region,
                    selectedGenre: selectedGenre,
                    selectedSatisfaction: selectedSatisfaction,
                    selectedDifficulty: selectedDifficulty,
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
