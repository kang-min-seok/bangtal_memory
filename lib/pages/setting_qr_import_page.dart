import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../hive/escape_record.dart';
import '../hive/genre_list.dart';

class QrImportPage extends StatefulWidget {
  const QrImportPage({super.key});

  @override
  State<QrImportPage> createState() => _QrImportPageState();
}

class _QrImportPageState extends State<QrImportPage> with WidgetsBindingObserver {
  /*───────────────── scanner & state ─────────────────*/
  final MobileScannerController _camCtrl = MobileScannerController(
    autoStart: false,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,             // 동일 프레임 중복 방지
    torchEnabled: false,                                      // 어두울 때 대비
    formats: [BarcodeFormat.qrCode],                         // QR 전용
  );


  // TODO 권한 문제 해결하기 (지금은 권한이 없으면 카메라가 안뜸, 권한을 물어보지 않음)
  // TODO 기록 불러오고 메인 페이지로 갔을때 불러온 데이터가 바로 표시되게끔 하기(지금은 필터 한번 클릭해서 화면 업데이트 해줘야 뜸)
  final List<String?> _chunks = []; // 0 … n-1
  int _total = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestAndStart();                        // ← 권한+카메라 시작
  }

  Future<void> _requestAndStart() async {
    // 0) 현재 상태 먼저 확인
    var status = await Permission.camera.status;
    print(status);
    // 1) 이미 허용 → 바로 카메라 ON
    if (status.isGranted) {
      await _camCtrl.start();
      return;
    }

    // 2) 아직 물어본 적 없음 → 요청
    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isGranted) {
        await _camCtrl.start();
        return;
      }
    }

    // 3) permanentlyDenied 혹은 여전히 거부
    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('카메라 권한 필요'),
          content: const Text('QR 스캔을 위해 카메라 권한이 필요합니다.\n'
              '설정 화면에서 권한을 허용해 주세요.'),
          actions: [
            TextButton(
              onPressed: openAppSettings,      // permission_handler 제공
              child: const Text('설정 열기'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        ),
      );
      Navigator.pop(context);                 // 이때만 페이지 닫기
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_camCtrl.value.isStarting && _camCtrl.value.hasCameraPermission) {
      if (state == AppLifecycleState.resumed) {
        _camCtrl.start();
      } else if (state == AppLifecycleState.paused) {
        _camCtrl.stop();
      }
    }
  }


  /*───────────────── UI ─────────────────*/
  @override
  Widget build(BuildContext context) {
    final cut = MediaQuery.of(context).size.width * 0.75;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('QR 코드로 복원'),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: MobileScanner(
        controller: _camCtrl,
        onDetect: _onDetect,                                  // ★ NEW
      ),
    );
  }

  /*───────────────── 스캔 콜백 ─────────────────*/
  void _onDetect(BarcodeCapture cap) {
    final raw = cap.barcodes.first.rawValue;
    if (raw == null) return;
    _processChunk(raw);
  }

  /*───────────────── chunk 처리 로직 (기존 그대로) ─────────────────*/
  void _processChunk(String text) async {
    // 포맷: "순번/총개|payload"
    final parts = text.split('|');
    if (parts.length != 2) return;

    final header = parts[0].split('/');
    if (header.length != 2) return;

    final idx   = int.tryParse(header[0]) ?? 0;
    final total = int.tryParse(header[1]) ?? 0;
    if (idx == 0 || total == 0) return;

    if (_chunks.length != total) _chunks.length = total;
    if (_chunks[idx - 1] != null) return;                    // 중복 스캔 무시
    _chunks[idx - 1] = parts[1];
    _total = total;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('QR $idx / $total 스캔 완료')));

    if (_chunks.every((c) => c != null)) {
      _camCtrl.stop();
      final merged = _chunks.join();
      await _restoreFromBase64(merged);
      if (mounted) Navigator.pop(context, true);
    }
  }

  /*───────────────── 복원 util (동일) ─────────────────*/
  Future<void> _restoreFromBase64(String b64) async {
    try {
      final gzBytes   = base64Decode(b64);
      final jsonBytes = GZipDecoder().decodeBytes(gzBytes);
      final map       = jsonDecode(utf8.decode(jsonBytes));
      await _importData(map);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('데이터 복원이 완료되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('복원 실패: $e')));
      }
    }
  }

  Future<void> _importData(Map<String, dynamic> map) async {
    final recBox   = Hive.box<EscapeRecord>('escape_records');
    final genreBox = Hive.box<GenreList>('genreLists');

    await recBox.clear();
    await genreBox.clear();

    for (final g in map['genres']) {
      final obj = GenreList(
        id: 0,
        genre: g['genre'],
        colorValue: g['colorValue'],
      );
      obj.id = await genreBox.add(obj);
      await obj.save();
    }

    for (final r in map['records']) {
      final obj = EscapeRecord(
        id: 0,
        date:         r['date'],
        storeName:    r['storeName'],
        themeName:    r['themeName'],
        difficulty:   r['difficulty'],
        satisfaction: r['satisfaction'],
        genre:        r['genre'],
        region:       r['region'],
        review:       (r['review'] as String?)?.trim(),
        imagePaths:   const [],       // 이미지 미포함
      );
      obj.id = await recBox.add(obj);
      await obj.save();
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camCtrl.dispose();
    super.dispose();
  }
}
