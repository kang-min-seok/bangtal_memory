import 'package:bangtal_memory/pages/write_search_page.dart';
import 'package:flutter/material.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';

class WriteMainPage extends StatefulWidget {
  const WriteMainPage({super.key});

  @override
  _WriteMainPageState createState() => _WriteMainPageState();
}

class _WriteMainPageState extends State<WriteMainPage> {
  final TextEditingController _themeController = TextEditingController();
  final TextEditingController _storeController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  // 난이도 선택 상태
  String? selectedDifficulty;

  // 별점 선택 상태
  double? selectedRating;

  @override
  void dispose() {
    _themeController.dispose();
    _storeController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _selectDifficulty(String difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
      selectedRating = 0; // 별점 초기화
    });
  }

  void _selectRating(double rating) {
    setState(() {
      selectedRating = rating;
      selectedDifficulty = null; // 난이도 초기화
    });
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
          // 주의! SingleChildScrollView는 단 하나의 자식만을 가질 수 있다.
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WriteSearchPage()),
                        );
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
                child: buildTextField('테마', '테마 이름을 입력해주세요.', _themeController),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: buildTextField('매장', '매장 이름을 입력해주세요.', _storeController),
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
                      SizedBox(height: 15.0),
                      Text(
                        '만족도',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
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
                  _selectRating(rating);
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
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WriteSearchPage()),
                  );
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
