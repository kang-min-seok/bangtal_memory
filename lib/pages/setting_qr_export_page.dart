import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // ◀️ pubspec 추가

import '../hive/escape_record.dart';
import '../hive/genre_list.dart';

class QrExportPage extends StatefulWidget {
  const QrExportPage({super.key});

  @override
  State<QrExportPage> createState() => _QrExportPageState();
}

class _QrExportPageState extends State<QrExportPage> {
  static const int chunkSize = 2000;            // v40-L 한계 직전
  late final List<String> _payloads;            // “1/3|…”, “2/3|…” …
  final _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    _payloads = _makePayloads();
  }

  @override
  Widget build(BuildContext context) {
    final total = _payloads.length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text('백업 QR 코드'),
      ),
      body: Column(
        children: [
          // ───────────── 상단 안내 영역 ─────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            alignment: Alignment.centerLeft,
            child: Text(
              total == 1
                  ? '카메라로 이 QR 하나만 스캔하면 백업이 완료돼요!'
                  : '데이터가 많아 QR 이 $total개로 나뉘었습니다.\n'
                  '←→ 좌우로 슬라이드하며 순서대로 모두 스캔하세요.',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),

          // ───────────── QR PageView ─────────────
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: total,
              itemBuilder: (context, idx) {
                final payload = _payloads[idx];

                // 화면 너비의 70%만 QR 모듈, 나머지는 캔버스 여백
                final double qrSide = MediaQuery.of(context).size.width * 0.85;

                return Center(
                  child: Container(
                    // 넉넉한 흰색 캔버스 (QR 모듈 + 24px 패딩)
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12), // 라운드 모서리(선택)
                      boxShadow: [
                        BoxShadow(                     // 살짝 그림자(선택)
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: payload,
                      version: QrVersions.auto,
                      gapless: true,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      size: qrSide,
                      backgroundColor: Colors.white,   // 캔버스와 동일
                    ),
                  ),
                );
              },
            ),
          ),

          // ───────────── 하단 인디케이터 + 현재 순번 ─────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageCtrl,
                  count: total,
                  effect: ExpandingDotsEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 6,
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _pageCtrl,
                  builder: (_, __) {
                    // hasClients 체크 후, 소수점 반올림
                    final idx = _pageCtrl.hasClients ? _pageCtrl.page?.round() ?? 0 : 0;
                    return Text(
                      '${idx + 1} / $total',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*───────────────────── util: payload 생성 ─────────────────────*/
  List<String> _makePayloads() {
    final recBox   = Hive.box<EscapeRecord>('escape_records');
    final genreBox = Hive.box<GenreList>('genreLists');

    final map = {
      'records': recBox.values.map((r) => {
        'id': r.id,
        'date': r.date,
        'storeName': r.storeName,
        'themeName': r.themeName,
        'difficulty': r.difficulty,
        'satisfaction': r.satisfaction,
        'genre': r.genre,
        'region': r.region,
      }).toList(),
      'genres': genreBox.values.map((g) => {
        'id': g.id,
        'genre': g.genre,
        'colorValue': g.colorValue,
      }).toList(),
    };

    final gz = GZipEncoder().encode(utf8.encode(jsonEncode(map)))!;
    final b64 = base64Encode(gz);

    final chunks = <String>[];
    for (var i = 0; i < b64.length; i += chunkSize) {
      chunks.add(b64.substring(i, (i + chunkSize).clamp(0, b64.length)));
    }

    // “1/3|…”, “2/3|…”
    return List.generate(
      chunks.length,
          (i) => '${i + 1}/${chunks.length}|${chunks[i]}',
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }
}
